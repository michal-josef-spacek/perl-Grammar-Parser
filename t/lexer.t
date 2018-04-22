#!/usr/bin/env perl

BEGIN { require "test-helper-common.pl" }
BEGIN { require "test-helper-lexer.pl" }

use Data::Printer;

use Encode qw[];
use Hash::Util qw[];
use Ref::Util qw[];

use Grammar::Parser::Lexer;

sub simple_grammar;
sub bnf_grammar;

sub build_lexer;
sub test_next_token;
sub test_lexer;
sub token;

binmode STDOUT, ':utf8';

plan tests => 5;
describe_lexer 'simple grammar - happy scenario' => sub {
	arrange_grammar simple_grammar;
	arrange_data <<'DATA';
1  - 2+ 13
 =
12
DATA

	expect_next_token number => (
		value => '1',
		line => 1,
		column => 1,
	);

	expect_next_token minus => (
		value => '-',
		line => 1,
		column => 4,
	);

	expect_next_token number => (
		value => '2',
		line => 1,
		column => 6,
	);

	expect_next_token plus => (
		value => '+',
		line => 1,
		column => 7,
	);

	expect_next_token number => (
		value => '13',
		line => 1,
		column => 9,
	);

	expect_next_token equals => (
		value => '=',
		line => 2,
		column => 2,
	);

	expect_next_token number => (
		value => '12',
		line => 3,
		column => 1,
	);

	expect_last_token;
};

not 1 and test_lexer 'simple grammar - with final token' => (
	grammar => simple_grammar,
	final_token => 'equals',
	data => [ '1  - 2+ 13 = 12' ],
	plan => [
		{ expect => [ number => ( MATCH => '1',  LINE => 1, COLUMN => 1 ) ] },
		{ expect => [ minus  => ( MATCH => '-',  LINE => 1, COLUMN => 4 ) ] },
		{ expect => [ number => ( MATCH => '2',  LINE => 1, COLUMN => 6 ) ] },
		{ expect => [ plus   => ( MATCH => '+',  LINE => 1, COLUMN => 7 ) ] },
		{ expect => [ number => ( MATCH => '13', LINE => 1, COLUMN => 9 ) ] },
		{ expect => [ equals => ( MATCH => '=',  LINE => 1, COLUMN => 12, remaining_data => ' 12' ) ] },
		{ expect => [ ], title => 'last token' },
	],
);

describe_lexer 'simple grammar - return whitespace if requested' => sub {
	arrange_grammar simple_grammar;
	arrange_data   '1  - 2 + 13 = 12';

	expect_next_token number => (
		value => '1',
		significant => 1,
	);

	expect_next_token whitespace => (
		value => '  ',
		significant => 0,
		accept => [ 'whitespace', 'minus' ],
	);

	expect_next_token minus => (
		value => '-',
		significant => 1,
	);
};

test_lexer 'simple grammar - throws if requested not found' => (
	grammar => simple_grammar,
	data    => [ '1  - 2 + 13 = 12' ],
	plan    => [
		{ expect => [ number => () ] },
		{ accept => [ plus   => () ], throws => 'Grammar::Parser::X::Lexer::Notfound' },
		{ expect => [ minus  => () ] },
	],
);

test_lexer 'bnf grammar - operator in string' => (
	grammar => bnf_grammar,
	data    => [ "operator: '+' | '-' | '*' | '/'" ],
	plan    => [
		{ expect => [ nonterminal => ( MATCH => 'operator', value => 'operator' ) ] },
		{ expect => [ DEFINITION  => ( MATCH => ':' ) ] },
		{ expect => [ literal     => ( MATCH => "'+'", quoting => "'", value => '+' ) ] },
		{ expect => [ ALTERNATIVE => ( MATCH => '|' ) ] },
		{ expect => [ literal     => ( MATCH => "'-'", quoting => "'", value => '-' ) ] },
		{ expect => [ ALTERNATIVE => ( MATCH => '|' ) ] },
		{ expect => [ literal     => ( MATCH => "'*'", quoting => "'", value => '*' ) ] },
		{ expect => [ ALTERNATIVE => ( MATCH => '|' ) ] },
		{ expect => [ literal     => ( MATCH => "'/'", quoting => "'", value => '/' ) ] },
	],
);

