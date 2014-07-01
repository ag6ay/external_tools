#!/usr/bin/perl -wT
#
#
#
# compare_expected_vs_actual_results
#

#
#
# A script for those tired of trying to read 5000 character lines...
#

use strict;
use warnings;
use English;
use Errno;
use Data::Dumper;
use Time::Local;
#use DumpValue;

$| = 1;		# inhibit stdout buffering...

use constant INFILE => "../../logs/auditAutomation.log";

use constant DBGOUT => "/dev/null";
#use constant DBGOUT => "/dev/stderr";
#use constant DBGOUT => "/dev/stdout";

use constant EXPECTED_DATA_STATE	=> "expected_data";
use constant ACTUAL_DATA_STATE		=> "actual_data";

use constant DEFAULT_FIELD_WIDTH => 60;
use constant DEFAULT_MAX_FIELD_DIFFERRENCES => 4;

my @Months = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

sub do_untaint($);

sub do_xlate_date($$);

sub do_untaint($) {
	my $tainted=shift;
	if ( not defined $tainted or $tainted eq '' ) {
		return '';
	}
	$tainted =~ s/\$\([^\)]*\)//g;
	$tainted =~ s/([^\`]+)//;

	return $1;
}

sub do_xlate_date($$){
	#
	#
	# Translate auditAutomation.pl format date into internal ctime date
	#
	# From: http://objectmix.com/perl/20039-reading-ctime-formatted-date.html
	#
	my $dateStrArg=shift;
	my $timeStrArg=shift;

	my $retval = undef;

	my @dateArray=split '-', $dateStrArg;

	my @timeArray=split ':', $timeStrArg;

	my $ctime_seconds = timelocal( $timeArray[2], $timeArray[1], $timeArray[0], $dateArray[1], $dateArray[0]-1, $dateArray[2] );

	$retval = $ctime_seconds;

	return $retval;
}

my $dbgout;
my $tmp_dbgout;

if ( DBGOUT ne "/dev/stdout" ) {
	open $dbgout, "> ".DBGOUT or die "Unable to open '".DBGOUT."'\n\t$!\n";
} else {
	$dbgout = *STDOUT;
}
my $debugflag=0;
#$debugflag=1;

my $infilename=&INFILE;

$infilename = do_untaint($ENV{'INFILE'}) unless not $ENV{'INFILE'};

open my $infile, $infilename or die "Unable to open '$infilename'\n\t$!\n";

my $printEqualLines=0;

if ( $ENV{'PRINTEQUAL'} and uc(do_untaint($ENV{'PRINTEQUAL'})) eq 'TRUE' ) {
	$printEqualLines=1;
}

my $tcname = "";
my $stepid = "";

my $tccount = 0;
my $stepcount = 0;

my $state = "";
my $found_expected=0;
my $found_actual=0;

my @expected_results_array = ();
my @actual_results_array   = ();

my @expected_data_lines    = ();
my @actual_data_lines      = ();

my $mismatchCount=0;
my $totalCountPartialMismatches=0;
my $totalCountTotalMismatches=0;

END {
	print "number of test cases found ", $tccount,".\n" unless not defined $tccount;
	print "number of test steps found ", $stepcount,".\n" unless not defined $stepcount;
	print "number of ER/AR line pairs that 'almost' matched ", $totalCountPartialMismatches, ".\n" unless not defined $totalCountPartialMismatches;
	print "number of ER or AR lines that were not even close ", $totalCountTotalMismatches, ".\n" unless not defined $totalCountTotalMismatches;

	if ( DBGOUT ne "/dev/stdout" and not defined $tmp_dbgout ) {
		close $dbgout unless not defined $dbgout;
	}
	close $infile unless not defined $infile;
}

#
#
# Main Program:  main()  MAIN() Main()
#
#

print 	"\n\nInput File:\t	$infilename\n";
print	"Difference Field width:\t", $ENV{FIELD_WIDTH} ? do_untaint($ENV{FIELD_WIDTH}) : &DEFAULT_FIELD_WIDTH, "\n";
print	"printEqualLines:\t$printEqualLines.\n";
print	"\n";

my $foundtime=0;

foreach (<$infile>) {
	chomp;
	s/\r//g;
	s/[[:space:]]{1,}$//;
	$debugflag && print $dbgout $_,"\n";

	my $tmpstr = $_;
	$tmpstr =~ s/^[[:space:]]{1,}//;

	my @wordsplit = split /[[:space:]]/, $tmpstr;

	if ( $foundtime == 0 ) {
		# TEST BEGIN TIME: 12-05-2011 12:25:52
		$tmpstr =~ m/^TEST BEGIN TIME:/ && do {
			$debugflag && print $dbgout "DTG is $wordsplit[3] $wordsplit[4].\n";
			my $ctime_local = do_xlate_date($wordsplit[3], $wordsplit[4] );
			$debugflag && print $dbgout "Ctime is $ctime_local.\n";
			$debugflag && print $dbgout "Reformatted time is ", scalar localtime($ctime_local),"\n";
			$foundtime++;			
		};
	}

	$wordsplit[0] = '' unless defined $wordsplit[0];

	$debugflag && print $dbgout "word 0 = '$wordsplit[0]', length word0 ", length ($wordsplit[0]), ", words ", scalar @wordsplit,".\n";

	defined $wordsplit[0] and do {


		$wordsplit[0] eq "TEST_CASE_ID:" && do {
			$debugflag && print $dbgout $wordsplit[0], " ", $wordsplit[1],"\n";
			$tcname = $wordsplit[1];
			$tccount++;
			next;
		};

		$wordsplit[0] eq "STEP_ID:" && do {
			$stepid = $wordsplit[1];
			$stepcount++;
			$found_expected=0;
			$found_actual=0;
			@expected_data_lines    = ();
			@actual_data_lines      = ();
			@actual_results_array   = ();
			@expected_results_array = ();
			$debugflag && print $dbgout "TEST_CASE_ID: $tcname, ", $wordsplit[0], " ", $wordsplit[1],"\n";
			$mismatchCount=0;
			next;
		};

		if ( $debugflag > 0 and DBGOUT ne "/dev/stdout" ) {
			# delay debug output until the indicated TC and TS...
			# TC_CBS2_V2_GET_ACCOUNT_LIST_FORM_MASK_FT, STEP_ID: 1.
			if ( $tcname eq "TC_CBS2_V2_GET_ACCOUNT_LIST_FORM_MASK_FT" and $stepid == 1 ) {
				$tmp_dbgout = $dbgout;
				$dbgout = *STDOUT;
			} else {
				if (defined $tmp_dbgout ) {
					$dbgout = $tmp_dbgout;
					undef $tmp_dbgout;
				}
			}
		}

		$wordsplit[0] eq "EXPECTED_RESULT:" && do {
			$state=EXPECTED_DATA_STATE;
			$found_expected++;
			next;
		};

		$wordsplit[0] eq "ACTUAL_RESULT:" && do {
			$state=ACTUAL_DATA_STATE;
			$found_actual++;
			next;
		};

		next unless $state eq EXPECTED_DATA_STATE or $state eq ACTUAL_DATA_STATE;

		$wordsplit[0] eq '' and scalar @wordsplit == 1 and do {
			$debugflag && print $dbgout " \t... clearing state variable from '$state'.\n";
			$state='';
		};		# must be done separate from reporting...

		$wordsplit[0] eq '' and scalar @wordsplit == 1 
		    and $found_expected > 0 and $found_actual > 0 
		    and do {
			# if both actual and expected have been found for this TS then do the comparison...
			#
			#
			#
			$debugflag && print $dbgout "\nExpected Data Lines Array:\n";
			$debugflag && print $dbgout Dumper(\@expected_data_lines);
			$debugflag && print $dbgout "\n";
			#
			$debugflag && print $dbgout "\nActual Data Lines Array:\n";
			$debugflag && print $dbgout Dumper(\@actual_data_lines);
			$debugflag && print $dbgout "\n";
			#
			$debugflag && print $dbgout "\nExpected PARSED Data Array:\n";
			$debugflag && print $dbgout Dumper(\@expected_results_array);
			$debugflag && print $dbgout "\n";
			#
			$debugflag && print $dbgout "\nActual PARSED Data Array:\n";
			$debugflag && print $dbgout Dumper(\@actual_results_array);
			$debugflag && print $dbgout "\n";

			#
			# Now, for the analysis...
			#

			my $number_expected_lines = scalar @expected_data_lines;
			my $number_actual_lines   = scalar @actual_data_lines;

			my @expected_lines_used = ();
			my @actual_lines_used   = ();

			my $matches=0;

			for (my $i=0; $i < $number_expected_lines; $i++) {
				push @expected_lines_used, 0;
			}

			for (my $i=0; $i < $number_actual_lines; $i++) {
				push @actual_lines_used, 0;
			}


			#
			# Select a direction... and just go that way...
			#
NEXT_EXPECTED:
			for (my $i=0; $i < $number_expected_lines; $i++) {
REDO_EXPECTED_LINE_I:
				if ( $expected_lines_used[$i] != 0 ) {	# skip if already 'used'...
					$debugflag && print $dbgout "Pass 1: skipping already used expected line $i count $expected_lines_used[$i].\n";
					next NEXT_EXPECTED;
				}
				$debugflag && print $dbgout "Pass 1: Looking at expected line $i.\n";

				my $matched = 0;
				my @mismatchedCounts=();
				my $unset=2000000000;	# really big number...
				my $minMismatchedCountSubscript=$unset;
				my $minMismatchedCountExpectedSubscript=$unset;
				my $minMismatchedCount=$unset;

				#
				# check all of the unused actual lines
				# if we find an 'exact match', marke lines as used, declare victory and move on
				# while looking for the exact match keep track of the first actual results line 
				#			with the fewest differences
				# When all of the unused actual results lines are checked
				# 	If minMismatchedCountSubscript is not set to unset
				#		If number of differences in below threshhold
				#			report out individual field differences
				#			mark lines as used
				#			declare victory, move on
				#		endif
				#	endif
				# endWhen
				#
				my $il = scalar @{$expected_results_array[$i]};
				for ( my $j=0; $j< $number_actual_lines; $j++) {
					push @mismatchedCounts, 0;
					if ( $actual_lines_used[$j] != 0 ) {
						$debugflag && print $dbgout "Pass 1: skipping already used actual line $j count $actual_lines_used[$j].\n";
						next;
					}
					$debugflag && print $dbgout "Pass 1:        Looking at actual line $i.\n";

					#	
					# Okay, we now have references to two arrays of values to try to compare.
					#
					# The first step... look for equality... two lines with same # fields and data 'matches'
					#
					my $jl = scalar @{$actual_results_array[$j]};

					my $numflds =  $il > $jl ? $il : $jl ;
					my $minflds =  $il < $jl ? $il : $jl ;

					# number fields not equal...
					# try for a 'near match' anyway...
					$debugflag && print $dbgout "First Pass: Mis-matched number of fields er line $i ($il), ar line $j ($jl).\n";
					my $ik=0;
					my $jk=0;
					my $diffi=0;
					my $diffj=0;
					my $diffBoth=0;
					while ( $ik < $il and $jk < $jl ) {
						my $prtik = defined $expected_results_array[$i]->[$ik] ? $expected_results_array[$i]->[$ik] : "~~~~~~~~~~EOL" ;
						my $prtjk = defined $actual_results_array[$j]->[$jk] ? $actual_results_array[$j]->[$jk] : "~~~~~~~~~~EOL" ;
						$debugflag && print $dbgout "ik = $ik : '$prtik', jk = $jk : '$prtjk'.\n";
						if ( $ik >= $il ) {		# end of expected results list
							$jk++;
							next;
						}
						if ( $jk >= $jl ) {		# end of actual results list
							$ik++;
							next;
						}
						if ( $prtik eq $prtjk ) { # matched!!
							$ik++;
							$jk++;
							next;
						}
						my $equalidx = index $prtik, "=";
						if ( $prtik =~ m/=__DYNAMIC\(IGNORE\{\}\)__/ ) {	# skip known _IGNORE_
							
							$debugflag && print $dbgout "\t $equalidx, (__DYNAMIC(IGNORE)__) ... -> ", substr($expected_results_array[$i]->[$ik], 0, $equalidx), ", ", substr($actual_results_array[$j]->[$jk],0, $equalidx), ".\n";
							if ( substr($prtik, 0, $equalidx) eq substr($prtjk, 0, $equalidx) ) {	# ignore iff field names are the same...
								$ik++;
								$jk++;
								next;
							}
						}
						my $inc_ik=0;
						my $inc_jk=0;
						if ( $prtik lt $prtjk ) {
							$inc_ik++;
						} else {
							$inc_jk++;
						}
						if ( substr($prtik, 0, $equalidx) eq substr($prtjk, 0, $equalidx) ) {	# ignore iff field names are the same...
							$ik++;
							$jk++;
							$diffBoth++;
						} else {
							if ( $inc_ik > 0 ) {
								$ik++;
								$diffi++;
							} else {
								$jk++;
								$diffj++;
							}
						}
						next;
					}
					my $diffcount = $diffi + $diffj + $diffBoth;
					$debugflag && print $dbgout "Difference er line $i fieldcount $il ar line $j fieldcount $jl diff count $diffcount, minMismatchedCount $minMismatchedCount, minflds $minflds.\n";
					# diffcount == 0 here???
					if ( $diffcount == 0 and $il == $jl ) { # no difference and exactly same # of fields...
						$expected_lines_used[$i]++;
						$actual_lines_used[$j]++;
						$debugflag && print $dbgout "Found a match expected $i, actual $j.\n";
						$matches++;
						next NEXT_EXPECTED;
					}
					if ( $minMismatchedCount > $diffcount and $diffcount < $minflds ) {
						$debugflag && print $dbgout "\tPass 1: better match...\n";
						$minMismatchedCount = $diffcount;
						$minMismatchedCountSubscript=$j;
						$minMismatchedCountExpectedSubscript=$i;
					} else {
						# already have 'better fit' candidate...
						$debugflag && print $dbgout "\t\tnot as good as we already have $minMismatchedCount, ",
						  "$minMismatchedCountExpectedSubscript, ",
						  "$minMismatchedCountSubscript, ",
						  " $diffcount, $minflds...\n";
					}
				}
				#
				# T.B.D.
				#
				# now... here... make sure the actual result line nominated as the 'closest'
				# doesn't have a 'better' or 'exact' match in the rest of the unchecked
				# expected results lines...
				#


				### $minMismatchedCount = $diffcount;
				### $minMismatchedCountSubscript=$j;
				### $minMismatchedCountExpectedSubscript=$i;

				# looking for a second mismatch where the number of mismatches is < $minMismatchedCount
				# If by some strange chance we find 'equality' declare victory, mark as used, and move on...

				# code shamelessly copied, pasted, and hacked... with apologies to the reader!

				$debugflag && print $dbgout "\nAfter first comparison pass, minMismatchedCount = $minMismatchedCount",
					", minMismatchedCountSubscript = $minMismatchedCountSubscript",
					", minMismatchedCountExpectedSubscript = $minMismatchedCountExpectedSubscript",
					", i = $i",
					".\n";


				my $aye=0;

				# skip second pass at matching if nothing in first pass was even close...

				if ( $minMismatchedCountSubscript != $unset ) {
					for ($aye=0; $aye < $number_expected_lines; $aye++) {
						$debugflag && print $dbgout "Pass 2: expected line $aye used $expected_lines_used[$aye].\n";
						next if $expected_lines_used[$aye] > 0 ;
						next if $aye == $i ;	# do not look again at the current pass1 line...

						my $j = $minMismatchedCountSubscript;

						$debugflag && print $dbgout "In second comparison pass, expected $aye, actual $j.\n";
						my $il = scalar @{$expected_results_array[$aye]};
						my $jl = scalar @{$actual_results_array[$j]};

						my $numflds =  $il > $jl ? $il : $jl ;
						my $minflds =  $il < $jl ? $il : $jl ;
						
						if ( $il == $jl and 1 == 2 ) {
							# same number of fields... try for equality...
							my @mismatched=();
							my $diffcount=0;
							$debugflag && print $dbgout "Pass 2 Expected line $aye field count $il is equal to actual line $j field count $jl.\n";
							for ( my $k = 0; $k < $il; $k++ ) {
								$mismatched[$k] = 0;
								if ( $expected_results_array[$aye]->[$k] ne $actual_results_array[$j]->[$k] ) {
									$debugflag && print $dbgout "Pass 2 Field Count equality Mis-Match: $aye ",$expected_results_array[$aye]->[$k]," $j.\n";
									if ( $expected_results_array[$aye]->[$k] =~ m/=__DYNAMIC\(IGNORE\{\}\)__/ ) {
										# we may get to ignore this... ;-)
										my $equalidx = index $expected_results_array[$aye]->[$k], "=";
										$debugflag && print $dbgout "Pass 2 $equalidx, ... -> ", substr($expected_results_array[$aye]->[$k], 0, $equalidx), ", ", substr($actual_results_array[$j]->[$k],0, $equalidx), ".\n";
										next if substr($expected_results_array[$aye]->[$k], 0, $equalidx) eq substr($actual_results_array[$j]->[$k],0, $equalidx);
										
									}
									$mismatchedCounts[$j]++;
									$mismatched[$k]++;
									$diffcount++;
								}
							}
							if ( $diffcount == 0 ) {
								$expected_lines_used[$aye]++;
								$actual_lines_used[$j]++;
								$debugflag && print $dbgout "Found a match expected $aye, actual $j.\n";
								$matches++;
								next NEXT_EXPECTED;
							} else {
								$debugflag && print $dbgout "Difference er line $aye fieldcount $il ar line $j fieldcount $jl diff count $diffcount, minMismatchedCount $minMismatchedCount, minflds $minflds.\n";
								if ( $minMismatchedCount > $diffcount and $diffcount < $minflds ) {
									$debugflag && print $dbgout "\tPass 2: better match...\n";
									$minMismatchedCount = $diffcount;
									$minMismatchedCountSubscript=$j;
									$minMismatchedCountExpectedSubscript=$aye;
								} else {
									$debugflag 
									    && print $dbgout "\t\tnot as good as we already have $minMismatchedCount, ",
									  "$minMismatchedCountExpectedSubscript, ",
									  "$minMismatchedCountSubscript, ",
									  " $diffcount, $minflds...\n";
									# already have 'better fit' candidate...
								}
							}
						} else {
							# number fields not equal...
							# try for a 'near match' anyway...
							$debugflag && print $dbgout "Second Pass: Mis-matched number of fields er line $aye, ar line $j.\n";
							my $ik=0;
							my $jk=0;
							my $diffi=0;
							my $diffj=0;
							my $diffBoth=0;
							while ( $ik < $il and $jk < $jl ) {
								my $prtik = defined $expected_results_array[$aye]->[$ik] ? $expected_results_array[$aye]->[$ik] : "~~~~~~~~~~EOL" ;
								my $prtjk = defined $actual_results_array[$j]->[$jk] ? $actual_results_array[$j]->[$jk] : "~~~~~~~~~~EOL" ;
								$debugflag && print $dbgout "ik = $ik : '$prtik', jk = $jk : '$prtjk'.\n";
								if ( $ik >= $il ) {		# end of expected results list
									$jk++;
									next;
								}
								if ( $jk >= $jl ) {		# end of actual results list
									$ik++;
									next;
								}
								if ( $prtik eq $prtjk ) { # matched!!
									$ik++;
									$jk++;
									next;
								}
								my $equalidx = index $prtik, "=";
								if ( $prtik =~ m/=__DYNAMIC\(IGNORE\{\}\)__/ ) {	# skip known _IGNORE_
									
									$debugflag && print $dbgout "\t $equalidx, (__DYNAMIC(IGNORE)__) ... -> ", substr($expected_results_array[$aye]->[$ik], 0, $equalidx), ", ", substr($actual_results_array[$j]->[$jk],0, $equalidx), ".\n";
									if ( substr($prtik, 0, $equalidx) eq substr($prtjk, 0, $equalidx) ) {	# ignore iff field names are the same...
										$ik++;
										$jk++;
										next;
									}
								}
								my $inc_ik=0;
								my $inc_jk=0;
								if ( $prtik lt $prtjk ) {
									$inc_ik++;
								} else {
									$inc_jk++;
								}
								if ( substr($prtik, 0, $equalidx) eq substr($prtjk, 0, $equalidx) ) {	# ignore iff field names are the same...
									$ik++;
									$jk++;
									$diffBoth++;
								} else {
									if ( $inc_ik > 0 ) {
										$ik++;
										$diffi++;
									} else {
										$jk++;
										$diffj++;
									}
								}
								next;
							}
							my $diffcount = $diffi + $diffj + $diffBoth;
							$debugflag && print $dbgout "Difference er line $aye fieldcount $il ar line $j fieldcount $jl diff count $diffcount, minMismatchedCount $minMismatchedCount, minflds $minflds.\n";
							# diffcount == 0 ???
							if ( $minMismatchedCount > $diffcount and $diffcount < $minflds ) {
								$debugflag 
								    && print $dbgout 
									"Pass 2: Found a better fit expected $aye, actual $j, ", 
									"minMismatchedCount $minMismatchedCount > diffcount $diffcount, ",
									" < minflds $minflds.\n";
								$minMismatchedCount = $diffcount;
								$minMismatchedCountSubscript=$j;
								$minMismatchedCountExpectedSubscript=$aye;
							} else {
								# already have 'better fit' candidate...
							}
						}
					}
				}


				$debugflag && print $dbgout "\nAfter second comparison pass, minMismatchedCount = $minMismatchedCount",
					", minMismatchedCountSubscript = $minMismatchedCountSubscript",
					", minMismatchedCountExpectedSubscript = $minMismatchedCountExpectedSubscript",
					", i = $i",
					", aye = $aye",
					".\n";



				if ( $minMismatchedCount != $unset and $minMismatchedCount > 0 ) {
					my $j = $minMismatchedCountSubscript;
					my $aye = $minMismatchedCountExpectedSubscript;
					my $jl = scalar @{$actual_results_array[$j]};
					my $il = scalar @{$expected_results_array[$aye]};
					my $formattedFieldWidth = $ENV{FIELD_WIDTH} ? do_untaint($ENV{FIELD_WIDTH}) : &DEFAULT_FIELD_WIDTH; # To Do:  simplify!!!
					print "\n\nTEST_CASE_ID: $tcname, STEP_ID: $stepid.\n" unless $mismatchCount > 0;
					$mismatchCount++;
					$totalCountPartialMismatches++;
					my $difffmt = "%-$formattedFieldWidth.${formattedFieldWidth}s %-1.1s %-${formattedFieldWidth}.${formattedFieldWidth}s\n";
					print "\n\nDifferences found between ER line $aye and AR line $j:\n\n";
					printf $difffmt, 'Expected Results', ' ', 'Actual Results';
					printf $difffmt, '================', '=', '==============';
					my $between = ' ';
					my $ik=0;
					my $jk=0;
					#for ( my $k = 0; $k < $il; $k++ ) {
					# while ( $ik < $il and $jk < $jl ) {
					while ( $ik < $il or $jk < $jl ) {
						my $prtik = defined $expected_results_array[$aye]->[$ik] ? $expected_results_array[$aye]->[$ik] : "~~~~~~~~~~~~EOL" ;
						my $prtjk = defined $actual_results_array[$j]->[$jk] ? $actual_results_array[$j]->[$jk] : "~~~~~~~~~~~~EOL" ;
						$debugflag && print $dbgout "ik = $ik : '$prtik', jk = $jk : '$prtjk', il = $il, jl = $jl.\n";
						if ( $ik >= $il ) {		# end of expected results list
							$debugflag && print $dbgout "expected list item $ik past end of list $il, printing actual.\n";
							printf $difffmt, ' ', '>', $prtjk;
							$jk++;
							next;
						}
						if ( $jk >= $jl ) {		# end of actual results list
							$debugflag && print $dbgout "actual list item $jk past end of list $jl, printing expected.\n";
							printf $difffmt, $prtik, '<', ' ';
							$ik++;
							next;
						}
						my $equalidx = index $prtik, "=";
						my $inc_ik=0;
						my $inc_jk=0;
						my $print_ik="";
						my $print_jk="";
						if ( ( $prtik eq $prtjk ) or ( ( $prtik =~ m/=__DYNAMIC\(IGNORE\{\}\)__/ ) and substr($prtik, 0, $equalidx) eq substr($prtjk, 0, $equalidx) ) ) {
							# lines are either absolutely equal or IGNOREd equal...

							$debugflag && print $dbgout "'$prtik' eq '$prtjk'.\n";
							$ik++;
							$jk++;
							next if $printEqualLines == 0;
							$between = '=';
							$print_ik=$prtik;
							$print_jk=$prtjk;
						} elsif ( $prtik lt $prtjk ) {
							
							$debugflag && print $dbgout "'$prtik' lt '$prtjk'.\n";
							$between = '<';
							$print_ik=$prtik;
							$inc_ik++;
						} else {
							$debugflag && print $dbgout "'$prtik' gt '$prtjk'.\n";
							$between = '>';
							$print_jk=$prtjk;
							$inc_jk++;
						}
						if ( ($between ne '=') and ( substr($prtik, 0, $equalidx) eq substr($prtjk, 0, $equalidx) ) ) {	# print both iff field names are the same...
							if ( $inc_ik > 0 ) {
								$print_jk = $prtjk;
								$inc_jk++;
							} else {
								$print_ik = $prtik;
								$inc_ik++;
							}
						}
						printf $difffmt,
							$print_ik,
							$between,
							$print_jk;
						$ik+=$inc_ik;
						$jk+=$inc_jk;
						next;
					}
					$expected_lines_used[$minMismatchedCountExpectedSubscript]++;	
					$actual_lines_used[$j]++;
					print "\n";
					next NEXT_EXPECTED if $minMismatchedCountExpectedSubscript == $i;
					$debugflag && print $dbgout "goto REDO_EXPECTED_LINE_I $i $minMismatchedCountExpectedSubscript $j\n";
					my $sum=0;
					for ( my $ix=0; $ix < scalar @expected_lines_used; $ix++ ) {
						$debugflag && print $dbgout $expected_lines_used[$ix], " ";
						$sum += $expected_lines_used[$ix];
					}
					$debugflag && print $dbgout " -- Used $sum.\n";
					$sum=0;
					for ( my $ix=0; $ix < scalar @actual_lines_used; $ix++ ) {
						$debugflag && print $dbgout $actual_lines_used[$ix], " ";
						$sum += $actual_lines_used[$ix];
					}
					$debugflag && print $dbgout " -- Used $sum.\n";
					# printed expected and actual lines used arrays here... for debugging
					goto REDO_EXPECTED_LINE_I;		# YUCK!!!!!!
					### next NEXT_EXPECTED;
				}
			}
			my $completeMismatches = 0;
			if ( $matches < $number_expected_lines or $matches < $number_actual_lines ) {
				if ( $mismatchCount == 0 ) {	# repeated just in case there were no 'close' lines above...
					print "\n\nTEST_CASE_ID: $tcname, STEP_ID: $stepid.\n";
				}
				$mismatchCount++;
				# Now print out lines that were kinda not even close...
				my $myflag;
				$myflag=0;
				for (my $i=0; $i < $number_expected_lines; $i++) {
					if ( $expected_lines_used[$i] == 0 ) {
						if ( $completeMismatches++ == 0 ) {
							print "\nMis-Matches: #matches $matches #expected lines $number_expected_lines #actual lines $number_actual_lines\n";
						}
						if ( $myflag == 0 ) {
							print "\nEXPECTED_RESULTS:\n";
						}
						print $i+1, ": ", $expected_data_lines[$i],"\n";
						$myflag++;
					}
				}
				print "\n" unless $myflag == 0;
				$myflag = 0;
				for ( my $j=0; $j< $number_actual_lines; $j++) {
					if ( $actual_lines_used[$j] == 0 ) {
						if ( $completeMismatches++ == 0 ) {
							print "\nMis-Matches: #matches $matches #expected lines $number_expected_lines #actual lines $number_actual_lines\n";
						}
						if ( $myflag == 0 ) {
							print "\nACTUAL_RESULTS:\n";
						}
						print $j+1, ": ", $actual_data_lines[$j],"\n";
						$myflag++;
					}
				}
				print "\n" unless $myflag == 0;
			}
			$totalCountTotalMismatches += $completeMismatches;
		};
		$wordsplit[0] eq '' and scalar @wordsplit == 1 and do {
			next;
		};

		# if here then the input line should be a data line to be sliced, diced, and julian fried... ;-)

		if ( $state eq EXPECTED_DATA_STATE ) { 
			push @expected_data_lines, $_;
		}

		if ( $state eq ACTUAL_DATA_STATE ) { 
			push @actual_data_lines, $_;
		}


		my @data_array = ();
		my $parse_string = $_;

PARSE_A_LINE: while( 1 == 1 ) {
			my $mystr = '';
			my $index1 = 0;
			my $index1a = 0;
			my $index2 = 0;

			$index1=index $_, '=';			# find first '=' in string
			$index1a = index $_, ' ', $index1;	# find first ' ' after '='

			if ( $index1a <= 0 ) { 	# end of line if no following space...
				$mystr = $_;	# should edit this data for known issues...
				push @data_array, $mystr;
				last PARSE_A_LINE;
			}

			$index2 = index $_, '=', $index1a;

			$debugflag && print $dbgout "index1 $index1, index1a $index1a, index2 $index2, line '$_'.\n";

			if ( $index2 <= 0 ) { 	# end of line if no following '='
				$mystr = $_;	# should edit this data for known issues...
				push @data_array, $mystr;
				last PARSE_A_LINE;
			}


			my $i = -1;	# go look for the space most immediately before the second '='

			for ( $i = $index2-1; $i > $index1a; $i-- ) {
				last if substr($_, $i, 1) eq ' ';
			}

			$mystr = substr($_,0, $i);

			$debugflag && print $dbgout "DEBUG: mystr = '$mystr'\n";
			push @data_array, $mystr;		# TO DO: edit this...

			$_ = substr($_, $i+1);

		};

		@data_array = sort @data_array;

		if ( $state eq EXPECTED_DATA_STATE ) { 
			push @expected_results_array, \@data_array;
		}
		if ( $state eq ACTUAL_DATA_STATE ) { 
			push @actual_results_array, \@data_array;
		}

	};
}
