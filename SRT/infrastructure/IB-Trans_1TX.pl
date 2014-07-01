#!/usr/bin/perl -w

use strict;

#----------------------------------------------------------------------#
#Set initial and final processing dates
#----------------------------------------------------------------------#
my $t_initial                   = "20101022";

#----------------------------------------------------------------------#
#Set user to begin creating transactions with:
#----------------------------------------------------------------------#
my $tickticker                  = 3300004;

#----------------------------------------------------------------------#
#Srt user to stop creating transaction with:
#----------------------------------------------------------------------#
my $tickticker_sto              = 3300004;

#----------------------------------------------------------------------#
#Used to set the twice monthly frequency date values. t_frequency=3
#----------------------------------------------------------------------#
my $date1                       = "22";
my $date2                       = "30";

#----------------------------------------------------------------------#
#FREQ-NUM1th-OCCUR-OFTHE-NUM2-WEEKDY - not typically set. Not used in
# or supported in production
#----------------------------------------------------------------------#
my $num1a                       = "1";
my $num2a                       = "4";

#----------------------------------------------------------------------#
#FREQ-EVRY-NUM1-WKS-ON-NUM2-DY - Used to set bi-weekly frequency's
#t_frequency=4
#----------------------------------------------------------------------#
my $num1b                       = "1";
my $num2b                       = "2";

#----------------------------------------------------------------------#
#Set the total number of payments for each transaction created
#----------------------------------------------------------------------#
my $pmt_cnt                     = "1";

#----------------------------------------------------------------------#
#Toggle for Send final payment notification 0 = Off - 1 = On.
#----------------------------------------------------------------------#
my $send_final                  = "0";

#----------------------------------------------------------------------#
#Payment Option:
#	 0 = default, host system determines use of funds
#	 1 = multiple payment, TAMT is assumed to be a multiple of the payment due.
#	 2 = interest-only payment.
#	 3 = principal-only payment.
#	 4 = excess-payment to interest.
#	 5 = excess payment to principal.
#	 6 = escrow-only payment.
#	 7 = fees-only payment.
#----------------------------------------------------------------------#
my $pay_opt					="0";

#----------------------------------------------------------------------#
#Email address of where to send notifications
#For large batches use: testmail@qa.digitalinsight.com
#----------------------------------------------------------------------#
my $email_add                   = "amzad.hossain\@digitalinsight.com";
#my $email_add                   = "srtqa1\@gmail.com";

###########################################################################
#Begin creating SRT Migration flat file - DO NOT EDIT BELOW
###########################################################################
my $t_final                     = $t_initial;
my $values_inc                  = 1;
my $values_ticker               = $tickticker;
my $values_sto                  = $tickticker_sto;

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
	print"0,SCHEDULEDITEM,0,TRANSFER,$t_initial,$t_final,0,$pay_opt,0,0,0,$tickticker,2758248117,1,$tickticker,717550591,0,4500,0,SCHEDULEDTRANSFER,0,$email_add,SRT Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Success Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRT Failure Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Failure Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRTConcluded Scheduled Transfer Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Final Transfer Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,0,$send_final,1234\n";
	print"0,SCHEDULEDITEM,0,TRANSFER,$t_initial,$t_final,0,$pay_opt,4,$num1b,$num2b,$tickticker,2758248117,1,$tickticker,717550591,0,4500,0,SCHEDULEDTRANSFER,0,$email_add,SRT Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Success Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRT Failure Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Failure Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRTConcluded Scheduled Transfer Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Final Transfer Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,0,$send_final,1234\n";
#	print"0,SCHEDULEDITEM,0,TRANSFER,$t_initial,$t_final,0,$pay_opt,0,0,0,$tickticker,222222223,1,$tickticker,111111113,0,4500,0,SCHEDULEDTRANSFER,0,$email_add,SRT Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Success Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRT Failure Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Failure Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,SRTConcluded Scheduled Transfer Subject - Checking To Savings - 0 FREQ-ONCE-NXT-RUN,SRT Final Transfer Message~nBreak~nBreak~m Double Break~mYou should not see user values here:(~n~a~u)~mFooter Text,0,$send_final,1234\n";
	$tickticker++;
}
