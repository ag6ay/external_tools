#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   emailFSGConns.pl - Email FSG endpoint connection info in html format.    ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: DS - 08/29/2013 Ver. 1.00                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;



################################################################################
#Configure variables below
################################################################################
my $toAddress      = 'david_schwab@intuit.com,david_schwab@intuit.com';
my $fromAddress    = 'david_schwab@intuit.com';
my $replyToAddress = 'david_schwab@intuit.com';
my $subject        = 'Production SL1 FSG Connections';
my $url            = 'http://services-int-sl1-prd-qydc.banking.intuit.net/fsg/v2/repository/tools/endpoints/connectionInfo';


################################################################################
#Declare remaining variables below
################################################################################
my $message        = '';



##################################
#Subroutine Prototype
##################################
sub sendmail($$$$$$);



#Execute URL
$message = `wget -qO- $url`;

#Send email in html format
sendmail($toAddress, $fromAddress, $replyToAddress, $subject, $message, 'html');



################################################################################
#
# sendmail subroutine -
#
#
################################################################################
sub sendmail($$$$$$)
{
   my $toAddress      = $_[0];
   my $fromAddress    = $_[1];
   my $replyToAddress = $_[2];
   my $subject        = $_[3];
   my $message        = $_[4];
   my $format         = $_[5];

   my $sendmail       = '/usr/lib/sendmail -t';
   my $contentType    = '';

   #HTML Content-type Format
   if (lc($format) eq 'html')
   {
      $contentType = "text/html";
   }
   #PLAIN Content-type Format
   elsif (lc($format) eq 'plain')
   {
      $contentType = "text/plain";
   }
   #Bad $format
   else
   {
      return;
   }


   open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
      print SENDMAIL "To: $toAddress\n";
      print SENDMAIL "From: $fromAddress\n";
      print SENDMAIL "Reply-to: $replyToAddress\n";
      print SENDMAIL "Subject: $subject\n";
      print SENDMAIL "Content-type: $contentType\n\n";
      print SENDMAIL "$message\n";
   close(SENDMAIL);
}

