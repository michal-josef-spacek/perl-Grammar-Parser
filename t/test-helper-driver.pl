
use v5.14;
use strict;
use warnings;

BEGIN { require "test-helper-common.pl" }

sub behaves_like_grammar_parser_driver_with_calc_rpn {
	require "fixtures/calc-rpn-grammar.pl";

	proclaim 'driver-instance' => deduce 'calc-rpn-instance';

	plan tests => 1;

	it "should parse simple RPN expression using ${\ deduce 'driver-package' }" => (
		args   => [ '1 3 2 - +' ],
		expect => {
			expression => {
				number => '1',
				operator => 'add',
				expression => {
					number => '3',
					operator => 'sub',
					expression => { number => '2' },
				},
			},
		},
	);
}

sub behaves_like_grammar_parser_driver {
	my ($driver) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	act { deduce ('driver-instance')->parse (@_) };

	test_frame {
		proclaim 'driver-package' => $driver;

		behaves_like_grammar_parser_driver_with_calc_rpn;
	};
}

1;


