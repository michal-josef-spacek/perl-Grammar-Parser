
use v5.14;
use strict;
use warnings;

package Grammar::Parser v1.0.0;

use Class::Load qw();
use List::Util qw();
use Ref::Util qw( is_arrayref );

our $DEFAULT_ENV_NAME = 'GRAMMAR_PARSER_DRIVER';
our $DEFAULT_DRIVER   = 'Grammar::Parser::Driver::Marpa::R2';

sub new {
	my ($class, %params) = @_;
	my $self = bless { %params }, $class;

	my $driver  = $self->_build_driver;
	my $grammar = $self->_build_grammar;

	return $driver->new (%$self, grammar => $grammar);
}

sub _load_class {
	my ($self, $class) = @_;

	Class::Load::load_class ($class);
}

sub _load_driver {
	my ($self, @list) = @_;
	my $delimiter = qr:[/;,]:;

	local $@;
	my @error;

	while (@list) {
		my $candidate = shift @list or next;

		unshift @list, @$candidate and next
			if is_arrayref $candidate;

		unshift @list, split $delimiter, $candidate and next
			if $candidate =~ $delimiter;

		eval { $self->_load_class ($candidate) };
		return $candidate unless $@;
		push @error, "Cannot load $candidate: $@";
    }

	die join "\n", "Cannot load driver:", @error;
}

sub _build_driver {
    my ($self) = @_;

    my $driver     = delete $self->{driver};
    my $driver_env = delete $self->{driver_env};

    return $self->_load_driver (
        $driver,
        $ENV{ $driver_env // $DEFAULT_ENV_NAME },
        $DEFAULT_DRIVER,
    );
}

sub _build_grammar {
    my ($self) = @_;

	my $skeleton = delete $self->{skeleton};
	my $bnf      = delete $self->{bnf};

    return undef
        // $self->{grammar}
        // $self->_build_grammar_from_skeleton ($skeleton)
        // $self->_build_grammar_from_bnf ($bnf)
        ;
}

sub _build_grammar_from_skeleton {
    my ($self, $skeleton) = @_;

    return unless defined $skeleton;

    return $self->_load_class ($skeleton)->grammar;
}

sub _build_grammar_from_bnf {
    my ($self, $file) = @_;

    return unless defined $file;

    return Grammar::Parser::BNF->new->parse (file => $file)->result;
}

1;

__END__

=head1 NAME

Grammar::Parser - Unified API over misc grammar parser

=head1 SYNOPSIS

	use Grammar::Parser;

	my $grammar = Grammar::Parser->new (
		source   => 'my-grammar.bnf',
		skeleton => 'My::Grammar',
	);

	my $ast = $grammar->parse (start => 'token', file => $fh);
	my $ast = $grammar->parse (start => 'token', string => $to_parse);

=head1 DESCRIPTION

This module started its life as part of L<< SQL::Admin >> while having problems with
maintenance of L<< Parse::RecDescent >> grammars.

Its idea is to support:

=over

=item multiple backends using unified API

There are plenty of grammar parsing modules around, each one with its own callbacks,
grammar definition, features, lifecycle, performance.

Having unified API makes easier to change backends (regardless of reason).

=item maintain related grammars

Every SQL database has its own dialect based on one of SQL standards.
Even every version has different subset.

Maintaining their grammars and/or adding new one will be real pain without
possibility to reuse common parts.

=back

Grammar::Parser supports data structure grammar definition (inspired by L<< Marpa >>).

It also supports textual (BNF like) grammar description (see L<< Grammar::Parser::BNF >>)
with generated data structure definitions (see L<< /"Generated Skeleton" >>).

Grammar::Parser provides driver independent rule-to-action binding based on rule name.

=head1 METHODS

=head2 new

	my $parser = Grammar::Parser->new (I<parameters ...>);

Proxy constructor to build driver instance.

Passes-through unrecognized parameters to driver class (see L<< Grammar::Parser::Driver >>)

Recognized and consumed parameters:

=over

=item driver

Can be package name or arrayref of package names - what driver to instantiaze.

If not specified, tries to fetch its value from environment (see L<< /driver_env >>) first,
then from global variable C<< $DEFAULT_DRIVER >>.

See also: L<< /"Drivers" >>

=item driver_env

Name of environment variable with driver package name.
If not specified, global variable C<< $DEFAULT_ENV_NAME >> will be used.

It's possible to specify multiple drivers to try separating them
with comma, semicolon, and/or forward slash.

=item grammar

Data structure grammar definition (see L<< /"Grammar" >>).
If not specified, tries parameters L<< /"skeleton" >> and L<< /"bnf" >> to build it.

=item skeleton

If specified it should contain package name (autoloaded) which will be used to build grammar.

=item bnf

If specified it should contain file containing BNF source of grammar.

Relative path will be searched on @INC paths first, then $FindBin::Bin, and cwd.

=back

=head1 Grammar

This module uses data structure defined grammar.

Grammar structure is hashref with rule names as keys and arrayref values treated as:

=over

=item empty arrayref

empty rule

=item list of scalars and/or regexes

non-terminal symbol

=item list of arrayrefs with other rule names

rule alternatives

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file is part of L<< Grammar::Parser >>.
It can be distributed and/or modified under Artistic license 2.0

=cut

