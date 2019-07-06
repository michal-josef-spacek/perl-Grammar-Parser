#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use Path::Tiny;

use Test::More;
use Test::Deep;
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Grammar::Parser::BNF;

sub expect_parser_ast {
	my ($title, %params) = @_;

	use feature 'state';
	state $parser = Test::Grammar::Parser::BNF->new;

	my $result = $parser->parse ($params{parse});

	use Data::Printer;

	cmp_deeply $result, $params{expect}, $title
		or p $result;
}

plan tests => 6;

expect_parser_ast "alias rule" => (
	parse => 'table_name: identifier',
	expect => { bnf => [ {
		rule => 'table_name',
		nonterminal => 'identifier',
	} ] },
);


expect_parser_ast "alternative rule" => (
	parse => 'table_name: identifier | fully_qualified_identifier | string',
	expect => { bnf => [ {
		rule => 'table_name',
		alternative => [
			{ nonterminal => 'identifier' },
			{ nonterminal => 'fully_qualified_identifier' },
			{ nonterminal => 'string' },
		],
	} ] },
);

expect_parser_ast "alternative literals" => (
	parse => "operator: '+' | '-' | '*' | '/'",
	expect => { bnf => [ {
		rule => 'operator',
		alternative => [
			{ terminal => '+' },
			{ terminal => '-' },
			{ terminal => '*' },
			{ terminal => '/' },
		],
	} ] },
);

expect_parser_ast "alternative sequence" => (
	parse => 'expression: number | expression expression operator',
	expect => { bnf => [ {
		rule => 'expression',
		alternative => [
			{ nonterminal => 'number' },
			{ sequence => [
				{ nonterminal => 'expression' },
				{ nonterminal => 'expression' },
				{ nonterminal => 'operator' },
			] },
		],
	} ] },
);

expect_parser_ast "literal regex" => (
	parse => 'number: qr/\d+/',
	expect => { bnf => [ {
		rule => 'number',
		terminal => {
			regex => '\d+',
			delimiter => '/',
			modifiers => '',
		},
	} ] },
);

had_no_warnings 'no unexpected warnings in Grammar::Parser::BNF actions';

done_testing;

package Test::Grammar::Parser::BNF;

use Moo;

BEGIN {
	extends 'Grammar::Parser::BNF';

	has '+result_class' => (
		default => sub { undef },
	);
}

