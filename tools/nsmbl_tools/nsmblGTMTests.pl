#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##  nsmblGTMTests.pl - NSMBL GTM smoke tests used to validate NSMBL           ##
##                     is functional against Global Traffic Manager.          ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 03/15/2014 Ver. 1.0                   ##
##                                                                            ##
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
my $offeringId         = 'ServicesGatewayApp';
my $agent              = 'DI NSMBL TESTING';
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
#Define qa_qdc Variables below
#################################################################
$vars{'qa_qdc'}{'guid'}                          = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qa_qdc'}{'fiid'}                          = '00519';
$vars{'qa_qdc'}{'url'}                           = 'http://nsmbl-qal.banking.intuit.net';
$vars{'qa_qdc'}{'auth'}                          = 'd9a90be0-76c4-432d-ac05-896b468bc537';

#################################################################
#Define qal1_dca_dcb Variables below
#################################################################
$vars{'qal1_dca_dcb'}{'guid'}                    = 'c0a82a2600a9003651fae5ce0df34e00';
$vars{'qal1_dca_dcb'}{'fiid'}                    = '00519';
$vars{'qal1_dca_dcb'}{'url'}                     = 'http://nsmbl.qal1.diginsite.net';
$vars{'qal1_dca_dcb'}{'auth'}                    = 'd9a90be0-76c4-432d-ac05-896b468bc537';

#################################################################
#Define beta_qdc Variables below
#################################################################
$vars{'beta_qdc'}{'guid'}                        = 'c0a8f2b600030c0e45117c2606607a00';
$vars{'beta_qdc'}{'fiid'}                        = '03265';
$vars{'beta_qdc'}{'url'}                         = 'http://nsmbl-bta.banking.intuit.net';
$vars{'beta_qdc'}{'auth'}                        = '7bd60d7552c0450a98fde14b80d5cb1f';

#################################################################
#Define stg1_dca Variables below
#################################################################
$vars{'stg1_dca'}{'guid'}                        = 'c0a8f2b600030c0e45117c2606607a00';
$vars{'stg1_dca'}{'fiid'}                        = '03265';
$vars{'stg1_dca'}{'url'}                         = 'http://nsmbl.stg1.diginsite.net';
$vars{'stg1_dca'}{'auth'}                        = '7bd60d7552c0450a98fde14b80d5cb1f';

#################################################################
#Define prod_qdc_lvdc Variables below
#################################################################
$vars{'prod_qdc_lvdc'}{'guid'}                   = 'c0a8f2b5014f01204fe240110dfb2300';
$vars{'prod_qdc_lvdc'}{'fiid'}                   = '03402';
$vars{'prod_qdc_lvdc'}{'url'}                    = 'http://nsmbl-prd.banking.intuit.net';
$vars{'prod_qdc_lvdc'}{'auth'}                   = '7bd60d7552c0450a98fde14b80d5cb1f';

#################################################################
#Define prd1_dca_dcb Variables below
#################################################################
$vars{'prd1_dca_dcb'}{'guid'}                    = 'c0a8f2b5014f01204fe240110dfb2300';
$vars{'prd1_dca_dcb'}{'fiid'}                    = '03402';
$vars{'prd1_dca_dcb'}{'url'}                     = 'http://nsmbl.prd1.diginsite.net';
$vars{'prd1_dca_dcb'}{'auth'}                    = '7bd60d7552c0450a98fde14b80d5cb1f';







#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                      NSMBL GTM Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <env_key>\n\n" .
           "     <env_key>    - Supported values are:\n\n" .
           "                    qa_qdc\n" .
           "                    qal1_dca_dcb\n\n" .
           "                    beta_qdc\n" .
           "                    stg1_dca\n\n" .
           "                    prod_qdc_lvdc\n" .
           "                    prd1_dca_dcb\n\n" .
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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/notificationService/v2/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getNotificationAccounts-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/notificationService/v2/fis/$vars{$env}{'fiid'}/products/IB/notificationApps/MBL/fiCustomers/$vars{$env}{'guid'}/accounts", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
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
