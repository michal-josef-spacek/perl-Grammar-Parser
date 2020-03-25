#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

plan tests => 3;

subtest "word expectations" => sub {
	# 64 ... number of java keywords
	plan tests => 64;

	it 'expectation expect_word_abstract',
		got    => expect_word_abstract,
		expect => expect_token ('CSI::Language::Java::Token::Word::Abstract' => 'abstract'),
		;

	it 'expectation expect_word_assert',
		got    => expect_word_assert,
		expect => expect_token ('CSI::Language::Java::Token::Word::Assert' => 'assert'),
		;

	it 'expectation expect_word_boolean',
		got    => expect_word_boolean,
		expect => expect_token ('CSI::Language::Java::Token::Word::Boolean' => 'boolean'),
		;

	it 'expectation expect_word_break',
		got    => expect_word_break,
		expect => expect_token ('CSI::Language::Java::Token::Word::Break' => 'break'),
		;

	it 'expectation expect_word_byte',
		got    => expect_word_byte,
		expect => expect_token ('CSI::Language::Java::Token::Word::Byte' => 'byte'),
		;

	it 'expectation expect_word_case',
		got    => expect_word_case,
		expect => expect_token ('CSI::Language::Java::Token::Word::Case' => 'case'),
		;

	it 'expectation expect_word_catch',
		got    => expect_word_catch,
		expect => expect_token ('CSI::Language::Java::Token::Word::Catch' => 'catch'),
		;

	it 'expectation expect_word_char',
		got    => expect_word_char,
		expect => expect_token ('CSI::Language::Java::Token::Word::Char' => 'char'),
		;

	it 'expectation expect_word_class',
		got    => expect_word_class,
		expect => expect_token ('CSI::Language::Java::Token::Word::Class' => 'class'),
		;

	it 'expectation expect_word_const',
		got    => expect_word_const,
		expect => expect_token ('CSI::Language::Java::Token::Word::Const' => 'const'),
		;

	it 'expectation expect_word_continue',
		got    => expect_word_continue,
		expect => expect_token ('CSI::Language::Java::Token::Word::Continue' => 'continue'),
		;

	it 'expectation expect_word_default',
		got    => expect_word_default,
		expect => expect_token ('CSI::Language::Java::Token::Word::Default' => 'default'),
		;

	it 'expectation expect_word_do',
		got    => expect_word_do,
		expect => expect_token ('CSI::Language::Java::Token::Word::Do' => 'do'),
		;

	it 'expectation expect_word_double',
		got    => expect_word_double,
		expect => expect_token ('CSI::Language::Java::Token::Word::Double' => 'double'),
		;

	it 'expectation expect_word_else',
		got    => expect_word_else,
		expect => expect_token ('CSI::Language::Java::Token::Word::Else' => 'else'),
		;

	it 'expectation expect_word_enum',
		got    => expect_word_enum,
		expect => expect_token ('CSI::Language::Java::Token::Word::Enum' => 'enum'),
		;

	it 'expectation expect_word_exports',
		got    => expect_word_exports,
		expect => expect_token ('CSI::Language::Java::Token::Word::Exports' => 'exports'),
		;

	it 'expectation expect_word_extends',
		got    => expect_word_extends,
		expect => expect_token ('CSI::Language::Java::Token::Word::Extends' => 'extends'),
		;

	it 'expectation expect_word_false',
		got    => expect_word_false,
		expect => expect_token ('CSI::Language::Java::Token::Word::False' => 'false'),
		;

	it 'expectation expect_word_final',
		got    => expect_word_final,
		expect => expect_token ('CSI::Language::Java::Token::Word::Final' => 'final'),
		;

	it 'expectation expect_word_finally',
		got    => expect_word_finally,
		expect => expect_token ('CSI::Language::Java::Token::Word::Finally' => 'finally'),
		;

	it 'expectation expect_word_float',
		got    => expect_word_float,
		expect => expect_token ('CSI::Language::Java::Token::Word::Float' => 'float'),
		;

	it 'expectation expect_word_for',
		got    => expect_word_for,
		expect => expect_token ('CSI::Language::Java::Token::Word::For' => 'for'),
		;

	it 'expectation expect_word_goto',
		got    => expect_word_goto,
		expect => expect_token ('CSI::Language::Java::Token::Word::Goto' => 'goto'),
		;

	it 'expectation expect_word_if',
		got    => expect_word_if,
		expect => expect_token ('CSI::Language::Java::Token::Word::If' => 'if'),
		;

	it 'expectation expect_word_implements',
		got    => expect_word_implements,
		expect => expect_token ('CSI::Language::Java::Token::Word::Implements' => 'implements'),
		;

	it 'expectation expect_word_import',
		got    => expect_word_import,
		expect => expect_token ('CSI::Language::Java::Token::Word::Import' => 'import'),
		;

	it 'expectation expect_word_instanceof',
		got    => expect_word_instanceof,
		expect => expect_token ('CSI::Language::Java::Token::Word::Instanceof' => 'instanceof'),
		;

	it 'expectation expect_word_int',
		got    => expect_word_int,
		expect => expect_token ('CSI::Language::Java::Token::Word::Int' => 'int'),
		;

	it 'expectation expect_word_interface',
		got    => expect_word_interface,
		expect => expect_token ('CSI::Language::Java::Token::Word::Interface' => 'interface'),
		;

	it 'expectation expect_word_long',
		got    => expect_word_long,
		expect => expect_token ('CSI::Language::Java::Token::Word::Long' => 'long'),
		;

	it 'expectation expect_word_module',
		got    => expect_word_module,
		expect => expect_token ('CSI::Language::Java::Token::Word::Module' => 'module'),
		;

	it 'expectation expect_word_native',
		got    => expect_word_native,
		expect => expect_token ('CSI::Language::Java::Token::Word::Native' => 'native'),
		;

	it 'expectation expect_word_new',
		got    => expect_word_new,
		expect => expect_token ('CSI::Language::Java::Token::Word::New' => 'new'),
		;

	it 'expectation expect_word_null',
		got    => expect_word_null,
		expect => expect_token ('CSI::Language::Java::Token::Word::Null' => 'null'),
		;

	it 'expectation expect_word_open',
		got    => expect_word_open,
		expect => expect_token ('CSI::Language::Java::Token::Word::Open' => 'open'),
		;

	it 'expectation expect_word_opens',
		got    => expect_word_opens,
		expect => expect_token ('CSI::Language::Java::Token::Word::Opens' => 'opens'),
		;

	it 'expectation expect_word_package',
		got    => expect_word_package,
		expect => expect_token ('CSI::Language::Java::Token::Word::Package' => 'package'),
		;

	it 'expectation expect_word_private',
		got    => expect_word_private,
		expect => expect_token ('CSI::Language::Java::Token::Word::Private' => 'private'),
		;

	it 'expectation expect_word_protected',
		got    => expect_word_protected,
		expect => expect_token ('CSI::Language::Java::Token::Word::Protected' => 'protected'),
		;

	it 'expectation expect_word_provides',
		got    => expect_word_provides,
		expect => expect_token ('CSI::Language::Java::Token::Word::Provides' => 'provides'),
		;

	it 'expectation expect_word_public',
		got    => expect_word_public,
		expect => expect_token ('CSI::Language::Java::Token::Word::Public' => 'public'),
		;

	it 'expectation expect_word_requires',
		got    => expect_word_requires,
		expect => expect_token ('CSI::Language::Java::Token::Word::Requires' => 'requires'),
		;

	it 'expectation expect_word_return',
		got    => expect_word_return,
		expect => expect_token ('CSI::Language::Java::Token::Word::Return' => 'return'),
		;

	it 'expectation expect_word_short',
		got    => expect_word_short,
		expect => expect_token ('CSI::Language::Java::Token::Word::Short' => 'short'),
		;

	it 'expectation expect_word_static',
		got    => expect_word_static,
		expect => expect_token ('CSI::Language::Java::Token::Word::Static' => 'static'),
		;

	it 'expectation expect_word_strictfp',
		got    => expect_word_strictfp,
		expect => expect_token ('CSI::Language::Java::Token::Word::Strictfp' => 'strictfp'),
		;

	it 'expectation expect_word_super',
		got    => expect_word_super,
		expect => expect_token ('CSI::Language::Java::Token::Word::Super' => 'super'),
		;

	it 'expectation expect_word_switch',
		got    => expect_word_switch,
		expect => expect_token ('CSI::Language::Java::Token::Word::Switch' => 'switch'),
		;

	it 'expectation expect_word_synchronized',
		got    => expect_word_synchronized,
		expect => expect_token ('CSI::Language::Java::Token::Word::Synchronized' => 'synchronized'),
		;

	it 'expectation expect_word_this',
		got    => expect_word_this,
		expect => expect_token ('CSI::Language::Java::Token::Word::This' => 'this'),
		;

	it 'expectation expect_word_throw',
		got    => expect_word_throw,
		expect => expect_token ('CSI::Language::Java::Token::Word::Throw' => 'throw'),
		;

	it 'expectation expect_word_throws',
		got    => expect_word_throws,
		expect => expect_token ('CSI::Language::Java::Token::Word::Throws' => 'throws'),
		;

	it 'expectation expect_word_to',
		got    => expect_word_to,
		expect => expect_token ('CSI::Language::Java::Token::Word::To' => 'to'),
		;

	it 'expectation expect_word_transient',
		got    => expect_word_transient,
		expect => expect_token ('CSI::Language::Java::Token::Word::Transient' => 'transient'),
		;

	it 'expectation expect_word_true',
		got    => expect_word_true,
		expect => expect_token ('CSI::Language::Java::Token::Word::True' => 'true'),
		;

	it 'expectation expect_word_try',
		got    => expect_word_try,
		expect => expect_token ('CSI::Language::Java::Token::Word::Try' => 'try'),
		;

	it 'expectation expect_word_uses',
		got    => expect_word_uses,
		expect => expect_token ('CSI::Language::Java::Token::Word::Uses' => 'uses'),
		;

	it 'expectation expect_word_underline',
		got    => expect_word_underline,
		expect => expect_token ('CSI::Language::Java::Token::Word::_' => '_'),
		;

	it 'expectation expect_word_var',
		got    => expect_word_var,
		expect => expect_token ('CSI::Language::Java::Token::Word::Var' => 'var'),
		;

	it 'expectation expect_word_void',
		got    => expect_word_void,
		expect => expect_token ('CSI::Language::Java::Token::Word::Void' => 'void'),
		;

	it 'expectation expect_word_volatile',
		got    => expect_word_volatile,
		expect => expect_token ('CSI::Language::Java::Token::Word::Volatile' => 'volatile'),
		;

	it 'expectation expect_word_while',
		got    => expect_word_while,
		expect => expect_token ('CSI::Language::Java::Token::Word::While' => 'while'),
		;

	it 'expectation expect_word_with',
		got    => expect_word_with,
		expect => expect_token ('CSI::Language::Java::Token::Word::With' => 'with'),
		;

	done_testing;
};

