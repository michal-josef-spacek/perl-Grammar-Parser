#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'block_statement';

plan tests => 4;

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

test_rule "lambda / method call" => (
	data => <<'EODATA',
	users.sort((o1, o2) -> strategy.compare(o1.getId(), o2.getId()));
EODATA
	expect => ignore,
);

had_no_warnings;

done_testing;
