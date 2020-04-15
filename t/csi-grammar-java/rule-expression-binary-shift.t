#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 6;

test_rule "binary shift expression / left shift" => (
	data => 'a << b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_reference ('a'),
			expect_operator_binary_shift_left,
			expect_reference ('b'),
		)),
	],
);

test_rule "binary shift expression / right shift" => (
	data => 'a >> b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_reference ('a'),
			expect_operator_binary_shift_right,
			expect_reference ('b'),
		)),
	],
);

test_rule "binary shift expression / unsigned right shift" => (
	data => 'a >>> b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_reference ('a'),
			expect_operator_binary_ushift_right,
			expect_reference ('b'),
		)),
	],
);

test_rule "binary shift expression / associativity" => (
	data => 'a >> b >>> c << d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_reference ('a'),
			expect_operator_binary_shift_right,
			expect_reference ('b'),
			expect_operator_binary_ushift_right,
			expect_reference ('c'),
			expect_operator_binary_shift_left,
			expect_reference ('d'),
		)),
	],
);

test_rule "binary shift expression / precedence" => (
	data => 'a + b << c - d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_element ('CSI::Language::Java::Expression::Additive' => (
				expect_reference ('a'),
				expect_operator_addition,
				expect_reference ('b'),
			)),
			expect_operator_binary_shift_left,
			expect_element ('CSI::Language::Java::Expression::Additive' => (
				expect_reference ('c'),
				expect_operator_subtraction,
				expect_reference ('d'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
