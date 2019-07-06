
use Test::Deep;

sub is_lexer_value {
	my ($value, @required_keys) = @_;

	@required_keys = qw[ MATCH ]
		unless @required_keys;

	eq_deeply $value, [ superhashof ({
		map +($_ => ignore), @required_keys,
	})];
}

sub is_lexer_nonterminal ($) {
	is_lexer_value @_, 'value';
}

sub is_lexer_literal_string ($) {
	is_lexer_value @_, 'quote', 'value';
}

sub _generate_fixture_expectation {
	my ($constraint) = @_;

	my $test = "is_$constraint";
	$test =~ tr/-/_/;
	$test = __PACKAGE__->can ($test);

	sub ($$) {
		my ($name, $fixture) = @_;
		local $Test::Builder::Level = $Test::Builder::Level + 1;

		ok
			$test->($fixture),
			"fixture $name should match $constraint constraint"
			;

		return $fixture;
	}
}

BEGIN {
	*expect_lexer_nonterminal_fixture    = _generate_fixture_expectation 'lexer-nonterminal';
	*expect_lexer_literal_string_fixture = _generate_fixture_expectation 'lexer-literal-string';
}

1;
