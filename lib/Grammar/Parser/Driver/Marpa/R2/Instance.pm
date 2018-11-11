
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Driver::Marpa::R2::Instance v1.0.0;

use Moo;

extends 'Grammar::Parser::Driver::Instance';

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

    $lexer->push_data (@what);

	my $step = 0;
    while (1) {
		$step++;
        my $expected = $marpa->terminals_expected;
		Test::More::diag ("Step ${step}: expect ${\ join ' ', @$expected }");
		Test::More::diag ("     ${step}: ${ $lexer->_data }");
        last unless @$expected;
        my $symbol = $lexer->next_token (@$expected);
        last unless $symbol;
        last unless @$symbol;

		my ($name, $value) = @$symbol;
        $value = $self->run_action ($name, $value);

        $marpa->read ($name => $value);
    }

    $self->result;
}

sub result {
    my ($self) = @_;

    my $ref = $self->marpa->value;

    die "Not parsed" unless $ref;

    return $$ref;
}

1;
