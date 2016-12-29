
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Driver v1.0.0 {
	use Moo;
	use Scalar::Util qw[];
	use Ref::Util qw[ is_arrayref ];
	use Ref::Util qw[ is_hashref ];
	use Ref::Util qw[ is_coderef ];

	use Grammar::Parser::Grammar;

	use namespace::clean;

	has _grammar => (
		is       => 'ro',
		init_arg => 'grammar',
		required => 1,
	);

	has _action_name => (
		is       => 'ro',
		init_arg => 'action_name',
	);

	has _action_map => (
		is       => 'ro',
		init_arg => 'action_map',
	);

	has _action_lookup => (
		is       => 'ro',
		init_arg => 'action_lookup',
		default  => sub { [] },
	);

	has _result_class => (
		is       => 'ro',
		init_arg => 'result_class',
	);

	around BUILDARGS => sub {
		my ($orig, $self, %params) = @_;

		if ($params{grammar}) {
			$params{grammar} = $params{grammar}->new
				unless ref $params{grammar};

			$params{grammar} = Grammar::Parser::Grammar->new (
				grammar        => $params{grammar},
				(start         => $params{start})         x!! $params{start},
				(empty         => $params{empty})         x!! $params{empty},
				(insignificant => $params{insignificant}) x!! $params{insignificant},
			) unless Scalar::Util::blessed $params{grammar};

			delete @params{qw[ start empty insignificant ]};
		}

		$params{result_class} //= delete $params{result}
			if exists $params{result};

		if ($params{action_lookup}) {
			my @action_lookup = ($params{action_lookup});
			my @flatten;

			while (@action_lookup) {
				my $head = shift @action_lookup;

				next
					unless defined $head;

				push @flatten, $head and next
					unless is_arrayref $head;

				unshift @action_lookup, @$head;
			}

			$params{action_lookup} = \ @flatten;
		}

		return $self->$orig (%params);
	};

	sub build_instance_grammar {
		my ($self, %params) = @_;

		$self->_grammar->new (%params);
	}

	sub action_lookup_for {
		my ($self, $action_name) = @_;

		return $action_name if is_coderef ($action_name);

		my @action_lookup = @{ $self->_action_lookup };

		my $retval;
		my $autoload;

		until (defined $retval) {
			last unless my $current = shift @action_lookup;

			if (is_hashref $current) {
				$retval = $current->{$action_name};
				$autoload //= $current->{AUTOLOAD};
				next;
			}

			$retval = $current->can ($action_name);
			$autoload //= $current->can ('AUTOLOAD');
		}

		return $retval // $autoload // sub { die "noop: $action_name" ; ()};
	}

	sub action_name_for {
		my ($self, $rule) = @_;
		local $_;

		$rule = $_->($rule) if $_ = $self->_action_name;
		$rule = $_->{$rule} if $_ = $self->_action_map and exists $_->{$rule};

		return $rule;
	}

	sub instance {
		...;
	}

	sub parse {
		my ($self, @data) = @_;

		my $result = $self->instance->parse (@data);

		$result = $self->_result_class->new ($result)
			if $self->_result_class;

		return $result;
	}
}

1;

__END__

=head1 NAME

Grammar::Parser::Driver - driver base class

=head1 SYNOPSIS

   package Grammar::Parser::Driver::Foo::Bar;
   use parent 'Grammar::Parser::Driver';

   ...;

=head1 DESCRIPTION

=head2 Constructor

=over

=item grammar

Grammar package name, L<< Grammar::Parser::Grammar >> instance, or arrayref
as accepted by Grammar::Parser::Grammar's C<< grammar >> constructor parameter.

In case of arrayref also consumes parameters C<< start >>, C<< empty >>, and C<< insignificant >>

=item result_class

Package providing AST transformation.

=item action_name

Function to transform rule name into action name.

=item action_map

Simplest form of rule to action transformation hashref with C<< rule => action >> pairs.

=item action_lookup

List (arrayref) of action to code lookups.

=over

=item package name

=item dispatch table

=item another arrayref of same types

=back

Action lookup first examines entries for exact match.
If coderef is not found, repeates search with action name C<< AUTOLOAD >>

=back
