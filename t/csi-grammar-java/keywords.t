#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-csi-language-java.pl" }

sub test_keyword {
	my ($keyword, %params) = @_;
	$params{allowed_identifier} //= 0;
	$params{allowed_type_name}  //= 0;

	subtest "word $keyword" => sub {
		plan tests => 3;

		test_rule "word $keyword is a keyword" => (
			rule => 'keyword',
			data => $keyword,
			expect => ignore,
		);

		test_rule "word $keyword is${\ ($params{allowed_identifier} ? '' : ' not') } allowed identifier" => (
			rule => "keyword_identifier",
			data => $keyword,
			$params{allowed_identifier}
				? (expect => ignore)
				: (throws => 1)
				,
		);

		test_rule "word $keyword is${\ ($params{allowed_type_name} ? '' : ' not') } allowed type identifier" => (
			rule => "keyword_type_identifier",
			data => $keyword,
			$params{allowed_type_name}
				? (expect => ignore)
				: (throws => 1)
				,
		);
	}
}

sub ALLOWED_IDENTIFIER { allowed_identifier => 1 }
sub ALLOWED_TYPE_NAME  { allowed_type_name  => 1 }

# 1 .... warnings
# 61 ... number of java keywords
plan tests => 1 + 64;

test_keyword _              =>                                       ;
test_keyword abstract       =>                                       ;
test_keyword assert         =>                                       ;
test_keyword boolean        =>                                       ;
test_keyword break          =>                                       ;
test_keyword byte           =>                                       ;
test_keyword case           =>                                       ;
test_keyword catch          =>                                       ;
test_keyword char           =>                                       ;
test_keyword class          =>                                       ;
test_keyword const          =>                                       ;
test_keyword continue       =>                                       ;
test_keyword default        =>                                       ;
test_keyword do             =>                                       ;
test_keyword double         =>                                       ;
test_keyword else           =>                                       ;
test_keyword enum           =>                                       ;
test_keyword exports        => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword extends        =>                                       ;
test_keyword false          =>                                       ;
test_keyword final          =>                                       ;
test_keyword finally        =>                                       ;
test_keyword float          =>                                       ;
test_keyword for            =>                                       ;
test_keyword goto           =>                                       ;
test_keyword if             =>                                       ;
test_keyword implements     =>                                       ;
test_keyword import         =>                                       ;
test_keyword instanceof     =>                                       ;
test_keyword int            =>                                       ;
test_keyword interface      =>                                       ;
test_keyword long           =>                                       ;
test_keyword module         => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword native         =>                                       ;
test_keyword new            =>                                       ;
test_keyword null           =>                                       ;
test_keyword open           => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword opens          => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword package        =>                                       ;
test_keyword private        =>                                       ;
test_keyword protected      =>                                       ;
test_keyword provides       => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword public         =>                                       ;
test_keyword requires       => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword return         =>                                       ;
test_keyword short          =>                                       ;
test_keyword static         =>                                       ;
test_keyword strictfp       =>                                       ;
test_keyword super          =>                                       ;
test_keyword switch         =>                                       ;
test_keyword synchronized   =>                                       ;
test_keyword this           =>                                       ;
test_keyword throw          =>                                       ;
test_keyword throws         =>                                       ;
test_keyword to             => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword transient      =>                                       ;
test_keyword true           =>                                       ;
test_keyword try            =>                                       ;
test_keyword uses           => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;
test_keyword var            => ALLOWED_IDENTIFIER,                   ;
test_keyword void           =>                                       ;
test_keyword volatile       =>                                       ;
test_keyword while          =>                                       ;
test_keyword with           => ALLOWED_IDENTIFIER, ALLOWED_TYPE_NAME ;

had_no_warnings;

done_testing;
