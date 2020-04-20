#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'method_modifiers';

plan tests => 12;

test_rule "method modifiers / private" => (
	data => 'private',
	expect => [
		expect_modifiers (
			expect_modifier_private,
		),
	],
);

test_rule "method modifiers / protected" => (
	data => 'protected',
	expect => [
		expect_modifiers (
			expect_modifier_protected,
		),
	],
);

test_rule "method modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "method modifiers / abstract" => (
	data => 'abstract',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
		),
	],
);

test_rule "method modifiers / final" => (
	data => 'final',
	expect => [
		expect_modifiers (
			expect_modifier_final,
		),
	],
);

test_rule "method modifiers / native" => (
	data => 'native',
	expect => [
		expect_modifiers (
			expect_modifier_native,
		),
	],
);

test_rule "method modifiers / static" => (
	data => 'static',
	expect => [
		expect_modifiers (
			expect_modifier_static,
		),
	],
);

test_rule "method modifiers / strictfp" => (
	data => 'strictfp',
	expect => [
		expect_modifiers (
			expect_modifier_strictfp,
		),
	],
);

test_rule "method modifiers / synchronized" => (
	data => 'synchronized',
	expect => [
		expect_modifiers (
			expect_modifier_synchronized,
		),
	],
);

test_rule "method modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "method modifiers / multiple modifiers" => (
	data => 'abstract @foo@bar public@baz static native synchronized final',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
			expect_annotation ([qw[ foo ]]),
			expect_annotation ([qw[ bar ]]),
			expect_modifier_public,
			expect_annotation ([qw[ baz ]]),
			expect_modifier_static,
			expect_modifier_native,
			expect_modifier_synchronized,
			expect_modifier_final,
		),
	],
);

had_no_warnings;

done_testing;
