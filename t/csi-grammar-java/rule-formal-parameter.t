#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'formal_parameter';

plan tests => 2;

test_rule "formal parameter / array" => (
	data   => 'char chars[]',
	expect => expect_element ('::Parameter' => (
		expect_type_char,
		expect_variable_name ('chars'),
		expect_array_dimension,
	)),
);

had_no_warnings;

done_testing;
