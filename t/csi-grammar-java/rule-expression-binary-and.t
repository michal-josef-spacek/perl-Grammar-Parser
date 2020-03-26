#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 4;

test_rule "binary and expression" => (
	data => 'a & b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::And' => (
			expect_reference ('a'),
			expect_operator_binary_and,
			expect_reference ('b'),
		)),
	],
);

test_rule "binary and expression / associativity" => (
	data => 'a & b & c',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::And' => (
			expect_reference ('a'),
			expect_operator_binary_and,
			expect_reference ('b'),
			expect_operator_binary_and,
			expect_reference ('c'),
		)),
	],
);

test_rule "binary and expression / precedence" => (
	data => 'a != b & c == d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::And' => (
			expect_element ('CSI::Language::Java::Expression::Equality' => (
				expect_reference ('a'),
				expect_operator_inequality,
				expect_reference ('b'),
			)),
			expect_operator_binary_and,
			expect_element ('CSI::Language::Java::Expression::Equality' => (
				expect_reference ('c'),
				expect_operator_equality,
				expect_reference ('d'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
