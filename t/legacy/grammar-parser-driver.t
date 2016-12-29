#!/usr/bin/env perl

use strict;
use warnings;

use Grammar::Parser::Driver;

use FindBin;
use lib $FindBin::Bin;

BEGIN { require "test-helper.pl" }

sub instance;
sub arrange_parameter_action_map;
sub arrange_parameter_action_name;
sub arrange_parameter_action_lookup;
sub expect_action_name_for;
sub expect_action_lookup_for;

plan tests => 3;

subtest 'action_name_for ()' => sub {
	plan tests => 4;

	context 'without any transformation' => sub {
		plan tests => 2;

		expect_action_name_for 'ident'  => 'ident';
		expect_action_name_for '-ident' => '-ident';
	};

    context 'with transformation map' => sub {
		plan tests => 2;

		arrange_parameter_action_map +{ '-ident' => 'bbb' };

		expect_action_name_for 'ident'  => 'ident';
		expect_action_name_for '-ident' => 'bbb';
    };

	context 'with transformation callback' => sub {
		plan tests => 4;

        arrange_parameter_action_name deduce 'action-name-replace-nonword';

		expect_action_name_for 'ident'    => 'ident';
		expect_action_name_for '-ident'   => '_ident';
		expect_action_name_for '*ident'   => '_ident';
		expect_action_name_for '-id::ent' => '_id_ent';
	};

    context 'with transformation callback and map' => sub {
		plan tests => 3;

        arrange_parameter_action_name deduce 'action-name-replace-nonword';
		arrange_parameter_action_map  +{ '_id_ent' => '-ident' },

		expect_action_name_for '_ident'   => '_ident';
		expect_action_name_for '-ident'   => '_ident';
		expect_action_name_for '-id::ent' => '-ident';
    };

	done_testing;
};

subtest 'action_lookup_for ()' => sub {
	my $without_autoload_action_foo = sub { 'without-autoload-action-foo' };
	my $without_autoload_action_bar = sub { 'without-autoload-action-bar' };
	my $with_autoload_action_foo	= sub { 'with-autoload-action-foo' };
	my $with_autoload_action_baz	= sub { 'with-autoload-action-baz' };
	my $with_autoload_autoload		= sub { 'with-autoload-autoload-bar' };

	context "with hashref without autoload" => sub {
		arrange_parameter_action_lookup [ {
			foo => $without_autoload_action_foo,
			bar => $without_autoload_action_bar,
		} ];

		expect_action_lookup_for foo => $without_autoload_action_foo;
		expect_action_lookup_for bar => $without_autoload_action_bar;
		expect_action_lookup_for XXX => undef;
	};

    my $hash_without = {
        action_1 => sub { 'hash-without-action-1' },
        action_2 => sub { 'hash-without-action-2' },
    };

    my $hash_with = {
        action_2 => sub { 'hash-with-action-2' },
        action_h => sub { 'hash-with-action-h' },
        AUTOLOAD => sub { 'hash-with-autoload' },
    };

    my $test_code = sub {
        my $self = shift;
        my $rv = $self->action_lookup_for (@_);
        $rv = $rv->() if defined $rv;
        return $rv;
    };

	#plan tests => 5;

    subtest 'hashref without autoload' => sub {
        my $obj = instance (
            action_lookup => [ $hash_without ]
        );

        is $obj->$test_code ('action_1'), 'hash-without-action-1', 'existing action 1';
        is $obj->$test_code ('action_2'), 'hash-without-action-2', 'existing action 2';
        is $obj->$test_code ('action_X'), undef,                   'undefined action';
    };

    subtest 'build from hashref with autoload' => sub {
        my $obj = instance (
            action_lookup => [ $hash_with ]
        );

        is $obj->$test_code ('action_2'), 'hash-with-action-2', 'existing action 2';
        is $obj->$test_code ('action_h'), 'hash-with-action-h', 'existing action h';
        is $obj->$test_code ('action_X'), 'hash-with-autoload', 'autoload action';
    };

    subtest 'build from package' => sub {
        my $obj = instance (
            action_lookup => [ 'Sample::Grammar::Parser::Driver::action_lookup::without_autoload' ]
        );

        is $obj->$test_code ('action_1'), 'pkg-without-action-1', 'existing action 1';
        is $obj->$test_code ('action_2'), 'pkg-without-action-2', 'existing action 2';
        is $obj->$test_code ('action_X'), undef,                  'undefined action';
    };

    subtest 'build from package with autoload' => sub {
        my $obj = instance (
            action_lookup => [ 'Sample::Grammar::Parser::Driver::action_lookup::with_autoload' ]
        );

        is $obj->$test_code ('action_2'), 'pkg-with-action-2', 'existing action 2';
        is $obj->$test_code ('action_p'), 'pkg-with-action-p', 'existing action p';
        is $obj->$test_code ('action_X'), 'pkg-with-autoload', 'autoload action';
    };

    subtest 'build from list actions' => sub {
        my $obj = instance (
            action_lookup => [
                [
                    $hash_without,
                    'Sample::Grammar::Parser::Driver::action_lookup::with_autoload',
                ],
                $hash_with,
            ]
        );

        is $obj->$test_code ('action_1'), 'hash-without-action-1',  'existing action 1 from 1st';
        is $obj->$test_code ('action_2'), 'hash-without-action-2',  'existing action 2 from 1st (not overriden by later)';
        is $obj->$test_code ('action_h'), 'hash-with-action-h',     'existing action 3 from 3rd (not overriden by 2nd AUTOLOAD)';
        is $obj->$test_code ('action_X'), 'pkg-with-autoload',      'autoload action from 2nd not overriden by 3rd';
    };

	done_testing;
};


