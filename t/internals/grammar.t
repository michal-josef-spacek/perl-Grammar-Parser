#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";

BEGIN { require "test-helper-common.pl" }

use Grammar::Parser::Grammar;

sub build_grammar;

plan tests => 3;

subtest 'full grammar' => sub {
    my $grammar = build_grammar start => 'equation';

    is 'should start with full grammar start rule',
        got    => $grammar->start,
        expect => 'equation',
    ;

    it 'should provide all used terminals',
        got    => [ $grammar->list_terminals ],
        expect => bag (qw[ equals number operator paren_l paren_r ]),
    ;

    it 'should provide all used rules',
        got    => [ $grammar->list_nonterminals ],
        expect => bag (qw[ equation expression ]),
    ;
};

subtest 'sub-grammar' => sub {
    my $grammar = build_grammar start => 'expression';

    is 'should start with sub-grammar rule',
        got    => $grammar->start,
        expect => 'expression',
    ;

    it 'should minimize used terminals',
        got    => [ $grammar->list_terminals ],
        expect => bag (qw[ number operator paren_l paren_r ]),
    ;

    it 'should minimize used rules',
        got    => [ $grammar->list_nonterminals ],
        expect => bag (qw[ expression ]),
    ;
};

had_no_warnings 'no unexpected warnings in Grammar::Parser::Grammar';

done_testing;

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

