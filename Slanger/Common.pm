package Slanger::Common;

use strict;
use warnings;
use utf8;
use Slanger::Common::SQL;
use DBI;
use File::stat;
use File::Find;
use Date::Format;
use XML::Simple qw(:strict);

our( %userfile, $pathroot, $alldbs, $sql );


$alldbs = { 'common' => q[asdic] };
$pathroot = '/usr/home/al/export_nfs/aslang.com';
$sql = $Slanger::Common::SQL::sql;


sub allright { my $path = shift; open(SOMEFILEIN, ">", $path); print SOMEFILEIN 'ready'; close(SOMEFILEIN); }

sub file_get_content
{
	my $filename = shift;
	my $odir = $pathroot.qq[/tmpupload/$filename];
	undef $/;
	open(FL, "<:utf8", $odir) or die $!; my $result = <FL>; close(FL);
	unlink( $odir );
	return $result;
}

sub getuserxml
{
	my ($uid, $path) = @_;
	my $odir = $pathroot.q[/slanger/];
	undef $/;
	open(FL, "<:utf8", $odir . $uid . $path) or die $!; my $resultt = <FL>; close(FL);
	return $resultt;
}

sub create_user 		# create new user files
{
  my ($uid, $package) = @_;
  my $uidir = $pathroot.q[/slanger/]; #user root dir
  my $dsrc = q[/src/]; #common source file dir
  my $dtrg = q[/trg/]; #common target file dir
	mkdir( $uidir . $uid );
	&xmlcopy($package, $uid);                    # create a blank xml readme file for the user
	mkdir( $uidir . $uid . $dsrc );
	mkdir( $uidir . $uid . $dtrg );
  return;
};

sub xmlcopy 				# xml tmpl copy to a user's directory
{
  my ($res, $uid)     = @_;
  my $tdir            = $pathroot.q[/slanger/txml/];     #xml tmpl dir
  my $txml            = q[filelist.xml];  #xml tmpl
	my $xs = &xmltmplread($txml);
  $xs->{'root'}->{'userdata'}->{'reserved'} = $res;
	&xmlallwrite("/slanger/$uid/filelist.xml", $xs);
  return;
};

sub getfiles 		# chk user src & trg dir contents
{
  my $uid = shift;
  my $uidir   = $pathroot.q[/slanger/];
  my $dsrc    = q[/src/];
  my $dtrg    = q[/trg/];
  my @dsearch = ( qq[$uidir$uid$dsrc], qq[$uidir$uid$dtrg] ); # usr src & trg dirs
  find(\&wanted, @dsearch);
  return \%userfile;
};

sub wanted 		  # File::Find hook
{
  my %fdata;																																# my $mtime = ctime(stat($_)->mtime); chomp( $mtime );
  my $mtime = time2str( "%x %X", stat($_)->mtime);
  @fdata{ qw{ file_ID file_NAME file_DATE file_SIZE } } = ( 0, $_, $mtime, stat($_)->size ) if( -f && m/\.(src|trg)$/ );
  push @{ $userfile{ $File::Find::dir } }, \%fdata;
};

sub xmltmplread 		# xml read
{
  my $ftmplname = shift;
  my $tdir            = $pathroot.q[/slanger/txml/];       	#xml tmpl dir
  my %att             = (
                        'AttrIndent'  => 1,
                        'ForceArray'  => 0,
                        'KeepRoot'    => 1,
                        'KeyAttr'     => [],
                        'NoAttr'      => 1,
                        'SearchPath'  => $tdir,
  );
  my $xs = XML::Simple->new( %att );
  return $xs->XMLin( $ftmplname );
};

sub xmlallwrite 		# xml read
{
  my ($pathname, $xml) = @_;
  my $tdir = $pathroot.$pathname;  # $pathname = /slanger/$uid/trg/$fid/$numstr.xml
  my %att = (
		'AttrIndent'  => 1,
		'ForceArray'  => 0,
		'KeepRoot'    => 1,
		'KeyAttr'     => [],
		'NoAttr'      => 1,
		'OutputFile'  => $tdir,
  );
  my $xs = XML::Simple->new( %att );
  $xs->XMLout( $xml );
  return;
};

