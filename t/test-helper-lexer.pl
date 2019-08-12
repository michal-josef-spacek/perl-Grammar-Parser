
use v5.14;
use strict;
use warnings;

use Test::More;

use Carp::Always;

our $CURRENT_LEXER;

sub describe_lexer {
	my ($title, $code) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 2;

	subtest $title => sub {
		local $CURRENT_LEXER;

		$code->();
	};
}

sub arrange_grammar {
	my ($grammar) = @_;

	$CURRENT_LEXER = Grammar::Parser::Lexer->new (%$grammar);
}

sub arrange_data {
	my (@data) = @_;

	$CURRENT_LEXER->push_data (@data);
}

sub expect_token {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my @accept = defined $params{with_accept}
		? @{ $params{with_accept} }
		: ($params{expect_token}) x!! defined $params{expect_token}
		;

	my $token;
	my $lives_ok = eval {
		$token = $CURRENT_LEXER->next_token (@accept);
		1;
	};
	my $error = $@;

	if ($params{throws}) {
		if ($lives_ok) {
			fail $title;
			diag "expect to die but still lives";
			return
		}

		$params{throws} = obj_isa ($params{throws}) unless ref $params{throws};
		$params{throws} = re ($params{throws}) if Ref::Util::is_regexpref ($params{throws});

		return cmp_deeply $error, $params{throws}, $title;
	}

	unless ($lives_ok) {
		fail $title;
		diag "expect to live but died with $error";
		return;
	}

	# last token ...
	return cmp_deeply $token, [], $title
		unless defined $params{expect_token};

	$params{expect_significant} = bool ($params{expect_significant})
		if defined $params{expect_significant} && ! ref $params{expect_significant};

	subtest $title => sub {
		cmp_deeply $token->[0], $params{expect_token}, "expect token $params{expect_token}"
			if defined $params{expect_token};
		cmp_deeply $token->[1]->value, $params{expect_value}, "expect value «$params{expect_value}»"
			if exists $params{expect_value};
		cmp_deeply $token->[1]->significant, $params{expect_significant}, "expect significant token"
			if exists $params{expect_significant};
		cmp_deeply $token->[1]->line, $params{expect_line}, "expect match at line $params{expect_line}"
			if exists $params{expect_line};
		cmp_deeply $token->[1]->line, $params{expect_line}, "expect match at line $params{expect_line}"
			if exists $params{expect_line};
		cmp_deeply $token->[1]->column, $params{expect_column}, "expect match at column $params{expect_column}"
			if exists $params{expect_column};
		cmp_deeply $token->[1]->captures, $params{expect_captures}, "expect token captures"
			if exists $params{expect_captures};
	};
}

sub expect_next_token {
	my ($token, %params) = @_;

	my $value = delete $params{value};
	my $line = delete $params{line};
	my $significant = delete $params{significant};
	my $column = delete $params{column};
	my $throws = delete $params{throws};
	my $accept = delete $params{accept};

	my $title;
	$title //= "expect $token throws an exception" if $throws;
	$title //= "expect $token «$value»";

	expect_token $title,
		expect_token => $token,
		expect_value => $value,
		(expect_significant => $significant) x!! defined $significant,
		(expect_line => $line) x!! defined $line,
		(expect_column => $column) x!! defined $column,
		(expect_captures => \%params) x!! %params,
		(throws => $throws) x!! defined $throws,
		(with_accepted => $accept) x!! defined $accept,
		 ;
}

sub expect_last_token {
	expect_token "expect last token",
		expect_token => undef
}

1;
