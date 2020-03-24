#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 5;

test_rule "additive expression / addition" => (
	data => 'a + b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Additive' => (
			expect_reference ('a'),
			expect_operator_addition,
			expect_reference ('b'),
		)),
	],
);

test_rule "additive expression / subtraction" => (
	data => 'a - b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Additive' => (
			expect_reference ('a'),
			expect_operator_subtraction,
			expect_reference ('b'),
		)),
	],
);

test_rule "additive expression / associativity" => (
	data => 'a + b + c - d - e',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Additive' => (
			expect_reference ('a'),
			expect_operator_addition,
			expect_reference ('b'),
			expect_operator_addition,
			expect_reference ('c'),
			expect_operator_subtraction,
			expect_reference ('d'),
			expect_operator_subtraction,
			expect_reference ('e'),
		)),
	],
);

test_rule "additive expression / precedence" => (
	data => 'a * b + c / d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Additive' => (
			expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
				expect_reference ('a'),
				expect_operator_multiplication,
				expect_reference ('b'),
			)),
			expect_operator_addition,
			expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
				expect_reference ('c'),
				expect_operator_division,
				expect_reference ('d'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
