
use v5.14;
use strict;
use warnings;

package Grammar::Parser::BNF::Result v1.0.0;

use Ref::Util qw( is_hashref );
use List::Util qw( none all any );

use Grammar::Parser::Action::Util;
use Grammar::Parser::BNF;

use constant HANDLER_NOT_SET => 0;
use constant HANDLER_SET => 1;

use namespace::clean;

sub new {
    my ($class, $result) = @_;

    return bless { bnf => $result->{bnf}, prefix => '' }, $class;
}

sub prefix {
    my ($self, $prefix) = @_;

    $self->{prefix} = "${prefix}::";

    return $self;
}

sub build_grammar {
    my ($self) = @_;

    return $self->process->{-grammar};
}

sub build_action_map {
    my ($self) = @_;

    return $self->process->{-handler};
}

sub process {
    # Process parser output
    my ($self) = @_;

    $self->{-grammar} //= do {
        # expand rules - expand groups, repeats, alternatives
        my $expanded = $self->expand_bnf;

        local $self->{-lexer}  = {};
        local $self->{-parser} = {};

        # and generate grammar and handlers
        my @list = map [ $_, $expanded->{$_} ], sort keys %$expanded;

        @list = grep ! $self->lexer_handle_symbol (@$_), @list;

        # parser_build_rules changes hashrefs to rule names
        # { nonterminal => 'value' } => 'value'
        @list = map $self->parser_build_rules (@$_), @list;

        # alter handler types
        @list = grep ! $self->detect_literal_value (@$_), @list;
        @list = grep ! $self->detect_alias         (@$_), @list;
        @list = grep ! $self->detect_list          (@$_), @list;

        $self->regex_interpolate ($_)
            for keys %{ $self->{-lexer} };

        +{
            %{ $self->{-lexer} },
            %{ $self->{-parser} },
        };
    };

    return $self;
}

sub regex_for_rule {
    my ($self, $name) = @_;

    $self->regex_interpolate ($name);
    my @list = @{ $self->{-lexer}{ $name } };
    for my $entry (@list) {
        $entry = qr/(?<!\w(?=\w))\Q$entry\E(?!(?<=\w)\w)/ unless ref $entry;
        $entry = qr/(?:$entry)/;
    }
    my $regex = join '|', @list;
    return qr/$regex/;
}

sub regex_interpolate {
    my ($self, $name) = @_;
    my $name_regex = join '|', @{ Grammar::Parser::BNF->grammar->{nonterminal} };

    for my $entry (@{ $self->{-lexer}{ $name }}) {
        next unless is_hashref $entry;
        my ($regex, $modifiers) = @$entry{'regex', 'modifiers'};
        $modifiers //= '';

        $regex =~ s{\$(?:$name_regex)}{
            my $name = $1 // $2 // $3;
            $self->regex_for_rule ($name);
        }gex;

		# TODO: validate regular expression
        $entry = qr/(?${modifiers}:$regex)/;
    }
}

sub expand_bnf {
    # Expand bnf into map:
    # - key = rule name
    # - value = list of alternatives (aref of href)
    #
    # where alternative can be:
    # - scalar or regex => terminal symbol
    # - aref of symbol names => nonterminal sequence
    #
    # creates anonymous rules if necessary

    my ($self) = @_;

    unless (defined $self->{expand}) {
        $self->{expand} = {};

        local $self->{-counter} = '000000';
        local $self->{-terminal_cache} = {};

		my @rules = @{ $self->{bnf} };
		$self->preprocess_keywords ($_) for @rules;

        my %map = map +( $_->{rule} => $_ ), @rules;
        $self->expand_rule ($_, $map{$_}) for sort keys %map;
    }

    $self->{expand};
}

sub expand_rule {
    my ($self, $rule_name, $rule) = @_;

    $rule_name = $self->prefix_rule_name ($rule_name, $rule);

    $self->{expand}{ $rule_name } = $self->expand_one_rule (undef, $rule);
}

