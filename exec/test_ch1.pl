#!/usr/bin/perl
use DBI;

$SIG{'INT'} = \&sigIntHandler;

#fork and exit;

while(1) {
    my $db = DBI->connect("dbi:mysql:jrp:localhost:3386", "root", "");
    $db->do("SET NAMES 'utf8'");
    $h = $db->prepare("SELECT * FROM `jrp_playlist` WHERE `genre` = 'psybient' ORDER BY RAND()");
    $h->execute;
    while(@row = $h->fetchrow_array()) {
	system("ffmpeg -i \"".esc_chars($row[2])."\" -acodec pcm_s16le -ar 44100 -ac 2 -f WAV - 2>/tmp/ch1_in.log | throttle -v -w 5 -k 1411.2 2>/tmp/ch1_th.log | ffmpeg -i - -threads 8 http://localhost:8090/1.ffm 2>/tmp/ch1_out.log");
    }
}

sub esc_chars {
    my $arg = shift;
    $arg =~ s/([\"])/\\$1/g;
    return $arg;
}


sub sigIntHandler {
    print "INT caught!\n";
    exit;
}