
use v5.14;
use strict;
use warnings FATAL => 'all';
use utf8;

use FindBin;
use lib $FindBin::Bin;

use Test::More;
use Test::Deep;
use Data::Printer;

use Grammar::Parser::BNF::Result;
use Grammar::Parser::BNF::Action;

BEGIN { require "bnf-test-helper.pl" }

sub bnf {
	state $bnf = Grammar::Parser::BNF->new;
}