sub expand_one_rule {
    my ($self, $result, $rule) = @_;
    $result //= $self->empty_result;

    state $expand_map = { map +($_ => $self->can ('expand_' . $_)), (
        qw( nonterminal terminal ),
        qw( alternative sequence group option ),
        qw( repeat repeat_option ),
    )};

    say 'oops: ', $rule unless is_hashref $rule;
    my ($method) = grep defined, @$expand_map{ keys %$rule };

    warn "expand_one: unhandled keys: [" . join (', ', keys %$rule) . "]\n" and return
      unless defined $method;

    return $self->$method ($result, $rule);
}

sub expand_nonterminal {
    my ($self, $result, $rule) = @_;

    return [ map [ @$_, $rule ], @$result ];
}

sub preprocess_keywords {
	my ($self, $rule) = @_;

	return unless exists $rule->{keywords};

	my @keywords = map $_->{keyword}, @{ delete $rule->{keywords} };
	$rule->{rule} = $keywords[0];
	my $regex = "(?>\\b(?:${\ join '|', @keywords })\\b)";

	$rule->{keyword} = 1;
	$rule->{terminal} = {
		delimiter => '/',
		modifiers => '',
		regex	  => $regex,
	};

    ();
}

sub expand_terminal {
    my ($self, $result, $rule) = @_;

    $rule = $self->create_anonymous_terminal ($rule)
        unless $rule->{rule};

    return [ map [ @$_, $rule ], @$result ];
}

sub expand_alternative {
    my ($self, $result, $rule) = @_;
    my @content = @{ $rule->{alternative} };

    # if it is only alternative of terminals, add name to each child
    # to prevent creation of anonymous rules
    # @content = map +{ %$_, name => $rule->{name} }, @content
    #   if $rule->{name} and none { exists $_->{terminal} } @content;

    return [ map @{ $self->expand_one_rule ($result, $_) }, @content ];
}

sub expand_sequence {
    my ($self, $result, $rule) = @_;

    $result = $self->expand_one_rule ($result, $_)
        for @{ $rule->{sequence} };

    return $result;
}

sub expand_group {
    my ($self, $result, $rule) = @_;

    $self->expand_one_rule ($result, $rule->{group});
}

sub expand_option {
    my ($self, $result, $rule) = @_;

    # New paths: previous paths without and with expansion
    [ @$result, @{ $self->expand_one_rule ($result, $rule->{option}) } ];
}

sub expand_repeat {
    my ($self, $result, $rule) = @_;

    unless (defined $rule->{rule}) {
        my $anon = $self->create_anonymous_rule;
        $self->expand_rule ($anon->{rule}, {%$rule, %$anon});
        $rule = $self->create_rule_ref ($anon->{rule});
    } else {
        $rule = { sequence => [
            $rule->{repeat},
            { option => { sequence => [
                ($rule->{repeat_delimiter}) x !! $rule->{repeat_delimiter},
                $self->create_rule_ref ($rule->{rule})
            ] } },
        ]};
    }

    return $self->expand_one_rule ($result, $rule);
}

sub expand_repeat_option {
    my ($self, $result, $rule) = @_;
    my $copy = { %$rule };

    my $name = delete $copy->{rule};
    $copy->{repeat} = delete $copy->{repeat_option};

    return $self->expand_one_rule ($result, { option => $copy });
}

sub empty_result {
    [[]];
}

sub create_anonymous_rule {
    my ($self, $name, @content) = @_;

    return +{
        @content,
        rule     => $name // "#-${\ $self->{-counter}++ }",
        handler  => 'pass_through',
    };
}

sub create_anonymous_terminal {
    my ($self, $rule) = @_;

    my $new_name = $rule->{terminal};
    $new_name = $new_name->{regex} if ref $new_name;

    my $new_rule = $self->{-terminal_cache}{ $new_name } //= do {
        my $rv = $self->create_anonymous_rule ($new_name, %$rule);
        $self->expand_rule ($rv->{rule}, $rv);
        $rv;
    };
}

sub create_rule_ref {
    my ($self, $name) = @_;

    +{
        nonterminal => $name,
    };
}

sub is_anonymous_rule {
    my ($self, $rule_name, @def) = @_;

    return scalar grep $_->{rule} eq $rule_name && $_->{handler}, @def;
}

