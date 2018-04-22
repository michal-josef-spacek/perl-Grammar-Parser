
use v5.14;
use strict;
use warnings;

package Grammar::Parser::X::Lexer::Notfound v1.0.0;

use parent 'Grammar::Parser::X';

use Moo;

has line => (
	is => 'ro',
	required => 1,
);

has column => (
	is => 'ro',
	required => 1,
);

has near_data => (
	is => 'ro',
	required => 1,
);

has expected => (
	is => 'ro',
	required => 1,
);

sub _format_message {
	my ($self) = @_;
	local $" = ' ';

	return "Unrecognized token at line:${\ $self->line } column:${\ $self->column } near:>${\ $self->near_data }.\n  expected symbol(s): @{ $self->expected }";
}

1;

