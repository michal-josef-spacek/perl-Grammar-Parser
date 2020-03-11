#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_implements';

plan tests => 3;

test_rule "class implements" => (
	data => 'implements Foo, Bar, foo.bar.Baz',
	expect => expect_class_implements (
		[[qw[ Foo ]]],
		[[qw[ Bar ]]],
		[[qw[ foo bar Baz ]]],
	),
	expectation_expanded => expect_element ('CSI::Language::Java::Class::Implements' => (
		expect_word_implements,
		expect_class_type ([qw[ Foo ]]),
		expect_token_comma,
		expect_class_type ([qw[ Bar ]]),
		expect_token_comma,
		expect_class_type ([qw[ foo bar Baz ]]),
	)),
);

had_no_warnings;

done_testing;
