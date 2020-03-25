#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'reference';

plan tests => 5;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-PackageOrTypeName";

test_rule "PackageOrTypeName / identifier" => (
	data   => 'simple',
	expect => expect_reference (qw[ simple ]),
);

test_rule "PackageOrTypeName / 'var' as an identifier" => (
	data   => 'var',
	expect => expect_reference (qw[ var ]),
);

test_rule "PackageOrTypeName / qualified identifier" => (
	data   => 'foo.bar.baz',
	expect => expect_reference (qw[ foo bar baz ]),
);

test_rule "PackageOrTypeName / 'var' as a part of qualified identifier" => (
	data   => 'var.var.var',
	expect => expect_reference (qw[ var var var ]),
);

had_no_warnings;

done_testing;
