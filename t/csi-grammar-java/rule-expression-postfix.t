#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'expression';

plan tests => 6;

test_rule "postfix expression - decrement" => (
	data => 'foo--',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_decrement,
		)),
	],
);

test_rule "postfix expression - increment" => (
	data => 'foo++',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_increment,
		)),
	],
);

test_rule "postfix expression - decrement associativity" => (
	data => 'foo----',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_decrement,
			expect_operator_decrement,
		)),
	],
);

test_rule "postfix expression - increment associativity" => (
	data => 'foo++++',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_increment,
			expect_operator_increment,
		)),
	],
);

test_rule "postfix expression - associativity" => (
	data => 'foo++--++',
	expect => [
		expect_element ('CSI::Language::Java::Expression::Postfix' => (
			expect_reference ('foo'),
			expect_operator_increment,
			expect_operator_decrement,
			expect_operator_increment,
		)),
	],
);


had_no_warnings;

done_testing;
