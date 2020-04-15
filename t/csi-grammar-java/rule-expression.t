#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 16;

test_rule "primary expression / literal / null" => (
	data => 'null',
	expect => [ expect_literal_null ],
);

test_rule "primary expression / literal / integer number" => (
	data => '0L',
	expect => [ expect_literal_integral_decimal ('0L') ],
);

test_rule "primary expression / class literal" => (
	data => 'String.class',
	expect => [ expect_literal_class (expect_reference ([qw[ String ]])) ]
);

test_rule "primary expression / group expression" => (
	data => '(null)',
	expect => [
		expect_token_paren_open,
		expect_literal_null,
		expect_token_paren_close,
	],
);

test_rule "primary expression / double-group expression" => (
	data => '((null))',
	expect => [
		expect_token_paren_open,
		expect_token_paren_open,
		expect_literal_null,
		expect_token_paren_close,
		expect_token_paren_close,
	],
);

test_rule "primary expression / this" => (
	data => 'this',
	expect => [
		expect_element ('CSI::Language::Java::Expression::This' => (
			expect_word_this,
		)),
	],
);

test_rule "primary expression / qualified this" => (
	data => 'Foo.Bar.this',
	expect => [
		expect_element ('CSI::Language::Java::Expression::This' => (
			expect_identifier ('Foo'),
			expect_token_dot,
			expect_identifier ('Bar'),
			expect_token_dot,
			expect_word_this,
		)),
	],
);

test_rule "primary expression / method reference" => (
	data => 'Foo.Bar::method',
	expect => [
		expect_element ('CSI::Language::Java::Method::Reference' => (
			expect_type_class ([qw[ Foo Bar ]]),
			expect_token ('CSI::Language::Java::Token::Double::Colon' => '::'),
			expect_method_name ('method'),
		)),
	],
);

test_rule "primary expression / field access / field of 'var' variable" => (
	data => 'var.field',
	expect => [
		expect_reference (qw[ var field ]),
	],
);

test_rule "postfix expression / decrement" => (
	data => 'foo--',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_decrement,
		)),
	],
);

test_rule "expression / prefix expression" => (
	data => '--foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_decrement,
			expect_reference ('foo'),
		)),
	],
);

test_rule "expression / multiplicative expression" => (
	data => 'foo * 2',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Multiplicative' => (
			expect_reference ('foo'),
			expect_operator_multiplication,
			expect_literal_integral_decimal ('2'),
		)),
	],
);

test_rule "expression / additive expression" => (
	data => 'foo + bar',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Additive' => (
			expect_reference ('foo'),
			expect_operator_addition,
			expect_reference ('bar'),
		)),
	],
);

test_rule "expression / binary shift expression" => (
	data => 'foo >> bar',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Binary::Shift' => (
			expect_reference ('foo'),
			expect_operator_binary_shift_right,
			expect_reference ('bar'),
		)),
	],
);

test_rule "expression / relational expression" => (
	data => 'foo > bar',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Relational' => (
			expect_reference ('foo'),
			expect_operator_greater_than,
			expect_reference ('bar'),
		)),
	],
);

had_no_warnings;

done_testing;
