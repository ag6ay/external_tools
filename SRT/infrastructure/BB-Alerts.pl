#!/usr/bin/perl -w

use strict;

my $tickticker        			= 3300001;
my $tickticker_sto			= 3300001;

my $values_inc				= 1;
my $values_ticker			= $tickticker;
my $values_sto				= $tickticker_sto;

my $date1				= "18";
my $date2				= "29";

#FREQ-NUM1th-OCCUR-OFTHE-NUM2-WEEKDY
my $num1a				= "1";
my $num2a				= "1";

#FREQ-EVRY-NUM1-WKS-ON-NUM2-DY
my $num1b				= "3";
my $num2b				= "5";

my $t_initial				= "20091118";
my $t_final				= "20170729";

my $email_add				= "srtqa1\@gmail.com";

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

	print "SERVICE,TEST,ACTION,T_INITIAL,T_FINAL,A_AATTRIB,T_AATTRIB,A_ANUM,T_ANUM,A_ATYP,T_ATYP,T_USR,T_TESTTYPE,T_THRESHOLD,A_ALERTTYPE,T_AATTRIBTYPE,A_EMAIL,A_SUBJECT,A_MESSAGE,A_MPRIORITY,PIN\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,AABAL,AABAL,2758248117,2758248117,1,1,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (AABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,AABAL,AABAL,717550591,717550591,0,0,$tickticker,GT,200,0,MONEY,$email_add,Greater Than Balance Alert Notification Subject,Test Alert LT Message~nBreak~nDouble Break~n~nBalance (AABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,ABAL,ABAL,2758248117,2758248117,1,1,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (ABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,ABAL,ABAL,717550591,717550591,0,0,$tickticker,GT,200,0,MONEY,$email_add,Greater Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (ABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,LABAL,LABAL,365077,365077,32,32,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (LABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,LABAL,LABAL,365179,365179,64,64,$tickticker,GT,200,0,MONEY,$email_add,Greater Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (LABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,LBAL,LBAL,365077,365077,32,32,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (LBAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,LBAL,LBAL,365179,365179,64,64,$tickticker,GT,200,0,MONEY,$email_add,Greater Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (LBAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,IABAL,IABAL,465855,465855,16,16,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (IABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,IABAL,IABAL,688779,688779,4096,4096,$tickticker,GT,200,0,MONEY,$email_add,Greater Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (IABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,IBAL,IBAL,465855,465855,16,16,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (IBAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";
	print "1,SWEEPITEM,ALERT,$t_initial,$t_final,IBAL,IBAL,688779,688779,4096,4096,$tickticker,GT,200,0,MONEY,$email_add,Greater Than Balance Alert Notification Subject,Test Alert GT Message~nBreak~nDouble Break~n~nBalance (IBAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";

	$tickticker++;
}
