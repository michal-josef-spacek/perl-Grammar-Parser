#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'constructor_declaration';

plan tests => 2;

test_rule "default constructor" => (
	data => 'public Foo () { }',
	expect => expect_element ('CSI::Language::Java::Constructor::Declaration' => (
		expect_modifier_public,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::List::Parameters' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_element ('CSI::Language::Java::Constructor::Body' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

had_no_warnings;

done_testing;
