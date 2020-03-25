#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'type_reference';

plan tests => 6;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-6.html#jls-TypeName";

test_rule "TypeName / identifier" => (
	data   => 'simple',
	expect => expect_reference (qw[ simple ]),
);

test_rule "TypeName / 'var' is not allowed as a type name" => (
	data   => 'var',
	throws => 1,
);

test_rule "TypeName / qualified identifier" => (
	data   => 'foo.bar.baz',
	expect => expect_reference (qw[ foo bar baz ]),
);

test_rule "TypeName / 'var' can be part of reference qualification" => (
	data   => 'var.var.baz',
	expect => expect_reference (qw[ var var baz ]),
);

test_rule "TypeName / qualified 'var' is not allowed as a type name" => (
	data   => 'foo.bar.var',
	throws => 1,
);

had_no_warnings;

done_testing;
