#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";

use Sub::Override;

BEGIN { require "test-helper-lexer.pl" }

# plan tests => 6;

note 'Behaviour of internal lexer methods';

arrange_lexer
	tokens => {
		no_ref => qr/no-ref/,
		simple_ref => qr/simple_ref(??{ 'no_ref' })/,
		hierarchy  => qr/hierarchy(??{ 'simple_ref' })/,
		recursive  => qr/(?<recursive>recursive(??{ 'recursive' }))/,
	},
	patterns => {
		simple_ref_2 => qr/simple_ref_2(??{ 'no_ref' })(??{ 'no_ref' })/,
	},
;

subtest "_parser_def_map() should compile given patterns into regex snippets with referencies" => sub {
	it "should return definition map" => (
		got => (deduce 'current-lexer')->_parser_def_map,
		expect => {
			no_ref     => {
				regex => "(?^:no-ref)",
				refs  => [],
			},
			simple_ref => {
				regex => "(?^:simple_ref(?&d_no_ref))",
				refs  => [qw[ no_ref ]],
			},
			simple_ref_2 => {
				regex => "(?^:simple_ref_2(?&d_no_ref)(?&d_no_ref))",
				refs  => [qw[ no_ref ]],
			},
			hierarchy => {
				regex => "(?^:hierarchy(?&d_simple_ref))",
				refs  => [qw[ simple_ref ]],
			},
			recursive => {
				regex => "(?^:(?<recursive>recursive(?&d_recursive)))",
				refs  => [qw[ recursive ]],
			},
		},
	);
};

# TODO: subtest "_list_regex_referencies"

subtest "_build_single_parser_regex() should compile regex definition" => sub {
	act { deduce ('current-lexer')->_build_single_parser_regex (@_) };

	it "should pass-through regex" => (
		args   => [ qr/foo/ ],
		expect => "(?^:foo)",
	);

	it "should quote meta in string" => (
		args   => [ 'A.*' ],
		expect => 'A\\.\\*',
	);

	it "should expand string ref as regex reference" => (
		args   => [ \ 'foo' ],
		expect => "(??{ 'foo' })",
	);

	it "should treat arrayref as alternatives" => (
		args   => [ [
			qr/foo/,
			[ 'A' ],
			[ 'B' ],
			[ \ qw[ A B ] ],
		] ],
		expect => "(?:(?:${\ qr/foo/ })|(?:A)|(?:B)|(?:(??{ 'A' }))|(?:(??{ 'B' })))",
	),
};

subtest "_define_referencies() should build DEFINE regex from dependencies required to evaluate dependant regex" => sub {
	act { deduce ('current-lexer')->_define_referencies (@_) };

	it "should return empty string when there are no references" => (
		args => [],
		expect => "",
	);

	it "should enlist given reference as DEFINE regex / string" => (
		args => [qw[ no_ref ]],
		expect => join "\n\t", (
			"(?(DEFINE)",
			"(?<d_no_ref>(?^:no-ref))",
			")",
		),
	);

	it "should enlist hierarchical dependencies" => (
		args => [qw[ hierarchy ]],
		expect => join "\n\t", (
			"(?(DEFINE)",
			"(?<d_hierarchy>(?^:hierarchy(?&d_simple_ref)))",
			"(?<d_no_ref>(?^:no-ref))",
			"(?<d_simple_ref>(?^:simple_ref(?&d_no_ref)))",
			")",
		),
	);

	it "should enlist all given dependencies" => (
		args => [qw[ simple_ref simple_ref_2 ]],
		expect => join "\n\t", (
			"(?(DEFINE)",
			"(?<d_no_ref>(?^:no-ref))",
			"(?<d_simple_ref>(?^:simple_ref(?&d_no_ref)))",
			"(?<d_simple_ref_2>(?^:simple_ref_2(?&d_no_ref)(?&d_no_ref)))",
			")",
		),
	);

	it "should enlist all given dependencies" => (
		args => [qw[ simple_ref simple_ref_2 ]],
		expect => join "\n\t", (
			"(?(DEFINE)",
			"(?<d_no_ref>(?^:no-ref))",
			"(?<d_simple_ref>(?^:simple_ref(?&d_no_ref)))",
			"(?<d_simple_ref_2>(?^:simple_ref_2(?&d_no_ref)(?&d_no_ref)))",
			")",
		),
	);

};

subtest "_parser_lookup_regex()" => sub {
	act { deduce ('current-lexer')->_parser_lookup_regex (@_) };

	it "should return empty string when there are no references" => (
		args => [],
		expect => qr/(?{ {} })
(?=((?&d_hierarchy))(?{ $^R->{hierarchy} = $^N; $^R }) )?
(?=((?&d_no_ref))(?{ $^R->{no_ref} = $^N; $^R }) )?
(?=((?&d_recursive))(?{ $^R->{recursive} = $^N; $^R }) )?
(?=((?&d_simple_ref))(?{ $^R->{simple_ref} = $^N; $^R }) )?
(?(DEFINE)
	(?<d_hierarchy>(?^:hierarchy(?&d_simple_ref)))
	(?<d_no_ref>(?^:no-ref))
	(?<d_recursive>(?^:(?<recursive>recursive(?&d_recursive))))
	(?<d_simple_ref>(?^:simple_ref(?&d_no_ref)))
	)/ux,
	);

};

subtest "_parser_token_map() should contain regex map that will match every token providing captures" => sub {
	act { deduce ('current-lexer')->_parser_token_regex (@_) };

	it "should return simple non-reference match regex" => (
		args => ['no_ref'],
		expect => qr/(?^:no-ref)/ux,
	);

	it "should return match regex with groups and referencies" => (
		args => ['recursive'],
		expect => qr/(?^:(?<recursive>recursive(?&d_recursive)))(?(DEFINE)
	(?<d_recursive>(?^:(?<recursive>recursive(?&d_recursive))))
	)/ux,
	);
};

done_testing;

