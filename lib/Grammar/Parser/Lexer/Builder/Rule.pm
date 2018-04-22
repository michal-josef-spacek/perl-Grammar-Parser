
use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer::Builder::Rule v1.0.0;

use Ref::Util qw[ is_ref is_regexpref is_hashref ];

use namespace::clean;

sub build {
	my ($self, $name, $definition) = @_;

	my @list = map $self->_build_one_rule ($name, $_), @$definition;

	return
		unless @list;

	@list = join '|', @list
		if @list > 1;

	return $list[0];
}

sub _build_one_rule {
	my ($self, $name, $definition) = @_;

	return qr/\Q$_\E/
		unless is_ref ($definition);

	return $definition
		if is_regexpref ($definition);

	return
		unless is_hashref ($definition);

	return $self->_build_keyword ($name, $definition)
		if exists $definition->{keyword};

	return;
}

sub _build_keyword {
	my ($self, $name, $definition) = @_;
}

1;
