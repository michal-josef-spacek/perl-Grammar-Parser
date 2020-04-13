#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_type';

plan tests => 15;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannClassType";

test_rule "UnannClassType / single identifier" => (
	data   => 'simple',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('simple'),
	)),
);

test_rule "UnannClassType / 'var' is prohibited as an class type" => (
	data   => 'var',
	throws => ignore,
);

test_rule "UnannClassType / annotated single identifier" => (
	data   => '@foo@bar simple',
	throws => 1,
);

test_rule "UnannClassType / single identifier with type parameters" => (
	data   => 'simple<>',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('simple'),
		expect_element ('::Type::Arguments' => (
			expect_token_type_list_open,
			expect_token_type_list_close,
		)),
	)),
);

test_rule "UnannClassType / annotated single identifier with type parameters" => (
	data   => '@foo simple<>',
	throws => 1,
);

test_rule "UnannClassType / qualified identifier" => (
	data   => 'foo.bar.baz',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('foo'),
		expect_token_dot,
		expect_identifier ('bar'),
		expect_token_dot,
		expect_identifier ('baz'),
	)),
);

test_rule "UnannClassType / 'var' is allowed as a part of qualification" => (
	data   => 'foo.var.baz',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('foo'),
		expect_token_dot,
		expect_identifier ('var'),
		expect_token_dot,
		expect_identifier ('baz'),
	)),
);

test_rule "UnannClassType / qualified 'var' is not allowed class type" => (
	data   => 'foo.baz.var',
	throws => ignore,
);

test_rule "UnannClassType / annotated qualified identifier" => (
	data   => 'foo.@foo bar.@bar baz',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('foo'),
		expect_token_dot,
		expect_annotation ([qw[ foo ]]),
		expect_identifier ('bar'),
		expect_token_dot,
		expect_annotation ([qw[ bar ]]),
		expect_identifier ('baz'),
	)),
);

test_rule "UnannClassType / qualified identifier with type arguments" => (
	data   => 'foo.bar<>.baz<>.boo',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('foo'),
		expect_token_dot,
		expect_identifier ('bar'),
		expect_type_arguments,
		expect_token_dot,
		expect_identifier ('baz'),
		expect_type_arguments,
		expect_token_dot,
		expect_identifier ('boo'),
	)),
);

test_rule "UnannClassType / annotated qualified identifier with type arguments" => (
	data   => 'foo.@foo bar<>.@bar baz<>.boo',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('foo'),
		expect_token_dot,
		expect_annotation ([qw[ foo ]]),
		expect_identifier ('bar'),
		expect_type_arguments,
		expect_token_dot,
		expect_annotation ([qw[ bar ]]),
		expect_identifier ('baz'),
		expect_type_arguments,
		expect_token_dot,
		expect_identifier ('boo'),
	)),
);

test_rule "UnannClassType / 'var' is not allowed after first annotation" => (
	data   => 'foo.@foo bar.var.boo',
	throws => ignore,
);

test_rule "UnannClassType / 'var' is not allowed after first type arguments" => (
	data   => 'foo.bar<>.var.boo',
	throws => ignore,
);

test_rule "UnannClassType / with type parameters / inner class" => (
	data   => 'simple<>.inner',
	expect => expect_element ('::Type::Class' => (
		expect_identifier ('simple'),
		expect_element ('::Type::Arguments' => (
			expect_token_type_list_open,
			expect_token_type_list_close,
		)),
		expect_token_dot,
		expect_identifier ('inner'),
	)),
);

had_no_warnings;

done_testing;
