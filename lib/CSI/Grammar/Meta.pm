
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Grammar::Meta v1.0.0 {
	use Moo;

	has class => (
		is => 'ro',
	);

	has grammar => (
		is => 'ro',
		init_arg => undef,
		default => sub { +{} },
	);

	has _dom => (
		is => 'ro',
		init_arg => undef,
		default => sub { +{} },
	);

	has actions => (
		is => 'ro',
		init_arg => undef,
		default => sub { +{} },
	);

	has insignificant => (
		is => 'ro',
		init_arg => undef,
		default => sub { +[] },
	);

	has action_lookup => (
		is => 'ro',
		init_arg => undef,
		default => sub { +[qw[ CSI::Grammar::Actions ]] },
	);

	has default_rule_action => (
		is => 'rw',
		init_arg => undef,
		default => sub { 'default' },
	);

	has default_token_action => (
		is => 'rw',
		init_arg => undef,
		default => sub { 'literal' },
	);

	has start => (
		is => 'rw',
	);

	has rule_name_order_check => (
		is => 'rw',
		init_arg => undef,
		default => sub { 0 },
	);

	has last_rule => (
		is => 'rw',
		init_arg => undef,
	);

	sub add_rule {
		my ($self, $rule, $def) = @_;

		if ($self->rule_name_order_check) {
			warn "Rule $rule should be defined before ${\ $self->last_rule }"
				if $rule lt $self->last_rule;
			$self->last_rule ($rule);
		}

		$self->grammar->{$rule} = $def;
	}

	sub append_rule {
		my ($self, $rule, $def) = @_;

		push @{ $self->grammar->{$rule} //= [] }, $def;
	}

	sub rule_exists {
		my ($self, $rule) = @_;

		exists $self->grammar->{$rule};
	}

	sub add_action {
		my ($self, $rule, $action) = @_;

		return unless $action;

		$action = 'rule_' . $action
			unless ref $action;

		$self->actions->{$rule} = $action;
	}

	sub action_exists {
		my ($self, $rule) = @_;

		exists $self->actions->{$rule};
	}

	sub append_insignificant {
		my ($self, @rules) = @_;

		push @{ $self->insignificant }, @rules;
	}

	sub prepend_action_lookup {
		my ($self, @loookup) = @_;

		unshift @{ $self->action_lookup }, @loookup;
	}

	sub add_dom {
		my ($self, $rule, $class) = @_;

		$self->_dom->{$rule} = $class;
	}

	sub dom_for {
		my ($self, $rule) = @_;

		$self->_dom->{$rule};
	}

	sub ensure_rule_name_order {
		my ($self) = @_;

		$self->rule_name_order_check (1);
		$self->last_rule ('');
	}

	sub reset_rule_name_order {
		my ($self) = @_;

		$self->rule_name_order_check (0);
	}

	1;
};
