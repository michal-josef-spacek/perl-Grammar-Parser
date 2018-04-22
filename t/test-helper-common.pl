
use strict;
use warnings;
use utf8;

use Test::More;
use Test::Deep;
use Test::Exception qw[];
use Test::Warnings qw[ :no_end_test had_no_warnings ];

# Similar to Test::Exception except it uses Test::Deep
sub throws_ok (&$;$) {
	my ($coderef, $expected, @message) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = Test::Exception::_try_as_caller ($coderef);

	cmp_deeply $got, $expected, @message;
}

1;
