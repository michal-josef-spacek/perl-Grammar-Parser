#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'type_reference';

plan tests => 7;

test_rule "type reference / single identifier" => (
	data => 'simple',
	expect => expect_reference (
		'simple',
	),
	expectation_expanded => expect_element ('CSI::Language::Java::Reference' => (
		expect_identifier ('simple'),
	)),
);

test_rule "type reference - qualified identifier" => (
	data   => 'com.var.foo',
	expect => expect_reference (
		'com',
		'var',
		'foo',
	),
	expectation_expanded => expect_element ('CSI::Language::Java::Reference' => (
		expect_identifier ('com'),
		expect_token_dot,
		expect_identifier ('var'),
		expect_token_dot,
		expect_identifier ('foo'),
	)),
);

test_rule "type reference / single identifier 'var' is not allowed" => (
	data => 'var',
	throws => 1,
);

test_rule "type reference / qualified 'var' is not allowed" => (
	data => 'com.foo.var',
	throws => 1,
);

had_no_warnings;

done_testing;
