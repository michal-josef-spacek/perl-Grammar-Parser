#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

not 1 and plan tests => 18;

not 1 and test_rule "prefix expression / unary minus" => (
	data => '-foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_unary_minus,
			expect_reference ('foo'),
		)),
	],
);

not 1 and test_rule "prefix expression / unary plus" => (
	data => '+foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_unary_plus,
			expect_reference ('foo'),
		)),
	],
);

not 1 and test_rule "prefix expression / decrement" => (
	data => '--foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_decrement,
			expect_reference ('foo'),
		)),
	],
);

not 1 and test_rule "prefix expression / increment" => (
	data => '++foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_increment,
			expect_reference ('foo'),
		)),
	],
);

not 1 and test_rule "prefix expression / logical complement" => (
	data => '!foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_logical_complement,
			expect_reference ('foo'),
		)),
	],
);

not 1 and test_rule "prefix expression / binary complement" => (
	data => '~foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_binary_complement,
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / cast" => (
	data => '(String) foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Cast' => (
			expect_element ('CSI::Language::Java::Operator::Cast' => (
				expect_token_paren_open,
				expect_type_string,
				expect_token_paren_close,
			)),
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / associativity / decrement" => (
	data => '----foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_decrement,
			expect_operator_decrement,
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / associativity / increment" => (
	data => '++++foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_increment,
			expect_operator_increment,
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / associativity / unary minus > decrements" => (
	data => '-----foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_unary_minus,
			expect_operator_decrement,
			expect_operator_decrement,
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / associativity / unary plus > increments" => (
	data => '+++++foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_unary_plus,
			expect_operator_increment,
			expect_operator_increment,
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / associativity / logical complements" => (
	data => '!!foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_logical_complement,
			expect_operator_logical_complement,
			expect_reference ('foo'),
		)),
	],
);

test_rule "prefix expression / associativity / binary complements" => (
	data => '~~foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_binary_complement,
			expect_operator_binary_complement,
			expect_reference ('foo'),
		)),
	],
);

not 1 and test_rule "prefix expression / asosciativity / casts" => (
	data => '(String) (Foo) foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Cast' => (
			expect_element ('CSI::Language::Java::Operator::Cast' => (
				expect_token_paren_open,
				expect_type_string,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Expression::Cast' => (
				expect_element ('CSI::Language::Java::Operator::Cast' => (
					expect_token_paren_open,
					expect_type_class (['Foo']),
					expect_token_paren_close,
				)),
				expect_reference ('foo'),
			)),
		)),
	],
);

not 1 and test_rule "prefix expression / associativity / reference cast vs grouping" => (
	data => '(string) + foo',
	throws => 1,
);

not 1 and test_rule "prefix expression / associativity" => (
	data => '!~+-++--(int)foo',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_logical_complement,
			expect_operator_binary_complement,
			expect_operator_unary_plus,
			expect_operator_unary_minus,
			expect_operator_increment,
			expect_operator_decrement,
			expect_element ('CSI::Language::Java::Expression::Cast' => (
				expect_element ('CSI::Language::Java::Operator::Cast' => (
					expect_token_paren_open,
					expect_type_int,
					expect_token_paren_close,
				)),
				expect_reference ('foo'),
			)),
		)),
	],
);

not 1 and test_rule "prefix expression / precedence" => (
	data => '++foo--',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Prefix' => (
			expect_operator_increment,
			expect_element ('CSI::Language::Java::Expression::Postfix' => (
				expect_reference ('foo'),
				expect_operator_decrement,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
