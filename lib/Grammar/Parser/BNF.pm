
use v5.14;
use strict;
use warnings;

package Grammar::Parser::BNF v1.0.0;

use Moo;

use Grammar::Parser;
use Grammar::Parser::BNF::Action;
use Grammar::Parser::BNF::Result;

use namespace::clean;

has action_class => (
    init_arg => undef,
    is => 'ro',
    lazy => 1,
    default => sub { 'Grammar::Parser::BNF::Action' },
);

has result_class => (
    init_arg => undef,
    is => 'ro',
    lazy => 1,
    default => sub { 'Grammar::Parser::BNF::Result' },
);

has parser => (
    init_arg => undef,
    is => 'ro',
    lazy => 1,
    handles => [ 'parse' ],
    default => sub {
        my ($self) = @_;

        return Grammar::Parser->new (
            grammar       => $self->grammar,
            start         => 'bnf',
            white         => [ qw[ whitespace comment ]],
            action_name   => $self->action_class->can ('action_name'),
            action        => [ $self->action_class ],
            result_class  => $self->result_class,
        );
    },
);

sub grammar {
    my $re_full = qr/
		(?&Identifier) (?: :: (?&Identifier))?
		(?(DEFINE)
			(?<Identifier> (?> (?= \w) (?! \d) [-\w\d]+ (?<= \w) ) )
		)
	/x;

    +{
        whitespace    => [ qr/\s+/mx ],
        comment       => [ qr/\#.*/x ],

        regex         => [ qr/qr (?<delimiter> \/ ) (?<regex> (?: [^\\] | \\. )+?) \g{delimiter} (?<modifiers>[ixms]*)/mx ],
        literal       => [ qr/
				(?> (?<quote>\') (?<value> (?: [^\\\'] | \\. )*? ) \' )
			|	(?> (?<quote>\") (?<value> (?: [^\\\"] | \\. )*? ) \" )
			/smx ],

        nonterminal   => [
            # nonterminal:
            # - must starts with word character but not digit
            # - must ends with word character
            # - can contain any word character, '-' or '::'
            # - can be surrounded by < >
            qr/(?: «  \s* (?<value>$re_full) \s*  » )/mx,
            qr/(?: <  \s* (?<value>$re_full) \s*  > )/mx,
            qr/(?: \b     (?<value>$re_full)     \b )/x
        ],
		keyword         => [
			qr/ \b (?! \d) \w+ \b/x,
		],

        # operators
        # = : := :: ::=
        DEFINITION      => [ qr/(?= [:=]) (?: :{0,2} =? )(?! [:=]) /mx ],
        TERMINATION     => [ ';'   ],
        GROUP_START     => [ '('   ],
        GROUP_END       => [ ')'   ],
        REPEAT_START    => [ '{'   ],
        REPEAT_END      => [ '}'   ],
        OPTION_START    => [ '['   ],
        OPTION_END      => [ ']'   ],
        ALTERNATIVE     => [ '|', '/' ],
        REPETITION      => [ '...' ],
        #INCLUDE         => [ qr/:include \b/xmi ],
        #FROM            => [ qr/\b from \b/xmi ],
		KEYWORD         => [ '@keyword' ],

        bnf             => [
            [qw[ element     ]],
            [qw[ element bnf ]],
        ],
        element         => [
			[qw[ one_element ]],
			[qw[ one_element TERMINATION ]]
		],
		one_element     => [
            [qw[ rule ]],
			[qw[ rule_keyword ]],
        #    [qw[ include ]],
        ],
        #include => [
        #    [qw[ INCLUDE nonterminal FROM file_name ]],
        #],
        name            => [
            [qw[ nonterminal ]],
        ],
		keywords        => [
			[qw[ keyword ]],
			[qw[ keyword ALTERNATIVE keywords ]],
		],
        rule            => [
            [qw[ name DEFINITION expression ]],
		],
		rule_keyword    => [
			[qw[ KEYWORD keywords ]],
        ],
        expression    => [
            [qw[ nonterminal   ]],
            [qw[ literal       ]],
            [qw[ regex         ]],
            [qw[ alternative   ]],
            [qw[ sequence      ]],
            [qw[ group         ]],
            [qw[ option        ]],
            [qw[ repeat        ]],
            [qw[ repeat_option ]],
        ],
        alternative   => [
            [qw[ expression ALTERNATIVE expression ]],
        ],
        sequence      => [
            [qw[ expression expression ]],
        ],
        group         => [
            [qw[ GROUP_START expression GROUP_END ]],
        ],
        option        => [
            [qw[ OPTION_START expression OPTION_END ]],
        ],
        repeat_delimiter => [
            [qw[ expression ]],
        ],
        repeat_expression => [
            [qw[ expression ]],
        ],
        repeat        => [
            [qw[ REPEAT_START repeat_expression REPETITION repeat_delimiter REPEAT_END ]],
            [qw[ REPEAT_START repeat_expression REPETITION                  REPEAT_END ]],
            [qw[ REPEAT_START repeat_expression                             REPEAT_END ]],
        ],
        repeat_option => [
            [qw[ OPTION_START repeat_expression REPETITION repeat_delimiter OPTION_END ]],
            [qw[ OPTION_START repeat_expression REPETITION                  OPTION_END ]],
        ],
    };
}

1;

__END__

=encoding utf8

=head1 NAME

Grammar::Parser::BNF - parse Grammar::Parser's bnf file

=head1 SYNOPSIS

   use Grammar::Parser::BNF;

   my $ast = Grammar::Parser::BNF->new->parse_file ($bnf_file);

=head1 DESCRIPTION

=head1 GRAMMAR

See L<Grammar::Parser::BNF::Grammar>

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<Grammar::Parser>.
It can be distributed and/or modified under Artistic license 2.0

=cut
