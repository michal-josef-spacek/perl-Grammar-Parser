#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

#arrange_start_rule 'enum_constant';

plan tests => 2;

test_rule "constructor with some parameters" => (
	data   => do { undef $/; scalar <DATA> },
	expect => expect_element ('CSI::Document' => (
		expect_package_declaration ([qw[ org apache kafka message ]]),
		expect_import_declaration  ([qw[ com fasterxml jackson annotation JsonProperty  ]]),
		expect_element ('CSI::Language::Java::Enum::Declaration' => (
			expect_modifier_public,
			expect_word_enum,
			expect_type_name ('MessageSpecType'),
			expect_element ('CSI::Language::Java::Enum::Body' => (
				expect_token_brace_open,
				expect_element ('CSI::Language::Java::Enum::Constant' => (
					expect_annotation (
						[qw[ JsonProperty ]],
						expect_literal_string ("request"),
					),
					expect_token ('CSI::Language::Java::Enum::Constant::Name' => 'REQUEST'),
				)),
				expect_token_comma,
				expect_element ('CSI::Language::Java::Enum::Constant' => (
					expect_annotation (
						[qw[ JsonProperty ]],
						expect_literal_string ("response"),
					),
					expect_token ('CSI::Language::Java::Enum::Constant::Name' => 'RESPONSE'),
				)),
				expect_token_comma,
				expect_element ('CSI::Language::Java::Enum::Constant' => (
					expect_annotation (
						[qw[ JsonProperty ]],
						expect_literal_string ("header"),
					),
					expect_token ('CSI::Language::Java::Enum::Constant::Name' => 'HEADER'),
				)),
				expect_token_comma,
				expect_element ('CSI::Language::Java::Enum::Constant' => (
					expect_annotation (
						[qw[ JsonProperty ]],
						expect_literal_string ("data"),
					),
					expect_token ('CSI::Language::Java::Enum::Constant::Name' => 'DATA'),
				)),
				expect_token_semicolon,
				expect_token_brace_close,
			)),
		)),
	)),
);

had_no_warnings;

done_testing;

__DATA__
package org.apache.kafka.message;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum MessageSpecType {
    @JsonProperty("request")
    REQUEST,

    @JsonProperty("response")
    RESPONSE,

    @JsonProperty("header")
    HEADER,

    @JsonProperty("data")
    DATA;
}
