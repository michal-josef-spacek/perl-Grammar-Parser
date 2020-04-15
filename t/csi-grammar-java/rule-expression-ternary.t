#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 5;

test_rule "ternary expression / syntax" => (
	data => <<'EODATA',
a?b:c
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Expression::Ternary' => (
			expect_reference ('a'),
			expect_token_question_mark,
			expect_reference ('b'),
			expect_token_colon,
			expect_reference ('c'),
		)),
	],
);

test_rule "ternary expression / associativity / then branch" => (
	data => <<'EODATA',
a?b?c?d:e:f:g
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Expression::Ternary' => (
			expect_reference ('a'),
			expect_token_question_mark,
			expect_element ('CSI::Language::Java::Expression::Ternary' => (
				expect_reference ('b'),
				expect_token_question_mark,
				expect_element ('CSI::Language::Java::Expression::Ternary' => (
					expect_reference ('c'),
					expect_token_question_mark,
					expect_reference ('d'),
					expect_token_colon,
					expect_reference ('e'),
				)),
				expect_token_colon,
				expect_reference ('f'),
			)),
			expect_token_colon,
			expect_reference ('g'),
		)),
	],
);

test_rule "ternary expression / associativity / else branch" => (
	data => <<'EODATA',
a?b:c?d:e?f:g
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Expression::Ternary' => (
			expect_reference ('a'),
			expect_token_question_mark,
			expect_reference ('b'),
			expect_token_colon,
			expect_element ('CSI::Language::Java::Expression::Ternary' => (
				expect_reference ('c'),
				expect_token_question_mark,
				expect_reference ('d'),
				expect_token_colon,
				expect_element ('CSI::Language::Java::Expression::Ternary' => (
					expect_reference ('e'),
					expect_token_question_mark,
					expect_reference ('f'),
					expect_token_colon,
					expect_reference ('g'),
				)),
			)),
		)),
	],
);

test_rule "ternary expression / precedence" => (
	data => <<'EODATA',
a || b ? c || d : e || f
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Expression::Ternary' => (
			expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
				expect_reference ('a'),
				expect_operator_logical_or,
				expect_reference ('b'),
			)),
			expect_token_question_mark,
			expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
				expect_reference ('c'),
				expect_operator_logical_or,
				expect_reference ('d'),
			)),
			expect_token_colon,
			expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
				expect_reference ('e'),
				expect_operator_logical_or,
				expect_reference ('f'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;

__END__

