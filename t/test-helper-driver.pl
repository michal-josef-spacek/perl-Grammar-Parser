
use v5.14;
use strict;
use warnings;

use Test::More;
use Test::Deep;

use Grammar::Parser::Action::Util qw[ generate_rule_handler generate_action_name ];

sub calc_rpn_grammar {
	my $number_re = qr/
		[-+]?               # sign
		(?! 0\d )           # can be '0' but cannot be '01'
		(?= \.? \d )        # must contain either integer or decimal digit
		\d*                 # integer part (optional)
		(?: \.\d* )?        # decimal part (optional)
	/x;

    +{
        whitespace => [ qr/\s+/ ],
        NUMBER => [ $number_re ],
        ADD    => [ '+' ],
        SUB    => [ '-' ],
        MUL    => [ '*', 'x' ],
        DIV    => [ '/', '÷' ],

        number => [ [ 'NUMBER' ] ],
        add => [ [ 'ADD' ] ],
        sub => [ [ 'SUB' ] ],
        mul => [ [ 'MUL' ] ],
        div => [ [ 'DIV' ] ],

        operator => [
            [ 'add' ],
            [ 'sub' ],
            [ 'mul' ],
            [ 'div' ],
        ],

        expression => [
            [ 'number' ],
            [ 'number', 'expression', 'operator' ],
        ],
    }
}

sub calc_rpn_action {
	'Sample::Calc::RPN::Action';
}

sub calc_rpn_action_name {
	generate_action_name;
}

sub calc_rpn_start {
	'expression';
}

sub calc_rpn_white {
	[qw[ whitespace ]];
}

sub behaves_like_grammar_parser_driver_with_calc_rpn {
	my ($package, %params) = @_;

	plan tests => 1;

	my $driver = $package->new (
		grammar     => calc_rpn_grammar,
		action      => calc_rpn_action,
		action_name => calc_rpn_action_name,
		start       => calc_rpn_start,
		white       => calc_rpn_white,
	);

	my $result = $driver->parse ('1 3 2 - +');
	my $expected = {
		expression => {
			number => '1',
			operator => 'add',
			expression => {
				number => '3',
				operator => 'sub',
				expression => { number => '2' },
			},
		},
	};

	cmp_deeply
		$result,
		$expected,
		"$package should parse RPN",
		;
}

sub behaves_like_grammar_parser_driver {
	&behaves_like_grammar_parser_driver_with_calc_rpn;
}

package Sample::Calc::RPN::Action;

use Grammar::Parser::Action::Util qw[ rule ];

use namespace::clean;

rule number     => 'literal_value';
rule add        => 'symbol';
rule sub        => 'symbol';
rule mul        => 'symbol';
rule div        => 'symbol';
rule operator   => 'alias';
rule expression => 'default';

1;


