#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 6;

test_rule "primary expression / literal / null" => (
	data => 'null',
	expect => [ expect_literal_null ],
);

test_rule "primary expression / literal / integer number" => (
	data => '0L',
	expect => [ expect_literal_integral_decimal ('0L') ],
);

test_rule "primary expression / class literal" => (
	data => 'String.class',
	expect => [ expect_literal_class (expect_reference ([qw[ String ]])) ]
);

test_rule "primary expression / group expression" => (
	data => '(null)',
	expect => [
		expect_token_paren_open,
		expect_literal_null,
		expect_token_paren_close,
	],
);

test_rule "primary expression / double-group expression" => (
	data => '((null))',
	expect => [
		expect_token_paren_open,
		expect_token_paren_open,
		expect_literal_null,
		expect_token_paren_close,
		expect_token_paren_close,
	],
);

had_no_warnings;

done_testing;
