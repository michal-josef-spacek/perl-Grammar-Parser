#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'data_type';

plan tests => 4;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-8.html#jls-UnannType";

subtest "UnannType / primitive type" => sub {
	plan tests => 8;

	test_rule "UnannType / primitive type / boolean" => (
		data   => 'boolean',
		expect => [ expect_type_boolean ],
	);

	test_rule "UnannType / primitive type / byte" => (
		data   => 'byte',
		expect => [ expect_type_byte ],
	);

	test_rule "UnannType / primitive type / char" => (
		data   => 'char',
		expect => [ expect_type_char ],
	);

	test_rule "UnannType / primitive type / double" => (
		data   => 'double',
		expect => [ expect_type_double ],
	);

	test_rule "UnannType / primitive type / float" => (
		data   => 'float',
		expect => [ expect_type_float ],
	);

	test_rule "UnannType / primitive type / int" => (
		data   => 'int',
		expect => [ expect_type_int ],
	);

	test_rule "UnannType / primitive type / long" => (
		data   => 'long',
		expect => [ expect_type_long ],
	);

	test_rule "UnannType / primitive type / short" => (
		data   => 'short',
		expect => [ expect_type_short ],
	);

	done_testing;
};

subtest "UnannType / reference type / array type" => sub {
	plan tests => 3;

	test_rule "UnannType / reference type / array type / one dimensional" => (
		data => 'int[]',
		expect => [ expect_type_array ([ expect_type_int ]) ],
	);

	test_rule "UnannType / reference type / array type / multi-dimensional dimensional" => (
		data => 'int[][][]',
		expect => [ expect_type_array ([[[ expect_type_int ]]]) ],
	);

	test_rule "UnannType / reference type / array type / reference type" => (
		data => 'Foo<>[]',
		expect => [ expect_type_array ([
			expect_element ('::Type::Class' => (
				expect_identifier ('Foo'),
				expect_type_arguments,
			)),
		]) ],
	);

	done_testing;
};

subtest "UnannType / reference type / class type" => sub {
	plan tests => 2;

	test_rule "UnannType / reference type / class type / short class type" => (
		data => 'String',
		expect => [ expect_type_string ],
	);

	test_rule "UnannType / reference type / class type / qualified class type" => (
		data => 'java.lang.String',
		expect => [ expect_type_class ([qw[ java lang String ]]) ],
	);

	done_testing;
};

had_no_warnings;

done_testing;
