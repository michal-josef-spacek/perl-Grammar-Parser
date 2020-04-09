#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement';

plan tests => 5;

test_rule "if-then statement" => (
	data => <<'EODATA',
if (true) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "if-then-else statement" => (
	data => <<'EODATA',
if (true) { } else { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_word_else,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "if-if-then-else statement" => (
	data => <<'EODATA',
if (true) if (true) { } else { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Statement::If' => (
				expect_word_if,
				expect_element ('CSI::Language::Java::Clause::Condition' => (
					expect_token_paren_open,
					expect_literal_true,
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
				expect_word_else,
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
		)),
	],
);

test_rule "if-if-then-else-else statement" => (
	data => <<'EODATA',
if (true) if (true) { } else { } else { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Statement::If' => (
				expect_word_if,
				expect_element ('CSI::Language::Java::Clause::Condition' => (
					expect_token_paren_open,
					expect_literal_true,
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
				expect_word_else,
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
			expect_word_else,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
