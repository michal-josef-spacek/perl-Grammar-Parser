
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

	has start => (
		is => 'rw',
	);

	sub add_rule {
		my ($self, $rule, $def) = @_;

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
};

1;
