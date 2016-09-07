#!/usr/bin/env perl

use v5.14;

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper-common.pl" }

plan tests => 4 + 1;

note "Action::Util can import rule handler directly";

use Grammar::Parser::Action::Util (
	{ action_prefix => 'prefix' },
	action_name => { as => 'custom_action_name' },
	alias1      => { is => 'alias', as => 'custom_alias1' },
	alias2      => { is => 'alias' },
);


ok "should not import rule()",
	got    => ! __PACKAGE__->can ('rule'),
;

can_ok __PACKAGE__, 'custom_action_name';
can_ok __PACKAGE__, 'custom_alias1';
can_ok __PACKAGE__, 'prefixalias2';

had_no_warnings;

done_testing;
