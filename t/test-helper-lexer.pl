
use v5.14;
use strict;
use warnings;

use Test::More;
use Grammar::Parser::Grammar;

use Carp::Always;
use Context::Singleton;

contrive 'grammar::instance' => (
	class => 'Grammar::Parser::Grammar',
	dep => [ 'grammar' ],
	as => sub {
		my ($class, $grammar) = @_;

		$class->new (
			grammar => $grammar,
			start => 'bnf',
		);
	},
);

contrive 'lexer' => (
	deduce => 'grammar::instance',
	builder => 'lexer',
);

sub describe_lexer {
	my ($title, $code) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	subtest $title => sub {
		frame {
			$code->();
		}
	};
}

sub arrange_grammar {
	my ($grammar) = @_;

	proclaim 'grammar' => $grammar;
}

sub expect_token {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	Test::More::diag ("deduce lexer ...");
	my $lexer = deduce 'lexer';
	my $data = $params{with_data};
	$lexer->_data (\ $data);

	my $token;
	my $lives_ok = eval {
		$token = $lexer->next_token (($params{expect_token}) x!! defined $params{expect_token});
		1;
	};
	my $error = $@;

	unless ($lives_ok) {
		fail $title;
		diag "expect to live but died with $error";
		return;
	}

	subtest $title => sub {
		cmp_deeply $token->[0], $params{expect_token}, "expect token $params{expect_token}";
		cmp_deeply $token->[1]->value, $params{expect_value}, "expect token value"
			if exists $params{expect_value};
		cmp_deeply $token->[1]->captures, $params{expect_captures}, "expect token captures"
			if exists $params{expect_captures};
	};
}

1;
