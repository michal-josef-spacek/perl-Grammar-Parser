#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement';

plan tests => 4;

test_rule "loop statement / infinite loop" => (
	data => <<'EODATA',
for (;;) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Loop' => (
			expect_word_for,
			expect_token_paren_open,
			expect_token_semicolon,
			expect_token_semicolon,
			expect_token_paren_close,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "foreach statement" => (
	data => <<'EODATA',
for (String line : lines) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Foreach' => (
			expect_word_for,
			expect_token_paren_open,
			expect_type_string,
			expect_element ('CSI::Language::Java::Variable::ID' => (
				expect_token ('CSI::Language::Java::Variable::Name' => 'line'),
			)),
			expect_token_colon,
			expect_reference ('lines'),
			expect_token_paren_close,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "foreach statement / iterator variable can be named 'var'" => (
	data => <<'EODATA',
for (String var : vars) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Foreach' => (
			expect_word_for,
			expect_token_paren_open,
			expect_type_string,
			expect_element ('CSI::Language::Java::Variable::ID' => (
				expect_token ('CSI::Language::Java::Variable::Name' => 'var'),
			)),
			expect_token_colon,
			expect_reference ('vars'),
			expect_token_paren_close,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
