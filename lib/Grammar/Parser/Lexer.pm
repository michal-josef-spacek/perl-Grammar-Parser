
use v5.14;
use Syntax::Construct 1.008 qw[ package-version package-block ];

use strict;
use warnings;

package Grammar::Parser::Lexer v1.0.0 {
	use Moo;
	use List::Util 1.45 qw[ uniq ];
	use Ref::Util qw[ is_regexpref ];
	use Ref::Util qw[ is_arrayref ];
	use Ref::Util qw[ is_scalarref ];

	use Grammar::Parser::X::Lexer::Notfound;
	use Grammar::Parser::Lexer::Builder::Token;

	use namespace::clean;

	my $reference_prefix = 'd_';
	my $reference_regex =
		qr/\(\?\?\{ \s* \\? \s* (?<d>[\'\"]) (?<name>(\w+)) \g{d} \s* \}\)/x
		;

	has tokens          => (
		is              => 'ro',
		required        => 1,
	);

	has patterns        => (
		is              => 'ro',
		default         => sub { +{} },
	);

	has insignificant   => (
		is              => 'ro',
		default         => sub { +[] },
	);

	has final_token     => ( # TODO
		is              => 'ro',
		default         => sub { },
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

	has _insignificant_map => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_insignificant_map',
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

	has _significant_tokens => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_significant_tokens',
	);

	has _parser_lookup_regex => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_parser_lookup_regex',
	);

	has _parser_token_map => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_parser_token_map',
	);

	has _parser_def_map => (
		init_arg        => undef,
		is              => 'ro',
		lazy            => 1,
		builder         => '_build_parser_def_map',
	);

	sub _define_referencies {
		my ($self, @referencies) = @_;

		return "" unless @referencies;

		my $def_map = $self->_parser_def_map;

		my %define;
		while (my $ref = shift @referencies) {
			next if exists $define{$ref};

			$define{$ref} = $def_map->{$ref}{regex};
			push @referencies, @{ $def_map->{$ref}{refs} // [] };
		}

		return join "\n\t",
			'(?(DEFINE)',
			(map "(?<$reference_prefix$_>$define{$_})", sort keys %define),
			')',
			;
	}

	sub _build_parser_lookup_regex {
		my ($self) = @_;

		my @tokens = sort keys %{ $self->tokens };

		# lookup regex should provide longest match
		# that is achieved by optional zero-length look-ahead patterns storing match
		# in $LAST_REGEX_CODE_RESULT

		my $template = '(?=((?&' . $reference_prefix . 'NAME))(?{ $^R->{NAME} = $^N; $^R }) )?';
		my $regex = join "\n",
			'(?{ {} })',
			(map { $template =~ s/NAME/$_/gr } @tokens),
			$self->_define_referencies (@tokens),
			;

		use re 'eval';

		# 5.22 .. 5.26 do not like much optional look-ahead
		no warnings;
		return qr/$regex/ux;
	}

	sub _build_parser_token_map {
		my ($self) = @_;

		my $def_map = $self->_parser_def_map;

		my %parser_map;
		for my $token (sort keys %{ $self->tokens } ) {
			my $def = $def_map->{$token};

			my $regex  = $def->{regex};
			my $define = $self->_define_referencies (@{ $def->{refs} });
			$parser_map{$token} = qr/$regex$define/x;
		}

		\ %parser_map;
	}

	sub _build_parser_def_map {
		my ($self) = @_;

		my %regexes = (
			%{ $self->tokens },
			%{ $self->patterns },
		);

		for my $key (keys %regexes) {
			my $regex = $self->_build_single_parser_regex ($key, $regexes{$key});
			my @referencies = $self->_list_regex_referencies ($regex);

			$regexes{$key} = {
				regex => $self->_expand_regex_referencies ($regex),
				refs  => \@referencies,
			};
		}

		\ %regexes;
	}

	sub _list_regex_referencies {
		my ($self, $regex) = @_;

		my %deps;
		while ($regex =~ m/$reference_regex/gc) {
			$deps{$+{name}} = 1;
		}

		return sort keys %deps;
	}

	sub _expand_regex_referencies {
		my ($self, $regex) = @_;

		return $regex =~ s/$reference_regex/(?&$reference_prefix$+{name})/gr;
	}

	sub _build_single_parser_regex {
		my ($self, $name, @definition) = @_;

		my @list;
		while (defined (my $item = shift @definition)) {
			if (is_arrayref ($item)) {
				push @definition, @$item;
				next;
			}

			if (is_regexpref ($item)) {
				push @list, "$item";
				next;
			}

			if (is_scalarref ($item)) {
				push @list, "(??{ '$$item' })";
				next;
			}

			unless (ref $item) {
				push @list, quotemeta $item;
				next;
			}

			die "Invalid regex definition $name => $item ($$item)";
		}

		return $list[0] if @list < 2;

		return "(?:(?:${\ join ')|(?:', @list }))";
	}

	sub _build_insignificant_map {
		my ($self) = @_;

		my $token_map = $self->_parser_token_map;

		+{ map +($_ => 1), grep exists $token_map->{$_}, @{ $self->insignificant } };
	}

	sub _build_significant_tokens {
		my ($self) = @_;

		my $insignificant_map = $self->_insignificant_map;
		[ grep ! exists $insignificant_map->{$_}, keys %{ $self->_parser_token_map } ];
	}

	sub _build_match_value {
		my ($self, %params) = @_;

		$self->token_builder->build (%params);
	}

	sub _lookup_longest_match {
		my ($self, $accepted) = @_;

		${ $self->_data } =~ $self->_parser_lookup_regex;

		my $lookup = $^R;
		return
			unless %$lookup;

		my $token_name =
			List::Util::reduce { length $lookup->{$a} > length $lookup->{$b} ? $a : $b }
			grep { exists $lookup->{$_} }
			$accepted
				? keys %$accepted
				: keys %$lookup
		;

		return
			unless defined $token_name;

		my $match = $lookup->{$token_name};

		$match =~ $self->_parser_token_map->{ $token_name };

		my $value = $self->_build_match_value (
			name		=> $token_name,
			match		=> $match,
			line		=> $self->_line,
			column      => $self->_column,
			significant => ! exists $self->_insignificant_map->{$token_name},
			captures	=> { %+ },
		);

		return [ $token_name, $value ];
	}

	sub _lookup_first_match {
		my ($self, @accepted) = @_;
		state $counter = 0;
		$counter ++;

		@accepted = keys %{ $self->tokens }
			unless @accepted;

		for my $token_name (@accepted) {
			my $regex = $self->_parser_token_map->{$token_name};
			next unless $regex;

			next unless ${ $self->_data } =~ m/^$regex/gc;
			my $match = substr (${ $self->_data}, 0, pos ${ $self->_data});

			my $value = $self->_build_match_value (
				name		=> $token_name,
				match		=> $match,
				line		=> $self->_line,
				column      => $self->_column,
				significant => ! exists $self->_insignificant_map->{$token_name},
				captures	=> { %+ },
			);

			return [ $token_name, $value ];
		}

		();
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
			expected    => [ sort @accepted ],
		)
	}

	sub _parser_token_regex {
		my ($self, $token) = @_;

		$self->_parser_token_map->{$token};
	}

	sub add_data {
		my ($self, @pieces) = @_;

		${ $self->_data } .= join '', @pieces;

		();
	}

	sub next_token {
		my ($self, @accepted) = @_;

		my $priority_token = 'PRIORITY_TOKEN';
		if (grep { $_ eq $priority_token } @accepted) {
			my $value = $self->_build_match_value (
				name		=> $priority_token,
				match		=> '',
				line		=> $self->_line,
				column      => $self->_column,
				significant => 0,
				captures	=> { },
			);
			return [ $priority_token, $value ];
		}

		@accepted = $self->_significant_tokens
			unless @accepted;

		my %accepted;
		my %allowed;

		@accepted{@accepted} = ();
		my @allowed = (@accepted, @{ $self->insignificant });
		@allowed{@allowed} = ();

		my $token;
		until ($token) {
			$token = $self->_lookup_longest_match (\%allowed);
			#$token = $self->_lookup_first_match (@allowed);

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

	# part of SQL grammar
	my $lexer = Grammar::Parser::Lexer (
		tokens => {
			CREATE      => qr/(?> \b CREATE \b)/xi,
			TEMPORARY   => qr/(?> \b TEMP (?: ORARY ) \b)/xi,
			TABLE       => qr/(?> \b TABLE \b)/xi,
			identifier  => qr/(?> (?! (??{ 'keyword' }) (?! \d+ ) \w+/x
		},
		patterns => {
			keyword     => qr/(?> (?&CREATE) | (?&TEMPORARY) | (?&TABLE) )/x,
		},
		insignificant => [qw[ whitespaces comment ]],
	);

	$lexer->add_data ($_) while <>;

	my $token = $lexer->next_token;
	my $token = $lexer->next_token (@allowed);

=head1 DESCRIPTION

Module provides simple input data tokenization.

=head1 METHODS

=head2 new (%arguments)

Create new lexer.

Recognizes named arguments:

=over

=item tokens

Hashref with token name / token pattern pairs.

See L</"PATTERN DEFINITION">

=item patterns

Define named patterns.
Named pattern can be addressed in pattern definition but is not available
as a token (where token name is recognized).

See L</"PATTERN DEFINITION">

=item insignificant

List (arrayref) of tokens that are treated as insignificant.
Insignificant tokens are skipped unless explicitly required.

=item final_token

I<Not implemented yet>

Significant token name, will be treated as end of input data

Once reached, lexer will stop parsing and will add capture C<remaining_data>
(it doesn't affect token's C<match>).

Use case for example: parse HTTP header from HTTP response stream.

=back

=head2 add_data (@data)

Adds more data.

=head2 next_token (@accepted)

Examine current data to find next token.

Unless explicitly specified all significant tokens are considered.

Unless explicitly specified all insignificant tokens are skipped.

Returns C<name> => C<value> pair where name is a token name and value
is an instance of L<< Grammar::Parser::Lexer::Token >> with parse data.

Returns empty list if there is no more data or final token was reached.

If requested token is not found and there are still data left,
throws exception L<< Grammar::Parser::X::Lexer::Notfound >>.

=head1 PATTERN DEFINITION

Pattern definition can be scalar or regex or arrayref of them.

=over

=item SCALAR

Literal string.

For example:

	name => 'string',

	# is same as
	name => qr/\Qstring\E/,

=item REGEX

Perl regex.

Referencing other pattern by name is available via abusing expression C<(??{ 'pattern_name' })>.
Such construct with literal string with value of known pattern name will be replaced
with named regex reference and such reference will be available.

For example

	# Regex
	qr/(?! (??{ 'keyword' }) ) (\w+) \b/x,

	# will become
	qr/(?! (?&keyword) ) (\w+) \b (?(DEFINE) (?<keyword> ....))/x,

=item ARRAYREF

Acts as an another way how to write alternatives.

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<Grammar::Parser>.
It can be distributed and modified under Artistic license 2.0

=cut

