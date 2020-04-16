#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use Grammar::Parser;
use CSI::Language::Java::Grammar;
use CSI::Grammar::Actions;

BEGIN { require "test-helper-common.pl" }

our $DUMP_IT_GOT = 1;
our $DUMP_IT_EXPECTED = 1;

contrive 'csi-parser-start' => (
	deduce  => 'csi-language',
	builder => 'start_rule',
);

contrive 'csi-parser-grammar' => (
	deduce  => 'csi-language',
	builder => 'grammar',
);

contrive 'csi-parser-action-map' => (
	deduce  => 'csi-language',
	builder => 'actions',
);

contrive 'csi-parser-insignificant' => (
	deduce  => 'csi-language',
	builder => 'insignificant_rules',
);

contrive 'csi-parser-action-lookup' => (
	deduce  => 'csi-language',
	builder => 'action_lookup',
);

contrive 'csi-parser' => (
	class => 'Grammar::Parser',
	dep => {
		grammar       => 'csi-parser-grammar',
		action_lookup => 'csi-parser-action-lookup',
		action_map    => 'csi-parser-action-map',
		start         => 'csi-parser-start',
		insignificant => 'csi-parser-insignificant',
	},
);

my $last_result;
act {
	$last_result = deduce ('csi-parser')->parse (@_);
	$last_result;
};

sub arrange_start_rule {
	my ($rule) = @_;

	proclaim 'csi-parser-start' => $rule;
}

sub is_arranged_start_rule {
	my ($rule) = @_;

	try_deduce 'csi-parser-start';
	is_deduced 'csi-parser-start';
}

sub test_rule {
	my ($title, %params) = @_;

	test_frame {
		arrange_start_rule $params{rule}
			if defined $params{rule};

		arrange_start_rule $title
			unless is_arranged_start_rule;

		$title = $params{title}
			if exists $params{title};

		act_arguments $params{data};

		if (exists $params{throws}) {
			local $Grammar::Parser::Driver::Marpa::R2::Instance::SHOW_PROGRESS_ON_ERROR = 0;

			act_throws $title => throws => ignore
				#ok $title, got => ! scalar deduce 'act-lives'
				#and diag ("died with ${\ deduce 'act-error' }")
				;

			return;
		}

		it $title => (
			expect => $params{expect},
		) or do {
			use DDP;
			if ($DUMP_IT_GOT) {
				diag ("== Got");
				diag (np $last_result);
			}
			if ($DUMP_IT_EXPECTED) {
				diag ("== Expected");
				diag (np $params{expect});
			}
		};

		if ($params{expectation_expanded}) {
			it "$title (expectation expanded)" => (
				args => [ $params{data} ],
				expect => $params{expectation_expanded},
			);
		}
	};
}

1;

