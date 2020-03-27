#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'arguments';

plan tests => 7;

test_rule "arguments / empty arguments" => (
	data => '()',
	expect => expect_arguments,
	expectation_expanded => expect_element ('CSI::Language::Java::Arguments' => (
		expect_token_paren_open,
		expect_token_paren_close,
	)),
);

test_rule "arguments / single argument" => (
	data => '(true)',
	expect => expect_arguments (
		expect_literal_true,
	),
	expectation_expanded => expect_element ('CSI::Language::Java::Arguments' => (
		expect_token_paren_open,
		expect_literal_true,
		expect_token_paren_close,
	)),
);

test_rule "arguments / multiple arguments" => (
	data => '(true, false, null)',
	expect => expect_arguments (
		expect_literal_true,
		expect_literal_false,
		expect_literal_null,
	),
	expectation_expanded => expect_element ('CSI::Language::Java::Arguments' => (
		expect_token_paren_open,
		expect_literal_true,
		expect_token_comma,
		expect_literal_false,
		expect_token_comma,
		expect_literal_null,
		expect_token_paren_close,
	)),
);

had_no_warnings;

done_testing;
