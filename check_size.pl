#!/usr/bin/env perl

use Modern::Perl;
use Path::Tiny;

my $MAX_SIZE = 949;

@ARGV==1 or die "$0 file.P\n";
my $p_file = shift;
(my $map_file = $p_file) =~ s/\.\w+$/.map/;
for (path($map_file)->lines) {
	if (/^__size\s*=\s*\$([0-9A-Fa-f]+)/) {
		my $size = hex($1);
		say "Size of $p_file: $size bytes, ", ($MAX_SIZE-$size), " bytes free";
		if ($size > $MAX_SIZE) {
			say "$p_file to large for 1K\n";
		}
	}
}
