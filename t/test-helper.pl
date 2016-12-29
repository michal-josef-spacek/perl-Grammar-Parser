
use v5.14;
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Context::Singleton;

sub describe {
	my ($title, $test) = @_;

	frame { subtest $title => $test };
}

sub context {
	my ($title, $test) = @_;

	frame { subtest $title => $test }
}

sub is_deduce {
	my ($title, %params) = @_;
	my $deduce = delete $params{deduce};
	my $expect = delete $params{expect};
	my $got = deduce $deduce => %params;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	cmp_deeply $got, $expect, $title;
}

1;
