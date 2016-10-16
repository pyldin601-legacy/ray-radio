package Mediainfo;

use FindBin qw($Bin);

sub new
{
    my $pkg = shift;
    my $self = {@_};
    bless $self, $pkg;

    $self->mediainfo($self->{filename});
    return $self;
}

sub esc_chars {
	my $file = shift;
	$file =~ s/(\W)/\\$1/g;
	return $file;
}

sub mediainfo
{
    my $self = shift;
    my $file = shift || return undef;

    my $filesize = -s $file;
    $file = esc_chars($file);
    open(STRM, $Bin . "/mediainfo2 -f $file 2>/dev/null |");
    my $mediainfo = join('', <STRM>);
    close(STRM);

    $mediainfo =~ s/\r//g if $mediainfo;
    my ($genernal_info) = $mediainfo =~ /(^General\n.*?\n\n)/sm;
    return undef unless $genernal_info;

    my ($video_info) = $mediainfo =~ /(^Video[\s\#\d]*\n.*?\n\n)/sm;
    my ($audio_info) = $mediainfo =~ /(^Audio[\s\#\d]*\n.*?\n\n)/sm;

    my $container;
    ($container) = $genernal_info =~ /Format\s*:\s*([\w\_\-\\\/\. ]+)\n/;
    $container =~ s/\s//g if $container;
    my ($length) = $genernal_info =~ /\nDuration\s*:\s*(\d+)\.?\d*\n/;
    my ($bitrate) = $genernal_info =~ /Overall bit rate\s*:\s*(\d+)\n/;

    my ($title) = $genernal_info =~ /\nTitle\s*:\s*(.+)\n/;
    my ($artist) = $genernal_info =~ /\nPerformer\s*:\s*(.+)\n/;
    my ($tracknum) = $genernal_info =~ /\nTrack name\/Position\s*:\s*(\d+)\n/;
    my ($album) = $genernal_info =~ /\nAlbum\s*:\s*(.+)\n/;
    my ($band) = $genernal_info =~ /\nAlbum\/Performer\s*:\s*(.+)\n/;
    my ($genre) = $genernal_info =~ /\nGenre\s*:\s*(.+)\n/;
    my ($cover) = $genernal_info =~ /\nCover_Data\s*:\s*(.+)\n/;
    my ($year) = $genernal_info =~ /Recorded\sdate\s*:\s*(\d+)\n/;

    my $video_codec;
    my $video_format;
    my $video_length;
    my $video_bitrate;
    my $width;
    my $height;
    my $fps;
    my $frame_count;
    my $fps_mode;
    my $dar;
    if($video_info)
    {
        ($video_codec) = $video_info =~ /Codec\s*:\s*([\w\_\-\\\/ ]+)\n/;
        ($video_format) = $video_info =~ /Format\s*:\s*([\w\_\-\\\/ ]+)\n/;
        $video_codec =~ s/\s//g if $video_codec;
        $video_format =~ s/\s//g if $video_format;
        ($video_length) = $video_info =~ /Duration\s*:\s*(\d+)\.?\d*\n/;
        ($video_bitrate) = $video_info =~ /Bit rate\s*:\s*(\d+)\n/;
        ($width) = $video_info =~ /Original width\s*:\s*(\d+)\n/;
        ($width) = $video_info =~ /Width\s*:\s*(\d+)\n/ unless $width;
        ($height) = $video_info =~ /Original height\s*:\s*(\d+)\n/;
        ($height) = $video_info =~ /Height\s*:\s*(\d+)\n/ unless $height;
        ($fps) = $video_info =~ /Frame rate\s*:\s*([\d\.]+)\n/;
        ($fps) = $video_info =~ /frame rate\s*:\s*([\d\.]+)\s*fps\n/ unless $fps;
        ($frame_count) = $video_info =~ /Frame count\s*:\s*(\d+)\n/;
        ($fps_mode) = $video_info =~ /Frame rate mode\s*:\s*([\w\.]+)\n/i;
        ($dar) = $video_info =~ /Display aspect ratio\s*:\s*([\d\.]+)\n/i;
        $frame_count = int($fps * $video_length / 1000) if ($fps and $video_length and (!$frame_count or $frame_count <= 0) );
        $fps = substr($frame_count / $video_length * 1000, 0, 6) if ( (!$fps or $fps <= 0) and $video_length and $frame_count);
        $video_length = substr($frame_count / $fps * 1000, 0, 6) if ($fps and (!$video_length or $video_length <= 0) and $frame_count);
        $video_length = $length if (!$video_length and $length and $video_info);
    }

    my $audio_codec;
    my $audio_format;
    my $audio_length;
    my $audio_bitrate;
    my $audio_rate;
    my $audio_language;
    my $audio_year;
    if($audio_info)
    {
        ($audio_codec) = $audio_info =~ /Codec\s*:\s*([\w\_\-\\\/ ]+)\n/;
        ($audio_format) = $audio_info =~ /Format\s*:\s*([\w\_\-\\\/ ]+)\n/;
        $audio_codec =~ s/\s//g if $audio_codec;
        $audio_format =~ s/\s//g if $audio_format;
        ($audio_length) = $audio_info =~ /Duration\s*:\s*(\d+)\.?\d*\n/;
        ($audio_bitrate) = $audio_info =~ /Bit rate\s*:\s*(\d+)\n/;
        ($audio_rate) = $audio_info =~ /Sampling rate\s*:\s*(\d+)\n/;
        $audio_length = $video_length if ( (!$audio_length or $audio_length <= 0) and $video_length and $audio_info);
        ($audio_language) = $audio_info =~ /Language\s*:\s*(\w+)\n/;
    }

    $self->{'filename'} = $file;
    $self->{'filesize'} = $filesize;
    $self->{'container'} = lc($container);
    $self->{'length'} = $length;
    $self->{'bitrate'} = $bitrate;
    $self->{'video_codec'} = lc($video_codec);
    $self->{'video_format'} = lc($video_format);
    $self->{'video_length'} = $video_length;
    $self->{'video_bitrate'} = $video_bitrate;
    $self->{'width'} = $width;
    $self->{'height'} = $height;
    $self->{'fps'} = $fps;
    $self->{'fps_mode'} = lc($fps_mode);
    $self->{'dar'} = $dar;
    $self->{'frame_count'} = $frame_count;
    $self->{'audio_codec'} = lc($audio_codec);
    $self->{'audio_format'} = lc($audio_format);
    $self->{'audio_length'} = $audio_length;
    $self->{'audio_bitrate'} = $audio_bitrate;
    $self->{'audio_rate'} = $audio_rate;
    $self->{'audio_language'} = $audio_language;
    $self->{'have_video'} = ($video_info) ? 1 : 0;
    $self->{'have_audio'} = ($audio_info) ? 1 : 0;

    $self->{'tracktitle'} = $title;
    $self->{'trackartist'} = $artist;
    $self->{'trackband'} = $band;
    $self->{'tracknumber'} = $tracknum;
    $self->{'trackalbum'} = $album;
    $self->{'trackgenre'} = $genre;
    $self->{'trackcover'} = $cover;
    $self->{'trackyear'} = $year;

}

1;

__END__

=head1 NAME

Mediainfo - Perl interface to Mediainfo


=head1 SYNOPSIS

  use Mediainfo;
  my $foo_info = new Mediainfo("filename" => "/root/foo.mp4");
  print $foo_info->{video_format}, "\n";
  print $foo_info->{video_length}, "\n";
  print $foo_info->{video_bitrate}, "\n";


=head1 DESCRIPTION

This module is a thin layer above "Mediainfo" which supplies technical and tag information about a video or audio file.

L<http://mediainfo.sourceforge.net/>


=head1 EXAMPLES

  use Mediainfo;

  my $foo_info = new Mediainfo("filename" => "/root/foo.mp4");
  print $foo_info->{filename}, "\n";
  print $foo_info->{filesize}, "\n";
  print $foo_info->{container}, "\n";
  print $foo_info->{length}, "\n";
  print $foo_info->{bitrate}, "\n";
  print $foo_info->{video_codec}, "\n";
  print $foo_info->{video_format}, "\n";
  print $foo_info->{video_length}, "\n";
  print $foo_info->{video_bitrate}, "\n";
  print $foo_info->{width}, "\n";
  print $foo_info->{height}, "\n";
  print $foo_info->{fps}, "\n";
  print $foo_info->{fps_mode}, "\n";
  print $foo_info->{dar}, "\n";
  print $foo_info->{frame_count}, "\n";
  print $foo_info->{audio_codec}, "\n";
  print $foo_info->{audio_format}, "\n";
  print $foo_info->{audio_length}, "\n";
  print $foo_info->{audio_bitrate}, "\n";
  print $foo_info->{audio_rate}, "\n";
  print $foo_info->{audio_language}, "\n";
  print $foo_info->{have_video}, "\n";
  print $foo_info->{have_audio}, "\n";
             
             
=head1 AUTHOR

Written by ChenGang

yikuyiku.com@gmail.com

L<http://blog.yikuyiku.com/>


=head1 COPYRIGHT

Copyright (c) 2011 ChenGang.

This library is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.


=head1 SEE ALSO

L<Video::Info>, L<Movie::Info>
