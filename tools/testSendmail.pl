#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   testSendmail.pl - Test sendmail.                                         ##
##                                                                            ##
##                     Created by: David Schwab                               ##
##                     Last Updated By: DS 06/08/2014 Ver. 1.0                ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;




################################################################################
# sendmail subroutine -
################################################################################
sub sendmail($$$$$)
{
   my $toAddress      = $_[0];
   my $fromAddress    = $_[1];
   my $replyToAddress = $_[2];
   my $subject        = $_[3];
   my $message        = $_[4];

   my $sendmail       = '/usr/lib/sendmail -t';



   open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
      print SENDMAIL "To: $toAddress\n";
      print SENDMAIL "From: $fromAddress\n";
      print SENDMAIL "Reply-to: $replyToAddress\n";
      print SENDMAIL "Subject: $subject\n";
      print SENDMAIL "Content-type: text/html\n\n";
      print SENDMAIL "$message\n";
   close(SENDMAIL);
}


my $emailToAddress         = 'David.Schwab@DigitalInsight.com';
my $emailAddress           = 'httpMon@DigitalInsight.com';
my $emailReplyToAddress    = 'David.Schwab@DigitalInsight.com';
my $emailSubject           = 'This is a test';
my $emailMessage           = 'Testing';


#Send email that service is down
sendmail($emailToAddress, $emailAddress, $emailReplyToAddress, $emailSubject, $emailMessage);
