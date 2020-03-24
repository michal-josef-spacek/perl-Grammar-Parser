#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'method_reference';

plan tests => 8;

test_rule "method reference / class method" => (
	data => 'String::equals',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_type_class ([qw[ String ]]),
		expect_token_double_colon,
		expect_method_name ('equals'),
	))
);

test_rule "method reference / class with type arguments method" => (
	data => 'Foo<>::equals',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_type_class ([qw[ Foo ]], type_arguments => []),
		expect_token_double_colon,
		expect_method_name ('equals'),
	))
);

test_rule "method reference / qualified class method" => (
	data => 'Map.Entry::getKey',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_type_class ([qw[ Map Entry ]]),
		expect_token_double_colon,
		expect_method_name ('getKey'),
	))
);

test_rule "method reference / instance method reference" => (
	data => 'this::method',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_element ('CSI::Language::Java::Expression::This' => (
			expect_word_this,
		)),
		expect_token_double_colon,
		expect_method_name ('method'),
	)),
);

test_rule "method reference / super method reference" => (
	data => 'super::method',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_word_super,
		expect_token_double_colon,
		expect_method_name ('method'),
	)),
);

test_rule "method reference / class constructor" => (
	data => 'String::new',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_class_type ([qw[ String ]]),
		expect_token_double_colon,
		expect_word_new,
	))
);

test_rule "method reference / array  constructor" => (
	data => 'String[]::new',
	expect => expect_element ('CSI::Language::Java::Method::Reference' => (
		expect_array_type ([ expect_type_class ([qw[ String ]]) ]),
		expect_token_double_colon,
		expect_word_new,
	))
);

had_no_warnings;

done_testing;
