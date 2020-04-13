#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'interface_declaration';

plan tests => 2;

test_rule "MessageGenerator.processDirectories" => (
	data => <<'EODATA',
public interface Foo {
	String foo = "FOO";
}
EODATA
	expect =>
		expect_element ('CSI::Language::Java::Interface::Declaration' => (
			expect_modifier_public,
			expect_word_interface,
			expect_type_name ('Foo'),
			expect_element ('CSI::Language::Java::Interface::Body' => (
				expect_token_brace_open,
				expect_element ('CSI::Language::Java::Constant::Declaration' => (
					expect_type_string,
					expect_element ('CSI::Language::Java::Variable::Declarator' => (
						expect_element ('CSI::Language::Java::Variable::ID' => (
							expect_variable_name ('foo'),
						)),
						expect_operator_assign,
						expect_literal_string ("FOO"),
					)),
					expect_token_semicolon,
				)),
				expect_token_brace_close,
			)),
		)),
);

had_no_warnings;

done_testing;
