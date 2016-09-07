#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

plan tests => 4 + 1;

note "Imported routines can have exact specified names";

use Grammar::Parser::Action::Util (
	{ action_prefix => 'verify' },
	rule        => { as => 'install_rule' },
	action_name => { as => 'custom_action_name' },
);

install_rule alias1 => 'alias';
install_rule alias2 => 'alias';

can_ok __PACKAGE__, 'install_rule';
can_ok __PACKAGE__, 'custom_action_name';
can_ok __PACKAGE__, 'verifyalias1';
can_ok __PACKAGE__, 'verifyalias2';

had_no_warnings;

done_testing;
