
#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'annotation_declaration';

plan tests => 3;

test_rule "empty public annotation" => (
	data => <<'EODATA',
public @interface Foo {
}
EODATA
	expect => expect_element ('CSI::Language::Java::Declaration::Annotation' => (
		expect_modifier_public,
		expect_token_annotation,
		expect_word_interface,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Structure::Body::Annotation' => (
			expect_token_brace_open,
			expect_token_brace_close,
		)),
	)),
);

test_rule "annotation with inner annotation" => (
	data => <<'EODATA',
public @interface Foo
{
        @interface Bar
        { }
}
EODATA
	expect => expect_element ('CSI::Language::Java::Declaration::Annotation' => (
		expect_modifier_public,
		expect_token_annotation,
		expect_word_interface,
		expect_type_name ('Foo'),
		expect_element ('CSI::Language::Java::Structure::Body::Annotation' => (
			expect_token_brace_open,
			expect_element ('CSI::Language::Java::Declaration::Annotation' => (
				expect_token_annotation,
				expect_word_interface,
				expect_type_name ('Bar'),
				expect_element ('CSI::Language::Java::Structure::Body::Annotation' => (
					expect_token_brace_open,
					expect_token_brace_close,
				)),
			)),
			expect_token_brace_close,
		)),
	)),
);

had_no_warnings;

done_testing;
