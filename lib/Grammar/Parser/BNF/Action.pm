
use v5.14;
use strict;
use warnings;

package Grammar::Parser::BNF::Action v1.0.0;

use Grammar::Parser::Action::Util qw( rule install_action_name );

use namespace::clean;

local $Grammar::Parser::Action::Util::PREFIX = 'bnf_';

install_action_name 'action_name';

rule bnf                => 'list';
rule nonterminal        => 'literal_value';
rule name               => 'alias';
rule element            => 'pass_through';
rule one_element        => 'pass_through';
rule rule               => 'alias_merge';
rule expression         => 'pass_through';
rule repeat_delimiter   => 'default';
rule repeat_expression  => 'default';
rule option             => 'default';
rule group              => 'default';
rule sequence           => 'list';
rule alternative        => 'list';
rule repeat             => 'alias_merge';
rule repeat_option      => 'alias_merge';
rule regex              => sub {
    my ($instance,  $rule, $value) = @_;

    +{ terminal => {
		regex => $value->capture ('regex'),
		delimiter => $value->capture ('delimiter'),
		modifiers => $value->capture ('modifiers'),
	} };
};

rule literal            => sub {
    my ($instance,  $name, $value) = @_;
	$value = $value->capture ('value');
    $value =~ s/\\(.)/$1/g;

    +{ terminal => $value };
};

rule include            => sub {
    my ($instance, $rule, undef, $nonterminal, undef, $file_name) = @_;

    say 'TODO: include';

    undef;
};

rule keywords           => 'list';
rule keyword            => 'literal_value';
rule rule_keyword       => sub {
	my $merge = Grammar::Parser::Action::Util::merge (@_);
	+{ rule => undef, %$merge };
};

1;

__END__

=pod

=head1 NAME

Grammar::Parser::BNF::Action - Actions for parsing Grammar::Parser bnf-like file

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<Grammar::Parser>.
It can be distributed and/or modified under Artistic license 2.0

=back

