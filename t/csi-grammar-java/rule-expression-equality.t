#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 4;

test_rule "equality expression / equality" => (
	data => 'a == b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Equality' => (
			expect_reference ('a'),
			expect_operator_equality,
			expect_reference ('b'),
		)),
	],
);

test_rule "equality expression / inequality" => (
	data => 'a != b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Equality' => (
			expect_reference ('a'),
			expect_operator_inequality,
			expect_reference ('b'),
		)),
	],
);

test_rule "equality expression / precedence" => (
	data => 'a > b == c < d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Equality' => (
			expect_element ('CSI::Language::Java::Expression::Relational' => (
				expect_reference ('a'),
				expect_operator_greater_than,
				expect_reference ('b'),
			)),
			expect_operator_equality,
			expect_element ('CSI::Language::Java::Expression::Relational' => (
				expect_reference ('c'),
				expect_operator_less_than,
				expect_reference ('d'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
