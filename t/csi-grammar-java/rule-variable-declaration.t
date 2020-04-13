#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'block_statement';

#plan tests => 6;

test_rule "variable declaration / without initialized" => (
	data => <<'EODATA',
float foo;
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Variable' => (
			expect_element ('CSI::Language::Java::Variable' => (
				expect_type_float,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'foo'),
					)),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "variable declaration / with initializer" => (
	data => <<'EODATA',
float foo = 1000.f;
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Variable' => (
			expect_element ('CSI::Language::Java::Variable' => (
				expect_type_float,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'foo'),
					)),
					expect_operator_assign,
					expect_literal_floating_decimal ('1000.f'),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "variable declaration / with var type" => (
	data => <<'EODATA',
var foo = 1000.f;
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Variable' => (
			expect_element ('CSI::Language::Java::Variable' => (
				expect_word_var,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'foo'),
					)),
					expect_operator_assign,
					expect_literal_floating_decimal ('1000.f'),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "variable declaration / with multiple variables" => (
	data => <<'EODATA',
float foo, bar = 1000.f, baz = 100.f;
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Variable' => (
			expect_element ('CSI::Language::Java::Variable' => (
				expect_type_float,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'foo'),
					)),
				)),
				expect_token_comma,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'bar'),
					)),
					expect_operator_assign,
					expect_literal_floating_decimal ('1000.f'),
				)),
				expect_token_comma,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'baz'),
					)),
					expect_operator_assign,
					expect_literal_floating_decimal ('100.f'),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "variable declaration / variable name can be var" => (
	data => <<'EODATA',
var var = 1000.f;
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Variable' => (
			expect_element ('CSI::Language::Java::Variable' => (
				expect_word_var,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'var'),
					)),
					expect_operator_assign,
					expect_literal_floating_decimal ('1000.f'),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

test_rule "variable declaration / annotated reference type variable" => (
	data => <<'EODATA',
@Foo Bar<Baz> foo;
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Variable' => (
			expect_element ('CSI::Language::Java::Variable' => (
				expect_modifiers (
					expect_annotation ([qw[ Foo ]]),
				),
				expect_type_class (
					[qw[ Bar ]],
					type_arguments => [ expect_type_class ([qw[ Baz ]]) ],
				),
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_token ('CSI::Language::Java::Variable::Name' => 'foo'),
					)),
				)),
			)),
			expect_token_semicolon,
		)),
	],
);

had_no_warnings;

done_testing;
