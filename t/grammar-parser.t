#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use Grammar::Parser;

BEGIN { require "test-helper-driver.pl" }

# Grammar::Parser is uniform interface to any underlying driver
behaves_like_grammar_parser_driver 'Grammar::Parser';

