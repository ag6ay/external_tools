#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   emailTCReports.pl - This script will make use of the automation.pl       ##
##                       report feature to generate reports for all           ##
##                       configured products and send an email to a defined   ##
##                       list of email recipients.                            ##
##                                                                            ##
##                       Created by: David Schwab                             ##
##                       Last Updated: DS - 05/18/2013 Ver. 1.11              ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use GLOBAL_lib;
use AUTO_lib;


#Define Variables
my $EMAIL_LIST_GLOBAL      = GLOBAL_lib::getAppConfigValue('EMAIL_LIST_GLOBAL', 'email.cfg', \@ARGV);
my $EMAIL_LIST_REPORTS     = GLOBAL_lib::getAppConfigValue('EMAIL_LIST_REPORTS', 'email.cfg', \@ARGV);
my $fromAddress            = GLOBAL_lib::getAppConfigValue('fromEmailAddress', 'email.cfg', \@ARGV);
my $replyAddress           = GLOBAL_lib::getAppConfigValue('replyEmailAddress', 'email.cfg', \@ARGV);
my $webServer              = GLOBAL_lib::getAppConfigValue('webServerHostname', 'webServer.cfg', \@ARGV);
my $toAddress              = '';
my $subject                = '';
my $htmlHeader             = '';
my $htmlBody               = '';
my $htmlFooter             = '';
my $htmlMessage            = '';
my %reportID               = ();
my %reportTCFilter         = ();


#Populate %reportID and %reportTCFilter from Config Hash
GLOBAL_lib::getAppConfigHash('reportID', 'report.cfg', \%reportID);
GLOBAL_lib::getAppConfigHash('reportTCFilter', 'report.cfg', \%reportTCFilter);

#Set $toAddress
$toAddress = GLOBAL_lib::setEmailToList($EMAIL_LIST_GLOBAL, $EMAIL_LIST_REPORTS);

#Set $htmlHeader
$htmlHeader = AUTO_lib::constructHtmlReportHeader($webServer);

#Set table header
$htmlBody .= "<table>\n" .
                "<tr>\n" .
                   "<th>Product</th>\n" .
                   "<th>Test Case Filter(s)</th>\n" .
                   "<th>Number of Active Test Cases</th>\n" .
                   "<th>Number of Inactive Test Cases</th>\n" .
                   "<th>Total Number of Test Cases</th>\n" .
                   "<th>Number of Active Steps</th>\n" .
                   "<th>Number of Inactive Steps</th>\n" .
                   "<th>Total Number of Steps</th>\n" .
                   "<th>Total Number of Response Objects Validated</th>\n" .
                "</tr>\n";


#Loop through all $reportIDs, generate automation.pl report, then send email
for my $ID (sort keys %reportID)
{
   if (uc($reportID{$ID}) eq 'ACTIVE')
   {
      #Set new table row
      $htmlBody .= "<tr>\n";

      #Set Product
      $htmlBody .= "<td>$ID</td>\n";

      #Generate html body report for $reportTCFilter{$ID}
      $htmlBody .= AUTO_lib::genDetailedTCReport($reportTCFilter{$ID}, 'html');

      #End table row
      $htmlBody .= "</tr>\n";
   }
}

#End table
$htmlBody .= "</table>\n";

#Add breaking lines
$htmlBody .= "<br><br><br><br>\n";

#Set $htmlFooter
$htmlFooter = AUTO_lib::constructHtmlReportFooter();


#Set $subject
$subject = "Weekly IATF Test Case Summary Report";


#Put together Aggregate Report
$htmlMessage = $htmlHeader . $htmlBody . $htmlFooter;


#Send Aggregate Report
GLOBAL_lib::sendmail($toAddress, $fromAddress, $replyAddress, $subject, $htmlMessage, 'html');
