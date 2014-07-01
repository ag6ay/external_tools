#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
## casSwimLaneTests.pl - CAS swim lane smoke tests used to validate CAS       ##
##                       is functional in swim lane.                          ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 03/06/2014 Ver. 1.0                   ##
##                                                                            ##
##                   CAS Version: 2.9                                         ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use HTTP::Request;
use LWP::UserAgent;
system('clear');




#################################################################
#Configurable Variables
#################################################################
our $debug             = 'false';
my $offeringId         = 'CASSmokeTest';
my $agent              = 'DI CAS TESTING';
my $originatingIp      = '1.1.1.1';
my $tid                = '40a51cd1-560c-4d4c-bb00-f7d4d15714e7';
my $readTimeOut        = 30;




#################################################################
#Declare Variables
#################################################################
my %vars               = ();
my $env                = ($ARGV[0] || '');
my $msg                = '';
my $response           = '';
my $version            = '1.0';
my $testName           = '';
my $outboundProxy      = '';
my $httpResCode        = '';
my $httpResponseHeader = '';
my $httpResponseBody   = '';
my $httpResponse       = '';
my %httpHeaderHash     = ();
my $httpContentType    = 'application/xml';
my $httpBody           = '';
my $accountId          = '';
my $testResult         = '';
our $finalTestResult   = 'PASSED';



#################################################################
#Test Definitions Set Below
#################################################################

#################################################################
#Define qa_qdc_sl1 Variables below
#################################################################
$vars{'qa_qdc_sl1'}{'guid'}                      = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qa_qdc_sl1'}{'fiid'}                      = '00519';
$vars{'qa_qdc_sl1'}{'url'}                       = 'http://cas-sl1-qal-qydc.banking.intuit.net';
$vars{'qa_qdc_sl1'}{'auth'}                      = 'e32de5411bb846029952a586965cd357';

#################################################################
#Define qa_qdc_sl2 Variables below
#################################################################
$vars{'qa_qdc_sl2'}{'guid'}                      = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qa_qdc_sl2'}{'fiid'}                      = '00519';
$vars{'qa_qdc_sl2'}{'url'}                       = 'http://cas-sl1-qal-qydc.banking.intuit.net';
$vars{'qa_qdc_sl2'}{'auth'}                      = 'e32de5411bb846029952a586965cd357';

#################################################################
#Define qal1_dca_sl1 Variables below
#################################################################
$vars{'qal1_dca_sl1'}{'guid'}                    = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qal1_dca_sl1'}{'fiid'}                    = '00519';
$vars{'qal1_dca_sl1'}{'url'}                     = 'http://cas-sl1.qal1.dca.diginsite.net';
$vars{'qal1_dca_sl1'}{'auth'}                    = 'e32de5411bb846029952a586965cd357';

#################################################################
#Define qal1_dca_sl2 Variables below
#################################################################
$vars{'qal1_dca_sl2'}{'guid'}                    = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qal1_dca_sl2'}{'fiid'}                    = '00519';
$vars{'qal1_dca_sl2'}{'url'}                     = 'http://cas-sl2.qal1.dca.diginsite.net';
$vars{'qal1_dca_sl2'}{'auth'}                    = 'e32de5411bb846029952a586965cd357';

#################################################################
#Define qal1_dcb_sl1 Variables below
#################################################################
$vars{'qal1_dcb_sl1'}{'guid'}                    = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qal1_dcb_sl1'}{'fiid'}                    = '00519';
$vars{'qal1_dcb_sl1'}{'url'}                     = 'http://cas-sl1.qal1.dcb.diginsite.net';
$vars{'qal1_dcb_sl1'}{'auth'}                    = 'e32de5411bb846029952a586965cd357';

#################################################################
#Define qal1_dcb_sl2 Variables below
#################################################################
$vars{'qal1_dcb_sl2'}{'guid'}                    = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qal1_dcb_sl2'}{'fiid'}                    = '00519';
$vars{'qal1_dcb_sl2'}{'url'}                     = 'http://cas-sl2.qal1.dcb.diginsite.net';
$vars{'qal1_dcb_sl2'}{'auth'}                    = 'e32de5411bb846029952a586965cd357';

