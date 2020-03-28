#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 4;

test_rule "expression / array creation / with dimension expression" => (
	data => 'new int[size]',
	expect => [
		expect_element ('CSI::Language::Java::Array::Creation' => (
			expect_word_new,
			expect_type_int,
			expect_element ('CSI::Language::Java::Array::Dimension::Expression' => (
				expect_token_bracket_open,
				expect_reference ('size'),
				expect_token_bracket_close,
			)),
		)),
	],
);

test_rule "expression / array creation / with array initializer" => (
	data => 'new String[] { }',
	expect => [
		expect_element ('CSI::Language::Java::Array::Creation' => (
			expect_word_new,
			expect_type_string,
			expect_element ('CSI::Language::Java::Array::Dimension' => (
				expect_token_bracket_open,
				expect_token_bracket_close,
			)),
			expect_element ('CSI::Language::Java::Array::Initializer' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "expression / array creation / multi-dimensional" => (
	data => 'new String[][] { }',
	expect => [
		expect_element ('CSI::Language::Java::Array::Creation' => (
			expect_word_new,
			expect_type_string,
			expect_element ('CSI::Language::Java::Array::Dimension' => (
				expect_token_bracket_open,
				expect_token_bracket_close,
			)),
			expect_element ('CSI::Language::Java::Array::Dimension' => (
				expect_token_bracket_open,
				expect_token_bracket_close,
			)),
			expect_element ('CSI::Language::Java::Array::Initializer' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
