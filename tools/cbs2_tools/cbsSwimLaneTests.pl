#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
## cbsSwimLaneTests.pl - CBS swim lane smoke tests used to validate CBS       ##
##                       is functional in swim lane.                          ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 03/06/2014 Ver. 1.0                   ##
##                                                                            ##
##                   CBS Version: 4.10                                        ##
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
my $offeringId         = 'CBSSmokeTest';
my $agent              = 'DI CBS TESTING';
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
#Define qa_wlv_app_8180 Variables below
#################################################################
$vars{'qa_wlv_app_8180'}{'guid'}                 = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_wlv_app_8180'}{'fiid'}                 = '00508';
$vars{'qa_wlv_app_8180'}{'url'}                  = 'http://cbs2-vip.app.qa.diginsite.com:8180';
$vars{'qa_wlv_app_8180'}{'auth'}                 = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qa_wlv_app_8280 Variables below
#################################################################
$vars{'qa_wlv_app_8280'}{'guid'}                 = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_wlv_app_8280'}{'fiid'}                 = '00508';
$vars{'qa_wlv_app_8280'}{'url'}                  = 'http://cbs2-vip.app.qa.diginsite.com:8280';
$vars{'qa_wlv_app_8280'}{'auth'}                 = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qa_qdc_sl1 Variables below
#################################################################
$vars{'qa_qdc_sl1'}{'guid'}                      = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_sl1'}{'fiid'}                      = '00508';
$vars{'qa_qdc_sl1'}{'url'}                       = 'http://cbs-sl1-qal-qydc.banking.intuit.net';
$vars{'qa_qdc_sl1'}{'auth'}                      = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qa_qdc_sl2 Variables below
#################################################################
$vars{'qa_qdc_sl2'}{'guid'}                      = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_sl2'}{'fiid'}                      = '00508';
$vars{'qa_qdc_sl2'}{'url'}                       = 'http://cbs-sl2-qal-qydc.banking.intuit.net';
$vars{'qa_qdc_sl2'}{'auth'}                      = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qal1_dca_sl1 Variables below
#################################################################
$vars{'qal1_dca_sl1'}{'guid'}                    = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qal1_dca_sl1'}{'fiid'}                    = '00508';
$vars{'qal1_dca_sl1'}{'url'}                     = 'http://cbs-sl1.qal1.dca.diginsite.net';
$vars{'qal1_dca_sl1'}{'auth'}                    = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qal1_dca_sl2 Variables below
#################################################################
$vars{'qal1_dca_sl2'}{'guid'}                    = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qal1_dca_sl2'}{'fiid'}                    = '00508';
$vars{'qal1_dca_sl2'}{'url'}                     = 'http://cbs-sl2.qal1.dca.diginsite.net';
$vars{'qal1_dca_sl2'}{'auth'}                    = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qal1_dcb_sl1 Variables below
#################################################################
$vars{'qal1_dcb_sl1'}{'guid'}                    = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qal1_dcb_sl1'}{'fiid'}                    = '00508';
$vars{'qal1_dcb_sl1'}{'url'}                     = 'http://cbs-sl1.qal1.dcb.diginsite.net';
$vars{'qal1_dcb_sl1'}{'auth'}                    = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define qal1_dcb_sl2 Variables below
#################################################################
$vars{'qal1_dcb_sl2'}{'guid'}                    = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qal1_dcb_sl2'}{'fiid'}                    = '00508';
$vars{'qal1_dcb_sl2'}{'url'}                     = 'http://cbs-sl2.qal1.dcb.diginsite.net';
$vars{'qal1_dcb_sl2'}{'auth'}                    = '597b651a5fca4893bad45e0bd7101226';

