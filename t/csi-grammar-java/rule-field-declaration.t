#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'field_declaration';

plan tests => 4;

test_rule "uninitialized field" => (
	data => 'private static final int field;',
	expect => expect_element ('CSI::Language::Java::Field::Declaration' => (
		expect_modifier_private,
		expect_modifier_static,
		expect_modifier_final,
		expect_type_int,
		expect_element ('CSI::Language::Java::Variable::Declarator' => (
			expect_element ('CSI::Language::Java::Variable::ID' => (
				expect_variable_name ('field'),
			)),
		)),
		expect_token_semicolon,
	)),
);

test_rule "initialized field" => (
	data => 'public static final String field = "foo";',
	expect => expect_element ('CSI::Language::Java::Field::Declaration' => (
		expect_modifier_public,
		expect_modifier_static,
		expect_modifier_final,
		expect_type_string,
		expect_element ('CSI::Language::Java::Variable::Declarator' => (
			expect_element ('CSI::Language::Java::Variable::ID' => (
				expect_variable_name ('field'),
			)),
			expect_token ('::Operator::Assign' => '='),
			expect_literal_string ('foo'),
		)),
		expect_token_semicolon,
	)),
);

test_rule "multiple fields field" => (
	data => 'String foo, bar;',
	expect => expect_element ('CSI::Language::Java::Field::Declaration' => (
		expect_type_string,
		expect_element ('CSI::Language::Java::Variable::Declarator' => (
			expect_element ('CSI::Language::Java::Variable::ID' => (
				expect_variable_name ('foo'),
			)),
		)),
		expect_token_comma,
		expect_element ('CSI::Language::Java::Variable::Declarator' => (
			expect_element ('CSI::Language::Java::Variable::ID' => (
				expect_variable_name ('bar'),
			)),
		)),
		expect_token_semicolon,
	)),
);

had_no_warnings;

done_testing;
