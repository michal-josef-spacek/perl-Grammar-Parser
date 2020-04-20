#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'package_declaration';

plan tests => 4;

test_rule "package declaration with simple package name" => (
	data => 'package foo;',
	expect => expect_package_declaration ([qw[ foo ]]),
);

test_rule "package declaration with qualified package identifier" => (
	data   => 'package foo.bar;',
	expect => expect_package_declaration ([qw[ foo bar]]),
);

test_rule "package declaration with annotation" => (
	data   => '@foo package foo.bar;',
	expect => expect_package_declaration (
		[qw[ foo bar]],
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	),
);

had_no_warnings;

done_testing;
