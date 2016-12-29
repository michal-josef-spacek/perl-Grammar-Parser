
use v5.12;
use strict;
use warnings;

package Grammar::Parser::Driver::Instance v1.0.0;

use Moo;

has driver => (
	is => 'ro',
);

has stash => (
    is => 'ro',
    default => sub { +{} },
);

sub parse {
    ...;
}

sub result {
    ...;
}

sub run_action {
	my ($self, $rule, $value) = @_;

	my $name = $self->driver->action_name_for ($rule);
	my $code = $self->driver->action_lookup_for ($name);

	return $value unless $code;
	return $code->($self, $rule, $value);
}

1;

