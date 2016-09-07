#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Warnings;

use Hash::Util;
use Grammar::Parser::Lexer;

my @templates = qw( alias alias_merge default literal literal_value list merge pass_through symbol value );

package
	Sample::With::Prefix::Default;

use Grammar::Parser::Action::Util qw( rule install_action_name );

rule $_ => $_ for @templates;
install_action_name 'action_name';

package
	Sample::With::Prefix::Custom;

use Grammar::Parser::Action::Util qw( rule install_action_name );

local $Grammar::Parser::Action::Util::PREFIX = 'verify';

rule $_ => $_ for @templates;
install_action_name 'action_name';

package main;

sub build_symbol {
	state $lexer = Grammar::Parser::Lexer->new (
		terminals => {},
	);

	return $lexer->_build_symbol (@_);
}

sub is_action {
    my ($title, %params) = @_;
    Hash::Util::lock_keys %params, qw[ action instance rule params expected ];

    $params{instance} //= {};
    $params{rule} //= 'test';

    my $got = $params{action}->($params{instance}, $params{rule}, @{ $params{params} });

    cmp_deeply $got, $params{expected}, $title;
}

our $CURRENT_TEMPLATE;
sub is_template {
    my ($title, %params) = @_;
    Hash::Util::lock_keys %params, qw[ rule params expected action ];

    $params{rule} //= $CURRENT_TEMPLATE;
    $params{action} //= Grammar::Parser::Action::Util->can ($params{rule});

    is_action ($title, %params);
}

sub methods_are_installed {
    my ($title, %params) = @_;
    Hash::Util::lock_keys %params, qw[ package action_name prefix ];

    my $action_name = $params{action_name};
    my $package = $params{package};
    my $prefix = $params{prefix};

    subtest $title => sub {
        plan tests => 1 + 2 * @templates;
        ok my $callback = $package->can ($action_name), "action name installed";
        ok $package->can ("$prefix$_"), "rule $prefix$_ installed" for @templates;
        is $callback->($_), "$prefix$_", "action name for $_" for @templates;
    };
}

sub with_scalars {
    undef, 'scalar-foo'
}

sub with_value_literal {
    build_symbol (match => 'literal-full-match', captures => { value => 'literal-value'} )
}

sub with_match_literal {
    build_symbol (match => 'literal-full-match')
}

sub with_literals {
    with_value_literal, with_match_literal
}

sub with_source {
    { source => 'data' }
}

sub with_source2 {
    { source => 'data-2' }
}

sub with_another {
    { another => 'data-A' }
}

subtest 'installed methods' => sub {
    plan tests => 2;

    methods_are_installed "with default prefix (rule_)" => (
        package => 'Sample::With::Prefix::Default',
        action_name => 'action_name',
        prefix => 'rule_',
    );

    methods_are_installed "with custom prefix (verify)" => (
        package => 'Sample::With::Prefix::Custom',
        action_name => 'action_name',
        prefix => 'verify',
    );
};

subtest 'template alias' => sub {
    local $CURRENT_TEMPLATE = 'alias';

    plan tests => 5;

    is_template 'should make alias' => (
        params      => [ with_source ],
        expected    => { alias => 'data' },
    );

    is_template 'should ignore scalars' => (
        params      => [ with_scalars, with_source ],
        expected    => { alias => 'data' },
    );

    is_template 'should ignore literals' => (
        params      => [ with_literals, with_source ],
        expected    => { alias => 'data' },
    );

    is_template 'should accept only first value' => (
        params      => [ with_source, with_another ],
        expected    => { alias => 'data' },
    );

    is_template 'without value should be undef' => (
        params      => [ with_scalars, with_literals ],
        expected    => undef,
    );
};

subtest 'template alias_merge' => sub {
    local $CURRENT_TEMPLATE = 'alias_merge';

    plan tests => 6;

    is_template 'should make alias of first value' => (
        params      => [ with_source ],
        expected    => { alias_merge => 'data' },
    );

    is_template 'should make alias and merge' => (
        params      => [ with_source, with_source2, with_another ],
        expected    => { alias_merge => 'data', source => 'data-2', another => 'data-A' },
    );

    is_template 'should make alias and merge first values with same key' => (
        params      => [ with_another, with_source, with_source2 ],
        expected    => { alias_merge => 'data-A', source => 'data' },
    );

    is_template 'should ignore scalars' => (
        params      => [ with_scalars, with_source, with_source2 ],
        expected    => { alias_merge => 'data', source => 'data-2' },
    );

    is_template 'should ignore literals' => (
        params      => [ with_literals, with_source, with_source2 ],
        expected    => { alias_merge => 'data', source => 'data-2' },
    );

    is_template 'should be undef without value' => (
        params      => [ with_scalars, with_literals ],
        expected    => undef,
    );
};

