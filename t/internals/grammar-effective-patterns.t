#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";

BEGIN { require "test-helper-common.pl" }

use Grammar::Parser::Grammar;

plan tests => 2 + 1;

note <<'';
Grammar::Parser::Grammar supports named regex patterns
and recognize their dependencies while building effective grammar

my $grammar = Grammar::Parser::Grammar->new (
	grammar => {
		integer => qr/\b (??{ 'number' }) \b/sx,
		float   => qr/\b (??{ 'number' }) \. (??{ 'number' }) \b/sx,
		CREATE  => qr/\b CREATE \b/sxi,
		TABLE   => qr/\b TABLE  \b/sxi,
		identifier => qr/\b (?! (??{ 'keyword' }) ) (?! \d ) \w+ \b/sxi,

		number  => \ qr/\b \d+ \b/sx,
		keyword => \ [
			\ 'CREATE',
			\ 'TABLE',
		],

		full    => [qw[ identifier integer ]],
		partial => [qw[ CREATE TABLE integer ]],
	},
	start => 'full',
);

cmp_deeply "full grammar list_patterns() should report all referenced patterns",
	got    => [ $grammar->list_patterns ],
	expect => bag(qw[ number keyword ]),
;

my $partial = $grammar->clone (start => 'partial');

cmp_deeply "partial grammar list_patterns() should report only referenced pattern",
	got    => [ $partial->list_patterns ],
	expect => bag(qw[ number ]),
;

had_no_warnings;

done_testing;

