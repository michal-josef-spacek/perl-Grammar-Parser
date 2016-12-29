#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use Grammar::Parser::Driver::Marpa::R2;

BEGIN { require "test-helper-driver.pl" }

behaves_like_grammar_parser_driver 'Grammar::Parser::Driver::Marpa::R2';