#################################################################
#Define beta_qdc Variables below
#################################################################
$vars{'beta_qdc'}{'guid'}                        = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_qdc'}{'fiid'}                        = '05533';
$vars{'beta_qdc'}{'url'}                         = 'http://cas-sl1-bta-qydc.banking.intuit.net';
$vars{'beta_qdc'}{'auth'}                        = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define stg1_dca Variables below
#################################################################
$vars{'stg1_dca'}{'guid'}                        = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'stg1_dca'}{'fiid'}                        = '05533';
$vars{'stg1_dca'}{'url'}                         = 'http://cas-sl1.stg1.dca.diginsite.net';
$vars{'stg1_dca'}{'auth'}                        = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_qdc_sl1 Variables below
#################################################################
$vars{'prod_qdc_sl1'}{'guid'}                    = 'c0a8f208020600425228b11300440700';
$vars{'prod_qdc_sl1'}{'fiid'}                    = '04090';
$vars{'prod_qdc_sl1'}{'url'}                     = 'http://cas-sl1-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl1'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_qdc_sl2 Variables below
#################################################################
$vars{'prod_qdc_sl2'}{'guid'}                    = 'c0a8f2d502b601304d0ea80b1a66a500';
$vars{'prod_qdc_sl2'}{'fiid'}                    = '05157';
$vars{'prod_qdc_sl2'}{'url'}                     = 'http://cas-sl2-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl2'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_qdc_sl3 Variables below
#################################################################
$vars{'prod_qdc_sl3'}{'guid'}                    = 'c0a8f248006700be5086c9ba318fd300';
$vars{'prod_qdc_sl3'}{'fiid'}                    = '03845';
$vars{'prod_qdc_sl3'}{'url'}                     = 'http://cas-sl3-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl3'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_qdc_sl4 Variables below
#################################################################
$vars{'prod_qdc_sl4'}{'guid'}                    = 'c0a8f2ef0002f76e4510ee23313c1200';
$vars{'prod_qdc_sl4'}{'fiid'}                    = '03001';
$vars{'prod_qdc_sl4'}{'url'}                     = 'http://cas-sl4-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl4'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_qdc_sl5 Variables below
#################################################################
$vars{'prod_qdc_sl5'}{'guid'}                    = 'b3326436001923ac5303af712d08e71b';
$vars{'prod_qdc_sl5'}{'fiid'}                    = '01463';
$vars{'prod_qdc_sl5'}{'url'}                     = 'http://cas-sl5-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl5'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_qdc_sl6 Variables below
#################################################################
$vars{'prod_qdc_sl6'}{'guid'}                    = 'c0a8f2a1017b00f05314b5a62c871b00';
$vars{'prod_qdc_sl6'}{'fiid'}                    = '08167';
$vars{'prod_qdc_sl6'}{'url'}                     = 'http://cas-sl6-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl6'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_lvdc_sl1 Variables below
#################################################################
$vars{'prod_lvdc_sl1'}{'guid'}                   = 'c0a8f208020600425228b11300440700';
$vars{'prod_lvdc_sl1'}{'fiid'}                   = '04090';
$vars{'prod_lvdc_sl1'}{'url'}                    = 'http://cas-sl1-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl1'}{'auth'}                   = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_lvdc_sl2 Variables below
#################################################################
$vars{'prod_lvdc_sl2'}{'guid'}                   = 'c0a8f2d502b601304d0ea80b1a66a500';
$vars{'prod_lvdc_sl2'}{'fiid'}                   = '05157';
$vars{'prod_lvdc_sl2'}{'url'}                    = 'http://cas-sl2-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl2'}{'auth'}                   = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_lvdc_sl3 Variables below
#################################################################
$vars{'prod_lvdc_sl3'}{'guid'}                   = 'c0a8f248006700be5086c9ba318fd300';
$vars{'prod_lvdc_sl3'}{'fiid'}                   = '03845';
$vars{'prod_lvdc_sl3'}{'url'}                    = 'http://cas-sl3-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl3'}{'auth'}                   = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_lvdc_sl4 Variables below
#################################################################
$vars{'prod_lvdc_sl4'}{'guid'}                   = 'c0a8f2ef0002f76e4510ee23313c1200';
$vars{'prod_lvdc_sl4'}{'fiid'}                   = '03001';
$vars{'prod_lvdc_sl4'}{'url'}                    = 'http://cas-sl4-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl4'}{'auth'}                   = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_lvdc_sl5 Variables below
#################################################################
$vars{'prod_lvdc_sl5'}{'guid'}                   = 'b3326436001923ac5303af712d08e71b';
$vars{'prod_lvdc_sl5'}{'fiid'}                   = '01463';
$vars{'prod_lvdc_sl5'}{'url'}                    = 'http://cas-sl5-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl5'}{'auth'}                   = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prod_lvdc_sl6 Variables below
#################################################################
$vars{'prod_lvdc_sl6'}{'guid'}                   = 'c0a8f2a1017b00f05314b5a62c871b00';
$vars{'prod_lvdc_sl6'}{'fiid'}                   = '08167';
$vars{'prod_lvdc_sl6'}{'url'}                    = 'http://cas-sl6-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl6'}{'auth'}                   = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dca_sl1 Variables below
#################################################################
$vars{'prd1_dca_sl1'}{'guid'}                    = 'c0a8f208020600425228b11300440700';
$vars{'prd1_dca_sl1'}{'fiid'}                    = '04090';
$vars{'prd1_dca_sl1'}{'url'}                     = 'http://cas-sl1.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl1'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dca_sl2 Variables below
#################################################################
$vars{'prd1_dca_sl2'}{'guid'}                    = 'c0a8f2d502b601304d0ea80b1a66a500';
$vars{'prd1_dca_sl2'}{'fiid'}                    = '05157';
$vars{'prd1_dca_sl2'}{'url'}                     = 'http://cas-sl2.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl2'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dca_sl3 Variables below
#################################################################
$vars{'prd1_dca_sl3'}{'guid'}                    = 'c0a8f248006700be5086c9ba318fd300';
$vars{'prd1_dca_sl3'}{'fiid'}                    = '03845';
$vars{'prd1_dca_sl3'}{'url'}                     = 'http://cas-sl3.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl3'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dca_sl4 Variables below
#################################################################
$vars{'prd1_dca_sl4'}{'guid'}                    = 'c0a8f2ef0002f76e4510ee23313c1200';
$vars{'prd1_dca_sl4'}{'fiid'}                    = '03001';
$vars{'prd1_dca_sl4'}{'url'}                     = 'http://cas-sl4.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl4'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dca_sl5 Variables below
#################################################################
$vars{'prd1_dca_sl5'}{'guid'}                    = 'b3326436001923ac5303af712d08e71b';
$vars{'prd1_dca_sl5'}{'fiid'}                    = '01463';
$vars{'prd1_dca_sl5'}{'url'}                     = 'http://cas-sl5.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl5'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dca_sl6 Variables below
#################################################################
$vars{'prd1_dca_sl6'}{'guid'}                    = 'c0a8f2a1017b00f05314b5a62c871b00';
$vars{'prd1_dca_sl6'}{'fiid'}                    = '08167';
$vars{'prd1_dca_sl6'}{'url'}                     = 'http://cas-sl6.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl6'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dcb_sl1 Variables below
#################################################################
$vars{'prd1_dcb_sl1'}{'guid'}                    = 'c0a8f208020600425228b11300440700';
$vars{'prd1_dcb_sl1'}{'fiid'}                    = '04090';
$vars{'prd1_dcb_sl1'}{'url'}                     = 'http://cas-sl1.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl1'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dcb_sl2 Variables below
#################################################################
$vars{'prd1_dcb_sl2'}{'guid'}                    = 'c0a8f2d502b601304d0ea80b1a66a500';
$vars{'prd1_dcb_sl2'}{'fiid'}                    = '05157';
$vars{'prd1_dcb_sl2'}{'url'}                     = 'http://cas-sl2.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl2'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dcb_sl3 Variables below
#################################################################
$vars{'prd1_dcb_sl3'}{'guid'}                    = 'c0a8f248006700be5086c9ba318fd300';
$vars{'prd1_dcb_sl3'}{'fiid'}                    = '03845';
$vars{'prd1_dcb_sl3'}{'url'}                     = 'http://cas-sl3.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl3'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dcb_sl4 Variables below
#################################################################
$vars{'prd1_dcb_sl4'}{'guid'}                    = 'c0a8f2ef0002f76e4510ee23313c1200';
$vars{'prd1_dcb_sl4'}{'fiid'}                    = '03001';
$vars{'prd1_dcb_sl4'}{'url'}                     = 'http://cas-sl4.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl4'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dcb_sl5 Variables below
#################################################################
$vars{'prd1_dcb_sl5'}{'guid'}                    = 'b3326436001923ac5303af712d08e71b';
$vars{'prd1_dcb_sl5'}{'fiid'}                    = '01463';
$vars{'prd1_dcb_sl5'}{'url'}                     = 'http://cas-sl5.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl5'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';

