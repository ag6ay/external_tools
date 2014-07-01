#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   emailTCReports.pl - This script generates and sends out a high level     ##
##                       summary report of all active IATF projects.          ##
##                                                                            ##
##                       Created by: David Schwab                             ##
##                       Last Updated: DS - 06/11/2013 Ver. 1.13              ##
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

#Set intro description
$htmlBody .= "<h4>Hello,</h4>\n" .
             "<h4>This is a weekly high level summary report for IFS Shared Services indicating the level of functional automation by each service. This report is delivered in an automated fashion by way of the Infrastructure Automation Testing Framework (IATF).</h4>\n" .
             "<h4>Please reply to this email if you are not interested in seeing this report so your name is removed from the distribution list.</h4>\n" .
             "<h4>Thanks,<br>SSQA Team</h4>\n" .
             "<br><br>\n";

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
                   "<th>*Total Response Items Validated</th>\n" .
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
$htmlBody .= "<br><br>\n";

#Set Description Key
$htmlBody .= "<h5>*Total Response Items Validated = The total count of response items that are validated across all of the test cases for the given product. Some examples of a single data item might include: a parsed account number, a check image, a regular expression searching for a string match, etc.</h5><br><br><br><br>\n";


#Set $htmlFooter
$htmlFooter = AUTO_lib::constructHtmlReportFooter();


#Set $subject
$subject = "Weekly Automation Metrics for Shared Services";


#Put together Aggregate Report
$htmlMessage = $htmlHeader . $htmlBody . $htmlFooter;


#Send Aggregate Report
GLOBAL_lib::sendmail($toAddress, $fromAddress, $replyAddress, $subject, $htmlMessage, 'html');
