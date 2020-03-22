#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'compilation_unit';

plan tests => 2;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-7.html#jls-OrdinaryCompilationUnit";

test_rule "OrdinaryCompilationUnit / with package name" => (
	data   => <<'EODATA',
package foo.bar;
EODATA
	expect => [
		expect_package_declaration ([qw[ foo bar]]),
	],
);

had_no_warnings;

done_testing;
