#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 7;

test_rule "lambda expression / expression lambda" => (
	data => '() -> null',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Lambda' => (
			expect_element ('CSI::Language::Java::Expression::Lambda::Parameters' => (
				expect_token_paren_open,
				expect_token_paren_close,
			)),
			expect_token ('CSI::Language::Java::Token::Lambda' => '->'),
			expect_literal_null,
		)),
	],
);

test_rule "lambda expression / empty block lambda" => (
	data => '() -> {}',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Lambda' => (
			expect_element ('CSI::Language::Java::Expression::Lambda::Parameters' => (
				expect_token_paren_open,
				expect_token_paren_close,
			)),
			expect_token ('CSI::Language::Java::Token::Lambda' => '->'),
			expect_element ('CSI::Language::Java::Structure::Block'),
		)),
	],
);

test_rule "lambda expression / with variable name parameter" => (
	data => 'a -> {}',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Lambda' => (
			expect_element ('CSI::Language::Java::Expression::Lambda::Parameters' => (
				expect_variable_name ('a'),
			)),
			expect_token ('CSI::Language::Java::Token::Lambda' => '->'),
			expect_element ('CSI::Language::Java::Structure::Block'),
		)),
	],
);

test_rule "lambda expression / with multiple variable name parameters" => (
	data => '(a, b) -> {}',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Lambda' => (
			expect_element ('CSI::Language::Java::Expression::Lambda::Parameters' => (
				expect_token_paren_open,
				expect_variable_name ('a'),
				expect_token_comma,
				expect_variable_name ('b'),
				expect_token_paren_close,
			)),
			expect_token ('CSI::Language::Java::Token::Lambda' => '->'),
			expect_element ('CSI::Language::Java::Structure::Block'),
		)),
	],
);

test_rule "lambda expression / with cast operator" => (
	data => '(Foo) () -> {}',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Cast' => (
			expect_element ('CSI::Language::Java::Operator::Cast' => (
				expect_token_paren_open,
				expect_type_class ([qw[ Foo ]]),
				expect_token_paren_close,
			)),
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

test_rule "lambda expression / with relational expression" => (
	data => 'a -> a > 1',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Lambda' => (
			expect_element ('CSI::Language::Java::Expression::Lambda::Parameters' => (
				expect_variable_name ('a'),
			)),
			expect_token ('CSI::Language::Java::Token::Lambda' => '->'),
			expect_element ('CSI::Language::Java::Expression::Relational' => (
				expect_reference ('a'),
				expect_operator_greater_than,
				expect_literal_integral_decimal ('1'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
