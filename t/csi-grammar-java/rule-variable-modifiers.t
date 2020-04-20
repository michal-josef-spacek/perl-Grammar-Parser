#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'variable_modifiers';

plan tests => 4;

test_rule "variable modifiers / final" => (
	data => 'final',
	expect => [
		expect_modifiers (
			expect_modifier_final,
		),
	],
);

test_rule "variable modifiers / annotation" => (
	data => '@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
		),
	],
);

test_rule "variable modifiers / multiple modifiers" => (
	data => '@foo final@foo',
	expect => [
		expect_modifiers (
			expect_annotation ([qw[ foo ]]),
			expect_modifier_final,
			expect_annotation ([qw[ foo ]]),
		),
	],
);

had_no_warnings;

done_testing;
