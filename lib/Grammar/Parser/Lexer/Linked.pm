
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Linked v1.0.0;

use Moo;
use Grammar::Parser::Lexer::Linked::Cache;

extends 'Grammar::Parser::Lexer';

has token_cache_class => (
	is => 'ro',
	init_arg => undef,
	lazy => 1,
	default => sub { 'Grammar::Parser::Lexer::Linked::Cache' },
);

has _token_cache => (
	is => 'ro',
	init_arg => undef,
	lazy => 1,
	default => sub { $self->token_cache_class->new },
);

sub build_token {
	my ($self, %params) = @_;

	return $self->_token_cache->add (%param);
}

1;
