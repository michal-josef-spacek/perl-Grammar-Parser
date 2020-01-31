
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Language::Java::Actions v1.0.0 {
	use Ref::Util qw[ is_plain_arrayref ];
	use Ref::Util qw[ is_blessed_arrayref ];

	require Grammar::Parser::Action::Util;

	sub rule_integer_value {
		Grammar::Parser::Action::Util::rule_handler_literal_value (@_);
	}

	sub _flatten {
		map { is_plain_arrayref ($_) ? @$_ : $_ } @_;
	}

	sub rule_token {
		my ($context, $name, $token) = @_;

		+{ $name => $token->value };
	}

	sub rule_default {
		my ($context, $name, @elements) = _flatten @_;

		+{ $name => \@elements };
	}

	sub rule_pass_through {
		my ($context, $name, @elements) = _flatten @_;

		\@elements;
	}

	sub rule_list {
		my ($context, $name, @elements) = _flatten @_;

		my $list = exists $elements[-1]{$name}
			? pop @elements
			: { $name => [] },
			;

		unshift @{ $list->{$name} }, @elements;

		$list;
	}
};

1;

