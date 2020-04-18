#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'class_extends';

plan tests => 3;

test_rule "class extends" => (
	data => 'extends Foo',
	expect => expect_class_extends ([qw[ Foo ]]),
	expectation_expanded => expect_element ('CSI::Language::Java::Class::Extends' => (
		expect_token ('CSI::Language::Java::Token::Word::Extends' => 'extends'),
		expect_class_type ([qw[ Foo ]]),
	)),
);

had_no_warnings;

done_testing;
