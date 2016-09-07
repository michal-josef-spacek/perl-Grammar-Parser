#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

plan tests => 4 + 1;

note "Default prefix is 'rule_'";

use Grammar::Parser::Action::Util qw( rule action_name );

rule alias1 => 'alias';
rule alias2 => 'alias';

can_ok __PACKAGE__, 'rule';
can_ok __PACKAGE__, 'rule_action_name';
can_ok __PACKAGE__, 'rule_alias1';
can_ok __PACKAGE__, 'rule_alias2';

had_no_warnings;

done_testing;

