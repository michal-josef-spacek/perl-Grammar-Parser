#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expressions';

plan tests => 8;

test_rule "method invocation / without invocant" => (
	data => 'foo()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_method_name ('foo'),
			expect_arguments,
		)),
	],
);

test_rule "method invocation / with invocant / this" => (
	data => 'this.foo()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_element ('CSI::Language::Java::Expression::This' => (
					expect_word_this,
				)),
			)),
			expect_token_dot,
			expect_method_name ('foo'),
			expect_arguments,
		)),
	],
);

test_rule "method invocation / with invocant / super" => (
	data => 'super.foo()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_word_super,
			)),
			expect_token_dot,
			expect_method_name ('foo'),
			expect_arguments,
		)),
	],
);

test_rule "method invocation / with invocant / identifier" => (
	data => 'instance.foo()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_reference (qw[ instance ]),
			)),
			expect_token_dot,
			expect_method_name ('foo'),
			expect_arguments,
		)),
	],
);

test_rule "method invocation / with invocant / qualified identifier" => (
	data => 'Map.Entry.foo()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_reference (qw[ Map Entry ]),
			)),
			expect_token_dot,
			expect_method_name ('foo'),
			expect_arguments,
		)),
	],
);

test_rule "method invocation / with invocant / with type arguments" => (
	data => 'Collections.<String>emptyList()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_reference (qw[ Collections ]),
			)),
			expect_token_dot,
			expect_type_arguments (
				expect_class_type ([qw[ String ]]),
			),
			expect_method_name ('emptyList'),
			expect_arguments,
		)),
	],
);

test_rule "method invocation / with invocant / method call" => (
	data => 'foo().bar()',
	expect => [
		expect_element ('CSI::Language::Java::Method::Invocation' => (
			expect_element ('CSI::Language::Java::Method::Invocant' => (
				expect_element ('CSI::Language::Java::Method::Invocation' => (
					expect_method_name ('foo'),
					expect_element ('CSI::Language::Java::Arguments' => (
						expect_token_paren_open,
						expect_token_paren_close,
					)),
				)),
			)),
			expect_token_dot,
			expect_method_name ('bar'),
			expect_arguments,
		)),
	],
);

had_no_warnings;

done_testing;