sub prefix_rule_name {
    my ($self, $rule_name, @def) = @_;

    if ($self->{prefix}) {
        my $search = $self->is_anonymous_rule ($rule_name, @def) ? qr/(?<=^#-)/ : qr/^/;
        $rule_name =~ s/$search/$self->{prefix}/e;
    }

    return $rule_name;
}

sub lexer_handle_symbol {
    my ($self, $name, $def) = @_;
    # Literal: rule that expands to terminal(s) only
    # value is handled by 'literal' action

    # every branch must expand as one symbol
    return if grep 1 != @$_, @$def;

    # each alternative must be terminal
    return if grep ! exists $_->[0]{terminal}, @$def;

    $self->{-lexer}{ $name } = [ map $_->[0]{terminal}, @$def ];
    $self->{-handler}{ $name } //= $self->handler_literal;

    return 1;
}

sub handler_default {
    return 'default';
}

sub handler_alias {
    return 'alias';
}

sub handler_literal {
    return 'literal';
}

sub handler_literal_value {
    return 'literal_value';
}

sub handler_list {
    return 'list';
}

sub parser_build_rules {
    my ($self, $rule, $content) = @_;

    $self->{-handler}{ $rule } = $self->handler_default;

    # dereference rules to names
    $self->{-parser}{ $rule } = [
        map [ map $_->{nonterminal} // $_->{rule}, @$_ ],
        @$content
    ];

    return [ $rule, $self->{-parser}{ $rule } ];
}

sub is_literal_value {
    my ($self, $rule, $content) = @_;
    # Literal value: rule that expands as ref to literal(s)

    # Example:
    # Rules 'asc' and 'varchar' are literal_value rules
    #   ASC       : qr/ \b asc (?: ending) \b /xi
    #   VARCHAR   : qr/\b varchar \b /xi
    #   CHARACTER : qr/\b character \b /xi
    #   VARYING   : qr/\b varying \b /xi
    #
    #   asc       : ASC
    #   varchar   : VARCHAR | ( CHARACTER VARYING )

    # all variants must expands as ref to literal(s)
    return ! scalar grep ! exists $self->{-lexer}{ $_ }, map @$_, @$content;
}

sub detect_literal_value {
    my ($self, $rule, $content) = @_;

    return HANDLER_NOT_SET unless $self->is_literal_value ($rule, $content);

    $self->{-handler}{$rule} = $self->handler_literal_value;

    return HANDLER_SET;
}

sub is_alias {
    my ($self, $rule, $content) = @_;

    # every alternative must expand as exactly one symbol
    return unless all { @$_ == 1 } @$content;

    # every symbol must be nonterminal
    my $parser_map = $self->{-parser};
    return unless all { exists $parser_map->{ $_->[0] } } @$content;

    # single alternative
    return 1 if 1 == @$content;

    # alternative of literal values
    my $handler_map = $self->{-handler};
    my $literal_value = $self->handler_literal_value;
    return 1 if all { $handler_map->{ $_->[0] } eq $literal_value } @$content;

    return;
}

sub detect_alias {
    my ($self, $rule, $content) = @_;

    return HANDLER_NOT_SET unless $self->is_alias ($rule, $content);

    $self->{-handler}{$rule} = $self->handler_alias;

    return HANDLER_SET;
}

sub is_list {
    my ($self, $rule, $content) = @_;
    # is list if rule contains itself

    return any { $_ eq $rule } map @$_, @$content;
}

sub detect_list {
    my ($self, $rule, $content) = @_;

    return HANDLER_NOT_SET unless $self->is_list ($rule, $content);

    $self->{-handler}{$rule} = $self->handler_list;

    return HANDLER_SET;
}

1;

__END__

=pod

=head1 NAME

Grammar::Parser::BNF::Result - Process BNF AST

=head1 DESCRIPTION

Part of L<Grammar::Parser::BNF>, process AST generated by parser
and builds relevant grammar and actions.

Usage:

   my $result = instance of Grammar::Parser::BNF::Result;
   Grammar::Parser->new (
      ...,
      grammar => $result->build_grammar,
      action_map => $result->build_action_map,
      action => [
         ...,
         'Grammar::Parser::Action::Util',
      ],
   );

=head1 METHODS

=head2 build_grammar

Returns grammar suitable for L<Grammar::Parser>

=head2 build_action_map

Returns rule to action name map.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT

This file if part of L<Grammar::Parser>.
It can be distributed and/or modified under Artistic license 2.0

=cut
