#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'field_modifiers';

plan tests => 10;

test_rule "field modifiers / private" => (
	data => 'private',
	expect => [
		expect_modifiers (
			expect_modifier_private,
		),
	],
);

test_rule "field modifiers / protected" => (
	data => 'protected',
	expect => [
		expect_modifiers (
			expect_modifier_protected,
		),
	],
);

test_rule "field modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "field modifiers / final" => (
	data => 'final',
	expect => [
		expect_modifiers (
			expect_modifier_final,
		),
	],
);

test_rule "field modifiers / static" => (
	data => 'static',
	expect => [
		expect_modifiers (
			expect_modifier_static,
		),
	],
);

test_rule "field modifiers / transient" => (
	data => 'transient',
	expect => [
		expect_modifiers (
			expect_modifier_transient,
		),
	],
);

test_rule "field modifiers / volatile" => (
	data => 'volatile',
	expect => [
		expect_modifiers (
			expect_modifier_volatile,
		),
	],
);

test_rule "field modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "field modifiers / multiple modifiers" => (
	data => 'public @foo@bar static @baz transient volatile final',
	expect => [
		expect_modifiers (
			expect_modifier_public,
			expect_annotation ([qw[ foo ]]),
			expect_annotation ([qw[ bar ]]),
			expect_modifier_static,
			expect_annotation ([qw[ baz ]]),
			expect_modifier_transient,
			expect_modifier_volatile,
			expect_modifier_final,
		),
	],
);

had_no_warnings;

done_testing;