#################################################################
#Define prd1_dcb_sl6 Variables below
#################################################################
$vars{'prd1_dcb_sl6'}{'guid'}                    = 'c0a8f2a1017b00f05314b5a62c871b00';
$vars{'prd1_dcb_sl6'}{'fiid'}                    = '08167';
$vars{'prd1_dcb_sl6'}{'url'}                     = 'http://cas-sl6.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl6'}{'auth'}                    = '3e0b4d247e6345bf81a37421700c8e12';




#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                      CAS Swim Lane Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <env_key>\n\n" .
           "     <env_key>    - Supported values are:\n\n" .
           "                    qa_qdc_sl1\n" .
           "                    qa_qdc_sl2\n\n" .
           "                    qal1_dca_sl1\n" .
           "                    qal1_dca_sl2\n" .
           "                    qal1_dcb_sl1\n" .
           "                    qal1_dcb_sl2\n\n" .
           "                    beta_qdc\n" .
           "                    stg1_dca\n\n" .
           "                    prod_qdc_sl1\n" .
           "                    prod_qdc_sl2\n" .
           "                    prod_qdc_sl3\n" .
           "                    prod_qdc_sl4\n" .
           "                    prod_qdc_sl5\n" .
           "                    prod_qdc_sl6\n\n" .
           "                    prod_lvdc_sl1\n" .
           "                    prod_lvdc_sl2\n" .
           "                    prod_lvdc_sl3\n" .
           "                    prod_lvdc_sl4\n" .
           "                    prod_lvdc_sl5\n" .
           "                    prod_lvdc_sl6\n\n" .
           "                    prd1_dca_sl1\n" .
           "                    prd1_dca_sl2\n" .
           "                    prd1_dca_sl3\n" .
           "                    prd1_dca_sl4\n" .
           "                    prd1_dca_sl5\n" .
           "                    prd1_dca_sl6\n\n" .
           "                    prd1_dcb_sl1\n" .
           "                    prd1_dcb_sl2\n" .
           "                    prd1_dcb_sl3\n" .
           "                    prd1_dcb_sl4\n" .
           "                    prd1_dcb_sl5\n" .
           "                    prd1_dcb_sl6\n\n" .
           "****************************************************************************************************\n\n\n";

   print $msg;
   exit 0;
}





