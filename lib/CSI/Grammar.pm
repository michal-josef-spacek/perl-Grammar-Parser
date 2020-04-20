
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package CSI::Grammar v1.0.0 {
	require Exporter;

	use CSI::Grammar::Meta;
	use CSI::Grammar::Actions;

	my $anonymous_counter = "000000";

	sub import {
		my ($class, @params) = @_;

		return unless $class eq __PACKAGE__;
		my $caller = scalar caller;

		our @EXPORT = (
			qw[ keyword register_action_lookup ],
			qw[ insignificant start ],
			qw[ rule regex token ],
		);

		{
			no strict 'refs';

			my $meta = CSI::Grammar::Meta->new (class => $caller);
			$meta->prepend_action_lookup ("CSI::Grammar::Actions::__::${\ ++$anonymous_counter }::$class");
			*{"${caller}::__csi_grammar"} = sub { $meta };

			push @{ "${caller}::ISA" }, __PACKAGE__;
		}

		goto &Exporter::import;
	}

	sub _common {
		my ($class, $rule_name, @def) = @_;
		state $label_map = {
			dom    => 'DOM',
			action => 'ACTION',
			proto  => 'PROTO',
		};

		while (@def) {
			last if ref $def[0];
			last unless exists $label_map->{$def[0]};

			my ($key, $value) = (shift @def, shift @def);
			goto $label_map->{$key};

			ACTION:
			$class->__csi_grammar->add_action ($rule_name => $value)
				unless $class->__csi_grammar->dom_for ($rule_name);
			next;

			DOM:
			$class->__csi_grammar->add_dom ($rule_name => $value);
			$class->__csi_grammar->add_action ($rule_name => 'dom');
			next;

			PROTO:
			$class->__csi_grammar->append_rule ($value => \ $rule_name);
			next;
		}

		@def;
	}

	sub _ensure_unique_grammar_symbol {
		my ($class, $rule_name) = @_;

		die "Rule $rule_name already defined"
			if $class->__csi_grammar->rule_exists ($rule_name);
	}

	sub rule {
		my ($rule_name, @def) = @_;
		my $class = scalar caller;

		$class->__csi_grammar->add_rule ($rule_name => [ _common $class, $rule_name, action => 'default', @def ]);

		$rule_name;
	}

	sub regex {
		my ($rule_name, @def) = @_;
		my $class = scalar caller;

		$class->__csi_grammar->add_rule ($rule_name => \ [ @def ]);

		$rule_name;
	}

	sub token {
		my ($rule_name, @def) = @_;
		my $class = scalar caller;

		_ensure_unique_grammar_symbol $class, $rule_name;

		$class->__csi_grammar->add_rule ($rule_name => [ _common $class, $rule_name, action => 'literal', @def ]);

		$rule_name;
	}

	sub insignificant {
		my ($name, @rest) = @_;
		my $class = scalar caller;

		$class->__csi_grammar->append_insignificant ($name);

		($name, @rest);
	}

	sub start {
		my ($name, @rest) = @_;
		my $class = scalar caller;

		$class->__csi_grammar->start ($name);

		($name, @rest);
	}

	sub register_action_lookup {
		(scalar caller)->__csi_grammar->prepend_action_lookup (@_);
	}

	sub grammar {
		$_[0]->__csi_grammar->grammar;
	}

	sub actions {
		$_[0]->__csi_grammar->actions;
	}

	sub start_rule {
		$_[0]->__csi_grammar->start;
	}

	sub insignificant_rules {
		$_[0]->__csi_grammar->insignificant;
	}

	sub action_lookup {
		$_[0]->__csi_grammar->action_lookup;
	}

	sub _build_grammar {
		my ($self) = @_;

		Grammar::Parser::Grammar->new (
			grammar       => $self->grammar,
			start         => $self->start_rule,
			insignificant => $self->insignificant_rules,
		);
	}

	sub dom_for {
		$_[0]->__csi_grammar->dom_for ($_[1]);
	}
};

1;
