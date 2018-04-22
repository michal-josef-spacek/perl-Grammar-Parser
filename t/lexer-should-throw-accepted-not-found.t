#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 4 + 1;

note "Lexer should throw an exception when requested token is not found";

arrange_lexer
	tokens => {
		minus	  => '-',
		plus	  => '+',
		zero	  => '0',
	},
;

arrange_data '0-+';

expect_next_token zero      => (value => '0');
expect_next_token plus      => (throws => obj_isa ('Grammar::Parser::X::Lexer::Notfound'));

note "after exception data position should still remain";
expect_next_token minus     => (value => '-');
expect_next_token plus      => (value => '+');

had_no_warnings;

done_testing;

