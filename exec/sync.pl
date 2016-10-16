#!/usr/bin/perl

use DBI;
use LWP::Simple;
use URI::Escape;
use JSON;

use Data::Dumper;

my $use_genres = "chillwave,new age,chillout,dubstep,psybient,ambient,spacemusic,electronic";
my $max_titles = 1000; # maximum titles of one artist

my %titles = ();


my $db1 = DBI->connect("dbi:mysql:search:localhost:3386", "root", "");
my $db2 = DBI->connect("dbi:mysql:jrp:localhost:3386", "root", "");
$db1->do("SET NAMES 'utf8'");
$db2->do("SET NAMES 'utf8'");
$db2->do("TRUNCATE `jrp_playlist`");

my $h = $db1->prepare("SELECT CONCAT(`filepath`,'/',`filename`),`audio_artist`,`audio_title`,`audio_genre`,`avg_duration` FROM `search_files` WHERE `audio_artist` != '' AND `audio_title` != '' AND FIND_IN_SET(`audio_genre`, '$use_genres') ORDER BY RAND()");
$h->execute();
$max = $h->rows();
while(@row = $h->fetchrow_array()) {

	if(exists($titles{$row[1]})) {
	    ++$titles{$row[1]};
	} else {
	    $titles{$row[1]} = 1;
	}
	next if($titles{$row[1]} > $max_titles);
	
	$rnd = int(rand() * 1000000000);
	$filename = $db2->quote(@row[0]);
	$artist = $db2->quote(@row[1]);
	$title = $db2->quote(@row[2]);
	$genre = $db2->quote(@row[3]);
	$durat = @row[4];
	$pc = 0;
	$db2->do("INSERT INTO `jrp_playlist` VALUES (NULL,$rnd,$filename,$artist,$title,$genre,$durat,0,'$pc')");
	print "$row[1] - $row[2] - $pc\n";
}

$db2->do("OPTIMIZE TABLE `jrp_playlist`");

$db2->disconnect();
$db1->disconnect();

sub sk_genre {
	my $gen = shift;
	foreach $g ( @skip_genres ) {
		return 1 if (lc($gen) eq $g);
	}
	return 0;
}

sub fm_playcount {
    my $artist = uri_escape shift;
    my $title = uri_escape shift;
    my $st_json = decode_json(get("http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=f7a8f639e4747490849e3bc33475b118&artist=${artist}&track=${title}&format=json"));

    my $pc = int($st_json->{track}->{playcount});
    return $pc;
}