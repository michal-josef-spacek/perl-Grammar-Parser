
use v5.14;
use strict;
use utf8;

use FindBin;

use Test::More;
use Test::Deep;
use Test::Warnings qw[ had_no_warnings :no_end_test ];

use Path::Tiny;

use Data::Printer;

use Grammar::Parser::BNF;

BEGIN { require "test-helper-bnf.pl" }

describe_bnf_grammar "subset of java grammar - package declaration" => sub {
	arrange_bnf_source "data/bnf-java-package.bnf";

	expect_bnf_result_raw [ {
		rule => undef,
		keywords => [
			{ keyword => 'package' },
		],
	}, {
		rule => 'comment',
		terminal => {
			delimiter => '/',
			modifiers => 'x',
			regex 	  => ignore,
		},
	}, {
		rule => 'whitespace',
		terminal => {
			delimiter => '/',
			modifiers => '',
			regex     => '\s+',
		},
	}, {
		rule => 'start',
		nonterminal => 'compilation_unit',
	}, {
		rule => 'IDENTIFIER',
		terminal => ignore,
	}, {
		rule => 'identifier',
		nonterminal => 'IDENTIFIER',
	}, {
		rule => 'qualified_identifier',
		repeat => { nonterminal => 'identifier' },
		repeat_delimiter => { terminal => '.' },
	}, {
		rule => 'compilation_unit',
		option => { nonterminal => 'package_declaration' },
	}, {
		rule => 'package_declaration',
		sequence => [
			{ nonterminal => 'package' },
			{ nonterminal => 'qualified_identifier' },
			{ terminal => ';' },
		],
	} ];

	expect_bnf_result_grammar {
		# Terminals
		'.' => [ '.' ],
		';' => [ ';' ],
		package => [
			 qr/(?:(?>\b(?:package)\b))/,
		],

		# Non-terminals
		comment => [ ignore ],
		whitespace => [ ignore ],
		IDENTIFIER => [ ignore ],
		identifier => [ [ 'IDENTIFIER' ] ],

		start => [
			[ 'compilation_unit' ],
		],

		qualified_identifier => [
			[ 'identifier' ],
			[ 'identifier', '.', 'qualified_identifier' ],
		],

		compilation_unit => [
			[ ],
			[ 'package_declaration' ],
		],
		package_declaration => [
			[ 'package', 'qualified_identifier', ';' ],
		],
	};

	expect_bnf_result_action_map {
		'.' => 'literal',
		';' => 'literal',
		'comment' => 'literal',
		'whitespace' => 'literal',
		'start' => 'alias',
		'compilation_unit' => 'default',
		'IDENTIFIER'  => 'literal',
		'identifier'  => 'literal_value',
		'qualified_identifier' => 'list',
		'package' => 'literal',
		'package_declaration' => 'default',
	};

	not 1 and expect_parser_tree "should parse package declaration" => (
		source => <<'END_OF_SOURCE',
/* comment */
package test.grammar.parser;
END_OF_SOURCE
		tree   => [
		],
	);

	done_testing;
};

had_no_warnings;

done_testing;

