#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 5 + 1;

note 'Lexer should skip any insignificant token found in input sequence';

arrange_lexer
	tokens => {
		whitespace => qr/\s+/,
		plus => '+',
		minus => '-',
		number => qr/\d+/,
	},
	insignificant => [qw[ whitespace ]],
;

arrange_data '1 + 2 - 3';

expect_next_token number => (value => '1');
expect_next_token plus   => (value => '+');
expect_next_token number => (value => '2');
expect_next_token minus  => (value => '-');
expect_next_token number => (value => '3');

had_no_warnings;

done_testing;

