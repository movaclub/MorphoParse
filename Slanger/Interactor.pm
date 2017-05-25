package Slanger::Interactor;

use strict;
use warnings;
use utf8;
use Slanger::Common;
use Slanger::Common::SQL;
use Slanger::Common::Regex;

my %re = %{$Slanger::Common::Regex::re};
my %zhsql = %{$Slanger::Common::SQL::sql};

sub getstr_by_num # get the string by number
{
		my ($uid, $fid, $numstr, $direction) = @_;
		my $string;
		if (-e $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid/$numstr.xml]) { return; }

		open( FL,'<:utf8', $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid/$fid.lnum] ) or die $!;
		while(<FL>){ if (m/^$numstr\|(.+)$/) { $string = $1; last; } }
		close(FL);
		my $xmlfor = &matcher(&substringer($string, $uid, $fid, $numstr), $direction, $string) if ($direction =~ m/^(zht|zhs)/);
		#&substringer_e($string, $uid, $fid, $numstr) if ($direction =~ m/^(en|ru)/);

		my %atts = (
			0 => q[type],
			1 => q[stype],
			2 => q[g1],
			3 => q[g2],
			4 => q[g3]
		);

		&Slanger::Common::xmlout($xmlfor, \%atts, $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid/$numstr.xml]);

		return;
}

#sub substringer_e # only EN to .. or RU to ...
#{
#		my ($str, $uid, $fid, $numstr, $direction) = @_;
#		my (@blocks, %bclean);
#
#		no bytes;
#		@blocks = split(/\s+/, $str);
#		grep {
#			my $lex = $_;
#			$lex =~ s/($re{'RUEN'})//g
#			$bclean{$lex} = undef;
#		} @blocks;
#
#		return;
#}

sub substringer # only ZHT to ... or ZHS to ...
{
				my ($str, $uid, $fid, $numstr)   = @_; # file ID and line number
        my ($fl, %all, $lpos, $cpos, %uniqstr, %uniqh);

        no bytes;
        while( $str =~ m/($re{'ZH'})/g ) { my $zh = $1; $cpos = index $str, $zh, $lpos; $lpos = $cpos; $all{ $cpos } = $zh unless( $zh =~ m/($re{'zh'}+)/g ); }
        while( $str =~ m/($re{'zh'}+)/g ) { my $zh = $1; $cpos = index $str, $zh, $lpos; $lpos = $cpos; $all{ $cpos } = $zh; my @uc = split(//, $zh); @uniqh{ @uc } = (); }
				grep { @uniqstr{@{ &worder( $all{$_} ) }} = () if ( length $all{$_} >=  2 ) } sort{ $a <=> $b } keys %all;
				return (\%uniqstr, \%uniqh, \%all);
}

sub zhenCIt                                 # WORD chinese-english direction (Traditional)
{
  my ($queryname, $ci)  = @_;
	use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
		my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zhsql{$queryname}, undef, $cur,$cur,$cur );
      map { push @{$ci->{ $cur }}, { 'sword'=>$cur, 'strans'=>decode("utf8", $_->[1]), 'tword'=>$_->[2], 'ttrans'=>undef } } @{$res} if ( @{$res} > 0 );
      delete $ci->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $ci };
  $dbh->disconnect();
  return $ci;
};

sub zhenZIt                                 # CHAR chinese-english direction (Traditional)
{
  my ($queryname, $zi)  = @_;
	use Encode;
  my $dbh = &Slanger::Common::setDBI();
  grep{
		my $cur = $_;
      my $res = $dbh->selectall_arrayref( $zhsql{$queryname}, undef, $cur,$cur,$cur );
      map { push @{$zi->{ $cur }}, { 'sch'=>$cur, 'strans'=>decode("utf8", $_->[1]), 'tword'=>$_->[2], 'ttrans'=>undef } } @{$res} if ( @{$res} > 0 );
      delete $zi->{ $cur } unless ( @{$res} > 0 );
  } keys %{ $zi };
  $dbh->disconnect();
  return $zi;
};

