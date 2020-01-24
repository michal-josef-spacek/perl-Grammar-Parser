
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Grammar v1.0.0 {
	use Attribute::Handlers;
	require Exporter;

	use CSI::Grammar::Actions;

	my %grammar;
	my %regex;
	my %action;
	my %start;
	my %insignificant;

	sub import {
		my ($class, @params) = @_;

		return unless $class eq __PACKAGE__;
		my $caller = scalar caller;

		our @EXPORT = (
			qw[ keyword ],
			qw[ insignificant start ],
			qw[ rule regex token ],
		);

		goto &Exporter::import;
	}

	sub _common {
		my ($class, $rule_name, @def) = @_;
		state $label_map = {
			action => 'ACTION',
			proto  => 'PROTO',
		};

		while (@def) {
			last if ref $def[0];
			last unless exists $label_map->{$def[0]};

			my ($key, $value) = (shift @def, shift @def);
			goto $label_map->{$key};

			ACTION:
			$action{$class}{$rule_name} = "rule_$value";
			next;

			PROTO:
			push @{ $grammar{$class}{$value} //= [] }, \ $rule_name;
			next;
		}

		@def;
	}

	sub _token {
		my ($class, $rule_name, @def) = @_;

		$grammar{$class}{$rule_name} //= [ _common $class, $rule_name, action => 'literal', @def ];

		$rule_name;
	}

	sub _regex {
		my ($class, $rule_name, @def) = @_;

		$grammar{$class}{$rule_name} //= \ [ @def ];

		$rule_name;
	}

	sub _insignificant {
		my ($class, $name, @rest) = @_;

		push @{ $insignificant{$class} }, $name;

		($name, @rest);
	}

	sub _start {
		my ($class, $name, @rest) = @_;

		$start{$class} = $name;

		($name, @rest);
	}

	sub rule {
		my ($rule_name, @def) = @_;
		my $class = scalar caller;

		$grammar{$class}{$rule_name} //= [ _common $class, $rule_name, action => 'default', @def ];

		$rule_name;
	}

	sub regex {
		_regex scalar caller, @_;
	}

	sub token {
		_token scalar caller, @_;
	}

	sub insignificant {
		_insignificant scalar caller, @_;
	}

	sub start {
		_start scalar caller, @_;
	}

	sub keyword {
		my ($name, @def) = @_;

		my $keyword = lc $name;
		(
			$name,
			proto => 'Keyword',
			@def,
			eval "qr/(?> \\b $keyword \\b )/sx",
		);
	}

	sub _rule_name {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;
		*{ $symbol }{NAME};
	}

	sub _grammar_element {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		my $value =
		$grammar{$class}{_rule_name @_} = $class->$referent;

		return;

		my $name = _rule_name @_;

		return if $name eq 'TOP';

		die "$name contains empty rule"
			if grep { ! defined $_->[0] } grep Ref::Util::is_arrayref ($_), @$value;

		die "$name references itself"
			if grep { $_->[0] eq $name } grep Ref::Util::is_arrayref ($_), @$value;
	}

	sub _action {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		my $action = lc $attr_name =~ s/^ACTION_//r;

		$action{$class}{_rule_name @_} = "rule_$action";
	}

	sub RULE                :ATTR(CODE) { &_grammar_element }
	sub TOKEN               :ATTR(CODE) {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		_token $class, _rule_name (@_), $class->$referent;
	}

	sub REGEX               :ATTR(CODE) {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		_regex $class, _rule_name (@_), $class->$referent;
	}

	sub ACTION_ALIAS        :ATTR(CODE) { &_action }
	sub ACTION_DEFAULT      :ATTR(CODE) { &_action }
	sub ACTION_LIST         :ATTR(CODE) { &_action }
	sub ACTION_LITERAL      :ATTR(CODE) { &_action }
	sub ACTION_LITERAL_VALUE:ATTR(CODE) { &_action }
	sub ACTION_PASS_THROUGH :ATTR(CODE) { &_action }
	sub ACTION_SYMBOL       :ATTR(CODE) { &_action }
	sub START               :ATTR(CODE) {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		_start $class, _rule_name @_;

		&_grammar_element;
	}

	sub INSIGNIFICANT       :ATTR(CODE) {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		_insignificant $class, _rule_name @_;

		TOKEN (@_);
	}

	sub PROTO               :ATTR(CODE) {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		# TODO: multiple prototypes (TOKEN / RULE)
		# TODO: TOKEN only prototypes should be expanded as regex groups
		eval {
			my $rule_name = _rule_name @_;
			for my $proto (@$attr_data) {
				push @{ $grammar{$class}{$proto} //= [] }, \ $rule_name;
			}
		};

		if ($@) {
			say "Attribute handler PROTO";
			p $attr_data;
			exit;
		}
	}

	sub TRANSFORM           :ATTR(CODE) {
		my ($class, $symbol, $referent, $attr_name, $attr_data, $phase) = @_;

		# capture group transformation callback
		my $rule_name = _rule_name @_;
		return unless $rule_name eq 'LITERAL_STRING';
		use DDP;
		p $attr_data;

		my ($key, $transform) = @$attr_data;

		$action{$class}{_rule_name @_} = sub {
			my ($instance, $name, $token) = @_;

			$token->$key ($class->$transform ($token->$key));
			p $token;
			say "Found rule handler: $rule_name";
			$token;
		}
	}

	sub TRAIT               :ATTR(CODE) {
		# what role has to be applied on result
		# examples: Literal, Statement, Statement::Loop, Expression, Operator, Separator, ...
	}

	sub grammar {
		my ($self) = @_;
		$self = ref $self if ref $self;

		$grammar{$self};
	}

	sub actions {
		my ($self) = @_;
		$self = ref $self if ref $self;

		$action{$self};
	}

	sub start_rule {
		my ($self) = @_;

		$self = ref $self if ref $self;

		$start{$self};
	}

	sub insignificant_rules {
		my ($self) = @_;

		$self = ref $self if ref $self;

		$insignificant{$self} // [];
	}

	sub _build_grammar {
		my ($self) = @_;

		Grammar::Parser::Grammar->new (
			grammar       => $self->grammar,
			start         => $self->start_rule,
			insignificant => $self->insignificant_rules,
		);
	}
};

1;