#################################################################
#Define beta_qdc Variables below
#################################################################
$vars{'beta_qdc'}{'guid'}                        = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_qdc'}{'fiid'}                        = '05533';
$vars{'beta_qdc'}{'url'}                         = 'http://cbs-sl1-bta-qydc.banking.intuit.net';
$vars{'beta_qdc'}{'auth'}                        = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define stg1_dca Variables below
#################################################################
$vars{'stg1_dca'}{'guid'}                        = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'stg1_dca'}{'fiid'}                        = '05533';
$vars{'stg1_dca'}{'url'}                         = 'http://cbs-sl1.stg1.dca.diginsite.net';
$vars{'stg1_dca'}{'ap_auth'}                     = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_wlv_app Variables below
#################################################################
$vars{'prod_wlv_app'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_wlv_app'}{'fiid'}                    = '03399';
$vars{'prod_wlv_app'}{'url'}                     = 'http://cbs2-vip.app.prod.diginsite.com:8180';
$vars{'prod_wlv_app'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_qdc_sl1 Variables below
#################################################################
$vars{'prod_qdc_sl1'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_sl1'}{'fiid'}                    = '03399';
$vars{'prod_qdc_sl1'}{'url'}                     = 'http://cbs-sl1-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl1'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_qdc_sl2 Variables below
#################################################################
$vars{'prod_qdc_sl2'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_sl2'}{'fiid'}                    = '03399';
$vars{'prod_qdc_sl2'}{'url'}                     = 'http://cbs-sl2-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl2'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_qdc_sl3 Variables below
#################################################################
$vars{'prod_qdc_sl3'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_sl3'}{'fiid'}                    = '03399';
$vars{'prod_qdc_sl3'}{'url'}                     = 'http://cbs-sl3-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl3'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_qdc_sl4 Variables below
#################################################################
$vars{'prod_qdc_sl4'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_sl4'}{'fiid'}                    = '03399';
$vars{'prod_qdc_sl4'}{'url'}                     = 'http://cbs-sl4-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl4'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_qdc_sl5 Variables below
#################################################################
$vars{'prod_qdc_sl5'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_sl5'}{'fiid'}                    = '03399';
$vars{'prod_qdc_sl5'}{'url'}                     = 'http://cbs-sl5-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl5'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_qdc_sl6 Variables below
#################################################################
$vars{'prod_qdc_sl6'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_sl6'}{'fiid'}                    = '03399';
$vars{'prod_qdc_sl6'}{'url'}                     = 'http://cbs-sl6-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl6'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_lvdc_sl1 Variables below
#################################################################
$vars{'prod_lvdc_sl1'}{'guid'}                   = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_sl1'}{'fiid'}                   = '03399';
$vars{'prod_lvdc_sl1'}{'url'}                    = 'http://cbs-sl1-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl1'}{'auth'}                   = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_lvdc_sl2 Variables below
#################################################################
$vars{'prod_lvdc_sl2'}{'guid'}                   = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_sl2'}{'fiid'}                   = '03399';
$vars{'prod_lvdc_sl2'}{'url'}                    = 'http://cbs-sl2-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl2'}{'auth'}                   = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_lvdc_sl3 Variables below
#################################################################
$vars{'prod_lvdc_sl3'}{'guid'}                   = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_sl3'}{'fiid'}                   = '03399';
$vars{'prod_lvdc_sl3'}{'url'}                    = 'http://cbs-sl3-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl3'}{'auth'}                   = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_lvdc_sl4 Variables below
#################################################################
$vars{'prod_lvdc_sl4'}{'guid'}                   = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_sl4'}{'fiid'}                   = '03399';
$vars{'prod_lvdc_sl4'}{'url'}                    = 'http://cbs-sl4-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl4'}{'auth'}                   = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_lvdc_sl5 Variables below
#################################################################
$vars{'prod_lvdc_sl5'}{'guid'}                   = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_sl5'}{'fiid'}                   = '03399';
$vars{'prod_lvdc_sl5'}{'url'}                    = 'http://cbs-sl5-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl5'}{'auth'}                   = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prod_lvdc_sl6 Variables below
#################################################################
$vars{'prod_lvdc_sl6'}{'guid'}                   = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_sl6'}{'fiid'}                   = '03399';
$vars{'prod_lvdc_sl6'}{'url'}                    = 'http://cbs-sl6-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl6'}{'auth'}                   = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dca_sl1 Variables below
#################################################################
$vars{'prd1_dca_sl1'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dca_sl1'}{'fiid'}                    = '03399';
$vars{'prd1_dca_sl1'}{'url'}                     = 'http://cbs-sl1.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl1'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dca_sl2 Variables below
#################################################################
$vars{'prd1_dca_sl2'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dca_sl2'}{'fiid'}                    = '03399';
$vars{'prd1_dca_sl2'}{'url'}                     = 'http://cbs-sl2.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl2'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dca_sl3 Variables below
#################################################################
$vars{'prd1_dca_sl3'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dca_sl3'}{'fiid'}                    = '03399';
$vars{'prd1_dca_sl3'}{'url'}                     = 'http://cbs-sl3.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl3'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dca_sl4 Variables below
#################################################################
$vars{'prd1_dca_sl4'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dca_sl4'}{'fiid'}                    = '03399';
$vars{'prd1_dca_sl4'}{'url'}                     = 'http://cbs-sl4.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl4'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dca_sl5 Variables below
#################################################################
$vars{'prd1_dca_sl5'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dca_sl5'}{'fiid'}                    = '03399';
$vars{'prd1_dca_sl5'}{'url'}                     = 'http://cbs-sl5.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl5'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dca_sl6 Variables below
#################################################################
$vars{'prd1_dca_sl6'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dca_sl6'}{'fiid'}                    = '03399';
$vars{'prd1_dca_sl6'}{'url'}                     = 'http://cbs-sl6.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl6'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dcb_sl1 Variables below
#################################################################
$vars{'prd1_dcb_sl1'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dcb_sl1'}{'fiid'}                    = '03399';
$vars{'prd1_dcb_sl1'}{'url'}                     = 'http://cbs-sl1.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl1'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dcb_sl2 Variables below
#################################################################
$vars{'prd1_dcb_sl2'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dcb_sl2'}{'fiid'}                    = '03399';
$vars{'prd1_dcb_sl2'}{'url'}                     = 'http://cbs-sl2.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl2'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dcb_sl3 Variables below
#################################################################
$vars{'prd1_dcb_sl3'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dcb_sl3'}{'fiid'}                    = '03399';
$vars{'prd1_dcb_sl3'}{'url'}                     = 'http://cbs-sl3.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl3'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dcb_sl4 Variables below
#################################################################
$vars{'prd1_dcb_sl4'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dcb_sl4'}{'fiid'}                    = '03399';
$vars{'prd1_dcb_sl4'}{'url'}                     = 'http://cbs-sl4.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl4'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dcb_sl5 Variables below
#################################################################
$vars{'prd1_dcb_sl5'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dcb_sl5'}{'fiid'}                    = '03399';
$vars{'prd1_dcb_sl5'}{'url'}                     = 'http://cbs-sl5.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl5'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';

#################################################################
#Define prd1_dcb_sl6 Variables below
#################################################################
$vars{'prd1_dcb_sl6'}{'guid'}                    = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prd1_dcb_sl6'}{'fiid'}                    = '03399';
$vars{'prd1_dcb_sl6'}{'url'}                     = 'http://cbs-sl6.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl6'}{'auth'}                    = 'fd94c8bd2dc74599b4ca292b3a66cd93';




#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                      CBS Swim Lane Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <env_key>\n\n" .
           "     <env_key>    - Supported values are:\n\n" .
           "                    qa_wlv_app_8180\n" .
           "                    qa_wlv_app_8280\n\n" .
           "                    qa_qdc_sl1\n" .
           "                    qa_qdc_sl2\n\n" .
           "                    qal1_dca_sl1\n" .
           "                    qal1_dca_sl2\n" .
           "                    qal1_dcb_sl1\n" .
           "                    qal1_dcb_sl2\n\n" .
           "                    beta_qdc\n" .
           "                    stg1_dca\n\n" .
           "                    prod_wlv_app\n\n" .
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

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinancialInstitution-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomer-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}?fiCustomerIdType=GUID", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomer-v2-getPFMUser';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}?operation=getPFMUser", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinancialInfo-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/financialInfo", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getAccounts-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Parse account id
   ($accountId) = getXmlValue($httpResponseBody, ':id');

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getTransactions-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts/$accountId/transactions", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'invalidateUserCache-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/invalidateusercache", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'DELETE', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '204', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'deleteAccountUsrsumCache-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts/usrsum", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'DELETE', $httpBody, $outboundProxy);

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
