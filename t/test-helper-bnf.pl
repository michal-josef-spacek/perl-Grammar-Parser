
use v5.14;
use strict;
use warnings;

use Test::More;
use Test::Deep;

use Context::Singleton;

sub describe_bnf_grammar {
	my ($title, $code) = @_;

	frame {
		subtest $title => $code;
	};
}

sub arrange_bnf_source {
	my ($source) = @_;

	proclaim 'bnf::source' => $source;
}

sub expect_bnf_result_raw {
	my ($expected) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = deduce 'bnf::result::raw';
	my $result = cmp_deeply $got, $expected, "expect bnf result tree";
	diag np $got unless $result;

	return $result;
}

sub expect_bnf_result_grammar {
	my ($expected) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = deduce 'bnf::result::grammar';
	my $result = cmp_deeply $got, $expected, "expect bnf result grammar";
	diag np $got unless $result;

	return $result;
}

sub expect_bnf_result_action_map {
	my ($expected) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = deduce 'bnf::result::action-map';
	my $result = cmp_deeply $got, $expected, "expect bnf result action map";
	diag np $got unless $result;

	return $result;
}

sub expect_parser_tree {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	return frame {
		proclaim 'parser::source::content' => $params{source};

		my $got = deduce 'parser::result';
		my $result = cmp_deeply $got, $params{expect}, $title;
		diag np $got unless $result;

		return $result;
	};
}

contrive 'bnf::instance' => (
	class   => 'Grammar::Parser::BNF',
);

contrive 'findbin::bin' => (
	value   => $FindBin::Bin,
);

contrive 'bnf::source::path' => (
	class   => 'Path::Tiny',
	dep     => [ 'findbin::bin', 'bnf::source' ],
);

contrive 'bnf::source::content' => (
	deduce  => 'bnf::source::path',
	builder => 'slurp_utf8',
);

contrive 'bnf::result' => (
	deduce  => 'bnf::instance',
	builder => 'parse',
	dep     => [ 'bnf::source::content' ],
);

contrive 'bnf::result::raw' => (
	deduce  => 'bnf::result',
	as      => sub { $_[0]->{bnf} },
);

contrive 'bnf::result::grammar' => (
	deduce  => 'bnf::result',
	builder => 'build_grammar',
);

contrive 'bnf::result::action-map' => (
	deduce  => 'bnf::result',
	builder => 'build_action_map',
);

contrive 'parser' => (
	class   => 'Grammar::Parser',
	dep     => [ 'bnf::result::grammar', 'bnf::result::action-map' ],
	as      => sub {
		my ($class, $grammar, $action_map) = @_;

		$class->new (
			grammar => $grammar,
			start   => 'compilation_unit',
			action  => 'Grammar::Parser::Action::Util',
			action_lookup => $action_map,
		);
	},
);

contrive 'parser::result' => (
	deduce  => 'parser',
	dep     => [ 'parser::source::content' ],
	builder => 'parse',
);

sub describe_bnf_parser {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	subtest $title => sub {
		my $result = Grammar::Parser::BNF
			->new
			->parse (Path::Tiny->new ($FindBin::Bin, $params{source})->slurp_utf8)
			;

		cmp_deeply $result->{bnf}, $params{expect_bnf_tree}, "raw bnf tree"
			or diag (np $result->{bnf})
			if $params{expect_bnf_tree};

		my $grammar = $result->build_grammar;
		cmp_deeply $grammar, $params{expect_grammar}, "expect result grammar"
			or diag (np $grammar)
			if $params{expect_grammar};

		my $action_map = $result->build_action_map;
		cmp_deeply $action_map, $params{expect_action_map}, "expect result action map"
			or diag (np $action_map)
			if $params{expect_action_map};

		return;
	};
}

1;
