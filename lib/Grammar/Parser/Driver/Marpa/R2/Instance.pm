
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Driver::Marpa::R2::Instance v1.0.0 {
	use Moo;

	our $DIE_ON_MULTIPLE = 1;

	extends 'Grammar::Parser::Driver::Instance';

	our $SHOW_PROGRESS_ON_ERROR = 1;

	has lexer => (
		is => 'ro',
	);

	has marpa => (
		is => 'ro',
	);

	sub parse {
		my ($self, @what) = @_;

		my $lexer = $self->lexer;
		my $marpa = $self->marpa;

		$lexer->add_data (@what);

		eval {
			while (1) {
				my $expected = $marpa->terminals_expected;
				last unless @$expected;

				my $token = $lexer->next_token (@$expected);

				last unless $token;
				last unless @$token;

				my ($name, $value) = @$token;
				#say "# $name => ", $value->match;
				$value = $self->run_action ($name, $value) // $value;

				$marpa->read ($name => $value);
			}
		};

		if (my $eval_error = $@) {
			say $marpa->show_progress( 0, -1 ) if $SHOW_PROGRESS_ON_ERROR;
			die $eval_error if $eval_error;
		}

		$self->result;
	}

	sub result {
		my ($self) = @_;

		my $ref;
		my $counter = 0;

		while (my $value = $self->marpa->value) {
			$ref //= $value;
			$counter++;
			use DDP;
			use Test::Deep;
			Test::Deep::cmp_deeply ($ref, $value, "compare $counter")
				if $counter > 1;
			#p $ref if $counter == 2;
			#p $value if $counter > 1;
			die "Too many results received" if $DIE_ON_MULTIPLE && $counter > 1;
		}

		die "Not parsed" unless $ref;
		warn "Multiple results received ($counter)" if $counter > 1;

		return $$ref;
	}
}

1;