sub matcher
{
				my ($uniqstr, $uniqh, $all, $direction, $str) = @_;
				#my %uniqstr = %{$uniqstr};
				my %uniqh = %{$uniqh};
				my %all = %{$all};


				my %dataW = %{&zhenCIt($direction.'_ci', $uniqstr)};
				my %dataC = %{&zhenZIt($direction.'_zi', $uniqh)};


				#$dataW = {
				#		'sword' => [
				#				{'sword'=>, 'strans'=>, 'tword'=>, 'ttrans'=>},
				#
				#		]
				#}

				#my %dataW = %{&Slanger::Common::db_select_grep($direction.'_ci', \%uniqstr)};
				#my %dataC = %{&Slanger::Common::db_select_grep($direction.'_zi', \%uniqh)};

        my %fin;
        no warnings;

        grep {
            my $cpos = $_;
            grep {
                  my $zh = $_;
                  if( $all{ $cpos } =~ m/$zh/ ) {
                    my @set   = split( /$zh/, $all{ $cpos } );
                    push @set, $zh;
                    grep{
                        my $pc          = $_;
                        my $pc_pos      = index $str, $pc, $cpos;
                        push @{$fin{$pc}}, $pc_pos if( exists $dataW{ $pc } );
                    } @set;
                    #print join(':', @set ),"\n";
                  }
            }  keys %dataW;
        } sort { $a <=> $b } keys %all;

        my (%pair, %coor, $lstart, $lend);

        grep{
            my %her;
            my $cur = $_;
            @her{ @{$fin{$cur}} } = ();
            grep{
                  my @ha = ( ($_ + length $cur) => $cur );
                  push @{ $pair{$_} }, \@ha;
            } ( sort{ $a <=> $b } keys %her );
        } sort { $fin{$a} <=> $fin{$b} } keys %fin;

        grep{
            my $pozi = $lstart = $_;
						if( exists $pair{$pozi} and ( $lend <= $pozi) ) {
							grep{ ( $_->[0] > $lend ) ? $lend = $_->[0] : $lend = $lend; } @{ $pair{$pozi} };
							grep{
									my $cur = $_;
									if( exists $pair{$cur} )
									{
										grep{ ( $_->[0] > $lend ) ? $lend = $_->[0] : $lend = $lend; } @{ $pair{$cur} };
									}
							} ( $pozi .. ($lend-1) );

							$coor{ $pozi }{'lend'} = $lend;

							grep {
									push @{ $coor{ $pozi }{'str'} }, $pair{$_};
							} ( $pozi .. ($lend-1) );
						}
        } ( 0 .. length( $str ) );


        my (@found, @nfound);
        grep { push @found, ($_, $coor{$_}{'lend'}) } sort { $a <=> $b } keys %coor;
        unshift @found, 0; push @found, length( $str );
        grep{ push @nfound, $found[$_] if( ($found[$_] != $found[$_+1]) and ($found[$_] != $found[$_-1] ) ) } ( 0 .. $#found );
        while (@nfound) {
            my $f1 = shift @nfound;
            my $f2 = shift @nfound;
            if (($f2 - $f1) <= 10 ) {
                $coor{$f1}{'lend'} = $f2;
            } else {
                my $col = int(($f2 - $f1) / 10);
                my $begin = $f1;
                map {
                    $coor{$begin}{'lend'} = $begin + 10;
                    $begin += 10;
                } (1 .. $col);
                $coor{$begin}{'lend'} = $f2 if ($f2 > $begin);
            }
        }

        my @arr = split(//, $str);
        my (@finaly, @finalyh, %xmlresult);

        my $g1 = 1; # group counter
        grep{
						my $s_block = $_;
						$xmlresult{'dictionary'}{'block'}{$g1}{$g1}{$g1} = join('', @arr[$_ .. ($coor{$_}{'lend'} - 1)]);
            grep {
								my $g2 = 1; # sub group counter
                grep {
										my $string = $_->[1];
										$xmlresult{'dictionary'}{'sword'}{$g1}{$g2}{$g2} = $string;
										my $g3 = 1;  # sub sub group counter
										grep{
												$xmlresult{'dictionary'}{'strans'}{$g1}{$g2}{$g2} = $_->{'strans'} if ($_->{'strans'});
												$xmlresult{'dictionary'}{'tword'}{$g1}{$g2}{$g3} = $_->{'tword'} if ($_->{'tword'});
												$xmlresult{'dictionary'}{'ttrans'}{$g1}{$g2}{$g3} = $_->{'ttrans'} if ($_->{'ttrans'});
												$g3++;
										} @{$dataW{$string}};
										$g2++;
                } @{$_};
            } @{$coor{$_}{'str'}};
						$g1++;
        } sort { $a <=> $b } keys %coor;

				$g1 = 1; # group counter
				grep {
						my $g2 = 1;  # sub group counter
						my $string = $_;
						$xmlresult{'dictionary'}{'sch'}{$g1}{$g2}{$g2} = $string;
						grep {
								$xmlresult{'dictionary'}{'strans'}{$g1}{$g1}{$g2} = $_->{'strans'} if ($_->{'strans'});
								$xmlresult{'dictionary'}{'sbo'}{$g1}{$g1}{$g2} = $_->{'sbo'} if ($_->{'sbo'});
								$xmlresult{'dictionary'}{'tword'}{$g1}{$g2}{$g2} = $_->{'tword'} if ($_->{'tword'});
								$xmlresult{'dictionary'}{'ttrans'}{$g1}{$g2}{$g2} = $_->{'ttrans'} if ($_->{'ttrans'});
								$g2++;
						} @{ $dataC{$string} };
						$g1++;
				} keys %uniqh;

				return \%xmlresult;
};

#sub substringer # only ZHT to ... or ZHS to ...
#{
#				my ($str, $uid, $fid, $numstr)   = @_; # file ID and line number
#        my ($fl, %all, $lpos, $cpos, %uniqstr, %uniqh);
#
#        no bytes;
#        while( $str =~ m/($re{'ZH'})/g ) { my $zh = $1; $cpos = index $str, $zh, $lpos; $lpos = $cpos; $all{ $cpos } = $zh unless( $zh =~ m/($re{'zh'}+)/g ); }
#        while( $str =~ m/($re{'zh'}+)/g ) { my $zh = $1; $cpos = index $str, $zh, $lpos; $lpos = $cpos; $all{ $cpos } = $zh; my @uc = split(//, $zh); @uniqh{ @uc } = (); }
#				grep { @uniqstr{@{ &worder( $all{$_} ) }} = () if ( length $all{$_} >=  2 ) } sort{ $a <=> $b } keys %all;
#
#        my %fin; # final container
#        no warnings;
#
#        grep {
#            my $cpos = $_;
#            grep {
#                  my $zh = $_;
#                  if( $all{ $cpos } =~ m/$zh/ ) {
#                    my @set   = split( /$zh/, $all{ $cpos } );
#                    push @set, $zh;
#                    grep{
#                        my $pc          = $_;
#                        my $pc_pos      = index $str, $pc, $cpos;
#                        push @{$fin{$pc}}, $pc_pos if( exists $dataW{ $pc } );
#                    } @set;
#                    print join(':', @set ),"\n";
#                  }
#            }  keys %dataW;
#        } sort { $a <=> $b } keys %all;
#
#        my (%pair, %coor, $lstart, $lend);
#
#        grep{
#            my %her;
#            my $cur = $_;
#            @her{ @{$fin{$cur}} } = ();
#            grep{
#                  my @ha = ( ($_ + length $cur) => $cur );
#                  push @{ $pair{$_} }, \@ha;
#            } ( sort{ $a <=> $b } keys %her );
#        } sort { $fin{$a} <=> $fin{$b} } keys %fin;
#
#        grep{
#            my $pozi = $lstart = $_;
#						if( exists $pair{$pozi} and ( $lend <= $pozi) ) {
#							grep{ ( $_->[0] > $lend ) ? $lend = $_->[0] : $lend = $lend; } @{ $pair{$pozi} };
#							grep{
#									my $cur = $_;
#									if( exists $pair{$cur} )
#									{
#										grep{ ( $_->[0] > $lend ) ? $lend = $_->[0] : $lend = $lend; } @{ $pair{$cur} };
#									}
#							} ( $pozi .. ($lend-1) );
#
#							$coor{ $pozi }{'lend'} = $lend;
#
#							grep {
#									push @{ $coor{ $pozi }{'str'} }, $pair{$_};
#							} ( $pozi .. ($lend-1) );
#						}
#        } ( 0 .. length( $str ) );
#
#        my @found;
#        grep {
#            push @found, ($_, $coor{$_}{'lend'});
#        } sort { $a <=> $b } keys %coor;
#
#        unshift @found, 0; push @found, length( $str );
#
#        my @nfound;
#        print join(" ", @found), "\n";
#        grep{ push @nfound, $found[$_] if( ($found[$_] != $found[$_+1]) and ($found[$_] != $found[$_-1] ) ) } ( 0 .. $#found );
#        print join(" ", @nfound), "\n";
#
#        while (@nfound) {
#            my $f1 = shift @nfound;
#            my $f2 = shift @nfound;
#            if (($f2 - $f1) <= 10 ) {
#                $coor{$f1}{'lend'} = $f2;
#            } else {
#                my $col = int(($f2 - $f1) / 10);
#                my $begin = $f1;
#                map {
#                    $coor{$begin}{'lend'} = $begin + 10;
#                    $begin += 10;
#                } (1 .. $col);
#                $coor{$begin}{'lend'} = $f2 if ($f2 > $begin);
#            }
#        }
#
#        my @arr = split(//, $srt);
#        my (@finaly, @finalyh);
#        my $new_counter = 0;
#
#        grep{
#            my @wrdt;
#            grep {
#                grep {
#                    my @trgval;
#
#                    grep {
#                        push @trgval, $_->{'en'};
#                    } @{$dataW{$_->[1]}};
#
#                    push @wrdt, {
#                        'label' => $_->[1],
#                        'trgvalues' => {
#                            'trgvalue' => \@trgval
#                        }
#                    };
#
#                } @{$_};
#            } @{$coor{$_}{'str'}};
#
#            push @finaly, {
#                'label' => join('', @arr[$_ .. ($coor{$_}{'lend'} - 1)]),
#                'position' => $new_counter,
#                'words' => {
#                    'word' => \@wrdt
#                }
#            };
#            $new_counter++;
#        } sort { $a <=> $b } keys %coor;
#
#        grep {
#            push @finalyh, {
#                'label' => $_,
#                'pinyin' => 'fromDB',
#                'trgvalues' => {
#                    'trgvalue' => {}
#                }
#            }
#        } keys %uniqh;
#
#				# write the output xml
#        &Slanger::Common::xmlallwrite(
#						$Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid/$numstr.xml],
#						{
#							'root'=> {
#                'stat' => { 'fileid'=>'1' },
#                'loop' => { 'srcwords' => { 'block' => \@finaly }, 'hieroglyph' => { 'one' => \@finalyh } }
#							}
#						}
#				);
#
#				return;
#};

#sub zhenCIt                                 # WORD chinese-english direction (Traditional)
#{
#  my $ci  = shift;
#  my $dbh = &setDBI();
#  grep{
#      my $res = $dbh->selectall_arrayref( $zh{'zh_en_ciT'}, undef, $_,$_,$_ );
#      map { push @{$ci->{ $_ }}, { 'pin' => $_->[2], 'en' => $_->[3] } } @{$res} if ( $res[0] > 0 );
#      delete $ci->{ $_ } unless ( $res[0] > 0 );
#  } keys %{ $ci };
#  $dbh->disconnect();
#  return $ci;
#};
#
#sub zhenZIt                                 # CHAR chinese-english direction (Traditional)
#{
#  my $zi  = shift;
#  my $dbh = &setDBI();
#  grep{
#      my $res = $dbh->selectall_arrayref( $zh{'zh_en_ziT'}, undef, $_,$_,$_ );
#      map { push @{$zi->{ $_ }}, { 'pin' => $_->[2], 'en' => $_->[3] } } @{$res} if ( $res[0] > 0 );
#      delete $zi->{ $_ } unless ( $res[0] > 0 );
#  } keys %{ $zi };
#  $dbh->disconnect();
#  return $zi;
#};

sub worder # substring generating
{
  my $string      = shift;
  my @str         = split//, $string;
  my @all;
  grep {
        my $dlta  = $_;
        grep {
                my $alpha = $_;
                push @all, ( join( '', @str[ $dlta .. $alpha] ) ) unless(  ($alpha < $dlta) or ($alpha == $dlta) );
        } ( 1 .. $#str );
  } ( 0  .. $#str );
  return \@all;
};


sub splitter # string splitter
{
    my ($uid, $fid) = @_;
		my ( %fl, $filemy );
		undef $/;
		open( FL,'<:utf8', $Slanger::Common::pathroot.qq[/slanger/$uid/src/$fid.src] ) or die $!; $filemy = <FL>; close(FL);
		my @newfile = split(/[\n\r]/, $filemy);
		grep{ chomp( $newfile[$_] ); $fl{ ($_+1) } = $newfile[$_] } ( 0 .. $#newfile );

    no warnings;
		mkdir( $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid] );
    open( FL, '>:utf8' , $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid/$fid.lnum] ) or die $!;
    grep{ print FL $_,'|', $fl{ $_ },"\n" } sort { $a <=> $b } keys %fl;
    close( FL );

    open( FL, '>:utf8' , $Slanger::Common::pathroot.qq[/slanger/$uid/trg/$fid.trg] ) or die $!; print FL ''; close( FL );

    my ($ufilez, %tsize);
    my $xmlcopy  = &Slanger::Common::xmlread( $uid );
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
                    'file_NAME'     => 'manual_trans.txt',
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
};

sub needer_forxml
{
		my ($uid, $fid) = @_;
    &Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'actionf', 'false' );
    &Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'actioni', 'true' );
    &Slanger::Common::changexmlparam ( $uid, $fid, 'src', 'links', { 'link' => [0, 0, $fid] } );
		return;
}


1;