sub xmlread 		# xml read
{
  my $uid             = shift;
  my $tdir            = $pathroot.qq[/slanger/$uid/];       	#xml tmpl dir
  my $txml            = q[filelist.xml];            												#xml file for a $uid
  my %att             = (
                        'AttrIndent'  => 1,
                        'ForceArray'  => 0,
                        'KeepRoot'    => 1,
                        'KeyAttr'     => [],
                        'NoAttr'      => 1,
                        'SearchPath'  => $tdir,
  );
  my $xs = XML::Simple->new( %att );
  return $xs->XMLin( $txml );
};

sub xmlwrite 		# xml write
{
  my ($uid, $xml)     = @_; #die Dumper $xml;
  my $tdir            = $pathroot.qq[/slanger/$uid/];        #xml tmpl dir
  my $txml            = q[filelist.xml];       															#xml final
  my %att             = (
                        'AttrIndent'  => 1,
                        'ForceArray'  => 0,
                        'KeepRoot'    => 1,
                        'KeyAttr'     => [],
                        'NoAttr'      => 1,
                        'OutputFile'  => qq[$tdir/$txml],
  );
  my $xs = XML::Simple->new( %att );
  $xs->XMLout( $xml );
  return;
};

sub changexmlparam
{
    my ( $uid, $fid, $dire, $param, $value ) = @_;
    my $xmlcopy  = &Slanger::Common::xmlread( $uid );
    map { $_->{$param} = $value if ($_->{'file_ID'} eq $fid) } @{ $xmlcopy->{'root'}->{'loop'}->{'block_'.$dire}->{'file'} };
		&Slanger::Common::xmlwrite( $uid, $xmlcopy );
};

sub readxmlparam
{
    my ( $uid, $fid, $dire, $param ) = @_;
    my $xmlcopy  = &Slanger::Common::xmlread( $uid );
		my $value;
    map { $value = $_->{$param} if ($_->{'file_ID'} eq $fid) } @{ $xmlcopy->{'root'}->{'loop'}->{'block_'.$dire}->{'file'} };
		return $value;
};

## XML stuff

#my %atts = (
#	0 => q[type],
#	1 => q[stype],
#	2 => q[g1],
#	3 => q[g2],
#	4 => q[g3]
#);

sub xmlout
{
		my ($xml, $attr, $path) = @_;
		my ($fileh, $stack);
		open($fileh, ">:utf8", $path) or die $!;
		print $fileh qq[<?xml version="1.0" encoding="utf-8"?><root>\n];
		&recurdeep($xml, $attr, $fileh, $stack);
		print $fileh qq[</root>\n];
		close($fileh); return;
}

sub recurdeep
{
	my ($xml, $attr, $fileh, $stack) = @_;
	map {
		my $cur = $_;
		push @{$stack}, $cur;
		if ( ref($xml->{$cur}) ne 'HASH' ) {
			my $attrib = join(' ', map { qq[$attr->{$_}="$stack->[$_]"] } (0 .. $#{@{$stack}}));
			print $fileh "<value $attrib><![CDATA[$xml->{$cur}]]></value>\n";
			pop @{$stack};
		} else {
			&recurdeep($xml->{$cur}, $attr, $fileh, $stack);
			pop @{$stack};
		}
	} keys %{$xml};
	return;
};


## from AsEngine

sub sSELECT {
  my ($smode, $par, $dbname) = @_;
  my %sparam = %{$par};
  return &db_select( $dbname || $alldbs->{'common'}, $sql->{$smode}->{'q'}, [@sparam{ @{$sql->{$smode}->{'s'}}}] );
};

sub db_select {
  my ($dbname, $query, $datum) = @_;
  $datum = [] unless ($datum);
  my $dbh = &dbcon($dbname);
  $dbh->do('SET NAMES utf8');
  my $sth = $dbh->prepare($query);
  $sth->execute(@{$datum});
  $sth = 0 if ($DBI::errstr);
  my @res = ();
  while (my $r = $sth->fetchrow_hashref) { push @res, $r; }
  $dbh->disconnect();
  return \@res;
};

sub setDBI
{
  my $dbh = &dbcon( q[asdic] );
  $dbh->do(q[SET NAMES UTF8]);
  return $dbh;
};

sub dbcon {
  my $db_name = shift;
  my $host_name = '192.168.44.1';
  my $dsn = "DBI:mysql:host=$host_name;database=$db_name";
  return (DBI->connect ($dsn, 'root', '', { PrintError => 1, RaiseError => 1 }));
};

1;