#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'literal';

plan tests => 7;

test_rule "null literal" => (
	data => 'null',
	expect => [
		expect_literal_null,
	],
);

subtest "boolean literals" => sub {
	plan tests => 2;

	test_rule "boolean literal / false" => (
		data   => 'false',
		expect => [
			expect_literal_false,
		],
	);

	test_rule "boolean literal / true" => (
		data   => 'true',
		expect => [
			expect_literal_true,
		],
	);

	done_testing;
};

subtest "character literals" => sub {
	plan tests => 3;

	test_rule "character literal / with character" => (
		data => "' '",
		expect => [
			expect_literal_character (' '),
		],
	);

	test_rule "character literal / with character escape sequence" => (
		data => "'\\t'",
		expect => [
			expect_literal_character ("\x09"),
		],
	);

	test_rule "character literal / with octal escape" => (
		data => "'\\40'",
		expect => [
			expect_literal_character (' '),
		],
	);

	done_testing;
};

subtest "string literals" => sub {
	plan tests => 3;

	test_rule "string literal / empty string" => (
		data => '""',
		expect => [
			expect_literal_string (""),
		],
	);

	test_rule "string literal / non-empty string" => (
		data => '"non-empty"',
		expect => [
			expect_literal_string ("non-empty"),
		],
	);

	test_rule "string literal / with escape sequences" => (
		data => '"with\40\"escapes\""',
		expect => [
			expect_literal_string ('with "escapes"'),
		],
	);

	done_testing;
};

subtest "integral number literals" => sub {
	plan tests => 8;

	test_rule "integral number / binary" => (
		data => '0b0',
		expect => [
			expect_literal_integral_binary ('0b0'),
		],
	);

	test_rule "integral number / binary, long" => (
		data => '0B0L',
		expect => [
			expect_literal_integral_binary ('0B0L'),
		],
	);

	test_rule "integral number / decimal" => (
		data => '0',
		expect => [
			expect_literal_integral_decimal ('0'),
		],
	);

	test_rule "integral number / decimal, long" => (
		data => '0L',
		expect => [
			expect_literal_integral_decimal ('0L'),
		],
	);

	test_rule "integral number / hex" => (
		data => '0x0',
		expect => [
			expect_literal_integral_hex ('0x0'),
		],
	);

	test_rule "integral number / hex, long" => (
		data => '0X0L',
		expect => [
			expect_literal_integral_hex ('0X0L'),
		],
	);

	test_rule "integral number / octal" => (
		data => '00',
		expect => [
			expect_literal_integral_octal ('00'),
		],
	);

	test_rule "integral number - octal, long" => (
		data => '00L',
		expect => [
			expect_literal_integral_octal ('00L'),
		],
	);

	done_testing;
};

subtest "floating number literals" => sub {
	plan tests => 4;

	test_rule "float literal / decimal / with trailing dot" => (
		data => '0.',
		expect => [
			expect_literal_floating_decimal ('0.'),
		],
	);

	test_rule "float literal / decimal / with type identifier / float" => (
		data => '0f',
		expect => [
			expect_literal_floating_decimal ('0f'),
		],
	);

	test_rule "double literal / decimal / with type identifier / double" => (
		data => '0d',
		expect => [
			expect_literal_floating_decimal ('0d'),
		],
	);

	test_rule "float literal / hex" => (
		data => '0x1p31',
		expect => [
			expect_literal_floating_hex ('0x1p31'),
		],
	);

	done_testing;
};

had_no_warnings;

done_testing;
