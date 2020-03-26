#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 4;

test_rule "logical or expression" => (
	data => 'a || b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
			expect_reference ('a'),
			expect_operator_logical_or,
			expect_reference ('b'),
		)),
	],
);

test_rule "logical or expression / associativity" => (
	data => 'a || b || c',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
			expect_reference ('a'),
			expect_operator_logical_or,
			expect_reference ('b'),
			expect_operator_logical_or,
			expect_reference ('c'),
		)),
	],
);

test_rule "logical or expression / precedence" => (
	data => 'a && b || c && d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Logical::Or' => (
			expect_element ('CSI::Language::Java::Expression::Logical::And' => (
				expect_reference ('a'),
				expect_operator_logical_and,
				expect_reference ('b'),
			)),
			expect_operator_logical_or,
			expect_element ('CSI::Language::Java::Expression::Logical::And' => (
				expect_reference ('c'),
				expect_operator_logical_and,
				expect_reference ('d'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
