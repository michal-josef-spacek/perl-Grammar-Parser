#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use Path::Tiny;

my $template = do { local $/; <DATA> };

for my $list (@ARGV) {
	open my $fh, '<', $list or die "$list: $!";

	my $dest = Path::Tiny->new ("t/java/$list");
	$dest->mkpath;

	while (my $path = <$fh>) {
		chomp $path;
		next if $path =~ m/^#/;
		next unless $path;

		my $name = $path =~ s:.*/([^/]*)/([^/]*)/([^/]*).java$:$1-$2-$3:r;

		my $fh = $dest->child ($name . ".t")->openw;
		print $fh $template =~ s/TEMPLATE_PATH/$path/r;
		close $fh;
	}
}


__DATA__
#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

use Test::More;
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Path::Tiny;

use Grammar::Parser;
use CSI::Language::Java::Grammar;

my $language = 'CSI::Language::Java::Grammar';

my $parser = Grammar::Parser->new (
	grammar       => $language->grammar,
	action_lookup => $language->action_lookup,
	action_map    => $language->actions,
	start         => $language->start_rule,
	insignificant => $language->insignificant_rules,
);

my $path = "TEMPLATE_PATH";

plan tests => 2;

ok (
	scalar eval { $parser->parse (Path::Tiny->new ($path)->slurp_utf8) },
	"parse $path",
) || diag ($@);

had_no_warnings;

