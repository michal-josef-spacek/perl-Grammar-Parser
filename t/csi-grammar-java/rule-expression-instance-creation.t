#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 5;

test_rule "instance creation" => (
	data => 'new Foo ()',
	expect => [
		expect_element ('CSI::Language::Java::Instance::Creation' => (
			expect_word_new,
			expect_reference (qw[ Foo ]),
			expect_arguments,
		)),
	],
);

test_rule "instance creation / with annonymous class body" => (
	data => 'new Foo () { }',
	expect => [
		expect_element ('CSI::Language::Java::Instance::Creation' => (
			expect_word_new,
			expect_reference (qw[ Foo ]),
			expect_arguments,
			expect_element ('CSI::Language::Java::Class::Body' => (
				expect_token_brace_open,
				expect_token_brace_close,
			)),
		)),
	],
);

test_rule "instance creation / with type arguments" => (
	data => 'new ArrayList<>()',
	expect => [
		expect_element ('CSI::Language::Java::Instance::Creation' => (
			expect_word_new,
			expect_reference (qw[ ArrayList ]),
			expect_type_arguments,
			expect_arguments,
		)),
	],
);


test_rule "instance creation / instance inner-class construction" => (
	data => 'foo.new Bar()',
	expect => [
		expect_element ('CSI::Language::Java::Instance::Creation' => (
			expect_reference (qw[ foo ]),
			expect_token_dot,
			expect_word_new,
			expect_reference (qw[ Bar ]),
			expect_arguments,
		)),
	],
);

had_no_warnings;

done_testing;
