
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Grammar v1.0.0 {
	use Moo;

	use Clone 	   qw[ ];
	use Ref::Util  qw[ is_arrayref ];
	use Ref::Util  qw[ is_refref ];
	use Ref::Util  qw[ is_regexpref ];
	use Ref::Util  qw[ is_scalarref ];

	use Grammar::Parser::Lexer;

	sub hash_slice (\%@) {
		my ($hash, @list) = @_;

		my %slice;
		@slice{@list} = @$hash{grep exists $hash->{$_}, @list};

		%slice;
	}

	use namespace::clean;

	has grammar     => (
		is          => 'ro',
		required    => 1,
	);

	has empty       => (
		is          => 'ro',
		builder     => sub { [] },
	);

	has start       => (
		is          => 'lazy',
		builder     => sub { 'start' },
	);

	has insignificant => (
		is          => 'ro',
		builder     => sub { [qw[ whitespace comment ]] },
	);

	has lexer_class => (
		is          => 'ro',
		builder     => sub { 'Grammar::Parser::Lexer' },
	);

	has grammar_key => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_grammar_key',
	);

	has effective_grammar => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_effective_grammar',
	);

	has effective_terminals => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_effective_terminals',
	);

	has effective_nonterminals => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_effective_nonterminals',
	);

	has effective_patterns => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_effective_patterns',
	);

	has _list_patterns => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_list_patterns',
	);

	has _list_terminals => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_list_terminals',
	);

	has _list_nonterminals => (
		init_arg    => undef,
		is          => 'ro',
		lazy        => 1,
		builder     => '_build_list_nonterminals',
	);

	sub _empty_rule {
		[[]]
	}

	sub _list_regex_reference {
		my ($self, $regex) = @_;

		my @reference;
		while ($regex =~ m/( \(\?\?\{ \s* \\? \s* (?<d>[\'\"]) (?<n>(\w+)) \g{d} \s* \}\) )/xgc) {
			push @reference, $+{n};
		}

		@reference;
	}

	sub _expand_references {
		my ($self, @def) = @_;

		my @references;
		while (@def) {
			my $head = shift @def;

			push @references, $head and next
				unless ref $head;

			push @def, @$head and next
				if is_arrayref $head;

			push @def, $$head and next
				if is_refref $head;

			push @references, $$head and next
				if is_scalarref $head;

			if (is_regexpref $head) {
				push @references, $self->_list_regex_reference ($head);
				next;
			}

			die "unknown ref $head";
		}

		return @references;
	}

	sub _build_effective_grammar {
		my ($self) = @_;

		my $grammar = Clone::clone $self->grammar;
		$grammar->{$_} = $self->_empty_rule for @{ $self->empty };

		my $result = {};
		my @effective_rules = ($self->start, @{ $self->insignificant });

		while (my $rule = shift @effective_rules) {
			next # rule already processed
				if exists $result->{$rule};

			next # rule doesn't exist, ignored
				unless exists $grammar->{$rule};

			$result->{$rule} = $grammar->{$rule};

			push @effective_rules, $self->_expand_references ($result->{$rule});
		}

		return $result;
	}

	sub _build_effective_nonterminals {
		my ($self) = @_;

		return +{ hash_slice %{ $self->effective_grammar }, $self->list_nonterminals };
	}

	sub _build_effective_terminals {
		my ($self) = @_;

		return +{ hash_slice %{ $self->effective_grammar }, $self->list_terminals };
	}
	;

	sub _build_effective_patterns {
		my ($self) = @_;

		# TODO: test behaviour
		my $hash = +{ hash_slice %{ $self->effective_grammar }, $self->list_patterns };
		$_ = $$_ for values %$hash;

		$hash;
	}

	sub _build_grammar_key {
		my ($self) = @_;

		# Grammar key identifies effective grammar (for caching)
		return join '/',
			$self->start,
			"${\ join ';', sort @{ $self->insignificant }}",
			"${\ join ';', sort @{ $self->empty }}",
			;
	}

	sub _build_list_nonterminals {
		my ($self) = @_;
		my $grammar = $self->effective_grammar;

		return [
			grep is_arrayref $grammar->{$_}[0],
			grep is_arrayref $grammar->{$_},
			keys %{ $grammar }
		];
	}

	sub _build_list_terminals {
		my ($self) = @_;
		my $grammar = $self->effective_grammar;

		return [
			grep ! is_arrayref $grammar->{$_}[0],
			grep is_arrayref $grammar->{$_},
			keys %{ $grammar }
		];
	}

	sub _build_list_patterns {
		my ($self) = @_;
		my $grammar = $self->effective_grammar;

		return [
			grep is_refref $grammar->{$_},
			keys %{ $grammar }
		];
	}

	sub clone {
		my ($self, %params) = @_;

		$params{grammar}       //= $self->grammar;
		$params{empty}         //= $self->empty;
		$params{start}         //= $self->start;
		$params{insignificant} //= $self->insignificant;
		$params{lexer_class}   //= $self->lexer_class;

		$self->new (%params);
	}

	sub lexer {
		my ($self) = @_;

		return $self->lexer_class->new (
			insignificant => $self->insignificant,
			tokens        => $self->effective_terminals,
			patterns      => $self->effective_patterns,
		);
	}

	sub rule {
		my ($self, $name) = @_;

		return $self->effective_grammar->{$name};
	}

	sub list_patterns {
		my ($self) = @_;

		return @{ $self->_list_patterns };
	}

	sub list_terminals {
		my ($self) = @_;

		return @{ $self->_list_terminals };
	}

	sub list_nonterminals {
		my ($self) = @_;

		return @{ $self->_list_nonterminals };
	}
}

1;

__END__

=encoding utf8

=head1 NAME

Grammar::Parser::Grammar

=head1 SYNOPSIS

	my $grammar = Grammar::Parser::Grammar->new (
		grammar => $grammar,
		start   => 'my_start',
	);

=head1 DESCRIPTION

=head1 METHODS

=head2 new

Creates new instance, accepts named parameters:

=over

=item grammar

Grammar definition, see L<< /"GRAMMAR DEFINITION" >> section below.

=item empty

	# Default
	empty => [],

List of grammar rule names that should be evaluated as an empty rule.

=item start

	# Default
	start => 'start',

Starting (top level) rule name.

=item insignificant

	# Default
	insignificant => [qw[ whitespace comment ]],

List of terminal symbols treated as insignificant.
Lexer will skip insignificant symbols unless exactly requested.

Using BNF-like description, grammar rule

	rule := foo bar

Will behave like

	rule := insignificant* foo insignificant* bar insignificant*

=item lexer_class

	# Default
	lexer_class => 'Grammar::Parser::Lexer',

Lexer implementation class.

=back

=head2 clone

Creates clone of current grammar. Accepts same parameters as C<new> and uses
current instance as source of default values.

=head2 effective_grammar

Optimized grammar. Currently only unused rules are eliminated.

=head2 lexer

Build new C<lexer_class> instance using C<effective_grammar>.

=head2 list_terminals

Returns names of terminals

=head2 list_nonterminals

Return names of nonterminal rules

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<< Grammar::Parser >>.
It can be distributed and/or modified under Artistic license 2.0

=cut
