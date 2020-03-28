#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'array_initializer';

plan tests => 6;

test_rule "empty array initializer" => (
	data => '{ }',
	expect => expect_element ('CSI::Language::Java::Array::Initializer' => (
		expect_token_brace_open,
		expect_token_brace_close,
	)),
);

test_rule "empty array initializer with trailing comma" => (
	data => '{ , }',
	expect => expect_element ('CSI::Language::Java::Array::Initializer' => (
		expect_token_brace_open,
		expect_token_comma,
		expect_token_brace_close,
	)),
);

test_rule "array initializer" => (
	data => '{ null, "foo" }',
	expect => expect_element ('CSI::Language::Java::Array::Initializer' => (
		expect_token_brace_open,
		expect_literal_null,
		expect_token_comma,
		expect_literal_string ("foo"),
		expect_token_brace_close,
	)),
);

test_rule "array initializer with trailing comma" => (
	data => '{ null, "foo",  }',
	expect => expect_element ('CSI::Language::Java::Array::Initializer' => (
		expect_token_brace_open,
		expect_literal_null,
		expect_token_comma,
		expect_literal_string ("foo"),
		expect_token_comma,
		expect_token_brace_close,
	)),
);

test_rule "nested array initializer" => (
	data => '{ { }, { } }',
	expect => expect_element ('CSI::Language::Java::Array::Initializer' => (
		expect_token_brace_open,
		expect_element ('CSI::Language::Java::Array::Initializer' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
		expect_token_comma,
		expect_element ('CSI::Language::Java::Array::Initializer' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
		expect_token_brace_close,
	)),
);

had_no_warnings;

done_testing;
