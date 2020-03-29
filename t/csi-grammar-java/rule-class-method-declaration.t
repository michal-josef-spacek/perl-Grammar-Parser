#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_method_declaration';

#plan tests => 7;

test_rule "abstract method declaration" => (
	data => 'public abstract void method ();',
	expect => expect_element ('CSI::Language::Java::Method::Declaration' => (
		expect_modifier_public,
		expect_modifier_abstract,
		expect_element ('CSI::Language::Java::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Method::Body' => (
			expect_token_semicolon,
		)),
	)),
);

test_rule "method declaration with body" => (
	data => 'public static final void method () { }',
	expect => expect_element ('CSI::Language::Java::Method::Declaration' => (
		expect_modifier_public,
		expect_modifier_static,
		expect_modifier_final,
		expect_element ('CSI::Language::Java::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Method::Body' => (
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

test_rule "method declaration without modifiers" => (
	data => 'void method () { }',
	expect => expect_element ('CSI::Language::Java::Method::Declaration' => (
		expect_element ('CSI::Language::Java::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Method::Body' => (
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

test_rule "method declaration with variable parameters" => (
	data => 'void method (Object ... args) { }',
	expect => expect_element ('CSI::Language::Java::Method::Declaration' => (
		expect_element ('CSI::Language::Java::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_element ('CSI::Language::Java::Parameter' => (
				expect_type_class ([qw[ Object ]]),
				expect_token_elipsis,
				expect_variable_name ('args'),
			)),
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Method::Body' => (
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

test_rule "method declaration with multiple parameters" => (
	data => 'void method (Object foo, Object bar) { }',
	expect => expect_element ('CSI::Language::Java::Method::Declaration' => (
		expect_element ('CSI::Language::Java::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_element ('CSI::Language::Java::Parameter' => (
				expect_type_class ([qw[ Object ]]),
				expect_variable_name ('foo'),
			)),
			expect_token_comma,
			expect_element ('CSI::Language::Java::Parameter' => (
				expect_type_class ([qw[ Object ]]),
				expect_variable_name ('bar'),
			)),
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Method::Body' => (
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

test_rule "method declaration with throws clause" => (
	data => 'void method () throws Foo, Bar { }',
	expect => expect_element ('CSI::Language::Java::Method::Declaration' => (
		expect_element ('CSI::Language::Java::Method::Result' => (
			expect_word_void,
		)),
		expect_method_name ('method'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Method::Throws' => (
			expect_word_throws,
			expect_class_type ([qw[ Foo ]]),
			expect_token_comma,
			expect_class_type ([qw[ Bar ]]),
		)),
		expect_element ('CSI::Language::Java::Method::Body' => (
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	)),
);

had_no_warnings;

done_testing;
