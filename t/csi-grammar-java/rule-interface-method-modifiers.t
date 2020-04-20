#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'interface_method_modifiers';

plan tests => 9;

test_rule "interface method modifiers / private" => (
	data => 'private',
	expect => [
		expect_modifiers (
			expect_modifier_private,
		),
	],
);

test_rule "interface method modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "interface method modifiers / abstract" => (
	data => 'abstract',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
		),
	],
);

test_rule "interface method modifiers / default" => (
	data => 'default',
	expect => [
		expect_modifiers (
			expect_modifier_default,
		),
	],
);

test_rule "interface method modifiers / static" => (
	data => 'static',
	expect => [
		expect_modifiers (
			expect_modifier_static,
		),
	],
);

test_rule "interface method modifiers / strictfp" => (
	data => 'strictfp',
	expect => [
		expect_modifiers (
			expect_modifier_strictfp,
		),
	],
);

test_rule "interface method modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "interface method modifiers / multiple modifiers" => (
	data => 'public @foo@bar static @baz default',
	expect => [
		expect_modifiers (
			expect_modifier_public,
			expect_annotation ([qw[ foo ]]),
			expect_annotation ([qw[ bar ]]),
			expect_modifier_static,
			expect_annotation ([qw[ baz ]]),
			expect_modifier_default,
		),
	],
);

had_no_warnings;

done_testing;
