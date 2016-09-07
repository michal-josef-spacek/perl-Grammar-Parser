#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

plan tests => 4 + 1;

note "Imported action_name and rules can have custom action prefix";

use Grammar::Parser::Action::Util (
	{ action_prefix => 'verify' },
	qw( rule action_name ),
);

rule alias1 => 'alias';
rule alias2 => 'alias';

can_ok __PACKAGE__, 'rule';
can_ok __PACKAGE__, 'verifyaction_name';
can_ok __PACKAGE__, 'verifyalias1';
can_ok __PACKAGE__, 'verifyalias2';

had_no_warnings;

done_testing;
