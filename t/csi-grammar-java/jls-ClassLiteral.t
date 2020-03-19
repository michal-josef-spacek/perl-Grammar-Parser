#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_literal';

plan tests => 12;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-15.html#jls-ClassLiteral";

test_rule "ClassLiteral / primitive numeric type" => (
	data   => 'int.class',
	expect => expect_literal_class (expect_type_int),
);

test_rule "ClassLiteral / primitive numeric type / array" => (
	data   => 'int[].class',
	expect => expect_literal_class (
		expect_type_int,
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
	),
);

test_rule "ClassLiteral / primitive numeric type / array / multidimensional" => (
	data   => 'int[][].class',
	expect => expect_literal_class (
		expect_type_int,
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
	),
);

test_rule "ClassLiteral / primitive boolean type" => (
	data   => 'boolean.class',
	expect => expect_literal_class (expect_type_boolean),
);

test_rule "ClassLiteral / primitive boolean type / array" => (
	data   => 'boolean[].class',
	expect => expect_literal_class (
		expect_type_boolean,
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
	),
);

test_rule "ClassLiteral / primitive boolean type / array / multidimensional" => (
	data   => 'boolean[][].class',
	expect => expect_literal_class (
		expect_type_boolean,
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
	),
);

test_rule "ClassLiteral / reference type" => (
	data   => 'String.class',
	expect => expect_literal_class (expect_reference ([qw[ String ]])),
);

test_rule "ClassLiteral / reference type / array" => (
	data   => 'String[].class',
	expect => expect_literal_class (
		expect_reference ([qw[ String ]]),
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
	),
);

test_rule "ClassLiteral / reference type / array / multidimensional" => (
	data   => 'String[][].class',
	expect => expect_literal_class (
		expect_reference ([qw[ String ]]),
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
		expect_element ('::Literal::Class::Dim' => (
			expect_token_bracket_open,
			expect_token_bracket_close,
		)),
	),
);

test_rule "ClassLiteral / void" => (
	data   => 'void.class',
	expect => expect_literal_class (expect_word_void),
);

test_rule "ClassLiteral / 'var' is not allowed as a type name" => (
	data   => 'var.class',
	throws => 1,
);

had_no_warnings;

done_testing;
