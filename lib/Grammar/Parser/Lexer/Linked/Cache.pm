
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Linked::Cache v1.0.0;

use Moo;
use Grammar::Parser::Lexer::Linked::Token;

has _last_index => (
	is => 'rw',
	init_arg => undef,
	default => sub { -1 },
);

has _all_tokens => (
	is => 'rw',
	init_arg => undef,
	default => sub { [] },
);

has _next_tokens => (
	is => 'rw',
	init_arg => undef,
	default => sub { [] },
);

has _prev_tokens => (
	is => 'rw',
	init_arg => undef,
	default => sub { [] },
);

has token_class => (
	is => 'ro',
	default => sub { 'Grammar::Parser::Lexer::Linked::Token' },
);

sub last {
	my ($self) = @_;

	return if $self->_last_index < 0;
	return $self->_all_tokens->[ $self->_last_index ];
}

sub add {
	my ($self, %params) = @_;

	my $last_index = $self->_last_index;
	my $index = 1 + $last_index;

	my $token = $self->token_class->new (
		-cache => $self,
		-index => $index,
		%params,
	);

	if ($last_index > -1) {
		$self->_prev_tokens->[$last_index] = $index;
		$self->_next_tokens->[$index] = $last_index;
	}

	$self->_all_tokens->[$index] = $token;

	return $token;
}

sub previous_for {
	my ($self, $index) = @_;

	return if $index < 0;
	return if $index > @{ $self->_prev_tokens };
	return $self->_prev_tokens->[$index];
}

sub next_for {
	my ($self, $index) = @_;

	return if $index < 0;
	return if $index > @{ $self->_next_tokens };
	return $self->_next_tokens->[$index];
}

1;
