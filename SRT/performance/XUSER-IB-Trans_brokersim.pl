#!/usr/bin/perl -w

use strict;


my $tickticker                  = 3300001;
my $tickticker_sto              = 3301001;

my $values_inc                  = 1;
my $values_ticker               = $tickticker;
my $values_sto                  = $tickticker_sto;

my $date1                       = "11";
my $date2                       = "30";

#FREQ-NUM1th-OCCUR-OFTHE-NUM2-WEEKDY
my $num1a                       = "3";
my $num2a                       = "1";

#FREQ-EVRY-NUM1-WKS-ON-NUM2-DY
my $num1b                       = "4";
my $num2b                       = "4";

my $t_initial                   = "20090611";
my $t_final		            	= $t_initial;
my $pmt_cnt                     = "1";
my $send_final                  = "1";
my $standard_trans	        	= "true";
my $joint_trans		        	= "false";

##Payment Option:
# 0 = default, host system determines use of funds
# 1 = multiple payment, TAMT is assumed to be a multiple of the payment due.
# 2 = interest-only payment.
# 3 = principal-only payment.
# 4 = excess-payment to interest.
# 5 = excess payment to principal.
# 6 = escrow-only payment.
# 7 = fees-only payment.

my $pay_opt					="0";

my $email_add                    = "amzad.hossain\@digitalinsight.com";
#my $email_add                    = "testmail\@qa.digitalinsight.com";

## Begin Creation of migrate file:
print "The Dictionary contains ".($tickticker_sto - 3300000)." entries.\n";
print "[VALUES]\n";

while ( $values_ticker <=  $values_sto)
{
	print "$values_inc = $values_ticker\n";
	$values_inc++;
	$values_ticker++;
	
}	
	print "\n\n";
	print "[TABLES]\n";
	
while ( $tickticker <=  $tickticker_sto)
{
	print "\n";
	print "_NAME_:$tickticker\n";
	print"SERVICE,TEST,A_XTX,ACTION,T_INITIAL,T_FINAL,T_PMTCOUNT,A_TPAYOPT,T_FREQUENCY,T_NUM1,T_NUM2,A_FUSR,A_FNUM,A_FTYP,A_TUSR,A_TNUM,A_TTYP,A_TAMT,A_TXTYP,A_TDESC,A_TPAYOPT,A_EMAIL,A_SUBJECT,A_MESSAGE,A_FAILURESUBJECT,A_FAILUREMESSAGE,T_MFINALSUBJECT,T_MFINALBODY,A_NOBALCHK,T_MSENDFINAL,PIN\n";

if ($standard_trans eq "true"){
	print"0,SCHEDULEDITEM,2,TRANSFER,$t_initial,,$pmt_cnt,$pay_opt,3,$date1,$date2,$tickticker,2758248117,1,44568,717550591,0,4500,0,SCHEDULEDTRANSFER,0,$email_add,SRT Subject - Checking To Savings - 3 FREQ-2-DATES/MO,SRT Success Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRT Failure Subject - Checking To Savings - 3 FREQ-2-DATES/MO,SRT Failure Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRTConcluded Scheduled Transfer Subject - Checking To Savings - 3 FREQ-2-DATES/MO,SRT Final Transfer Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,0,$send_final,1234\n";
}
	$tickticker++;
}
