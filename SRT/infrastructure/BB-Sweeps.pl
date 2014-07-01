#!/usr/bin/perl -w

use strict;

my $tickticker          = 3300005;
my $tickticker_sto      = 3300005;

my $values_inc			= 1;
my $values_ticker		= $tickticker;
my $values_sto			= $tickticker_sto;

my $t_initial			= "20090515";
my $t_final			= "00000000";
my $email_add			= "amzad.hossain\@digitalinsight.com";

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
	print "SERVICE,TEST,A_XTX,ACTION,T_INITIAL,T_FINAL,T_AATTRIBTYPE,T_AATTRIB,T_TESTTYPE,T_THRESHOLD,A_TTHRESHOLD,A_FUSR,A_FNUM,T_ANUM,A_FTYP,T_ATYP,T_USR,A_TUSR,A_TNUM,A_TTYP,A_TPAYOPT,A_TMAX,A_NOBALCHK,A_TXTYP,A_TAMT,A_FCRNCY,A_TCRNCY,A_TDESC,A_EMAIL,A_SUBJECT,A_MESSAGE,A_FAILURESUBJECT,A_FAILUREMESSAGE\n";
	print "1,SWEEPITEM,0,TRANSFER,$t_initial,$t_final,MONEY,AABAL,GT,500,500,$tickticker,2758248117,2758248117,1,1,$tickticker,$tickticker,717550591,0,0,0,0,0,0,840,840,Sweep Transfer,$email_add,Successful GT (AABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds will be transferred to Inserter Account to meet this condition.,Failed GT (AABAL)Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds could not be transferred to Inserter Account for reason below. Please contact your financial institution.\n";
	print "1,SWEEPITEM,0,TRANSFER,$t_initial,$t_final,MONEY,AABAL,LT,500,500,$tickticker,717550591,717550591,0,0,$tickticker,$tickticker,2758248117,1,0,0,0,0,0,840,840,Sweep Transfer,$email_add,Successful LT (AABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds will be transferred to Inserter Account to meet this condition.,Failed LT (AABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds could not be transferred to Inserter Account for reason below. Please contact your financial institution.\n";
	print "1,SWEEPITEM,0,TRANSFER,$t_initial,$t_final,MONEY,ABAL,GT,500,500,$tickticker,2758248117,2758248117,1,1,$tickticker,$tickticker,717550591,0,0,0,0,0,0,840,840,Sweep Transfer,$email_add,Successful GT (ABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds will be transferred to Inserter Account to meet this condition.,Failed GT (ABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds could not be transferred to Inserter Account for reason below. Please contact your financial institution.\n";
	print "1,SWEEPITEM,0,TRANSFER,$t_initial,$t_final,MONEY,ABAL,LT,500,500,$tickticker,717550591,717550591,0,0,$tickticker,$tickticker,2758248117,1,0,0,0,0,0,840,840,Sweep Transfer,$email_add,Successful LT (ABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds will be transferred to Inserter Account to meet this condition.,Failed LT (ABAL) Sweep Notification,The Sweep Transfer (created MM/DD/YYYY HH:MM PM PST by user ADMIN) for Checking has met the defined condition. Funds could not be transferred to Inserter Account for reason below. Please contact your financial institution.\n";
	
	$tickticker++;
}
