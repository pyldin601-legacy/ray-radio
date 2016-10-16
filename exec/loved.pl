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
$db2->do("TRUNCATE TABLE `jrp_loved`");

my $page = 1;
my $totalPages = 1;


for(my $page=1; $page<=$totalPages; $page++) {
	if($data = XMLin(get("http://ws.audioscrobbler.com/2.0/?method=user.getlovedtracks&user=TedIrens&api_key=f7a8f639e4747490849e3bc33475b118&page=${page}"))) {
		$xmldata = $data->{'lovedtracks'};
		$totalPages = $xmldata->{'totalPages'};
		$tracks = $xmldata->{'track'};
		foreach $track (keys %{$tracks}) {
			$artist = $tracks->{$track}->{'artist'}->{'name'};
			$titlesql = $db2->quote($track);
			$artistsql = $db2->quote($artist);
			print "$artist - $track\n";
			$db2->do("REPLACE INTO `jrp_loved` VALUES ($artistsql, $titlesql)");
		}
	} else {
		die("Parsing XML error!");
	}
}

$db2->disconnect();
