#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_declaration';

plan tests => 4;

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
	public String bar;
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
				expect_element ('CSI::Language::Java::Field::Name' => (
					expect_identifier ('foo'),
				)),
				expect_token_semicolon,
			)),
			expect_element ('CSI::Language::Java::Field::Declaration' => (
				expect_modifier_public,
				expect_type_string,
				expect_element ('CSI::Language::Java::Field::Name' => (
					expect_identifier ('bar'),
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

had_no_warnings;

done_testing;
