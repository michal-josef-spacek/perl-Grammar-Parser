#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 7;

test_rule "relational expression / less than" => (
	data => 'a < b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('a'),
			expect_operator_less_than,
			expect_reference ('b'),
		)),
	],
);

test_rule "relational expression / less than or equal" => (
	data => 'a <= b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('a'),
			expect_operator_less_equal,
			expect_reference ('b'),
		)),
	],
);

test_rule "relational expression / greater than" => (
	data => 'a > b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('a'),
			expect_operator_greater_than,
			expect_reference ('b'),
		)),
	],
);

test_rule "relational expression / greater than or equal" => (
	data => 'a >= b',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('a'),
			expect_operator_greater_equal,
			expect_reference ('b'),
		)),
	],
);

test_rule "relational expression / instance of" => (
	data => 'a instanceof Foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('a'),
			expect_word_instanceof,
			expect_class_type (['Foo']),
		)),
	],
);

test_rule "relational expression / precedence" => (
	data => 'a >> b >= c >> d',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
				expect_reference ('a'),
				expect_operator_binary_shift_right,
				expect_reference ('b'),
			)),
			expect_operator_greater_equal,
			expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
				expect_reference ('c'),
				expect_operator_binary_shift_right,
				expect_reference ('d'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
