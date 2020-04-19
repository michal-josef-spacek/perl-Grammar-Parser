#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'type_parameters';

plan tests => 5;

test_rule "single type parameter" => (
	data => '<T>',
	expect => expect_element ('CSI::Language::Java::Type::Parameters' => (
		expect_token_type_list_open,
		expect_element ('CSI::Language::Java::Type::Parameter' => (
			expect_identifier ('T'),
		)),
		expect_token_type_list_close,
	)),
);

test_rule "multiple type parameters" => (
	data => '<T, V>',
	expect => expect_element ('CSI::Language::Java::Type::Parameters' => (
		expect_token_type_list_open,
		expect_element ('CSI::Language::Java::Type::Parameter' => (
			expect_identifier ('T'),
		)),
		expect_token_comma,
		expect_element ('CSI::Language::Java::Type::Parameter' => (
			expect_identifier ('V'),
		)),
		expect_token_type_list_close,
	)),
);

test_rule "type parameter with type bound" => (
	data => '<T extends Foo.Bar>',
	expect => expect_element ('CSI::Language::Java::Type::Parameters' => (
		expect_token_type_list_open,
		expect_element ('CSI::Language::Java::Type::Parameter' => (
			expect_identifier ('T'),
			expect_element ('CSI::Language::Java::Type::Bound' => (
				expect_word_extends,
				expect_class_type ([qw[ Foo Bar ]]),
			)),
		)),
		expect_token_type_list_close,
	)),
);

test_rule "type parameter with multiple type bounds" => (
	data => '<T extends Foo.Bar & Bar.Foo & Baz>',
	expect => expect_element ('CSI::Language::Java::Type::Parameters' => (
		expect_token_type_list_open,
		expect_element ('CSI::Language::Java::Type::Parameter' => (
			expect_identifier ('T'),
			expect_element ('CSI::Language::Java::Type::Bound' => (
				expect_word_extends,
				expect_class_type ([qw[ Foo Bar ]]),
				expect_operator_binary_and,
				expect_class_type ([qw[ Bar Foo ]]),
				expect_operator_binary_and,
				expect_class_type ([qw[ Baz ]]),
			)),
		)),
		expect_token_type_list_close,
	)),
);

had_no_warnings;

done_testing;
