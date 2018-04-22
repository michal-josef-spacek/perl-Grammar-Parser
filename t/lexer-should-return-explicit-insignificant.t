#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

note "Insignificant token are returned only when explicitly requested";

plan tests => 6 + 1;

arrange_lexer
	tokens => {
		whitespace => qr/\s+/,
		plus 	   => '+',
		minus 	   => '-',
		number 	   => qr/\d+/,
	},
	insignificant => [qw[ whitespace ]],
;

arrange_data '1 + 2 - 3';

expect_next_token number => (value => '1');
expect_next_token whitespace => (
	value => ' ',
	significant => 0,
	accept => [ 'whitespace', 'plus' ],
);

expect_next_token plus   => (value => '+');
expect_next_token number => (value => '2');
expect_next_token minus  => (value => '-');
expect_next_token number => (value => '3');

had_no_warnings;

done_testing;

