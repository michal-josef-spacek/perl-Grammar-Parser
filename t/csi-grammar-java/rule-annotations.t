#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'annotations';

plan tests => 4;

test_rule "marker annotation / single namespace identifier" => (
	data   => '@foo',
	expect => [
		expect_annotation (
			[qw[ foo ]],
		),
	],
);

test_rule "marker annotation / qualified identifier" => (
	data   => '@foo.bar.baz',
	expect => [
		expect_annotation (
			[qw[ foo bar baz ]],
		),
	],
);

test_rule "marker annotation / multiple annotations" => (
	data   => '@foo@foo.bar.baz@baz',
	expect => [
		expect_annotation (
			[qw[ foo ]],
		),
		expect_annotation (
			[qw[ foo bar baz ]],
		),
		expect_annotation (
			[qw[ baz ]],
		),
	],
);

had_no_warnings;

done_testing;
