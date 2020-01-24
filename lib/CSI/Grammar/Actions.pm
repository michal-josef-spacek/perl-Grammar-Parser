
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Grammar::Actions v1.0.0 {
	use Grammar::Parser::Action::Util (
		{ action_prefix => 'rule_' },
		action_name  => { as => 'action_name' },

		alias         => { is => 'alias' },
		default       => { is => 'default' },
		list          => { is => 'list' },
		literal       => { is => 'literal' },
		literal_value => { is => 'literal_value' },
		pass_through  => { is => 'pass_through' },
		symbol        => { is => 'symbol' },
	);
};

1;

