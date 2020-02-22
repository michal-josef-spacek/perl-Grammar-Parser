
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Language::Java::Actions v1.0.0 {
	use Ref::Util qw[ is_plain_arrayref ];
	use Ref::Util qw[ is_blessed_arrayref ];
	use List::Util qw[ first ];
	use Scalar::Util qw[ blessed ];

	require Grammar::Parser::Action::Util;

	sub _flatten {
		map { is_plain_arrayref ($_) ? @$_ : $_ } @_;
	}

	sub rule_dom {
		my ($parser, $name, @context) = _flatten @_;

		my $result;

		TOKENS_ONLY:
		{
			for my $element (@context) {
				next if blessed ($element) && $element->isa ('Grammar::Parser::Lexer::Token');
				last TOKENS_ONLY;
			}

			$result = rule_dom_token ($parser, $name, @context);
		}

		 $result //= rule_default ($parser, $name, @context);

		# TODO: construct instance ...
		return +{
			CSI::Language::Java::Grammar->dom_for ($name),
			$result->{$name},
		};
	}

	sub rule_dom_token {
		my ($context, $name, @tokens) = @_;

		my $value = join '', map $_->value, @tokens;

		+{ $name => $value };
	}

	my %char_escape_map = (
		# eg: https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-EscapeSequence
		'b' => 0x0008,
		't' => 0x0009,
		'n' => 0x000a,
		'f' => 0x000c,
		'r' => 0x000d,
		'"' => 0x0022,
		"'" => 0x0027,
		'\\' => 0x005c,
	);

	sub _unescape {
		my ($value) = @_;

		my $regex = CSI::Language::Java::Grammar->grammar->{Escape_Sequence};
		$regex = $$regex;
		$regex = $regex->[0];

		$value =~ s{$regex}{
			my $result;
			$result //= chr $char_escape_map{$+{char_escape}} if exists $+{char_escape};
			$result //= chr oct $+{octal_escape} if exists $+{octal_escape};
			$result //= chr hex $+{hex_escape} if exists $+{hex_escape};
			$result;
		}ger;
	}

	sub rule_integral_value {
		Grammar::Parser::Action::Util::rule_handler_literal_value (@_);
	}

	sub rule_float_value {
		Grammar::Parser::Action::Util::rule_handler_literal_value (@_);
	}

	sub rule_literal_unescape {
		my (undef, $name, @values) = @_;
		my $token = first { blessed $_ } @values;

		return +{ $name => _unescape ($token->value) };
	}


	sub rule_skip {
		[];
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

