#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'constant_modifiers';

plan tests => 6;

test_rule "constant modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "constant modifiers / final" => (
	data => 'final',
	expect => [
		expect_modifiers (
			expect_modifier_final,
		),
	],
);

test_rule "constant modifiers / static" => (
	data => 'static',
	expect => [
		expect_modifiers (
			expect_modifier_static,
		),
	],
);

test_rule "constant modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "constant modifiers / multiple modifiers" => (
	data => 'public @foo@bar static @baz final',
	expect => [
		expect_modifiers (
			expect_modifier_public,
			expect_annotation ([qw[ foo ]]),
			expect_annotation ([qw[ bar ]]),
			expect_modifier_static,
			expect_annotation ([qw[ baz ]]),
			expect_modifier_final,
		),
	],
);

had_no_warnings;

done_testing;
