#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 4;

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

had_no_warnings;

done_testing;
