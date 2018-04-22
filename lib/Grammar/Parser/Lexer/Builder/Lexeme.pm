
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Builder::Lexeme v1.0.0;

use Ref::Util qw[ is_regexpref ];

use namespace::clean;

sub build {
	my ($self, @rules) = @_;

	my @list = map $self->_build_one_rule ($_), @rules;

	return unless @list;
	return join '|', @list;
}

sub _build_one_rule {
	my ($self, $rule) = @_;

	return $rule if is_regexpref ($_);
	return qr/\Q$_\E/;
}

1;
