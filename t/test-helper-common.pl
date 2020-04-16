
use strict;
use warnings;
use utf8;

use Carp::Always;

use Test::Deep      qw[ !cmp_deeply ];
use Test::Exception qw[];
use Test::More      import => [qw[ !ok !subtest !can_ok !is !is_deeply ]];
use Test::Warnings  qw[ :no_end_test had_no_warnings ];

use Context::Singleton;

contrive 'act-arguments' => (
	as => sub { [] },
);

contrive 'act-result-log' => (
	dep => [qw[ act act-arguments ]],
	as => sub {
		my ($coderef, $arguments) = @_;
		my $value;
		my $lives_ok = eval { $value = $coderef->(@$arguments); 1 };
		my $error = $@;

		+{
			'act-lives' => $lives_ok,
			'act-error' => $error,
			'act-value' => $value,
		};
	},
);

contrive 'act-lives' => (
	dep => [qw[ act-result-log ]],
	as  => sub { $_[0]->{'act-lives' } },
);

contrive 'act-error' => (
	dep => [qw[ act-result-log ]],
	as  => sub { $_[0]->{'act-error' } },
);

contrive 'act-value' => (
	dep => [qw[ act-result-log ]],
	as  => sub { $_[0]->{'act-value' } },
);

sub test_frame (&) {
	my ($code) = @_;

	frame {
		local $Test::Builder::Level = $Test::Builder::Level + 2;

		$code->()
	};
}

sub build_got {
	my (%params) = @_;

	return $params{got} if exists $params{got};

	proclaim 'act-arguments' => $params{args} if exists $params{args};
	die "Provide 'got' or 'args'" unless try_deduce 'act-arguments';

	my $value = scalar deduce 'act-value';

	die "Act failed: ${\ deduce 'act-error' }"
		unless deduce 'act-lives';

	$value;
}

sub ok {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	Test::More::ok $params{got}, $title;
}

sub cmp_deeply {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame {
		my $got = build_got %params;
		Test::Deep::cmp_deeply $got, $params{expect}, $title;
	};
}

sub it {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame {
		my $got = build_got %params;
		Test::Deep::cmp_deeply $got, $params{expect}, $title;
	};
}

sub is {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	test_frame {
		my $got = build_got %params;
		Test::Deep::cmp_deeply $got, $params{expect}, $title;
	};
}

sub can_ok {
	my (@can) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $package = is_deduced ('package')
		? deduce ('package')
		: shift @can
	;

	Test::More::can_ok $package, @can;
}

sub subtest {
	my ($title, $code) = @_;

	# self + frame
	local $Test::Builder::Level = $Test::Builder::Level + 2;

	Test::More::subtest $title, sub { frame { $code->() } };
}

sub act (&) {
	my ($coderef) = @_;

	proclaim act => $coderef;

	#my $lives_ok = eval { $coderef->(); 1 };
	#my $error = $@;

	#proclaim 'act-lives' => $lives_ok;
	#proclaim 'act-error' => $error;
}

sub act_arguments {
	proclaim 'act-arguments' => [ @_ ];
}

sub act_throws {
	my ($title, %params) = @_;

	my $error = deduce 'act-error';

	fail $title or do { diag "expect to die but lived"; return }
		unless $error;

	cmp_deeply $title,
		got => $error,
		expect => $params{throws},
	;
}

sub act_should_live {
	my ($title) = @_;

	my $error = deduce 'act-error';

	fail $title or do { diag "expect to live but died with $error"; return }
		if $error;

	1;
}

# Similar to Test::Exception except it uses Test::Deep
sub throws_ok (&$;$) {
	my ($coderef, $expected, @message) = @_;

	fail "do not use";

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = Test::Exception::_try_as_caller ($coderef);

	$expected = obj_isa ($expected) unless ref $expected;
	$expected = re ($expected) if Ref::Util::is_regexpref ($expected);

	cmp_deeply $got, $expected, @message;
}

sub describe_package ($&) {
	my ($package, $code) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	subtest $package => sub {
		proclaim package => $package;

		$code->();
	}
}

1;
