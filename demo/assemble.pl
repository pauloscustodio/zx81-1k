#!/usr/bin/env perl

# convert zx81 character set and call z88dk-z80asm

use Modern::Perl;

my %CHARS = (
	" ",		0x00,
	"\\' ",		0x01,
	"\\ '",		0x02,
	"\\''",		0x03,
	"\\. ",		0x04,
	"\\: ",		0x05,
	"\\.'",		0x06,
	"\\:'",		0x07,
	"\\##",		0x08,
	"\\,,",		0x09,
	"\\~~",		0x0a,
	"\"",		0x0b,
	"\$",		0x0d,
	":",		0x0e,
	"?",		0x0f,
	"(",		0x10,
	")",		0x11,
	">",		0x12,
	"<",		0x13,
	"=",		0x14,
	"+",		0x15,
	"-",		0x16,
	"*",		0x17,
	"/",		0x18,
	";",		0x19,
	",",		0x1a,
	".",		0x1b,
	"0",		0x1c,
	"1",		0x1d,
	"2",		0x1e,
	"3",		0x1f,
	"4",		0x20,
	"5",		0x21,
	"6",		0x22,
	"7",		0x23,
	"8",		0x24,
	"9",		0x25,
	"A",		0x26,
	"B",		0x27,
	"C",		0x28,
	"D",		0x29,
	"E",		0x2a,
	"F",		0x2b,
	"G",		0x2c,
	"H",		0x2d,
	"I",		0x2e,
	"J",		0x2f,
	"K",		0x30,
	"L",		0x31,
	"M",		0x32,
	"N",		0x33,
	"O",		0x34,
	"P",		0x35,
	"Q",		0x36,
	"R",		0x37,
	"S",		0x38,
	"T",		0x39,
	"U",		0x3a,
	"V",		0x3b,
	"W",		0x3c,
	"X",		0x3d,
	"Y",		0x3e,
	"Z",		0x3f,
	"\\::",		0x80,
	"\\.:",		0x81,
	"\\:.",		0x82,
	"\\..",		0x83,
	"\\':",		0x84,
	"\\ :",		0x85,
	"\\'.",		0x86,
	"\\ .",		0x87,
	"\\\@\@",	0x88,
	"\\;;",		0x89,
	"\\!!",		0x8a,
	"%\"",		0x8b,
	"%\$",		0x8d,
	"%:",		0x8e,
	"%?",		0x8f,
	"%(",		0x90,
	"%)",		0x91,
	"%>",		0x92,
	"%<",		0x93,
	"%=",		0x94,
	"%+",		0x95,
	"%-",		0x96,
	"%*",		0x97,
	"%/",		0x98,
	"%;",		0x99,
	"%,",		0x9a,
	"%.",		0x9b,
	"%0",		0x9c,
	"%1",		0x9d,
	"%2",		0x9e,
	"%3",		0x9f,
	"%4",		0xa0,
	"%5",		0xa1,
	"%6",		0xa2,
	"%7",		0xa3,
	"%8",		0xa4,
	"%9",		0xa5,
	"%A",		0xa6,
	"%B",		0xa7,
	"%C",		0xa8,
	"%D",		0xa9,
	"%E",		0xaa,
	"%F",		0xab,
	"%G",		0xac,
	"%H",		0xad,
	"%I",		0xae,
	"%J",		0xaf,
	"%K",		0xb0,
	"%L",		0xb1,
	"%M",		0xb2,
	"%N",		0xb3,
	"%O",		0xb4,
	"%P",		0xb5,
	"%Q",		0xb6,
	"%R",		0xb7,
	"%S",		0xb8,
	"%T",		0xb9,
	"%U",		0xba,
	"%V",		0xbb,
	"%W",		0xbc,
	"%X",		0xbd,
	"%Y",		0xbe,
	"%Z",		0xbf,
);

my @opts;
my @files;
for my $arg (@ARGV) {
	if ($arg =~ /^-/) {
		push @opts, $arg;
	}
	else {
		(my $pp_file = $arg) =~ s/\.\w+$/.i/;
		convert_file($arg, $pp_file);
		push @files, $pp_file;
	}
}
@files or die "Usage: $0 files...\n";

(my $p_file = $files[0]) =~ s/\.\w+$/.P/;
run("z88dk-z80asm -m -b -o$p_file @opts @files");
exit 0;


sub convert_file {
	my($in, $out) = @_;
	say "$in -> $out";
	open(my $ifh, "<", $in) or die "open $in: $!\n";
	open(my $ofh, ">", $out) or die "create $out: $!\n";
	while (<$ifh>) {
		s/ \b zx81text \s* \" (.*) \" \s* (?:;.*)? $/ "db ".convert_string($1)."\n"/xie;
		print $ofh $_;
	}
}

sub convert_string {
	my($text) = @_;
	$text = uc($text);
	my @bytes;
char:
	while ($text ne "") {
		for my $len (reverse 1..3) {
			next if length($text) < $len;
			my $start = substr($text, 0, $len);
			if (exists $CHARS{$start}) {
				push @bytes, $CHARS{$start};
				$text = substr($text, $len);
				next char;
			}
		}
		die "cannot parse string: $text\n";
	}
	return join(",", @bytes);
}

sub run {
	my($cmd) = @_;
	say $cmd;
	0==system($cmd) or die "command failed: $cmd\n";
}
