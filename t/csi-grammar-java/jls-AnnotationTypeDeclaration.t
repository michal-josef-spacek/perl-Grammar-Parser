#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

arrange_start_rule 'annotation_declaration';

plan tests => 4;

note "https://docs.oracle.com/javase/specs/jls/se13/html/jls-9.html#jls-AnnotationTypeDeclaration";

test_rule "AnnotationTypeDeclaration / marker annotation" => (
	data   => <<'EODATA',
public @ interface Foo { }
EODATA
	expect => ignore,
);

test_rule "AnnotationTypeDeclaration / single value annotation" => (
	data   => <<'EODATA',
public @ interface Foo {
	long foo() default 0L;
}
EODATA
	expect => ignore,
);

test_rule "AnnotationTypeDeclaration / normal annotation" => (
	data   => <<'EODATA',
public @ interface Foo {
	long foo();
	String bar();
}
EODATA
	expect => ignore,
);

had_no_warnings;

done_testing;
