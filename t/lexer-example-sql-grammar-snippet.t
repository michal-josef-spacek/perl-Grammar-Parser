#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-lexer.pl" }

plan tests => 6;

note 'Snippet of real-live lexer (SQL grammar) - with keywords, addressing named regexes, and case insensitivity';

# small grammar based on SQL grammar
arrange_lexer
	tokens => {
		whitespace  => qr/(?> \s+ )/x,
		comment_sql => qr/(?> --.*(??{ 'end_of_line' }) )/x,
		comment_c   => qr/(?> (??{ 'comment_c_start' }) (?s:.*?) (??{ 'comment_c_end' }) )/x,
		CREATE      => qr/(?> \b CREATE \b)/xi,
		OR          => qr/(?> \b OR \b)/xi,
		REPLACE     => qr/(?> \b REPLACE \b)/xi,
		TABLE       => qr/(?> \b TABLE \b)/xi,
		identifier  => qr/(?> (?! (??{ 'keyword' }) ) (?! \d ) (\w+) \b )/x,
	},
	patterns => {
		end_of_line     => qr/ (?= [\r\n] ) \r? \n? /x,
		comment_c_start => qr/ \/\* /x,
		comment_c_end   => qr/ \*\/ /x,
		keyword         => [
			\ 'CREATE',
			\ 'OR',
			\ 'REPLACE',
			\ 'TABLE',
		],
	},
	insignificant => [
		qw[ whitespace ],
		qw[ comment_sql ],
		qw[ comment_c ],
	],
;

arrange_data <<'EODATA';
	-- SQL comment (insignificant by default)
	/* C comment (insignificant by default) */

	CREATE or rEPLACE TEMPORARY TABLE foo
EODATA

expect_next_token CREATE     => (value => 'CREATE');
expect_next_token OR         => (value => 'or');
expect_next_token REPLACE    => (value => 'rEPLACE');
expect_next_token identifier => (value => 'TEMPORARY');
expect_next_token TABLE      => (value => 'TABLE');
expect_next_token identifier => (value => 'foo');

done_testing;