################################################################################
#                          START TESTS                                         #
################################################################################

$msg =  "****************************************************************************************************\n" .
        "                               $0 (Ver. $version)\n" .
        "****************************************************************************************************\n";
print $msg;


#Print Which Environment Running Tests Against
print "Running tests for environment: $env\n";


#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'status';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinancialInstitution-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomers-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '204', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomer-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomer-v3-invalidateUserCache';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}?method=invalidateUserCache", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getDestinations-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/destinations", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomerStagedStatus-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/customerStagedStatus", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getGlobalPreferences-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/preferences", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFIPreferences-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/preferences", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getUserPreferences-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/preferences", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomerNavigation-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/navigationApps", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFIRegistrationConfig-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiRegistrationConfig", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getContactInfo-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/contactInfo", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomerOptions-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cas-web/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/fiCustomerOptions", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '204', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

################################################################################
#                           END TESTS                                          #
################################################################################


################################################################################
#FINAL TEST RESULT
################################################################################
print "****************************************************************************************************\n";
print "FINAL TEST RESULT:   $finalTestResult\n";
print "****************************************************************************************************\n";












################################################################################
#                     ALL SUBROUTINES BELOW                                    #
################################################################################


################################################################################
# httpRequest
################################################################################
sub httpRequest($$$$$$$$)
{
   my $url           = $_[0];
   my $headerData    = $_[1];
   my $agent         = $_[2];
   my $timeoutVal    = $_[3];
   my $contentType   = $_[4];
   my $requestType   = $_[5];
   my $requestData   = $_[6];
   my $proxy         = $_[7];

   my $userAgent;
   my $uaRequestAsString;
   my $uaRequest;
   my $uaResponse;
   my $uaResponseAsString;
   my $httpResCode;
   my $httpResponseHeader;
   my $httpResponseBody;
   my $rawRequestResponse;

   #Below is needed to prevent _ values from changing to - values in HTTP Header names
   $HTTP::Headers::TRANSLATE_UNDERSCORE = 0;


   if ( ($proxy ne '') && (lc($proxy) ne 'false') )
   {
      $ENV{HTTPS_PROXY} = "$proxy";
      $ENV{HTTP_PROXY}  = "$proxy";
   }
   else
   {
      $ENV{HTTPS_PROXY} = "";
      $ENV{HTTP_PROXY}  = "";
   }

   $userAgent = LWP::UserAgent->new;
   $userAgent->timeout($timeoutVal);
   $userAgent->agent($agent);

   $uaRequest = new HTTP::Request($requestType => $url);
   #Send Custom HTTP Headers
   if ( keys(%{$headerData}) > 0 )
   {
      $uaRequest->header(%{$headerData});
   }
   $uaRequest->content($requestData);
   $uaRequest->content_type($contentType);
   $uaRequest->content_length(length($requestData));
   $uaRequestAsString = $uaRequest->as_string();

   $uaResponse = $userAgent->request($uaRequest);
   $httpResCode = $uaResponse->{'_rc'};
   $httpResponseBody = $uaResponse->{'_content'};
   $httpResponseHeader = $uaResponse->headers_as_string;
   $uaResponseAsString = $uaResponse->as_string();

   if ( $httpResponseHeader =~ m/Content-Encoding: gzip/i )
   {
      $httpResponseBody = Compress::Zlib::memGunzip(my $buf = $httpResponseBody);
   }

   $rawRequestResponse = "HTTP REQUEST:\n$uaRequestAsString\nHTTP RESPONSE:\n$uaResponseAsString\n";


   return ($httpResCode, $httpResponseHeader, $httpResponseBody, $rawRequestResponse);
}



