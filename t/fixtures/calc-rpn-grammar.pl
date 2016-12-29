
use strict;
use warnings;

BEGIN { require "test-helper-common.pl" }

contrive 'calc-rpn-grammar' => (
	as => sub {
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
);

contrive 'calc-rpn-action' => (
	value => 'Sample::Calc::RPN::Action',
);

contrive 'calc-rpn-action-lookup' => (
	dep => [ 'calc-rpn-action' ],
	as => sub { [ @_ ] },
);

contrive 'calc-rpn-action-name' => (
	dep => [ 'calc-rpn-action' ],
	as  => sub { $_[0]->can ('action_name') },
);

contrive 'calc-rpn-start' => (
	value => 'expression',
);

contrive 'calc-rpn-insignificant' => (
	value => [qw[ whitespace ]],
);

contrive 'calc-rpn-instance' => (
	class => 'driver-package',
	dep   => {
		grammar       => 'calc-rpn-grammar',
		action_lookup => 'calc-rpn-action-lookup',
		action_name   => 'calc-rpn-action-name',
		start         => 'calc-rpn-start',
		insignificant => 'calc-rpn-insignificant',
	},
);

package Sample::Calc::RPN::Action;

use Grammar::Parser::Action::Util (
	'action_name' => { as => 'action_name' },
	number     => { is => 'literal_value' },
	add        => { is => 'symbol' },
	sub        => { is => 'symbol' },
	mul        => { is => 'symbol' },
	div        => { is => 'symbol' },
	operator   => { is => 'alias' },
	expression => { is => 'default' },
	ADD        => { is => 'literal' },
	SUB        => { is => 'literal' },
	MUL        => { is => 'literal' },
	DIV        => { is => 'literal' },
);

1;

