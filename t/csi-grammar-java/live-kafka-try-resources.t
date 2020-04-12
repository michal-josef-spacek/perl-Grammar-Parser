#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement';

plan tests => 2;

test_rule "MessageGenerator.processDirectories" => (
	data => <<'EODATA',
try (DirectoryStream<Path> directoryStream = Files
	.newDirectoryStream(Paths.get(inputDir), JSON_GLOB)) {
}
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Try' => (
			expect_word_try,
			expect_element ('CSI::Language::Java::List::Resources' => (
				expect_token_paren_open,
				expect_element ('CSI::Language::Java::Resource' => (
					expect_type_class (
						[ 'DirectoryStream' ],
						type_arguments => [ expect_type_class ([ 'Path' ]) ],
					),
					expect_element ('CSI::Language::Java::Variable::ID' => (
						expect_variable_name ('directoryStream'),
					)),
					expect_operator_assign,
					expect_element ('CSI::Language::Java::Method::Invocation' => (
						expect_element ('CSI::Language::Java::Method::Invocant' => (
							expect_reference (qw[ Files ]),
						)),
						expect_token_dot,
						expect_method_name ('newDirectoryStream'),
						expect_element ('CSI::Language::Java::Arguments' => (
							expect_token_paren_open,
							ignore,
							expect_token_comma,
							ignore,
							expect_token_paren_close,
						)),
					)),
				)),
				expect_token_paren_close,
			)),
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
