#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'type_arguments';

plan tests => 5;

test_rule "empty type arguments (aka diamond)" => (
	data => '<>',
	expect => expect_element ('CSI::Language::Java::Type::Arguments' => (
		expect_token_type_list_open,
		expect_token_type_list_close,
	)),
);

test_rule "type argument" => (
	data => '<String>',
	expect => expect_element ('CSI::Language::Java::Type::Arguments' => (
		expect_token_type_list_open,
		expect_class_type ([qw[ String ]]),
		expect_token_type_list_close,
	)),
);

test_rule "multiple type arguments" => (
	data => '<Void, String[]>',
	expect => expect_element ('CSI::Language::Java::Type::Arguments' => (
		expect_token_type_list_open,
		expect_class_type ([qw[ Void ]]),
		expect_token_comma,
		expect_array_type ([expect_type_class ([qw[ String ]])]),
		expect_token_type_list_close,
	)),
);

test_rule "wildcard type arguments" => (
	data => '<? extends Foo, ? super Bar>',
	expect => expect_element ('CSI::Language::Java::Type::Arguments' => (
		expect_token_type_list_open,
		expect_element ('CSI::Language::Java::Type::Wildcard' => (
			expect_token_question_mark,
			expect_word_extends,
			expect_class_type ([qw[ Foo ]]),
		)),
		expect_token_comma,
		expect_element ('CSI::Language::Java::Type::Wildcard' => (
			expect_token_question_mark,
			expect_word_super,
			expect_class_type ([qw[ Bar ]]),
		)),
		expect_token_type_list_close,
	)),
);

had_no_warnings;

done_testing;
