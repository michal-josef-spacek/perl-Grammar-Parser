#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'variable_type';

plan tests => 7;

test_rule "var" => (
	data => 'var',
	expect => [
		expect_word_var,
	],
);

test_rule "primitive type" => (
	data => 'float',
	expect => [
		expect_type_float,
	],
);

test_rule "reference type / simple reference" => (
	data => 'Foo',
	expect => [
		expect_type_class ([qw[ Foo ]]),
	],
);

test_rule "reference type / with type arguments" => (
	data => 'Foo<Bar>',
	expect => [
		expect_type_class (
			[qw[ Foo ]],
			type_arguments => [ expect_type_class ([qw[ Bar ]]) ],
		),
	],
);

test_rule "reference type / inner class" => (
	data => 'Foo.Inner',
	expect => [
		expect_type_class (
			[qw[ Foo Inner ]],
		),
	],
);

test_rule "reference type / with type arguments / inner class" => (
	data => 'Foo<Bar>.Inner',
	expect => [
		expect_element ('::Type::Class' => (
			expect_identifier ('Foo'),
			expect_type_arguments (expect_type_class ([qw[ Bar ]])),
			expect_token_dot,
			expect_identifier ('Inner'),
		)),
	],
);

had_no_warnings;

done_testing;
