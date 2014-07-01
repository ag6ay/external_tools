#!/usr/bin/perl -wT

#
#
# This script _DOES NOT_
#
# add ER lines
#

use strict;
use English;

sub do_untaint($);

my $fieldwidth=0;
my $tc="";
my $lastTc=' ';
my $ts="";
my $erl="";

my %setFields=();

my @matchArray=();
my @setArray=();
my @blankArray=();
my @clearArray=();

my @rptLines=();
my @TCS=();

my $numericSkippedCount=0;
my $fieldNameExceptionsCount=0;

my $transactionTransactionIdDate='';
my $transactionTransactionIdDateFormat='';

my $stored_displayDescription="";
my $stored_memo="";
my $stored_description="";

my $displayDescriptionExceptionCount=0;

my $infile;

my $infilename="";
$infilename=do_untaint($ENV{'INFILE'}) unless not $ENV{'INFILE'};
$infilename='/dev/stdin' unless $ENV{'INFILE'};

push @rptLines, "INFILENAME: $infilename";


sub do_untaint($) {
	my $tainted=shift;
	if ( not defined $tainted or $tainted eq '' ) {
		return '';
	}
	$tainted =~ s/\$\([^\)]*\)//g;
	$tainted =~ s/([^\`]+)//;

	return $1;
}

sub printWork() {
	my $item;
	foreach $item ( @matchArray ) {
		# as in check ER line field value
		push @rptLines, "CHECK: $item";
	}
	foreach $item ( @setArray ) {
		push @rptLines, "SET: $item";
	}
	foreach $item ( @clearArray ) {
		push @rptLines, "CLEAR: $item";
	}
	foreach $item ( @blankArray ) {
		push @rptLines, "BLANK: $item";
	}

	@matchArray=();
	@setArray=();
	@clearArray=();
	@blankArray=();
}

if ( $infilename ne '' ) {
	open $infile, "<$infilename" or die "Unable to open '$infilename': $!";
}

# TEST_CASE_ID: TC_CBS2_V2_SCHEDULE_TRANSFER_EDIT_FE, STEP_ID: 10.
# Differences found between ER line 11 and AR line 12:

while (<$infile>) {

	chomp $_;

	# print $_,"\n";

	$_ =~ m/^[0-9]{1,}:[[:space:]]/ and do {
		push @rptLines, "NumericSkipped: $_";
		$numericSkippedCount++;
		next;		# skip full ER and AR lines...
	};

	$_ =~ m/^TEST_CASE_ID: / and do {
		my @splitwords = split /[[:space:]]/, $_;
		$tc=$splitwords[1];
		$tc =~ s/\,$//;
		$ts=$splitwords[3];
		$ts =~ s/\.$//;

		printWork();

		push @rptLines,  "TC: $tc";
		if ( $tc ne $lastTc ) {
			push @TCS, $tc;
			$lastTc = $tc;
		}
		push @rptLines,  "TS: $ts";

		next;
	};


	$_ =~ m/^Differences found between ER line/ and do {
		my @splitwords1 = split /[[:space:]]/, $_;
		$erl=$splitwords1[5];

		printWork();

		$transactionTransactionIdDate='';
		$transactionTransactionIdDateFormat='';

		$stored_displayDescription="";
		$stored_memo="";
		$stored_description="";

		push @rptLines,  "ERL: $erl";
		next;
	};


	$_ =~ m/^Input File:\t/ and do {
		$_ =~ s/[[:space:]]{2,}/ /g;
		my @splitwords2 = split /[[:space:]]/, $_;
		my $infiletext = $splitwords2[2];
		push @rptLines,  "INFILE: $infiletext";
		next;
	};

	$_ =~ m/^Difference Field width:\t/ and do {
		my @splitwords3 = split /[[:space:]]/, $_;
		$fieldwidth = $splitwords3[3] + 0;
		push @rptLines,  "FIELDWIDTH: $fieldwidth";
		next;
	};

	$_ =~ m/^Expected Results[[:space:]]{1,}/ and do {
		next;
	};

	$_ =~ m/^[=]{1,}[[:space:]]{1,}/ and do {
		next;
	};

	next unless length($_) > $fieldwidth+3;

	$_ ne '' and do {
		# indicator is the character that tells whether two items are 'equal', or which is 'lesser'
		my $indicator = substr $_, $fieldwidth+1, 1;
		$indicator eq '=' and do {
			my $str=substr $_, 0, $fieldwidth;
			$str =~ s/[[:space:]]{1,}$//;
			$str !~ m/^[a-zA-Z]/ and do {	# ensure fieldname on front
				push @rptLines,  "EXCEPTION0: '$str'.";
				$fieldNameExceptionsCount++;
				next;
			};
			my $strfld = $str;
			my $strdata = $str;
			$strfld =~ s/=.*$//;
			$strdata =~ s/^[^=]{0,}=//;
			$setFields{$strfld}++;
			if ( $strdata eq "" ) { 
				$str = $strfld . "=__EMPTY__"
			}
			push @matchArray, $str;

			# save some stuff for later checking & setting

			$strfld eq "description" and do {
				$stored_description = $strdata;
			};
			$str eq "displayDescription" and do {
				$stored_displayDescription = $strdata;
			};

			# the later checking/setting...

			$str eq "memo" and do {
				$stored_memo = $strdata;
				if ( ( $stored_displayDescription eq $stored_description ) or ( $stored_displayDescription eq $stored_description. ' / ' . $stored_memo ) ) {
					# whew !
				} else {
					push @rptLines, "EXCEPTIOND: displayDescription = '$stored_displayDescription', description = '$stored_description', memo = '$stored_memo'.";
				}
			};
			next;
		};
		
		$indicator =~ m/^([<>])$/ and do {
			# something is different, generate the 'set' transaction...
			# print "indicator $indicator: $_\n";
			my $str1=substr $_, 0, $fieldwidth;
			$str1 =~ s/[[:space:]]{1,}$//;
			my $str1fld = $str1;
			$str1fld =~ s/=.*$//;
			my $str2=substr $_, $fieldwidth+3;
			$str2 =~ s/[[:space:]]{1,}$//;
			my $str2fld = $str2;
			$str2fld =~ s/=.*$//;
			my $str2Data = $str2;
			$str2Data =~ s/^[a-zA-z]{1,}=//;

			#
			# make sure we are looking at fieldnames
			#
			# can not take this for granted because we are parsing auditAutomation.log
			#

			$str1 ne '' and $str1 !~ m/^[a-zA-Z]/ and do {	# bad field name on left
				push @rptLines,  "EXCEPTION1: '$str1'.";
				$fieldNameExceptionsCount++;
				next;
			};
			$str2 ne '' and $str2 !~ m/^[a-zA-Z]/ and do {			# bad field name on right...
				push @rptLines,  "EXCEPTION2: '$str2'.";
				$fieldNameExceptionsCount++;
				next;
			};
			if ( $str1 eq '' ) {
				# no string 1... ensure str2 contains known, accepted fieldname...
				# print "Setting '$str2'.\n";
				if ( $str2 =~ m/transactionId=$transactionTransactionIdDate/ ) {
					# Save out the part after the date...
					# build format of %Y%m%d$afterpart 
					# rewrite $str2 as transactionId=$newstring...
					my $tmpstr = $str2;
					$tmpstr =~ s/transactionId=$transactionTransactionIdDate// ;
					$str2='transactionId='.$transactionTransactionIdDateFormat;
					$str2 =~ s/%d/%d$tmpstr/;
				}
				if ( $str2 =~ m/transaction_Id=$transactionTransactionIdDate/ ) {
					# Save out the part after the date...
					# build format of %Y%m%d$afterpart 
					# rewrite $str2 as transactionId=$newstring...
					my $tmpstr = $str2;
					$tmpstr =~ s/transaction_Id=$transactionTransactionIdDate// ;
					$str2='transaction_Id='.$transactionTransactionIdDateFormat;
					$str2 =~ s/%d/%d$tmpstr/;
				}
				if ( $str2fld eq "Date" or $str2fld eq "elapsedTime" or $str2fld eq "timeStamp") {	# ignore data...
					$str2 = "${str2fld}=__DYNAMIC(IGNORE{})__";
				} elsif ( $str2fld =~ m/Date/ ) {
					# handle date fields better...
				}
				if ( $str2fld eq "ofxTid" ) {
					#print "ofxTid found for initial field setting...\n";
					if ( $str2 =~ m/ofxTid=20[0-9][0-9][01][0-9][0-3][0-9]/ ) {
						my $my_str2 = "ofxTid=__DYNAMIC(DATE{0, \"%Y%m%d" . substr($str2, 15) . "\"})__";
						$str2 = $my_str2;
					}
				}
				if ( $str2Data eq "" ) {
					$str2 = $str2fld . "=" . "__EMPTY__";
				}
				push @setArray, $str2;
				$setFields{$str2fld}++;
			} elsif ( $str2 eq '' ) {
				# straight up CLEAR out the data...
				$setFields{$str1fld}++;
				push @clearArray, $str1fld;
			} else {
				$str1 =~ m/__DYNAMIC/ and do {
					# print "Skipping replacing __DYNAMIC '$str1' with '$str2'.\n";
					if ( $str1 =~ m/transactionDate/ ) {
						my $tmpval=$str2;
						$tmpval =~ s/^[^=]{1,}=//;
						$tmpval =~ s/-//g;
						$tmpval = substr $tmpval, 0, 8;
						push @rptLines, "TDATE: $tmpval";
						$transactionTransactionIdDate=$tmpval;
						$tmpval=$str1;
						$tmpval =~ s/^[^=]{1,}=//;
						$tmpval =~ s/Y-/Y/g;
						$tmpval =~ s/m-/m/g;
						$tmpval =~ s/d-/d/g;
						$tmpval =~ s/;[[:space:]]{0,}SUB.*0,10}//g;
						$transactionTransactionIdDateFormat=$tmpval;
						push @rptLines, "TFMT: $str1fld $tmpval";
					}
					$setFields{$str1fld}++;
					push @matchArray, $str1;	# a match on the existing expected result data ... just to be sure...
					next;
					
					$str1 =~ m/__EMPTY__/ and do {
						$setFields{$str1fld}++;
						push @matchArray, $str1;	# Another special value to handle...
						next;
					};
						
					# print "replacing '$str1' with '$str2'.\n";
					if ( $str2fld eq "ofxTid" ) {
						#print "ofxTid found in field update -- ER vs AR data different...\n";
						#print "old: $str1\n";
						#print "old: $str2\n";
						if ( $str2 =~ m/ofxTid=20[0-9][0-9][01][0-9][0-3][0-9]/ ) {
							my $my_str2 = "ofxTid=__DYNAMIC(DATE{0, \"%Y%m%d" . substr($str2, 15) . "\"})__";
							$str2 = $my_str2;
						}
						#print "new: $str2\n";
					}
					push @matchArray, $str1;	# a match on the existing expected result data ... just to be sure...
					push @setArray, $str2;
					$setFields{$str2fld}++;
				};
			}
			next;
		};
	};

	push @rptLines,  "DEFAULT: ". $_;

}

printWork();
push @rptLines,  "STAT: numericSkippedCount: $numericSkippedCount";
push @rptLines,  "STAT: fieldNameExceptionsCount: $fieldNameExceptionsCount";
push @rptLines,  "STAT: fieldsUsedCount: ". scalar keys %setFields;
push @rptLines,  "STAT: displayDescriptionExceptionCount:  $displayDescriptionExceptionCount";
push @rptLines,  "STAT: numberOfCellsCleared:  ", $#clearArray + 1;
my $key;
my $eol = "\r\n";
$lastTc='';
foreach $key ( sort @TCS ) {
	print "TESTCASE: $key$eol" unless $lastTc eq $key;
	$lastTc = $key;
}
foreach $key ( sort keys %setFields ) {
	print "FIELD: $key $setFields{$key}$eol";
}
foreach my $line (@rptLines) {
	print $line,$eol;
}
