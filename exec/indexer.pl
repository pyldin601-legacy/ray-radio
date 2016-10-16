#!/usr/bin/perl

use DBI;
use POSIX;
use Digest::MD5 qw(md5_hex);
use FindBin qw($Bin);
use POSIX qw(strftime);
use Date::Parse;

exit if check_lock();
create_lock();

require "$Bin/tags.pl";

chdir($Bin);

my @datadirs = ( "/media", "/medib" );

# file group
my $audio = 'mp3|ogg|m4a';

# mysql database
my $db_host = "localhost";
my $db_user = "root";
my $db_pass = "";
my $db_base = "jrp";
my $dsn = "dbi:mysql:database=$db_base:mysql_socket=/tmp/mysql.sock";

%filesHash = ();

my $begin = time;

$SIG{'INT'} = sub {
    terminate();
};

$dbh = DBI->connect($dsn, $db_user, $db_pass) || die "Can't connect to mysql!";
$dbh->do("set names 'utf8'");

# We cache indexed files;
$q = $dbh->prepare("SELECT * FROM `jrp2_tracklist` WHERE 1");
$q->execute();
while($row = $q->fetchrow_hashref()) {
	$filesHash{$row->{path}} = $row->{id};
}

print "Indexed ", scalar keys %filesHash, " files\n";

# Now we are scanning directories recursively and are updating information if changed
foreach $datadir(@datadirs) {
    scan_dir($datadir);
}

foreach $key (keys %filesHash) {
    uccons("[xF] $key");
    $dbh->do("delete from `jrp2_tracklist` where `id` = ?", undef, $filesHash{$key});
}

uccons("Finishing...");
$dbh->disconnect();

remove_lock();

exit;

sub scan_dir() {
    my $path = shift;
    my $q_path = $dbh->quote($path);

    my @darray = ();

    opendir(DIR, $path) || return -1; 
    my @tmp = readdir DIR;
    closedir(DIR);

    foreach my $file (sort @tmp) {
        $fullfile = $path . '/' . $file;
        if(-d $fullfile) {
            next if(($file eq '.') or ($file eq '..'));
            push(@darray, $file);
        } elsif(-e $fullfile) {
			next if($file !~ /\.($audio)$/);
            if(!exists($filesHash{$fullfile})) {
                # index new file
				uccons("Scanning file $fullfile...");
				
                index_this_file($file, $path);
            } else {
                # file not changed
                delete( $filesHash{$fullfile} );
            }
        }
    }
    
    # continue recursion here
    foreach $dfile(@darray) {
        scan_dir($path.'/'.$dfile);
    }

}

sub excluded
{
    my $path = shift;
    foreach $fp (@denyfiles) 
    {
        return 1 if ( $path =~ /\/$fp$/i );
    }
    foreach $fp (@exclude) 
    {
        return 1 if ( $path =~ /^$fp/i );
    }
    return 1 if ( $path =~ /\.part$/i );
    return 0;
}

sub index_this_file () 
{
    my @argm = ();
    my $fname = shift;
    my $fpath = shift;
    my $filename = $fpath . '/' . $fname;

    push @argm, $filename; # 0

    my @minfo = get_audio_info($filename);
    push @argm, @minfo; #1..4
	push @argm, md5_hex($filename); #4
	push @argm, rand(10000000000); #5

    for my $n (0..$#argm) { $argm[$n] = $dbh->quote($argm[$n]); }
    
    $qr = sprintf("insert into `jrp2_tracklist` (`path`, `length`, `artist`, `title`, `genre`, `uid`, `random`) values (%s)", join(', ', @argm));
    $dbh->do($qr);
    return 0;
}

sub uccons() 
{
    my $text = shift;
    print "$text\n";
}



sub terminate() 
{
    remove_lock();
    exit;
}

sub create_lock() 
{
    print "[LOCK] CREATING\n";
    open PD, ">", "$Bin/run/index.pid";
    print PD $$;
    close PD;
}

sub remove_lock() {
    print "[LOCK] REMOVING\n";
    unlink "$Bin/run/index.pid";
}

sub check_lock() {

    return 0 if (! -e "$Bin/run/index.pid");

    open PD, "<", "$Bin/run/index.pid";
    $pid = <PD>;
    close PD;
    chomp $pid;

    return 0 unless ( kill 0, $pid );

    print "[LOCK] LOCKED!\n";
    return 1;

}

