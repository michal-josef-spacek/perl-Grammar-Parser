#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'block_statement';

plan tests => 3;

test_rule "variable initialization with assignment" => (
	data => <<'EODATA',
int start = drainIndex = drainIndex % parts.size();
EODATA
	expect => ignore,
);

test_rule "assign lambda" => (
	data => <<'EODATA',
variable = () -> { };
EODATA
	expect => ignore,
);

had_no_warnings;

done_testing;
