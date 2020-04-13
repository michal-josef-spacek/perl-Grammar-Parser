#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_declaration';

plan tests => 5;

test_rule "empty public static abstract class" => (
	data => <<'EODATA',
public static abstract class Foo {
}
EODATA
	expect => expect_element ('CSI::Language::Java::Class::Declaration' => (
		expect_modifiers (
			expect_modifier_public,
			expect_modifier_static,
			expect_modifier_abstract,
		),
		expect_word_class,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Class::Body' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

test_rule "class with fields" => (
	data => <<'EODATA',
public class Foo {
	public String foo;
	public String bar, baz;
}
EODATA
	expect => expect_element ('CSI::Language::Java::Class::Declaration' => (
		expect_modifier_public,
		expect_word_class,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Class::Body' => (
			expect_token_brace_open,
			expect_element ('CSI::Language::Java::Field::Declaration' => (
				expect_modifier_public,
				expect_type_string,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('foo'),
					)),
				)),
				expect_token_semicolon,
			)),
			expect_element ('CSI::Language::Java::Field::Declaration' => (
				expect_modifier_public,
				expect_type_string,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('bar'),
					)),
				)),
				expect_token_comma,
				expect_element ('CSI::Language::Java::Variable::Declarator' => (
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('baz'),
					)),
				)),
				expect_token_semicolon,
			)),
			expect_token_brace_close,
		)),
	)),
);

test_rule "class with empty declaration" => (
	data => <<'EODATA',
public class Foo {
	;
}
EODATA
	expect => expect_element ('CSI::Language::Java::Class::Declaration' => (
		expect_modifier_public,
		expect_word_class,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Class::Body' => (
			expect_token_brace_open,
			expect_element ('CSI::Language::Java::Empty::Declaration' => (
				expect_token_semicolon,
			)),
			expect_token_brace_close,
		)),
	)),
);

test_rule "class with method declaration" => (
	data => <<'EODATA',
public class Foo {
	public void foo () { }
}
EODATA
	expect => expect_element ('CSI::Language::Java::Class::Declaration' => (
		expect_modifier_public,
		expect_word_class,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Class::Body' => (
			expect_token_brace_open,
			expect_element ('CSI::Language::Java::Method::Declaration' => (
				expect_modifier_public,
				expect_element ('CSI::Language::Java::Method::Result' => (
					expect_word_void,
				)),
				expect_method_name ('foo'),
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
			expect_token_brace_close,
		)),
	)),
);

had_no_warnings;

done_testing;
