#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 6;

test_rule "multiplicative expression / multiplication" => (
	data => 'a * b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_reference ('a'),
			expect_operator_multiplication,
			expect_reference ('b'),
		)),
	],
);

test_rule "multiplicative expression / division" => (
	data => 'a / b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_reference ('a'),
			expect_operator_division,
			expect_reference ('b'),
		)),
	],
);

test_rule "multiplicative expression / modulus" => (
	data => 'a % b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_reference ('a'),
			expect_operator_modulus,
			expect_reference ('b'),
		)),
	],
);

test_rule "multiplicative expression / associativity" => (
	data => 'a * b / c % d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_reference ('a'),
			expect_operator_multiplication,
			expect_reference ('b'),
			expect_operator_division,
			expect_reference ('c'),
			expect_operator_modulus,
			expect_reference ('d'),
		)),
	],
);

test_rule "multiplicative expression / precedence" => (
	data => '++a * -b / (int) ~c',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_element ('CSI::Language::Java::Expression::Prefix' => (
				expect_operator_increment,
				expect_reference ('a'),
			)),
			expect_operator_multiplication,
			expect_element ('CSI::Language::Java::Expression::Prefix' => (
				expect_operator_unary_minus,
				expect_reference ('b'),
			)),
			expect_operator_division,
			expect_element ('CSI::Language::Java::Expression::Cast' => (
				expect_element ('CSI::Language::Java::Operator::Cast' => (
					expect_token_paren_open,
					expect_type_int,
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Expression::Prefix' => (
					expect_operator_binary_complement,
					expect_reference ('c'),
				)),
			)),
		)),
	],
);


had_no_warnings;

done_testing;
