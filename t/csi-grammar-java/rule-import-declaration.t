#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'import_declaration';

plan tests => 5;

test_rule "simple import" => (
	data => 'import foo.bar;',
	expect => expect_import_declaration (
		[qw[ foo bar ]],
	),
);

test_rule "static import" => (
	data   => 'import static foo.bar;',
	expect => expect_import_declaration (
		'static',
		[qw[ foo bar ]],
	),
);

test_rule "type import" => (
	data => 'import foo.bar.*;',
	expect => expect_import_declaration (
		[qw[ foo bar ]],
		'*',
	),
);

test_rule "static type import" => (
	data   => 'import static foo.bar.*;',
	expect => expect_import_declaration (
		'static',
		[qw[ foo bar ]],
		'*',
	),
);

had_no_warnings;

done_testing;
