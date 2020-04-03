#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement';

plan tests => 7;

test_rule "try with simple catch" => (
	data => <<'EODATA',
try { } catch (Exception e) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Try::Catch' => (
				expect_word_catch,
				expect_element ('CSI::Language::Java::Structure::Try::Catch::Parameter' => (
					expect_token_paren_open,
					expect_element ('CSI::Language::Java::Structure::Try::Catch::Type' => (
						expect_reference (qw[ Exception ]),
					)),
					expect_variable_name ('e'),
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
		)),
	],
);

test_rule "try with multiple catches" => (
	data => <<'EODATA',
try { } catch (RuntimeException e) { } catch (Exception e) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Try::Catch' => (
				expect_word_catch,
				expect_element ('CSI::Language::Java::Structure::Try::Catch::Parameter' => (
					expect_token_paren_open,
					expect_element ('CSI::Language::Java::Structure::Try::Catch::Type' => (
						expect_reference (qw[ RuntimeException ]),
					)),
					expect_variable_name ('e'),
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
			expect_element ('CSI::Language::Java::Structure::Try::Catch' => (
				expect_word_catch,
				expect_element ('CSI::Language::Java::Structure::Try::Catch::Parameter' => (
					expect_token_paren_open,
					expect_element ('CSI::Language::Java::Structure::Try::Catch::Type' => (
						expect_reference (qw[ Exception ]),
					)),
					expect_variable_name ('e'),
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
		)),
	],
);

test_rule "try with multi-type catch" => (
	data => <<'EODATA',
try { } catch (Foo | Bar e) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Try::Catch' => (
				expect_word_catch,
				expect_element ('CSI::Language::Java::Structure::Try::Catch::Parameter' => (
					expect_token_paren_open,
					expect_element ('CSI::Language::Java::Structure::Try::Catch::Type' => (
						expect_reference (qw[ Foo ]),
						expect_operator_binary_or,
						expect_reference (qw[ Bar ]),
					)),
					expect_variable_name ('e'),
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
		)),
	],
);

test_rule "try with catch and finally" => (
	data => <<'EODATA',
try { } catch (Exception e) { } finally { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Try::Catch' => (
				expect_word_catch,
				expect_element ('CSI::Language::Java::Structure::Try::Catch::Parameter' => (
					expect_token_paren_open,
					expect_element ('CSI::Language::Java::Structure::Try::Catch::Type' => (
						expect_reference (qw[ Exception ]),
					)),
					expect_variable_name ('e'),
					expect_token_paren_close,
				)),
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
			expect_element ('CSI::Language::Java::Structure::Try::Finally' => (
				expect_word_finally,
				expect_element ('CSI::Language::Java::Structure::Block' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
		)),
	],
);

test_rule "try with resources" => (
	data => <<'EODATA',
try (String foo = expr; String bar = expr) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::List::Resources' => (
				expect_token_paren_open,
				expect_element ('CSI::Language::Java::Resource' => (
					expect_type_string,
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('foo'),
					)),
					expect_operator_assign,
					expect_reference ('expr'),
				)),
				expect_token_semicolon,
				expect_element ('CSI::Language::Java::Resource' => (
					expect_type_string,
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('bar'),
					)),
					expect_operator_assign,
					expect_reference ('expr'),
				)),
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "try with resources with trailing semicolon" => (
	data => <<'EODATA',
try (String foo = expr;) { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::List::Resources' => (
				expect_token_paren_open,
				expect_element ('CSI::Language::Java::Resource' => (
					expect_type_string,
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('foo'),
					)),
					expect_operator_assign,
					expect_reference ('expr'),
				)),
				expect_token_semicolon,
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
