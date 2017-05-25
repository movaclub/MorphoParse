package Slanger::Filer;

use strict;
use warnings;
use utf8;
use Slanger::Common;
use Slanger::Filer::Voca;
use Data::Dumper;
use File::Find;
use Date::Format;
use File::stat;
use File::Path;
use XML::Simple qw(:strict);

sub process # start process from Filer (generate vocabulary)
{
    my ($uid, $fid, $direction) = @_;

    my $xmlcopy  = &Slanger::Common::xmlread( $uid );
    my $tfid = 0;
    grep {
      ( $tfid < $_->{'file_ID'} ) ? $tfid = $_->{'file_ID'} : $tfid = $tfid;
    } @{ $xmlcopy->{'root'}->{'loop'}->{'block_trg'}->{'file'} };
    $tfid++;
    undef $xmlcopy;

    &Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'actionf', 'false' );
    &Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'actioni', 'false' );
    #&Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'links', { 'link' => [0, 0, $tfid] } );
    &Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'links', { 'link' => [0, 0, $fid] } );

    $Slanger::Filer::Voca::subsvoca{$direction}->(@_ = ($uid, $fid, $tfid)) if (exists $Slanger::Filer::Voca::subsvoca{$direction});

    my ($ufilez, %tsize);
    $xmlcopy  = &Slanger::Common::xmlread( $uid );
    $ufilez = &Slanger::Common::getfiles( $uid );
    grep{
        my $dira    = $_;
        grep{
            my %curr = %{$_};
            if ((keys %curr) > 0) {
                push @{ $xmlcopy->{'root'}->{'loop'}->{'block_trg'}->{'file'} },
                {
                    #'file_ID'       => $tfid,
                    'file_ID'       => $fid,
                    'file_NAME'     => 'auto_vocabulary.txt',
                    'file_SIZE'     => $curr{ 'file_SIZE' },
                    'file_DATE'     => $curr{ 'file_DATE' }
                #} if( $curr{'file_NAME'} eq "$tfid.trg" );
                } if( $curr{'file_NAME'} eq "$fid.trg" );
                $tsize{ $curr{'file_NAME'} } = $curr{'file_SIZE'} unless( exists $tsize{ $curr{'file_NAME'} } );
            }
        } @{ $ufilez->{$dira} };
    } keys %{ $ufilez };
    $xmlcopy->{'root'}->{'userdata'}->{'used'} = 0;
    $xmlcopy->{'root'}->{'userdata'}->{'used'} += $_ for( ( values %tsize  ) );
    &Slanger::Common::xmlwrite( $uid, $xmlcopy );

    return;
}

sub replacefile
{
    my ( $uid, $fid, $filecont, $direction ) = @_;

    my $udir = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];   #user src file directory
    use Encode;
    $filecont = decode("utf8", $filecont);
    open( FL, '>', $udir ) or die $!; print FL $filecont; close(FL);

    ########## recall size all files ###################
    my ($ufilez, %tsize, $sizenew);
    my $xmlcopy  = &Slanger::Common::xmlread( $uid );
    $ufilez = &Slanger::Common::getfiles( $uid );
    grep{
        my $dira    = $_;
        grep{
            my %curr = %{$_};
            if ((keys %curr) > 0) {
                $sizenew = $curr{'file_SIZE'} if( $curr{'file_NAME'} eq "$fid.trg" );
                $tsize{ $curr{'file_NAME'} } = $curr{'file_SIZE'} unless( exists $tsize{ $curr{'file_NAME'} } );
            }
        } @{ $ufilez->{$dira} };
    } keys %{ $ufilez };
    $xmlcopy->{'root'}->{'userdata'}->{'used'} = 0;
    $xmlcopy->{'root'}->{'userdata'}->{'used'} += $_ for( ( values %tsize  ) );
    &Slanger::Common::xmlwrite( $uid, $xmlcopy );

    &Slanger::Common::changexmlparam ( $uid, $fid, 'trg', 'file_SIZE', $sizenew );
    ####################################################

    return;
}

sub addfile  # register a new file for a user
{
    my ( $uid, $ufname, $fcont ) = @_;
    use Encode;
    my $fid = 0; 						# file IDs collector
    # read xml read.me
    my ($ufilez, $xml, %tsize);
    my $xmlcopy  = &Slanger::Common::xmlread( $uid );

    # chk for the file name duplication ( against xml read.me ) - (!) unconditional return (!)
    grep { ( $fid < $_->{'file_ID'} ) ? $fid = $_->{'file_ID'} : $fid = $fid; } @{ $xmlcopy->{'root'}->{'loop'}->{'block_src'}->{'file'} };

    $fid +=1;

    my $fname = $fid.q[.src];

    &filewrite($uid, $fname, $fcont);
    $ufilez = &Slanger::Common::getfiles( $uid );

    #use Data::Dumper;
    #print "\n\n", Dumper($ufilez, $fname), "\n\n";

    grep{
        my $dira    = $_;
        grep{
            my %curr = %{$_};
            if ((keys %curr) > 0) {
                push @{ $xmlcopy->{'root'}->{'loop'}->{'block_src'}->{'file'} },
                {
                    'file_ID'       => $fid,
                    'file_NAME'     => decode("utf8", $ufname),
                    'file_SIZE'     => $curr{ 'file_SIZE' },
                    'file_DATE'     => $curr{ 'file_DATE' },
                    'links'         => { 'link' => [0,0], },
                    'actionf'       => 'true',
                    'actioni'       => 'false'
                } if( $curr{'file_NAME'} eq $fname );
                #} if( $curr->{'file_NAME'}  =~ m/^$fname$/ );
                $tsize{ $curr{'file_NAME'} } = $curr{'file_SIZE'} unless( exists $tsize{ $curr{'file_NAME'} } );
            }
        } @{ $ufilez->{$dira} };
    } keys %{ $ufilez };
    $xmlcopy->{'root'}->{'userdata'}->{'used'} = 0;
    $xmlcopy->{'root'}->{'userdata'}->{'used'} += $_ for( ( values %tsize  ) );
    &Slanger::Common::xmlwrite( $uid, $xmlcopy );

		return $fid;
};

