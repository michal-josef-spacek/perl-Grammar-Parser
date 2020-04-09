#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement';

plan tests => 5;

test_rule "while statement" => (
	data => <<'EODATA',
while (true) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::While' => (
			expect_word_while,
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

test_rule "if-while-else statement" => (
	data => <<'EODATA',
if (true) while (true) { } else { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Statement::While' => (
				expect_word_while,
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
			expect_word_else,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "if-while-if-else statement" => (
	data => <<'EODATA',
if (true) while (true) if (true) { } else { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Statement::While' => (
				expect_word_while,
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
		)),
	],
);

test_rule "if-while-if-else statement" => (
	data => <<'EODATA',
if (true) while (true) if (true) { } else { } else {}
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::If' => (
			expect_word_if,
			expect_element ('CSI::Language::Java::Clause::Condition' => (
				expect_token_paren_open,
				expect_literal_true,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Statement::While' => (
				expect_word_while,
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
