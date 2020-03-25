#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use utf8;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'reference';

plan tests => 7;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-AmbiguousName";

test_rule "AmbiguousName / identifier" => (
	data   => 'simple',
	expect => expect_reference (qw[ simple ]),
);

test_rule "AmbiguousName / identifier with currency symbol" => (
	data   => 'x$simple',
	expect => expect_reference (qw[ x$simple ]),
);

test_rule "AmbiguousName / identifier starting with keyword followed by currency symbol" => (
	data   => 'do$simple',
	expect => expect_reference (qw[ do$simple ]),
);

test_rule "AmbiguousName / 'var' as an identifier" => (
	data   => 'var',
	expect => expect_reference (qw[ var ]),
);

test_rule "AmbiguousName / qualified identifier" => (
	data   => 'foo.bar.baz',
	expect => expect_reference (qw[ foo bar baz ]),
);

test_rule "AmbiguousName / 'var' as a part of qualified identifier" => (
	data   => 'var.var.var',
	expect => expect_reference (qw[ var var var ]),
);

had_no_warnings;

done_testing;
