#!/usr/bin/perl
use DBI;
use threads;
use threads::shared;
use Data::Dumper;

exit if check_lock();
create_lock();

$SIG{'INT'} = \&terminate;

#fork and exit;

my @threads = ();

my $db = DBI->connect("dbi:mysql:jrp:localhost:3386", "root", "");
$db->do("SET NAMES 'utf8'");
$h = $db->prepare("SELECT * FROM `jrp2_streams` WHERE 1");
$h->execute;


while(@row = $h->fetchrow_array()) {
    push @threads, threads->create( \&radio_bc, @row );
}

foreach $thread(@threads) { $thread->join(); }

remove_lock();

sub radio_bc {

    my $stream_id = shift;
    my $stream_title = shift;
    my $stream_query = shift;
    my $stream_ffm = shift;

	my $db = DBI->connect("dbi:mysql:jrp:localhost:3386", "root", "");
	$db->do("SET NAMES 'utf8'");
    while(1) {
		my @tracks = ();
		$h = $db->prepare($stream_query);
		$h->execute;
		while(@row = $h->fetchrow_array()) {
			push @tracks, [@row];
		}
		
		foreach $track (@tracks) {
			$filename = esc_chars(@{$track}[2]);
			$db->do("REPLACE INTO `jrp2_stat` VALUES (?, ?, ?, ?, ?)", undef, $stream_id, @{$track}[4], @{$track}[3], @{$track}[6], time);
			system("ffmpeg -i \"$filename\" -acodec pcm_s16le -ar 44100 -ac 2 -f WAV - 2>/dev/null | throttle -w 5 -k 1411.2 | ffmpeg -i - -metadata title='456' $stream_ffm 2>/dev/null");
		}
    }
}

sub esc_chars {
    my $arg = shift;
    $arg =~ s/([\"])/\\$1/g;
    return $arg;
}

sub terminate() {
    remove_lock();
    exit;
}

sub create_lock() {
    print "[LOCK] CREATING\n";
    open PD, ">", "$Bin/run/rs.pid";
    print PD $$;
    close PD;
}

sub remove_lock() {
    print "[LOCK] REMOVING\n";
    unlink "$Bin/run/rs.pid";
}

sub check_lock() {

    return 0 if (! -e "$Bin/run/rs.pid");

    open PD, "<", "$Bin/run/rs.pid";
    $pid = <PD>;
    close PD;
    chomp $pid;

    return 0 unless ( kill 0, $pid );

    print "[LOCK] LOCKED!\n";
    return 1;

}