sub deletefile
{
    my ( $uid, $fid, $dire ) = @_;
    my $fname     = $fid.q[.].$dire;# real user file name
    my $fext      = q[block_].$dire;# which block to look in
    my ($ufilez, $xml, $fnum, %tsize, $srcfid);
    # read xml read.me
    my $xmlcopy   = &Slanger::Common::xmlread( $uid );
    my @newfiles;
    grep{
          my $el = $_;
          if($fid  =~ m/^$xmlcopy->{'root'}->{'loop'}->{ $fext }->{'file'}->[ $el ]->{'file_ID'}$/)
          {
            $fnum = &delfile( $uid, $fname, $dire );

						# to do cascade delete if any
						if ($dire eq 'src') {
              my @trgids;
							map {
								my $curr = $_;
                if ($curr) {
                    push @trgids, $curr;
                    &delfile( $uid, $curr.'.trg', 'trg' );
                    rmtree( $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$curr] ); #, { verbose => 0 }
                }
							} @{$xmlcopy->{'root'}->{'loop'}->{ $fext }->{'file'}->[ $el ]->{'links'}{'link'}};

              map {
                my $curidtrgs = $_;
                my @localtrgfiles;
                map { push @localtrgfiles, $_ if ( $curidtrgs ne $_->{'file_ID'} ) } @{$xmlcopy->{'root'}->{'loop'}->{'block_trg'}->{'file'}};
                $xmlcopy->{'root'}->{'loop'}->{'block_trg'}->{'file'} = [@localtrgfiles];
              } @trgids;

						} else {
							rmtree( $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fname] ); #, { verbose => 0 }
							map {
                my $curfiled = $_;
                map { $srcfid = $curfiled->{'file_ID'} if ($_ eq $fid) } @{ $curfiled->{'links'}{'link'} };
							} @{$xmlcopy->{'root'}->{'loop'}->{'block_src'}->{'file'}};
						}

            $ufilez         = &Slanger::Common::getfiles( $uid );
            grep{
                my $dira    = $_;
                grep{
                      my %cur = %{$_};
                      if ((keys %cur) > 0) {
                        $tsize{ $cur{'file_NAME'} } = $cur{'file_SIZE'};		# unless( exists $tsize{ $cur->{'file_NAME'} } );
                        #delete $xmlcopy->{'root'}->{'loop'}->{$fext}->{'file'}->[ $el ];
                      }
                } @{ $ufilez->{$dira} };
            } keys %{ $ufilez };
          } else {
            push @newfiles, $xmlcopy->{'root'}->{'loop'}->{$fext}->{'file'}->[ $el ];
          }
    } ( 0 ..  $#{ $xmlcopy->{'root'}->{'loop'}->{ $fext }->{'file'} } );

    $xmlcopy->{'root'}->{'loop'}->{$fext}->{'file'} = [@newfiles];

    $xmlcopy->{'root'}->{'userdata'}->{'used'} = 0;
    $xmlcopy->{'root'}->{'userdata'}->{'used'} += $_ for( ( values %tsize  ) );
    &Slanger::Common::xmlwrite( $uid, $xmlcopy );

    &Slanger::Common::changexmlparam ( $uid, $srcfid, 'src', 'actionf', 'true' );
    &Slanger::Common::changexmlparam ( $uid, $srcfid, 'src', 'actioni', 'true' );
    &Slanger::Common::changexmlparam ( $uid, $srcfid, 'src', 'links', { 'link' => [0, 0] } );

    return $fid;
};

sub renamefile
{
    my ( $uid, $fid, $ufname, $dire ) = @_;
    use Encode;
    my $xmlcopy  = &Slanger::Common::xmlread( $uid ); #die Dumper $xmlcopy;
    map { $_->{'file_NAME'} = decode("utf8", $ufname) if ($_->{'file_ID'} == $fid) } @{ $xmlcopy->{'root'}->{'loop'}->{'block_'.$dire}->{'file'} };
		&Slanger::Common::xmlwrite( $uid, $xmlcopy );
};

sub filewrite 		# new user file writing
{
  my ($uid, $fname, $fcont) = @_;
  my $udir = $Slanger::Common::pathroot.qq[/slanger/$uid/src/];   #user src file directory
  use Encode;
  $fcont = decode("utf8", $fcont);
  open( FL,'>', $udir . $fname ) or die $!; print FL $fcont; close(FL);
  return $fname;
};

sub delfile 			# delete a user's file in one of two possible directories
{
  my ($uid, $fname, $dire) = @_;
  my $udirs = $Slanger::Common::pathroot.qq[/slanger/$uid/$dire/];   #user src file directory
  my $fnum = unlink( $udirs.$fname );
  return $fnum; #usually one file is deleted at a time
};

1;