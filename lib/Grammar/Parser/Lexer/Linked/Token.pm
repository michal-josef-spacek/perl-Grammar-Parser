
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Linked::Token v1.0.0;

use Moo;

extends 'Grammar::Parser::Lexer::Token';

has _cache => (
	is => 'ro',
	init_arg => '-cache',
);

has _index => (
	is => 'ro',
	init_arg => '-index',
);

sub next_sibling {
	my ($self) = @_;

	return $self->_cache->next_for ($self->_index);
}

sub next_significant_sibling {
	my ($self) = @_;

	my $token = $self;
	while (1) {
		$token = $token->next_sibling;
		last unless $token;
		last if $token->significant;
	}

	return $token;
}

sub previous_sibling {
	my ($self) = @_;

	return $self->_cache->previous_for ($self->_index);
}

sub previous_significant_sibling {
	my ($self) = @_;

	my $token = $self;
	while (1) {
		$token = $token->previous_sibling;
		last unless $token;
		last if $token->significant;
	}

	return $token;
}

1;
