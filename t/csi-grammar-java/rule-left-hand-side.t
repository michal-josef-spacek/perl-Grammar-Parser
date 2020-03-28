#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'left_hand_side';

plan tests => 8;

test_rule "variable" => (
	data => 'foo',
	expect => [
		expect_reference ('foo'),
	],
);

test_rule "array access" => (
	data => 'foo[1]',
	expect => [
		expect_element ('CSI::Language::Java::Array::Access' => (
			expect_reference ('foo'),
			expect_token_bracket_open,
			expect_literal_integral_decimal ("1"),
			expect_token_bracket_close,
		)),
	],
);

test_rule "multidimensional array access" => (
	data => 'foo[1][2][3]',
	expect => [
		expect_element ('CSI::Language::Java::Array::Access' => (
			expect_element ('CSI::Language::Java::Array::Access' => (
				expect_element ('CSI::Language::Java::Array::Access' => (
					expect_reference ('foo'),
					expect_token_bracket_open,
					expect_literal_integral_decimal ("1"),
					expect_token_bracket_close,
				)),
				expect_token_bracket_open,
				expect_literal_integral_decimal ("2"),
				expect_token_bracket_close,
			)),
			expect_token_bracket_open,
			expect_literal_integral_decimal ("3"),
			expect_token_bracket_close,
		)),
	],
);

test_rule "variable field access" => (
	data => 'foo.bar.baz',
	expect => [
		expect_reference ('foo', 'bar', 'baz'),
	],
);

test_rule "method field access" => (
	data => 'foo().bar',
	expect => [
		expect_element ('CSI::Language::Java::Field::Access' => (
			expect_element ('CSI::Language::Java::Method::Invocation' => (
				expect_method_name ('foo'),
				expect_element ('CSI::Language::Java::Arguments' => (
					expect_token_paren_open,
					expect_token_paren_close,
				)),
			)),
			expect_token_dot,
			expect_element ('CSI::Language::Java::Field::Name' => (
				expect_identifier ('bar'),
			)),
		)),
	],
);

test_rule "super field" => (
	data => 'super.baz',
	expect => [
		expect_element ('CSI::Language::Java::Field::Access' => (
			expect_word_super,
			expect_token_dot,
			expect_element ('CSI::Language::Java::Field::Name' => (
				expect_identifier ('baz'),
			)),
		)),
	],
);

test_rule "reference super field" => (
	data => 'Foo.Bar.super.baz',
	expect => [
		expect_element ('CSI::Language::Java::Field::Access' => (
			expect_reference ('Foo', 'Bar'),
			expect_token_dot,
			expect_word_super,
			expect_token_dot,
			expect_element ('CSI::Language::Java::Field::Name' => (
				expect_identifier ('baz'),
			)),
		)),
	],
);

had_no_warnings;

done_testing;
