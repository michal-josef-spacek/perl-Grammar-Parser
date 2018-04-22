#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 3 + 1;

note "lexer should provide longest match";

arrange_lexer
	tokens => {
		decrement => '--',
		minus	  => '-',
	},
;

arrange_data '-' x 5;

expect_next_token decrement => (value => '--');
expect_next_token decrement => (value => '--');
expect_next_token minus     => (value => '-');

had_no_warnings;

done_testing;

