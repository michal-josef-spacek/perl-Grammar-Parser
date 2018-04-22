
use v5.14;
use strict;
use warnings;

package Grammar::Parser::X v1.0.0;

use overload '""' => sub { $_[0]->_format_message };

use Moo;

sub throw {
	my ($self, %params) = @_;

	die $self->new (%params);
}

1;
