#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'annotations';

plan tests => 6;

test_rule "annotation / marker annotation / single namespace identifier" => (
	data   => '@foo',
	expect => [
		expect_annotation (
			[qw[ foo ]],
		),
	],
);

test_rule "annotation / marker annotation / qualified identifier" => (
	data   => '@foo.bar.baz',
	expect => [
		expect_annotation (
			[qw[ foo bar baz ]],
		),
	],
);

test_rule "annotation / marker annotation / multiple annotations" => (
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

test_rule "annotation / single element annotation" => (
	data   => <<'EODATA',
@JsonPropertyOrder({ "timestamp", "name" })
EODATA
	expect => [
		expect_annotation (
			[qw[ JsonPropertyOrder ]],
			expect_element ('CSI::Language::Java::Element::Value::Array' => (
				expect_token_brace_open,
				expect_literal_string ("timestamp"),
				expect_token_comma,
				expect_literal_string ("name"),
				expect_token_brace_close,
			)),
		),
	],
);

test_rule "annotation / normal annotation" => (
	data   => <<'EODATA',
@Foo(bar = "baz")
EODATA
	expect => [
		expect_annotation (
			[qw[ Foo ]],
			expect_element ('CSI::Language::Java::Element::Value::Pair' => (
				expect_identifier ('bar'),
				expect_operator_assign,
				expect_literal_string ("baz"),
			)),
		),
	],
);

had_no_warnings;

done_testing;
