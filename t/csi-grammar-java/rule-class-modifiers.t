#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_modifiers';

plan tests => 10;

test_rule "class modifiers / private" => (
	data => 'private',
	expect => [
		expect_modifiers (
			expect_modifier_private,
		),
	],
);

test_rule "class modifiers / protected" => (
	data => 'protected',
	expect => [
		expect_modifiers (
			expect_modifier_protected,
		),
	],
);

test_rule "class modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "class modifiers / abstract" => (
	data => 'abstract',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
		),
	],
);

test_rule "class modifiers / final" => (
	data => 'final',
	expect => [
		expect_modifiers (
			expect_modifier_final,
		)
	],
);

test_rule "class modifiers / static" => (
	data => 'static',
	expect => [
		expect_modifiers (
			expect_modifier_static,
		),
	],
);

test_rule "class modifiers / strictfp" => (
	data => 'strictfp',
	expect => [
		expect_modifiers (
			expect_modifier_strictfp,
		),
	],
);

test_rule "class modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "class modifiers / multiple modifiers" => (
	data => 'abstract @foo@bar public @baz static strictfp final',
	expect => [
		expect_modifiers (
			expect_modifier_abstract,
			expect_annotation ([qw[ foo ]]),
			expect_annotation ([qw[ bar ]]),
			expect_modifier_public,
			expect_annotation ([qw[ baz ]]),
			expect_modifier_static,
			expect_modifier_strictfp,
			expect_modifier_final,
		),
	],
);

had_no_warnings;

done_testing;
