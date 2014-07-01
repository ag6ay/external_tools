#!/usr/bin/perl -w

use strict;

my $tickticker        			= 3300001;
my $tickticker_sto			= 3300150;

my $values_inc				= 2;
my $values_ticker			= $tickticker;
my $values_sto				= $tickticker_sto;

my $date1				= "20";
my $date2				= "29";

#FREQ-NUM1th-OCCUR-OFTHE-NUM2-WEEKDY
my $num1a				= "1";
my $num2a				= "1";

#FREQ-EVRY-NUM1-WKS-ON-NUM2-DY
my $num1b				= "5";
my $num2b				= "5";

my $t_initial				= "20091120";
my $t_final				= "20170729";

my $email_add				= "srtqa1\@gmail.com";

print "The Dictionary contains ".($tickticker_sto - 3300000)." entries.\n";
print "[VALUES]\n";

while ( $values_ticker <=  $values_sto)
{
	print "$values_inc = $values_ticker\n";
	$values_inc++;
	$values_ticker+=2;
	
}	
	print "\n\n";
	print "[TABLES]\n";
	
while ( $tickticker <=  $tickticker_sto)
{
	print "\n";
	print "_NAME_:$tickticker\n";

	print "SERVICE,TEST,ACTION,T_INITIAL,T_FINAL,A_AATTRIB,T_AATTRIB,A_ANUM,T_ANUM,A_ATYP,T_ATYP,T_USR,T_TESTTYPE,T_THRESHOLD,A_ALERTTYPE,T_AATTRIBTYPE,A_EMAIL,A_SUBJECT,A_MESSAGE,A_MPRIORITY,PIN\n";
	
        print "1,SWEEPITEM,ALERT,$t_initial,$t_final,AABAL,AABAL,222222223,222222223,1,1,$tickticker,LT,100000000,0,MONEY,$email_add,Less Than Balance Alert Notification Subject,Test Alert LT Message~nBreak~nDouble Break~n~nBalance (AABAL) :~b~mYou should not see user values here:(~n~a~u)~mFooter Text,0,1234\n";

	$tickticker+=2;
}
