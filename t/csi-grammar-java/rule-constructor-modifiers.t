#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'constructor_modifiers';

plan tests => 6;

test_rule "constructor modifiers / private" => (
	data => 'private',
	expect => [
		expect_modifiers (
			expect_modifier_private,
		),
	],
);

test_rule "constructor modifiers / protected" => (
	data => 'protected',
	expect => [
		expect_modifiers (
			expect_modifier_protected,
		),
	],
);

test_rule "constructor modifiers / public" => (
	data => 'public',
	expect => [
		expect_modifiers (
			expect_modifier_public,
		),
	],
);

test_rule "constructor modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "constructor modifiers / multiple modifiers" => (
	data => 'public @foo',
	expect => [
		expect_modifiers (
			expect_modifier_public,
			expect_annotation ([qw[ foo ]]),
		),
	],
);

had_no_warnings;

done_testing;
