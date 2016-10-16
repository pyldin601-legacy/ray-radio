#!/usr/bin/perl

use DBI;
use XML::Simple;
use LWP::Simple;
use Data::Dumper;
use URL::Encode qw(url_encode);
use Encode qw(decode encode);

my $xml = new XML::Simple;

my $db2 = DBI->connect("dbi:mysql:jrp:localhost:3386", "root", "");
$db2->do("SET NAMES 'utf8'");

my $h = $db2->prepare('SELECT `artist`, `title` FROM `jrp_playlist` WHERE `playcount` = 0 GROUP BY `artist`, `title` ORDER BY RAND()');
$h->execute();
$max = $h->rows();
$pos = 0;
while(@row = $h->fetchrow_array()) {
	$pos ++;
	$artist = url_encode($row[0]);
	$title = url_encode($row[1]);

	$dbart = $db2->quote(decode('utf8',$row[0]));
	$dbtit = $db2->quote(decode('utf8',$row[1]));

	print "$pos/$max: $row[0] - $row[1]";

	$lastfm = get("http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=f7a8f639e4747490849e3bc33475b118&artist=${artist}&track=${title}");
	if($lastfm ne '') {
		if($data = XMLin($lastfm)) {
			my $pc = $data->{track}->{playcount};
			my $topref = $data->{track}->{toptags}->{tag};
			my $taglist = "";
			if(ref($topref) eq 'HASH') {
				my @tags = ();
				foreach $key (keys %{$topref}) {
					push @tags, '"'.$key.'"';
				}
				$taglist = $db2->quote(join(',', @tags));
			} else {
				$taglist = "''";
			}
			if(ref($pc) ne 'HASH') {
				print " ($pc)";
				$query = qq(UPDATE `jrp_playlist` SET `playcount` = '$pc', `tags` = $taglist WHERE `artist` = $dbart AND `title` = $dbtit);
				$ret = $db2->do($query);
				print " -> $ret";
			} else {
				print " (zero)";
			}
		} else {
			print " (error)";
		}
	} else {
		print " (not found)";
	}
	print "\n";
}

$db2->do("OPTIMIZE TABLE `jrp_playlist`");

$db2->disconnect();