subtest "literals"          => sub {
	plan tests => 10;

	is "expect_literal_false" =>
		expect => expect_literal_false,
		got    => {
			'CSI::Language::Java::Literal::Boolean::False' => [
				{ 'CSI::Language::Java::Token::Word::False' => 'false' },
			],
		},
		;

	is "expect_literal_true" =>
		expect => expect_literal_true,
		got    => {
			'CSI::Language::Java::Literal::Boolean::True' => [
				{ 'CSI::Language::Java::Token::Word::True' => 'true' },
			],
		},
		;

	is "expect_literal_null" =>
		expect => expect_literal_null,
		got    => {
			'CSI::Language::Java::Literal::Null' => [
				{ 'CSI::Language::Java::Token::Word::Null' => 'null' },
			],
		},
		;

	is "expect_literal_string" =>
		expect => expect_literal_string ('foo'),
		got    => {
			'LITERAL_STRING' => "foo",
		},
		;

	is "expect_literal_character" =>
		expect => expect_literal_character ('f'),
		got    => {
			'LITERAL_CHARACTER' => "f",
		},
		;

	it "expect_literal_integral_binary" =>
		expect => expect_literal_integral_binary ('0b0'),
		got => {
			'LITERAL_INTEGRAL_BINARY' => '0b0',
		},
		;

	is "expect_literal_integral_decimal" =>
		expect => expect_literal_integral_decimal ('0'),
		got    => {
			'LITERAL_INTEGRAL_DECIMAL' => "0",
		},
		;

	it "expect_literal_integral_hex" =>
		expect => expect_literal_integral_hex ('0x0'),
		got => {
			'LITERAL_INTEGRAL_HEX' => '0x0',
		},
		;

	it "expect_literal_integral_octal" =>
		expect => expect_literal_integral_octal ('06'),
		got => {
			'LITERAL_INTEGRAL_OCTAL' => '06',
		},
		;

	it "expect_literal_floating_decimal" =>
		expect => expect_literal_floating_decimal ('.0'),
		got => {
			'LITERAL_FLOAT_DECIMAL' => '.0',
		},
		;

	done_testing;
};

had_no_warnings;

done_testing;