subtest 'template default' => sub {
    local $CURRENT_TEMPLATE = 'default';

    plan tests => 6;

    is_template 'should handle single value' => (
        params      => [ with_source ],
        expected    => { default => { source => 'data' } },
    );

    is_template 'should merge multiple values' => (
        params      => [ with_source, with_another ],
        expected    => { default => { source => 'data', another => 'data-A' } },
    );

    is_template 'should merge use first value with same key' => (
        params      => [ with_source, with_source2, with_another ],
        expected    => { default => { source => 'data', another => 'data-A' } },
    );

    is_template 'should ignore scalars' => (
        params      => [ with_scalars, with_source, with_another ],
        expected    => { default => { source => 'data', another => 'data-A' } },
    );

    is_template 'should ignore literals' => (
        params      => [ with_literals, with_source, with_another ],
        expected    => { default => { source => 'data', another => 'data-A' } },
    );

    is_template 'without value should be empty' => (
        params      => [ with_scalars, with_literals ],
        expected    => { default => {} },
    );
};

subtest 'template literal' => sub {
    local $CURRENT_TEMPLATE = 'literal';

    plan tests => 3;

    is_template 'should ignore any value' => (
        params      => [ with_source ],
        expected    => undef,
    );

    is_template 'should ignore any literal' => (
        params      => [ with_literals ],
        expected    => undef,
    );

    is_template 'should ignore any scalar' => (
        params      => [ with_scalars ],
        expected    => undef,
    );
};

subtest 'template literal_value' => sub {
    local $CURRENT_TEMPLATE = 'literal_value';

    plan tests => 5;

    is_template 'should extract full match as value from match literal' => (
        params      => [ with_match_literal ],
        expected    => { literal_value => 'literal-full-match' },
    );

    is_template 'should extract full match as value from value literal' => (
        params      => [ with_value_literal ],
        expected    => { literal_value => 'literal-value' },
    );

    is_template 'should extract first literal (match)' => (
        params      => [ with_match_literal, with_value_literal ],
        expected    => { literal_value => 'literal-full-match' },
    );

    is_template 'should extract first literal (value)' => (
        params      => [ with_value_literal, with_match_literal ],
        expected    => { literal_value => 'literal-value' },
    );

    is_template 'should use rule name if there is no value' => (
        params      => [ ],
        expected    => { literal_value => 'literal_value' },
    );
};

subtest 'template list' => sub {
    our $CURRENT_TEMPLATE = 'list';

    plan tests => 4;

    is_template 'should build list' => (
        params      => [ with_source, with_source2 ],
        expected    => { list => [ with_source, with_source2 ] },
    );

    is_template 'should build ignore scalars and literals' => (
        params      => [ undef, with_source, with_literals, with_source2, 'foo' ],
        expected    => { list => [ with_source, with_source2 ] },
    );

    is_template 'should merge recursive rules' => (
        params      => [ with_source, { list => [ with_source2 ] }, { list => [ with_another ] } ],
        expected    => { list => [ with_source, with_source2, with_another ] },
    );

    is_template 'without values should build empty list' => (
        params      => [ 'foo', with_literals, undef ],
        expected    => { list => [ ] },
    );
};

subtest 'template merge' => sub {
    our $CURRENT_TEMPLATE = 'merge';

    plan tests => 4;

    is_template 'should merge values' => (
        params      => [ with_source, with_another ],
        expected    => { source => 'data', another => 'data-A' },
    );

    is_template 'should use first value for key' => (
        params      => [ with_source, with_source2, with_another ],
        expected    => { source => 'data', another => 'data-A' },
    );

    is_template 'should ignore scalars and literals' => (
        params      => [ with_scalars, with_literals, with_source, with_another ],
        expected    => { source => 'data', another => 'data-A' },
    );

    is_template 'without values should return empty hash' => (
        params      => [ with_scalars, with_literals ],
        expected    => { },
    );
};

subtest 'template pass_through' => sub {
    our $CURRENT_TEMPLATE = 'pass_through';

    plan tests => 3;

    is_template 'with value should take first value' => (
        params      => [ 'foo', with_literals, with_source, with_another ],
        expected    => { source => 'data' },
    );

    is_template ' without value should take first element' => (
        params      => [ 'foo' ],
        expected    => 'foo',
    );

    is_template 'should return undef on empty rule' => (
        params      => [ ],
        expected    => undef,
    );
};

subtest 'template symbol' => sub {
    our $CURRENT_TEMPLATE = 'symbol';

    plan tests => 4;

    is_template 'should ignore values' => (
        params      => [ with_source ],
        expected    => { symbol => 'symbol' },
    );

    is_template 'should ignore literals' => (
        params      => [ with_literals ],
        expected    => { symbol => 'symbol' },
    );

    is_template 'should ignore scalars' => (
        params      => [ with_scalars ],
        expected    => { symbol => 'symbol' },
    );

    is_template 'should ignore empty rule' => (
        params      => [ ],
        expected    => { symbol => 'symbol' },
    );
};

subtest 'template value' => sub {
    our $CURRENT_TEMPLATE = 'value';

    is_template 'should take first value' => (
        params      => [ with_source, with_another ],
        expected    => 'data',
    );

    is_template 'should ignore literals' => (
        params      => [ with_literals, with_source, with_another ],
        expected    => 'data',
    );

    is_template 'should ignore scalars' => (
        params      => [ with_scalars, with_source, with_another ],
        expected    => 'data',
    );

    is_template 'without values should return undef' => (
        params      => [ with_scalars, with_literals ],
        expected    => undef,
    );
};

done_testing;