had_no_warnings 'no unexpected warnings in Grammar::Parser::Driver';

BEGIN {
	contrive 'action-name-replace-nonword' => (
		value => sub { shift =~ s/[_\W]+/_/gr },
	);

	contrive 'test::grammar::instance' => (
		class => 'Grammar::Parser::Driver',
		as => sub {
			my ($class) = @_;

			my @params;
			push @params, action_name => deduce $_
				for grep { try_deduce $_ } 'test::grammar::action-name';
			push @params, action_map => deduce $_
				for grep { try_deduce $_ } 'test::grammar::action-map';
			push @params, action_lookup => deduce $_
				for grep { try_deduce $_ } 'test::grammar::action-lookup';

			$class->new (
				grammar => {},
				@params
			);
		},
	);

	contrive 'test::action-name-for' => (
		deduce  => 'test::grammar::instance',
		builder => 'action_name_for',
		dep     => [ 'test::action-name-for::rule' ],
	);

	contrive 'test::action-lookup-for' => (
		deduce  => 'test::grammar::instance',
		builder => 'action_lookup_for',
		dep     => [ 'test::action-lookup-for::rule' ],
	);
}

sub expect_action_name_for {
	my ($rule, $result) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	is_deduce "should transform '$rule' => '$result'" => (
		deduce => 'test::action-name-for',
		expect => $result,
		'test::action-name-for::rule' => $rule,
	);
}

sub expect_action_lookup_for {
	my ($rule, $result) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	is_deduce "should${\ (defined $result ? '' : ' not') } find action for rule '$rule'" => (
		deduce => 'test::action-lookup-for',
		expect => $result,
		'test::action-lookup-for::rule' => $rule,
	);
}

sub arrange_parameter_action_lookup {
	my ($action_lookup) = @_;

	proclaim 'test::grammar::action-lookup' => $action_lookup;
}

sub arrange_parameter_action_map {
	my ($action_map) = @_;

	proclaim 'test::grammar::action-map' => $action_map;
}

sub arrange_parameter_action_name {
	my ($action_name) = @_;

	proclaim 'test::grammar::action-name' => $action_name;
}

sub describe_method_action_name_for (&) {
	my ($code) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	frame {
		proclaim 'test::act' => 'test::act::action-name-for';

		$code->();
	};
}

sub instance {
    Grammar::Parser::Driver->new (grammar => {}, @_);
}


package Sample::Grammar::Parser::Driver::action_lookup::with_autoload;

sub action_2 {
    return 'pkg-with-action-2';
}

sub action_p {
    return 'pkg-with-action-p';
}

sub AUTOLOAD {
    return 'pkg-with-autoload';
}

package Sample::Grammar::Parser::Driver::action_lookup::without_autoload;

sub action_1 {
    return 'pkg-without-action-1';
}

sub action_2 {
    return 'pkg-without-action-2';
}

