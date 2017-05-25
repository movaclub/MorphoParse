package Slanger::Filer::Voca;
# process vocabulary module
use strict;
use warnings;
use utf8;
use Slanger::Common;
use Slanger::Common::SQL;
use Slanger::Common::Regex;
# use Encode;

our (%subsvoca);

my %zh = %{$Slanger::Common::SQL::sql};
my %re = %{$Slanger::Common::Regex::re};

%subsvoca = (
    'zhsru' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl = &getSRC( $pathsrc );
        my ( $zi, $ju )  = &genSTR( $fl );
        my $ZHRUstrS = &zhruCIs( $ju );                                     # Simp substring lookup
        my $ZHRUchrS = &zhruZIs( $zi );                                     # Simp char lookup
        &writevoca_zhru($ZHRUstrS, $ZHRUchrS, $pathtrg);
        return;
    },
    'zhtru' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl = &getSRC( $pathsrc );
        my ( $zi, $ju )  = &genSTR( $fl );
        my $ZHRUstrT = &zhruCIt( $ju );                                     # TRAD substring lookup
        my $ZHRUchrT = &zhruZIt( $zi );                                     # TRAD char lookup
        &writevoca_zhru($ZHRUstrT, $ZHRUchrT, $pathtrg);
        return;
    },
    'zhsen' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl = &getSRC( $pathsrc );
        my ( $zi, $ju )  = &genSTR( $fl );
        my $ZHENstrS = &zhenCIs( $ju );                                     # Simp substring lookup
        my $ZHENchrS = &zhenZIs( $zi );                                     # Simp char lookup
        &writevoca_zhen($ZHENstrS, $ZHENchrS, $pathtrg);
        return;
    },
		'zhten' => sub {
				my ($uid, $fid, $tfid) = @_;
        my $pathsrc = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
				my $pathtrg = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
				my $fl = &getSRC( $pathsrc );
				my ( $zi, $ju )  = &genSTR( $fl );
				my $ZHENstrT = &zhenCIt( $ju );                                     # TRAD substring lookup
				my $ZHENchrT = &zhenZIt( $zi );                                     # TRAD char lookup
        &writevoca_zhen($ZHENstrT, $ZHENchrT, $pathtrg);
        return;
		},
    'ruzht' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc  = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg  = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl       = &getSRCer( $pathsrc );
        my $ru       = &genSTRru( $fl );                                    # RU wf list
        my $RUZHstrT = &ruzhCIt( $ru );                                     # RU wf to ZH words
        my $RUZHchrT = &ruzhZIt( $ru );                                     # RU wf to ZH characters
        &writevoca_ruzh($RUZHstrT, $RUZHchrT, $pathtrg);
        return;
    },
    'ruzhs' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc  = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg  = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl       = &getSRCer( $pathsrc );
        my $ru       = &genSTRru( $fl );                                    # RU wf list
        my $RUZHstrS = &ruzhCIs( $ru );                                     # RU wf to ZH words
        my $RUZHchrS = &ruzhZIs( $ru );                                     # RU wf to ZH characters
        &writevoca_ruzh($RUZHstrS, $RUZHchrS, $pathtrg);
        return;
    },
    'enzht' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc  = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg  = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl       = &getSRCer( $pathsrc );
        my $en       = &genSTRen( $fl );                                    # EN wf list
        my $ENZHstrT = &enzhCIt( $en );                                     # EN wf to ZH words
        my $ENZHchrT = &enzhZIt( $en );                                     # EN wf to ZH characters
        &writevoca_enzh($ENZHstrT, $ENZHchrT, $pathtrg);
        return;
    },
    'enzhs' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc  = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg  = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl       = &getSRCer( $pathsrc );
        my $en       = &genSTRen( $fl );                                    # EN wf list
        my $ENZHstrS = &enzhCIs( $en );                                     # EN wf to ZH words
        my $ENZHchrS = &enzhZIs( $en );                                     # EN wf to ZH characters
        &writevoca_enzh($ENZHstrS, $ENZHchrS, $pathtrg);
        return;
    },
    'ruen' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc  = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg  = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl       = &getSRCer( $pathsrc );
        my $ru       = &genSTRru( $fl );                                    # RU wf list
        my $RUEN     = &ruen( $ru );                                        # RU wf to EN
        &writevoca_ruen($RUEN, $pathtrg);
        return;
    },
    'enru' => sub {
        my ($uid, $fid, $tfid) = @_;
        my $pathsrc  = $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src];
        my $pathtrg  = $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg];
        my $fl       = &getSRCer( $pathsrc );
        my $en       = &genSTRen( $fl );                                    # EN wf list
        my $ENRU     = &enru( $en );                                        # EN wf to RU words
        &writevoca_enru($ENRU, $pathtrg);
        return;
    },
);

