#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 14;

test_rule "assignment" => (
	data => 'foo = 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign' => '='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / plus" => (
	data => 'foo += 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Addition' => '+='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / minus" => (
	data => 'foo -= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Subtraction' => '-='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / multiplication" => (
	data => 'foo *= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Multiplication' => '*='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / division" => (
	data => 'foo /= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Division' => '/='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / binary and" => (
	data => 'foo &= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Binary::And' => '&='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / binary or" => (
	data => 'foo |= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Binary::Or' => '|='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / binary xor" => (
	data => 'foo ^= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Binary::Xor' => '^='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / binary shift left" => (
	data => 'foo <<= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Binary::Shift::Left' => '<<='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / binary shift right" => (
	data => 'foo >>= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Binary::Shift::Right' => '>>='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / binary unsigned shift right" => (
	data => 'foo >>>= 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign::Binary::UShift::Right' => '>>>='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);

test_rule "assignment / associativity" => (
	data => 'foo = bar = baz = 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign' => '='),
			expect_reference ('bar'),
			expect_token ('::Operator::Assign' => '='),
			expect_reference ('baz'),
			expect_token ('::Operator::Assign' => '='),
			expect_literal_integral_decimal ("1"),
		)),
	],
);
test_rule "assignment / rhs can be lambda" => (
	data => 'foo = () -> {}',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Assignment' => (
			expect_reference ('foo'),
			expect_token ('::Operator::Assign' => '='),
			expect_element ('CSI::Language::Java::Expression::Lambda' => (
				expect_element ('CSI::Language::Java::Expression::Lambda::Parameters' => (
					expect_token_paren_open,
					expect_token_paren_close,
				)),
				expect_token ('CSI::Language::Java::Token::Lambda' => '->'),
				expect_element ('CSI::Language::Java::Structure::Block'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
