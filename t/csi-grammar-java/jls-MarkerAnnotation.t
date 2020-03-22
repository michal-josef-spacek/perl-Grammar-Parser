#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'annotation';

plan tests => 6;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-MarkerAnnotation";

test_rule "MarkerAnnotation / identifier" => (
	data   => '@ foo',
	expect => expect_annotation ([qw[ foo ]]),
);

test_rule "MarkerAnnotation / 'var' is prohibited annotation reference" => (
	data   => '@ var',
	throws => 1,
);

test_rule "MarkerAnnotation / qualified identifier" => (
	data   => '@ foo.bar.baz',
	expect => expect_annotation ([qw[ foo bar baz ]]),
);

test_rule "MarkerAnnotation / 'var' is allowed as annotation reference qualification" => (
	data   => '@ foo.var.baz',
	expect => expect_annotation ([qw[ foo var baz ]]),
);

test_rule "MarkerAnnotation / qualified 'var' is prohibited annotation reference" => (
	data   => '@ foo.bar.var',
	throws => 1,
);

had_no_warnings;

done_testing;
