#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'statement';

plan tests => 2;

test_rule "labeled statement" => (
	data => <<'EODATA',
label : { }
EODATA
	expect => [
		expect_element ('CSI::Language::Java::Statement::Labeled' => (
			expect_token ('CSI::Language::Java::Label' => 'label'),
			expect_token_colon,
			expect_element ('CSI::Language::Java::Structure::Block' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

had_no_warnings;

done_testing;