################################################################################
# validateResponse -
################################################################################
sub validateResponse($$$$$$$$)
{
   my $testName           = $_[0];
   my $expectedResCode    = $_[1];
   my $expectedResHeader  = $_[2];
   my $expectedResBody    = $_[3];
   my $actualResCode      = $_[4];
   my $actualResHeader    = $_[5];
   my $actualResBody      = $_[6];
   my $httpResponse       = $_[7];

   my $testResult         = '';
   my $printLength        = 60;


   #Validate HTTP Response Code
   if ($expectedResCode ne '')
   {
      if ($actualResCode !~ $expectedResCode)
      {
         $testResult      = 'FAILED';
         $finalTestResult = 'FAILED';

         print "$testName:" . ' ' x ($printLength - length($testName)) . "FAILED\n";
         print "     EXPECTED RESPONSE CODE: $expectedResCode\n";
         print "     ACTUAL RESPONSE CODE: $actualResCode\n";
         print "     FULL RESPONSE:\n";
         print "$httpResponse\n";
         return ($testResult);
      }
   }


   #Validate HTTP Response Header
   if ($expectedResHeader ne '')
   {
      if ($actualResHeader !~ $expectedResHeader)
      {
         $testResult      = 'FAILED';
         $finalTestResult = 'FAILED';

         print "$testName:" . ' ' x ($printLength - length($testName)) . "FAILED\n";
         print "     EXPECTED RESPONSE HEADER: $expectedResHeader\n";
         print "     ACTUAL RESPONSE HEADER: $actualResHeader\n";
         print "     FULL RESPONSE:\n";
         print "$httpResponse\n";
         return ($testResult);
      }
   }


   #Validate HTTP Response Body
   if ($expectedResBody ne '')
   {
      if ($actualResBody !~ $expectedResBody)
      {
         $testResult      = 'FAILED';
         $finalTestResult = 'FAILED';

         print "$testName:" . ' ' x ($printLength - length($testName)) . "FAILED\n";
         print "     EXPECTED RESPONSE BODY: $expectedResBody\n";
         print "     ACTUAL RESPONSE BODY: $actualResBody\n";
         print "     FULL RESPONSE:\n";
         print "$httpResponse\n";
         return ($testResult);
      }
   }


   #Test Passed
   if ($testResult ne 'FAILED')
   {
      $testResult = 'PASSED';

      print "$testName:" . ' ' x ($printLength - length($testName)) . "PASSED\n";
   }

   return ($testResult);
}



################################################################################
# getXmlValue subroutine -
################################################################################
sub getXmlValue($$)
{
   my $xmlString        = $_[0];
   my $xmlKey           = $_[1];

   my $value            = '';
   my $strPos1          = 0;
   my $strPos2          = 0;


   #Search for $xmlKey in $xmlString and extract $value
   $strPos1 = index($xmlString, "$xmlKey>");
   if ($strPos1 >= 0)
   {
      $strPos2 = index($xmlString, '</', $strPos1 + length("$xmlKey>") + 1);
      if ($strPos2 >= 0)
      {
         $value = substr($xmlString, $strPos1 + length("$xmlKey>"), $strPos2 - $strPos1 - length("$xmlKey>"));
      }
      else
      {
         $value = 'NOT_FOUND';
      }
   }
   else
   {
      $value = 'NOT_FOUND';
   }


   return ($value);
}