sub writevoca_zhen # to put down both traditional & simplified translated into English
{
    my ($ci, $zi, $pathtrg) = @_;
    no warnings;
    open(FL,'>:utf8', $pathtrg) or die $!;
        grep{
						my @zicoo;
            print FL $_, " [" . @{$zi->{$_}}[0]->{'pin'} . "]\t - ";
            grep{ push @zicoo, $_->{'en'} } @{$zi->{ $_ }};
						print FL join('; ', @zicoo), "\n";
        } sort { $a cmp $b } keys %{ $zi };

        grep{
						my @cicoo;
            print FL $_, " [" . @{$ci->{$_}}[0]->{'pin'} . "]\t - ";
						grep{ push @cicoo, $_->{'en'} } @{$ci->{ $_ }};
						print FL join('; ', @cicoo), "\n";
        } sort { $a cmp $b } keys %{ $ci };

    close(FL);
    return;
};
sub writevoca_zhru # to put down both traditional & simplified translated into Russian
{
    my ($ci, $zi, $pathtrg) = @_;
    no warnings;
    open(FL,'>:utf8', $pathtrg) or die $!;
        grep{
            my @zicoo;
            print FL $_, " [" . @{$zi->{$_}}[0]->{'pin'} . "]\t - ";
            grep{ push @zicoo, $_->{'ru'} } @{$zi->{ $_ }};
            print FL join('; ', @zicoo), "\n";
        } sort { $a cmp $b } keys %{ $zi };

        grep{
            my @cicoo;
            print FL $_, " [" . @{$ci->{$_}}[0]->{'pin'} . "]\t - ";
            grep{ push @cicoo, $_->{'ru'} } @{$ci->{ $_ }};
            print FL join('; ', @cicoo), "\n";
        } sort { $a cmp $b } keys %{ $ci };

    close(FL);
    return;
};
sub writevoca_ruzh # to put down both traditional & simplified
{
    my ($ci, $zi, $pathtrg) = @_;
    no warnings;
    open(FL,'>:utf8', $pathtrg) or die $!;
        grep{
            my (@zi, @pin);
            print FL $_,' - ', @{$zi->{$_}}[0]->{'ru'}, "]\t - ";
            grep{ push @zi, $_->{'zi'}; push @pin, $_->{'pin'}; } @{$zi->{ $_ }};
            grep{ print FL $zi[$_],'[',$pin[$_],']'} (0 .. $#zi);
            print FL "\n";
        } sort { $a cmp $b } keys %{ $zi };
        grep{
            my (@ci, @pin);
            print FL $_,' - ', @{$ci->{$_}}[0]->{'ru'}, "]\t - ";
            grep{ push @ci, $_->{'ci'}; push @pin, $_->{'pin'}; } @{$ci->{ $_ }};
            grep{ print FL $ci[$_],'[',$pin[$_],']'} (0 .. $#ci);
            print FL "\n";
        } sort { $a cmp $b } keys %{ $ci };
    close(FL);
    return;
};
sub writevoca_ruen # to put down RU-EN
{
    my ($ruen, $pathtrg) = @_;
    no warnings;
    open(FL,'>:utf8', $pathtrg) or die $!;
        grep{
            my (@en, @tr);
            print FL $_,' - ', @{$ruen->{$_}}[0]->{'ru'}, "]\t - ";
            grep{ push @en, $_->{'en'}; push @tr, $_->{'tr'}; } @{ $ruen->{ $_ } };
            grep{ print FL $en[$_],'[',$tr[$_],']'} (0 .. $#en);
            print FL "\n";
        } sort { $a cmp $b } keys %{ $ruen };
    close(FL);
    return;
};
sub writevoca_enzh # to put down both traditional & simplified
{
    my ($ci, $zi, $pathtrg) = @_;
    no warnings;
    open(FL,'>:utf8', $pathtrg) or die $!;
        grep{
            my (@zi, @pin);
            print FL $_,' - ', @{$zi->{$_}}[0]->{'en'}, "]\t - ";
            grep{ push @zi, $_->{'zi'}; push @pin, $_->{'pin'}; } @{$zi->{ $_ }};
            grep{ print FL $zi[$_],'[',$pin[$_],']'} (0 .. $#zi);
            print FL "\n";
        } sort { $a cmp $b } keys %{ $zi };
        grep{
            my (@ci, @pin);
            print FL $_,' - ', @{$ci->{$_}}[0]->{'en'}, "]\t - ";
            grep{ push @ci, $_->{'ci'}; push @pin, $_->{'pin'}; } @{$ci->{ $_ }};
            grep{ print FL $ci[$_],'[',$pin[$_],']'} (0 .. $#ci);
            print FL "\n";
        } sort { $a cmp $b } keys %{ $ci };
    close(FL);
    return;
};
sub writevoca_enru # to put down EN-RU
{
    my ($enru, $pathtrg) = @_;
    no warnings;
    open(FL,'>:utf8', $pathtrg) or die $!;
        grep{
            my (@ru);
            print FL $_,' - ', @{$enru->{$_}}[0]->{'en'}, "]\t - ";
            grep{ push @ru, $_->{'ru'} } @{$enru->{ $_ }};
            grep{ print FL $ru[$_]} (0 .. $#ru);
            print FL "\n";
        } sort { $a cmp $b } keys %{ $enru };
    close(FL);
    return;
};
#---------------------------------------------------------------------------------------
#ZHEN start
sub zhenCIt                                 # WORD chinese-english direction (Traditional)
{
  my $ci  = shift;
	use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
		my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhten_ci'}, undef, $cur,$cur,$cur );
      map { push @{$ci->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'en' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $ci->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $ci };
  $dbh->disconnect();
  return $ci;
};
sub zhenZIt                                 # CHAR chinese-english direction (Traditional)
{
  my $zi  = shift;
	use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
		my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhten_zi'}, undef, $cur,$cur,$cur );
      map { push @{$zi->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'en' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $zi->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $zi };
  $dbh->disconnect();
  return $zi;
};
sub zhenCIs                                 # WORD chinese-english direction (Simplified)
{
  my $ci  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhsen_ci'}, undef, $cur,$cur,$cur );
      map { push @{$ci->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'en' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $ci->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $ci };
  $dbh->disconnect();
  return $ci;
};
sub zhenZIs                                 # CHAR chinese-english direction (Simplified)
{
  my $zi  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhsen_zi'}, undef, $cur,$cur,$cur );
      map { push @{$zi->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'en' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $zi->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $zi };
  $dbh->disconnect();
  return $zi;
};
#ZHEN finish
#----------------------------------------------------------------------------------------------
#ZHRU start
sub zhruCIt                                 # WORD chinese-russian direction (Traditional)
{
  my $ci  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhtru_ci'}, undef, $cur,$cur,$cur );
      map { push @{$ci->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'ru' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $ci->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $ci };
  $dbh->disconnect();
  return $ci;
};
sub zhruZIt                                 # CHAR chinese-russian direction (Traditional)
{
  my $zi  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhtru_zi'}, undef, $cur,$cur,$cur );
      map { push @{$zi->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'ru' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $zi->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $zi };
  $dbh->disconnect();
  return $zi;
};
sub zhruCIs                                 # WORD chinese-russian direction (Simplified)
{
  my $ci  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhsru_ci'}, undef, $cur,$cur,$cur );
      map { push @{$ci->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'ru' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $ci->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $ci };
  $dbh->disconnect();
  return $ci;
};
sub zhruZIs                                 # CHAR chinese-russian direction (Simplified)
{
  my $zi  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zh{'zhsru_zi'}, undef, $cur,$cur,$cur );
      map { push @{$zi->{ $cur }}, { 'pin' => decode("utf8", $_->[1]), 'ru' => decode("utf8", $_->[2]) } } @{$res} if ( @{$res} > 0 );
      delete $zi->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $zi };
  $dbh->disconnect();
  return $zi;
};
#ZHRU finish
#---------------------------------------------------------------------------------------
#RUZH start
sub ruzhZIt                                 # CHAR russian-chinese direction (Traditional)
{
  my $ru  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # Russian word form
      my $res = $dbh->selectall_arrayref( $zh{'ruwf'}, undef, $cur,$cur,$cur );# Russian main form lookup with a word form
      map {
            my $mru = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'ruzht_zi'}, undef, $mru,$mru,$mru ); # ZH char lookup with RU mform
            grep{ push @{$ru->{ $cur }}, { 'ru' => decode("utf8", $_->[0]), 'zi' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $ru->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $ru };
  $dbh->disconnect();
  return $ru;
};
sub ruzhZIs                                 # CHAR russian-chinese direction (Traditional)
{
  my $ru  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # Russian word form
      my $res = $dbh->selectall_arrayref( $zh{'ruwf'}, undef, $cur,$cur,$cur );# Russian main form lookup with a word form
      map {
            my $mru = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'ruzhs_zi'}, undef, $mru,$mru,$mru ); # ZH char lookup with RU mform
            grep{ push @{$ru->{ $cur }}, { 'ru' => decode("utf8", $_->[0]), 'zi' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $ru->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $ru };
  $dbh->disconnect();
  return $ru;
};
sub ruzhCIt                                 # WORD russian-chinese direction (Traditional)
{
  my $ru  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # Russian word form
      my $res = $dbh->selectall_arrayref( $zh{'ruwf'}, undef, $cur,$cur,$cur );# Russian main form lookup with a word form
      map {
            my $mru = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'ruzht_ci'}, undef, $mru,$mru,$mru ); # ZH char lookup with RU mform
            grep{ push @{$ru->{ $cur }}, { 'ru' => decode("utf8", $_->[0]), 'ci' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $ru->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $ru };
  $dbh->disconnect();
  return $ru;
};
sub ruzhCIs                                 # WORD russian-chinese direction (Simp)
{
  my $ru  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # Russian word form
      my $res = $dbh->selectall_arrayref( $zh{'ruwf'}, undef, $cur,$cur,$cur );# Russian main form lookup with a word form
      map {
            my $mru = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'ruzhs_ci'}, undef, $mru,$mru,$mru ); # ZH char lookup with RU mform
            grep{ push @{$ru->{ $cur }}, { 'ru' => decode("utf8", $_->[0]), 'ci' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $ru->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $ru };
  $dbh->disconnect();
  return $ru;
};
#RUZH finish
#---------------------------------------------------------------------------------------
#ENZH start
sub enzhZIt                                 # CHAR english-chinese direction (Traditional)
{
  my $en  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # English word form
      my $res = $dbh->selectall_arrayref( $zh{'enwf'}, undef, $cur,$cur,$cur );# English main form lookup with a word form
      map {
            my $men = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'enzht_zi'}, undef, $men,$men,$men ); # ZH char lookup with EN mform
            grep{ push @{$en->{ $cur }}, { 'en' => decode("utf8", $_->[0]), 'zi' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $en->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $en };
  $dbh->disconnect();
  return $en;
};
sub enzhZIs                                 # CHAR english-chinese direction (Simp)
{
  my $en  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # English word form
      my $res = $dbh->selectall_arrayref( $zh{'enwf'}, undef, $cur,$cur,$cur );# English main form lookup with a word form
      map {
            my $men = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'enzhs_zi'}, undef, $men,$men,$men ); # ZH char lookup with EN mform
            grep{ push @{$en->{ $cur }}, { 'en' => decode("utf8", $_->[0]), 'zi' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $en->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $en };
  $dbh->disconnect();
  return $en;
};
sub enzhCIt                                 # WORD english-chinese direction (Traditional)
{
  my $en  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # English word form
      my $res = $dbh->selectall_arrayref( $zh{'enwf'}, undef, $cur,$cur,$cur );# English main form lookup with a word form
      map {
            my $men = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'enzht_ci'}, undef, $men,$men,$men ); # ZH WORD lookup with EN mform
            grep{ push @{$en->{ $cur }}, { 'en' => decode("utf8", $_->[0]), 'ci' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $en->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $en };
  $dbh->disconnect();
  return $en;
};
sub enzhCIs                                 # WORD english-chinese direction (Simp)
{
  my $en  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # English word form
      my $res = $dbh->selectall_arrayref( $zh{'enwf'}, undef, $cur,$cur,$cur );# English main form lookup with a word form
      map {
            my $men = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'enzhs_ci'}, undef, $men,$men,$men ); # ZH WORD lookup with EN mform
            grep{ push @{$en->{ $cur }}, { 'en' => decode("utf8", $_->[0]), 'ci' => decode("utf8", $_->[1]), 'pin' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $en->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $en };
  $dbh->disconnect();
  return $en;
};
#ENZH finish
#---------------------------------------------------------------------------------------
#RUEN start
sub ruen                                 # russian-english direction
{
  my $ru  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # Russian word form
      my $res = $dbh->selectall_arrayref( $zh{'ruwf'}, undef, $cur,$cur,$cur );# Russian main form lookup with a word form
      map {
            my $mru = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'ruen'}, undef, $mru,$mru,$mru ); # EN word lookup with RU mform
            grep{ push @{$ru->{ $cur }}, { 'ru' => decode("utf8", $_->[0]), 'en' => decode("utf8", $_->[1]), 'tr' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $ru->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $ru };
  $dbh->disconnect();
  return $ru;
};
#RUEN finish
#---------------------------------------------------------------------------------------
#ENRU start
sub enru                                 # english-russian direction
{
  my $en  = shift;
  use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
    my $cur = $_; # English word form
      my $res = $dbh->selectall_arrayref( $zh{'enwf'}, undef, $cur,$cur,$cur );# English main form lookup with a word form
      map {
            my $men = decode("utf8", $_->[0]);
            my $les = $dbh->selectall_arrayref( $zh{'enru'}, undef, $men,$men,$men ); # RU word lookup with EN mform
            grep{ push @{$en->{ $cur }}, { 'en' => decode("utf8", $_->[0]), 'tr' => decode("utf8", $_->[1]), 'ru' => decode("utf8", $_->[2]) } } @{$les} if ( @{$les} > 0 );
            delete $en->{ $cur } unless ( @{$les} > 0 );
      } @{$res} if ( @{$res} > 0 );
  } keys %{ $en };
  $dbh->disconnect();
  return $en;
};
#ENRU finish
# -----------SOURCE & STRINGS--------------------------------------------------

sub getSRC #put a file into a hash (numbers are keys - sentence numbers)
{
  my $fl  = shift; # file name
  my (%fl, @fil, $fil, $num);
  undef $/;
  $num    = 1;
  open(FL,'<:utf8', $fl) or die $!; $fil = <FL>; close(FL);
  $/      = "\n";
  $fil    =~ s/\n\n+/。/g;
  @fil    = split(/[。.]/, $fil); # this symbol class should be expanded (!!!!)
  grep{ chomp; $fl{ $num++ } = $_ . '。' } @fil;
  return \%fl;
};
sub getSRCer #EN or RU src file into hash
{
  my $fl  = shift; # file name
  my (%fl, @fil, $fil, $num);
  undef $/;
  $num    = 1;
  open(FL,'<:utf8', $fl) or die $!; $fil = <FL>; close(FL);
  $/      = "\n";
  $fil    =~ s/\n\n+/./g;
  @fil    = split(/\./, $fil);
  grep{ chomp; $fl{ $num++ } = $_ . '。' } @fil;
  return \%fl;
};
sub genSTR                                              #find unique characters (?) and substrings as in the source text
{
  my ($fl, $direction) = @_;                                       # file hashref = &getSRC()
  my ( %zi, %ju );
  grep {
        my $string = $fl->{$_};
        my @str = split(//, $string);
        grep {
            my $dlta  = $_;
            grep {
                  my $alpha = $_;
                  $ju{ join( '', @str[ $dlta .. $alpha] ) } = undef unless(  ($alpha < $dlta) or ($alpha == $dlta) );
            } ( 1 .. $#str );
        } ( 0  .. $#str );
        while( $string =~ m/($re{'zh'}+)/g ) {
            my $zh = $1;
            my @uc = split(//, $zh);
            @zi{ @uc } = ();
        }
  } sort { $a <=> $b } keys %{ $fl };
  return ( \%zi, \%ju );
};
sub genSTRru       #find unique RU words
{
  my $fl = shift;
  my %ru;
  grep { $fl->{ $_ } =~ s/($re{'ru'}+)/{ $ru{$1} = undef }/g; } sort { $a <=> $b } keys %{ $fl };
  return \%ru;
};
sub genSTRen       #find unique EN words
{
  my $fl = shift;
  my %en;
  grep { $fl->{ $_ } =~ s/($re{'en'}+)/{ $en{$1} = undef }/g; } sort { $a <=> $b } keys %{ $fl };
  return \%en;
};

1;