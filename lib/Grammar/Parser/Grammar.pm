
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Grammar v1.0.0;

use Moo;

use Ref::Util qw[ is_arrayref ];
use Clone qw[ ];

use Grammar::Parser::Lexer;

sub hash_slice (\%@) {
	my ($hash, @list) = @_;

	my %slice;
	@slice{@list} = @$hash{@list};

	%slice;
}

use namespace::clean;

has grammar     => (
	is          => 'ro',
	required    => 1,
);

has start       => (
	is          => 'ro',
	builder     => sub { 'start' },
);

has empty       => (
	is          => 'ro',
	builder     => sub { [] },
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

has effective_terminals   => (
	init_arg    => undef,
	is          => 'ro',
	lazy        => 1,
	builder     => '_build_effective_terminals',
);

has effective_nonterminals   => (
	init_arg    => undef,
	is          => 'ro',
	lazy        => 1,
	builder     => '_build_effective_nonterminals',
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

sub _build_effective_grammar {
	my ($self) = @_;

	my $result = {};
	my $grammar = $self->grammar;
	my $empty = { map +($_ => [[]]), @{ $self->empty } };

	my @list = ($self->start, @{ $self->insignificant });
	while (my $name = shift @list) {
		next if exists $result->{$name};
		next unless exists $grammar->{$name};

		$result->{$name} = $empty->{$name} // Clone::clone ($grammar->{$name});

		push @list,
			map @$_,                       # expand alternative (is list of used rule names)
			grep is_arrayref $_,           # rule definition contains list of arefs
			@{ $result->{$name} }          # expand rule definition (aref)
			;
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
};

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

	return [ grep is_arrayref $grammar->{$_}[0], keys %{ $grammar } ];
}

sub _build_list_terminals {
	my ($self) = @_;
	my $grammar = $self->effective_grammar;

	return [ grep ! is_arrayref $grammar->{$_}[0], keys %{ $grammar } ];
}

sub clone {
	my ($self, %params) = @_;

	$params{start} //= $self->start;
	$params{empty} //= $self->empty;
	$params{insignificant} //= $self->insignificant;
	$params{grammar} //= $self->grammar;
	$params{lexer_class} //= $self->lexer_class;

	$self->new (%params);
}

sub lexer {
	my ($self) = @_;

	return $self->lexer_class->new (
		insignificant => [ @{ $self->insignificant } ],
		terminals => $self->effective_terminals,
	);
}

sub rule {
	my ($self, $name) = @_;

	return $self->effective_grammar->{$name};
}

sub list_terminals {
	my ($self) = @_;

	return @{ $self->_list_terminals };
}

sub list_nonterminals {
	my ($self) = @_;

	return @{ $self->_list_nonterminals };
}

1;

__END__

=encoding utf8

=head1 NAME

Grammar::Parser::Grammar

=head1 SYNOPSIS

   my $grammar = Grammar::Parser::Grammar->new (
     grammar => $grammar,
     start => 'my_start',
   );

=head1 DESCRIPTION

=head1 METHODS

=head2 new

Constructor, accepts named parameters:

=over

=item grammar

=item empty

List of grammar rules which should evaluate as empty rule.
Any existing rules will be overriden.

=item start

Name of start token

=item insignificant

List of terminal symbols treated as insignificant (white) symbols
(ignored by lexer unless specified)

=back

=head2 effective_grammar

=head2 list_terminals

Return list of terminals (their names)

=head2 list_rules

Return list of rules (their names)

=head2 lexer

Return lexer for this grammar.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<< Grammar::Parser >>.
It can be distributed and/or modified under Artistic license 2.0

=cut
