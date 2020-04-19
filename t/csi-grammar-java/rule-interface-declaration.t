#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'interface_declaration';

plan tests => 2;

test_rule "empty public interface" => (
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

had_no_warnings;

done_testing;
