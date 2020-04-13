#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'explicit_constructor_invocation';

plan tests => 3;

test_rule "super - parent's constructor" => (
	data => <<'EODATA',
super ();
EODATA
	expect => expect_element ('CSI::Language::Java::Constructor::Invocation' => (
		expect_word_super,
		expect_element ('CSI::Language::Java::Arguments' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_token_semicolon,
	)),
);

test_rule "this - another constructor" => (
	data => <<'EODATA',
this ();
EODATA
	expect => expect_element ('CSI::Language::Java::Constructor::Invocation' => (
		expect_word_this,
		expect_element ('CSI::Language::Java::Arguments' => (
			expect_token_paren_open,
			expect_token_paren_close,
		)),
		expect_token_semicolon,
	)),
);

had_no_warnings;

done_testing;
