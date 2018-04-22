
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Token v1.0.0;

use Moo;

has name => (
	is => 'ro',
);

has match => (
	is => 'ro',
);

has column => (
	is => 'ro',
);

has line => (
	is => 'ro',
);

has significant => (
	is => 'ro',
);

has captures => (
	is => 'ro',
	default => sub { +{} },
);

sub value {
	my ($self) = @_;

	return $self->capture ('value') // $self->match;
}

sub capture {
	my ($self, $name) = @_;

	return $self->captures->{$name};
}

1;

