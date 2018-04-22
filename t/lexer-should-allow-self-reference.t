#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 3 + 4 + 1;

note "token definition should allow reference of other tokens";

arrange_lexer
	tokens => {
		decrement => qr/ (??{ 'minus' }) (??{ 'minus' }) (?! (??{ 'decrement' }) )/x,
		minus	  => '-',
	},
;

arrange_data '-' x 4;

expect_next_token minus     => (value => '-');
expect_next_token minus     => (value => '-');
expect_next_token decrement => (value => '--');

arrange_data '-' x 5;

expect_next_token minus     => (value => '-');
expect_next_token minus     => (value => '-');
expect_next_token decrement => (value => '--');
expect_next_token minus     => (value => '-');

had_no_warnings;

done_testing;

