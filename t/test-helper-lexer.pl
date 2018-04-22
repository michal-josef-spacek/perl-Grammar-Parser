
use v5.14;
use strict;
use warnings;

BEGIN { require "test-helper-common.pl" }

require Grammar::Parser::Lexer;

use Context::Singleton;

sub _compare_expected {
	my ($mode, $got, $expect) = @_;
	my ($ok, $reason) = Test::Deep::cmp_details $got, $expect;

	$reason = "$mode:" . deep_diag $reason
		unless $ok;

	($ok, $reason);
}

sub arrange_lexer {
	my (%lexer) = @_;

	proclaim 'current-lexer-config' => \%lexer;
	proclaim 'current-lexer' => Grammar::Parser::Lexer->new (%lexer);
}

sub arrange_data {
	my (@data) = @_;

	deduce ('current-lexer')->add_data (@data);
}

sub expect_token {
	my ($title, %params) = @_;

	test_frame {
		#local $Test::Builder::Level = $Test::Builder::Level + 2;

		my @accept = defined $params{with_accept}
			? @{ $params{with_accept} }
			: ($params{expect_token}) x!! defined $params{expect_token}
			;

		my $token;
		act { $token = deduce ('current-lexer')->next_token (@accept) };

		return act_throws $title, throws => $params{throws}
			if exists $params{throws};

		act_should_live $title or return;

		# last token ...
		unless (defined $params{expect_token}) {
			return it $title,
				got => $token,
				expect => [],
			;
		}

		$params{expect_significant} = bool ($params{expect_significant})
			if defined $params{expect_significant} && ! ref $params{expect_significant};

		my ($ok, $reason) = (1, undef);

		($ok, $reason) = _compare_expected expect_token => $token->[0], $params{expect_token}
			if $ok && defined $params{expect_token};

		($ok, $reason) = _compare_expected expect_value => $token->[1]->value, $params{expect_value}
			if $ok && exists $params{expect_value};

		($ok, $reason) = _compare_expected expect_significant => $token->[1]->significant, $params{expect_significant}
			if $ok && exists $params{expect_significant};

		($ok, $reason) = _compare_expected expect_line => $token->[1]->line, $params{expect_line}
			if $ok && exists $params{expect_line};

		($ok, $reason) = _compare_expected expect_column => $token->[1]->column, $params{expect_column}
			if $ok && exists $params{expect_column};

		($ok, $reason) = _compare_expected expect_captures => $token->[1]->captures, $params{expect_captures}
			if $ok && exists $params{expect_captures};

		ok $title, got => $ok;
		diag $reason unless $ok;

		return $ok
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

sub it_should_recognize_token {
	my ($data, %params) = @_;

	my $config = deduce 'current-lexer-config';
	frame {
		local $Test::Builder::Level = $Test::Builder::Level + 1;

		arrange_lexer %$config;
		arrange_data $data;

		expect_next_token %params;
	};
}

sub expect_last_token {
	expect_token "expect last token",
		expect_token => undef
}

1;
