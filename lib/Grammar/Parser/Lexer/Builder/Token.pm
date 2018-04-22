
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Builder::Token v1.0.0;

use Grammar::Parser::Lexer::Token;

sub new {
	my ($class) = @_;

	return $class;
}

sub build {
	my ($self, %params) = @_;

	Grammar::Parser::Lexer::Token->new (%params);
}

1;
