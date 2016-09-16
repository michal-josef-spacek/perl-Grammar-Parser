
use v5.10;
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Grammar::Parser::Grammar;

sub build_grammar;

plan tests => 3;

subtest 'full grammar' => sub {
    my $grammar = build_grammar start => 'equation';

    is
        $grammar->start,
        'equation',
        'should start with full grammar start rule'
    ;

    cmp_deeply
        [ $grammar->list_terminals ],
        bag (qw[ equals number operator paren_l paren_r ]),
        'should provide all used terminals',
    ;

    cmp_deeply
        [ $grammar->list_nonterminals ],
        bag (qw[ equation expression ]),
        'should provide all used rules',
    ;
};

subtest 'sub-grammar' => sub {
    my $grammar = build_grammar start => 'expression';

    is
        $grammar->start,
        'expression',
        'should start with sub-grammar rule'
    ;

    cmp_deeply
        [ $grammar->list_terminals ],
        bag (qw[ number operator paren_l paren_r ]),
        'should minimize used terminals'
    ;

    cmp_deeply
        [ $grammar->list_nonterminals ],
        bag (qw[ expression ]),
        'should minimize used rules'
    ;
};

had_no_warnings 'no unexpected warnings in Grammar::Parser::Grammar';

sub build_grammar {
	my (%params) = @_;

	$params{empty} //= [];
	$params{grammar} //= {
		equation => [
			[qw[ expression equals expression ]],
		],
		expression => [
			[qw[ number ]],
			[qw[ paren_l expression paren_r ]],
			[qw[ expression operator expression ]],
		],
		number => [ qw/\d+/ ],
		operator => [ '+', '-', '*', '/' ],
		paren_l => [ '(' ],
		paren_r => [ ')' ],
		equals => [ '=' ],
	};

	Grammar::Parser::Grammar->new (%params);
}