had_no_warnings 'no unexpected warnings in Grammar::Parser::Lexer';
done_testing;

sub token {
	my ($name, %params) = @_;

	return [] unless $name;

	$params{MATCH}  //= ignore;
	$params{LINE}   //= ignore;
	$params{COLUMN} //= ignore;
	$params{SIGNIFICANT} //= 1;

	my $symbol = obj_isa ('Grammar::Parser::Lexer::Token')
		& methods (name => $name);

	$symbol &= methods (match => delete $params{MATCH})
		if exists $params{MATCH};

	$symbol &= methods (significant => bool (delete $params{SIGNIFICANT}))
		if exists $params{SIGNIFICANT};

	$symbol &= methods (line => delete $params{LINE})
		if exists $params{LINE};

	$symbol &= methods (column => delete $params{COLUMN})
		if exists $params{COLUMN};

	$symbol &= methods (significant => bool (delete $params{SIGNIFICANT}))
		if exists $params{SIGNIFICANT};

	my $value = $params{value} // $params{MATCH};
	$symbol &= methods (value => $value)
		if defined $value;

	$symbol &= methods ([capture => $_] => $params{$_})
		for keys %params;

	return [ $name, $symbol ];
}

sub bnf_grammar {
	+{
		insignificant => [qw[ whitespace ]],
		lexemes => {
			whitespace => [ qr/\s+/ ],
			literal       => [ qr/
				(?> (?<quoting>\') (?<value> [^\\\'] | \\. *?) \' )
			|	(?> (?<quoting>\") (?<value> [^\\\"] | \\. *?) \" )
			/mx ],
			nonterminal   => [ qr/(?: \b (?<value>\w+) \b )/x ],
			DEFINITION    => [ qr/(?= [:=]) (?: :{0,2} =? )(?! [:=]) /mx ],
			ALTERNATIVE   => [ '|', '/' ],
		},
	};
}

sub simple_grammar {
	+{
		insignificant => [qw[ whitespace ]],
		lexemes  => {
			whitespace => [ qr/\s+/ ],
			plus       => [ '+' ],
			minus      => [ '-' ],
			equals     => [ '=', qr/[:=]=/, qr/\b eq \b/x ],
			number     => [ qr/\d+/ ],
		},
	};
}

sub build_lexer {
	Grammar::Parser::Lexer->new (@_);
}

sub test_lexer {
	my ($title, %params) = @_;
return;
	Hash::Util::lock_keys %params, qw[ grammar lexer data plan final_token ];
	my @final_token = (final_token => $params{final_token}) x!! $params{final_token};

	$params{lexer} //= build_lexer (%{ $params{grammar} }, @final_token)
		if Ref::Util::is_hashref ($params{grammar});

	$params{lexer} //= build_lexer (@{ $params{grammar} }, @final_token)
		if Ref::Util::is_arrayref ($params{grammar});

	$params{lexer}->push_data (@{ $params{data} // [] });

	subtest $title => sub {
		plan tests => scalar @{ $params{plan} };
		for my $plan (@{ $params{plan} }) {
			my $params = { %$plan };

			my ($name, %expect) = @{ $params->{expect} // [] };

			my $title = delete $params->{title};
			$title //= 'throws ' . $plan->{throws}
				if $plan->{throws};
			$title //= do {
				my $title ="tokenize $name";
				$title .= " «$expect{MATCH}»" if defined $expect{MATCH};
				$title;
			};

			test_next_token $title => (
				lexer => $params{lexer},
				%$params,
				expect => token ($name, %expect),
			);
		}
	};
}
