#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'reference';

plan tests => 5;

test_rule "reference / identifier" => (
	data   => 'simple',
	expect => expect_reference (qw[ simple ]),
);

test_rule "reference / 'var' as an identifier" => (
	data   => 'var',
	expect => expect_reference (qw[ var ]),
);

test_rule "reference / qualified identifier" => (
	data   => 'foo.bar.baz',
	expect => expect_reference (qw[ foo bar baz ]),
);

test_rule "reference / 'var' as qualified identifier" => (
	data   => 'var.var.var',
	expect => expect_reference (qw[ var var var ]),
);

had_no_warnings;

done_testing;
