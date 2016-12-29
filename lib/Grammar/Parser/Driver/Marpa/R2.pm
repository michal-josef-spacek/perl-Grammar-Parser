
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Driver::Marpa::R2 v1.0.0 {

	use Marpa::R2;
	use Grammar::Parser::Driver::Marpa::R2::Instance;

	use Moo;

	extends 'Grammar::Parser::Driver';

	has _marpa_r2_grammar_cache => (
		init_arg => undef,
		is => 'ro',
		default => sub { +{} },
	);

	sub instance {
		my ($self, %params) = @_;

		my $instance;
		my $grammar = $self->_grammar->clone (%params);

		my %action_map;
		for my $rule ($grammar->list_nonterminals, $grammar->list_terminals) {
			my $action = $self->action_lookup_for ($self->action_name_for ($rule));

			next unless $action;

			$action_map{$rule} = sub { shift; $action->($instance, $rule, @_) };
			use Sub::Name;
			Sub::Name::subname "$rule", $action_map{$rule};
		}

		my $marpa_grammar = $self->_marpa_r2_grammar_cache->{ $grammar->grammar_key }
			//= do {
				my @rules;
				for my $rule ($grammar->list_nonterminals) {
					push @rules,
						map +{ lhs => $rule, rhs => $_, action => $rule },
						@{ $grammar->rule ($rule) // die "Rule $rule not defined" }
						;
				}

				my $marpa_grammar = Marpa::R2::Grammar->new ({
					start => $grammar->start,
					rules => \ @rules,
				});

				$marpa_grammar->precompute;
				$marpa_grammar;
			};

		my $recognizer = Marpa::R2::Recognizer->new ({
			too_many_earley_items => 0,
			grammar => $marpa_grammar,
			closures => \ %action_map,
		});

		$instance = Grammar::Parser::Driver::Marpa::R2::Instance->new (
			driver => $self,
			lexer => $grammar->lexer,
			marpa => $recognizer,
		);

		return $instance;
	}
}

1;

