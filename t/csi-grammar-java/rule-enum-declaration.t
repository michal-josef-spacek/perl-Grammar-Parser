#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'enum_declaration';

plan tests => 3;

test_rule "empty public enum" => (
	data => <<'EODATA',
public enum Foo {
}
EODATA
	expect => expect_element ('CSI::Language::Java::Enum::Declaration' => (
		expect_modifiers (
			expect_modifier_public,
		),
		expect_word_enum,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Enum::Body' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

test_rule "public enum with annotated constants and trailing comma" => (
	data => <<'EODATA',
public enum Foo {
	@marker BAR,
	@marker BAZ,
}
EODATA
	expect => expect_element ('CSI::Language::Java::Enum::Declaration' => (
		expect_modifier_public,
		expect_word_enum,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Enum::Body' => (
			expect_token_brace_open,
			expect_element ('CSI::Language::Java::Enum::Constant' => (
				expect_annotation ([qw[ marker ]]),
				expect_token ('CSI::Language::Java::Enum::Constant::Name' => 'BAR'),
			)),
			expect_token_comma,
			expect_element ('CSI::Language::Java::Enum::Constant' => (
				expect_annotation ([qw[ marker ]]),
				expect_token ('CSI::Language::Java::Enum::Constant::Name' => 'BAZ'),
			)),
			expect_token_comma,
			expect_token_brace_close,
		)),
	)),
);

had_no_warnings;

done_testing;
