
use Syntax::Construct 1.008 qw[ package-version package-block ];

use v5.14;
use strict;
use warnings;

package Grammar::Parser::Lexer v1.0.0 {

	use Moo;
	use Ref::Util qw[ is_regexpref ];

	use Grammar::Parser::X::Lexer::Notfound;
	use Grammar::Parser::Lexer::Builder::Token;
	use Grammar::Parser::Lexer::Builder::Lexeme;

	use namespace::clean;

	has lexemes         => (
		is              => 'ro',
		required        => 1,
	);

	has insignificant   => (
		is              => 'ro',
		default         => sub { +[] },
	);

	has final_token     => (
		is              => 'ro',
		default         => sub { undef },
	);

	has lexeme_builder_class => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { 'Grammar::Parser::Lexer::Builder::Lexeme' },
	);

	has token_builder_class => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { 'Grammar::Parser::Lexer::Builder::Token' },
	);

	has token_builder   => (
		is              => 'ro',
		lazy            => 1,
		default         => sub { $_[0]->token_builder_class->new },
	);

	has _lexeme_map     => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_lexeme_map',
	);

	has _insignificant_map => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_insignificant_map',
	);

	has _accepted_map   => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_accepted_map',
	);

	has _data           => (
		init_arg        => undef,
		is              => 'rw',
		default         => sub { \ (my $o = '') },
	);

	has _line           => (
		init_arg        => undef,
		is              => 'rw',
		default         => sub { 1 },
	);

	has _column         => (
		init_arg        => undef,
		is              => 'rw',
		default         => sub { 1 },
	);

	sub _build_lexeme_map {
		my ($self) = @_;

		my %lexeme_map;
		while (my ($name, $definition) = each %{ $self->lexemes } ) {
			my $lexeme = $self->lexeme_builder_class->build (@$definition);

			next unless $lexeme;

			$lexeme_map{$name} = $lexeme;
		}

		\ %lexeme_map;
	}

	sub _build_insignificant_map {
		my ($self) = @_;

		my $lexeme_map = $self->_lexeme_map;

		+{ map +($_ => 1), grep exists $lexeme_map->{$_}, @{ $self->insignificant } };
	}

	sub _build_accepted_map {
		my ($self) = @_;
		my $insignificant = $self->insignificant;

		my %map;
		@map{ keys %{ $self->_lexeme_map } } = ();
		delete @map{ keys %{ $self->_insignificant_map } };

		\%map;
	}

	sub _prepare_accepted_tokens {
		my ($self, $accepted) = @_;

		return $self->_accepted_map
			unless scalar @$accepted;

		my %hash;
		@hash{@$accepted} = ();

		return \%hash;
	}

	sub _prepare_allowed_tokens {
		my ($self, $accepted) = @_;
		$accepted = { %$accepted, %{ $self->_insignificant_map } };

		return [ @{ $self->_lexeme_map }{ keys %$accepted } ];
	}

	sub _build_token {
		my ($self, %params) = @_;

		return $self->token_builder->build (%params);
	}

	sub _lookup_best_match {
		my ($self, @allowed) = @_;

		my $data = $self->_data;

		# end of data
		return if $$data =~ m/\A \z/mx;

		my $token;
		my $max_length = 0;
		for my $name (@allowed) {
			my $regex = $self->_lexeme_map->{$name};

			# check if token's regexp matches current data
			next unless my ($match) = $$data =~ m/\A($regex)/mx;

			# try longest match
			next if $max_length > length $match;

			# TODO: how to determine best match ?
			# TODO: for now first match win, order by random
			# TODO: use ?> (how ?)
			next if $max_length == length $match;

			$max_length = length $match;

			my $value = $self->_build_token (
				name		=> $name,
				match		=> $match,
				line		=> $self->_line,
				column      => $self->_column,
				significant => ! exists $self->_insignificant_map->{$name},
				captures	=> { %+ },
			);

			$token = [ $name, $value ];
		}

		$token;
	}

	sub _adjust_data {
		my ($self, $token) = @_;

		my $match_length = length $token->[1]->match;

		# Symbol found, so get rid of match
		my $full = substr ${ $self->_data }, 0, $match_length, '';
		my (@parts) = split m/\n/, $full, -1;

		$self->_line ($self->_line + @parts - 1);
		$self->_column (1) if @parts > 1;
		$self->_column ($self->_column + length $parts[-1]);

		();
	}

	sub _report_error {
		my ($self, @accepted) = @_;

		my $data = ${ $self->_data };
		substr ($data, 97) = '...' if length $data > 100;
		Grammar::Parser::X::Lexer::Notfound->throw (
			line        => $self->_line,
			column      => $self->_column,
			near_data   => $data,
			expected    => \ @accepted,
		)
	}

	sub push_data {
		my ($self, @pieces) = @_;

		${ $self->_data } .= join '', @pieces;

		return;
	}

	sub next_token {
		my ($self, @accepted) = @_;
		my $insignificant_map = $self->_insignificant_map;

		@accepted = grep ! exists $insignificant_map->{$_}, keys %{ $self->_lexeme_map }
			unless @accepted;

		my %accepted = map +($_ => 1), @accepted;
		my %allowed  = map +($_ => 1), @accepted, keys %$insignificant_map;

		my $token;
		until ($token) {
			$token = $self->_lookup_best_match (keys %allowed);

			last unless $token;

			$self->_adjust_data ($token);

			last if exists $accepted{$token->[0]};

			$token = undef;
		}

		return $token if $token;
		return [] unless length ${ $self->_data };

		$self->_report_error (@accepted);
	}
};

1;

__END__

=head1 NAME

Grammar::Parser::Lexer - generic lexer

=head1 SYNOPSIS

	my $lexer = Grammar::Parser::Lexer (
		lexemes => {
			number      => qr/\d+/,
			or          => '|',
			whitespaces => qr/\s+/,
			comment     => [ qr/ \/\/ .* /x, gr/ \/\* [\s\S]* \*\/x ],
		},
		insignificant => [qw[ whitespaces comment ]],
	);

	$lexer->push_data ($_) while <>;

	my $token = $lexer->next_token;
	my $token = $lexer->next_token (@allowed);

=head1 DESCRIPTION

Generic lexer module

=head1 METHODS

=head2 new (%arguments)

Create new lexer.

Recognizes named arguments:

=over

=item tokens

Hashref with token names as keys and their definition as values

=item insignificant

Arrayref, list of token names that are treated as insignificant (ie omitted by default)

=item final_token

Name of token considered as terminal token.

Once reached lexer stops parsing and adds capture C<remaining_data> into returned
token (it doesn't affect token's C<match> property)

=back

=head2 push_data (@data)

Appends more data

=head2 next_token (@accepted)

Examine current data to find next token.

Unless explicitly specified all significant tokens are considered.

Unless explicitly specified all insignificant tokens are skipped.

Returns C<name> => C<value> pair where name is token name and value is an instance
of L<< Grammar::Parser::Lexer::Token >>.

Returns empty list if there is no more data (or final token was reached)

If requested token is not found and there are still data left,
throws exception L<< Grammar::Parser::X::Lexer::Notfound >>.

=head2 final_token

Significant token name.

When specified lexer stops parsing data after reaching it.

Use case for example: parse HTTP header from HTTP response stream.

Final token instance is constructed with pseudo capture group C<remaining_data>.

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<Grammar::Parser>.
It can be distributed and modified under Artistic license 2.0

=cut


