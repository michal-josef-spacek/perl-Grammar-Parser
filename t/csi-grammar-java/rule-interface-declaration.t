#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'interface_declaration';

plan tests => 3;

test_rule "marker interface" => (
	data => <<'EODATA',
public interface Foo {
}
EODATA
	expect => expect_element ('CSI::Language::Java::Interface::Declaration' => (
		expect_modifiers (
			expect_modifier_public,
		),
		expect_word_interface,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Interface::Body' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

test_rule "interface with methods" => (
	data => <<'EODATA',
public interface Foo {
	public void foo ();
	public default void bar () { }
}
EODATA
	expect => expect_element ('CSI::Language::Java::Interface::Declaration' => (
		expect_modifier_public,
		expect_word_interface,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Interface::Body' => (
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
					expect_token_semicolon,
				)),
			)),
			expect_element ('CSI::Language::Java::Method::Declaration' => (
				expect_modifier_public,
				expect_modifier_default,
				expect_element ('CSI::Language::Java::Method::Result' => (
					expect_word_void,
				)),
				expect_method_name ('bar'),
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
