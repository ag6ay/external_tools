#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##  prsGTMTests.pl - PRS GTM smoke tests used to validate PRS                 ##
##                   is functional against Global Traffic Manager.            ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 03/06/2014 Ver. 1.0                   ##
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
my $agent              = 'DI PRS TESTING';
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
$vars{'qa_qdc'}{'guid'}                          = 'c0a82a26015e00ec4f036fd737d24000';
$vars{'qa_qdc'}{'fiid'}                          = '09901';
#$vars{'qa_qdc'}{'url'}                           = 'http://prs-qal-qydc.banking.intuit.net';
$vars{'qa_qdc'}{'url'}                           = 'http://prs-pqa-qydc.banking.intuit.net';
$vars{'qa_qdc'}{'auth'}                          = '0aadebe08e2e4e979db8da4b19368267';

#################################################################
#Define qal1_dca_dcb Variables below
#################################################################
$vars{'qal1_dca_dcb'}{'guid'}                    = 'c0a82a26015e00ec4f036fd737d24000';
$vars{'qal1_dca_dcb'}{'fiid'}                    = '09901';
$vars{'qal1_dca_dcb'}{'url'}                     = 'http://prs.qal1.diginsite.net';
$vars{'qal1_dca_dcb'}{'auth'}                    = '0aadebe08e2e4e979db8da4b19368267';

#################################################################
#Define beta_qdc Variables below
#################################################################
$vars{'beta_qdc'}{'guid'}                        = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_qdc'}{'fiid'}                        = '05533';
$vars{'beta_qdc'}{'url'}                         = 'http://prs-bta-qydc.banking.intuit.net';
$vars{'beta_qdc'}{'auth'}                        = '05578a2630f24f6eb3a11f4e3655ab0a';

#################################################################
#Define stg1_dca Variables below
#################################################################
$vars{'stg1_dca'}{'guid'}                        = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'stg1_dca'}{'fiid'}                        = '05533';
$vars{'stg1_dca'}{'url'}                         = 'http://prs.stg1.diginsite.net';
$vars{'stg1_dca'}{'auth'}                        = 'c00b576b-b4c3-49e4-8b1d-c3cd54861e38';

#################################################################
#Define prod_qdc_lvdc Variables below
#################################################################
$vars{'prod_qdc_lvdc'}{'guid'}                   = 'c0a8f2b2013500e2530523bf3b3dc500';
$vars{'prod_qdc_lvdc'}{'fiid'}                   = '03633';
$vars{'prod_qdc_lvdc'}{'url'}                    = 'http://prs-prd.banking.intuit.net';
$vars{'prod_qdc_lvdc'}{'auth'}                   = '05578a2630f24f6eb3a11f4e3655ab0a';

#################################################################
#Define prd1_dca_dcb Variables below
#################################################################
$vars{'prd1_dca_dcb'}{'guid'}                    = 'c0a8f2b2013500e2530523bf3b3dc500';
$vars{'prd1_dca_dcb'}{'fiid'}                    = '03633';
$vars{'prd1_dca_dcb'}{'url'}                     = 'http://prs.prd1.diginsite.net';
$vars{'prd1_dca_dcb'}{'auth'}                    = '05578a2630f24f6eb3a11f4e3655ab0a';







#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                      PRS GTM Tests Ver. $version\n" .
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
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'auth'}";
   $httpHeaderHash{'intuit_appId'}             = "$offeringId";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'intuit_sessionId'}         = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/prs/v2/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getUserOffers-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/prs/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/userOffers", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getPRAccountsInfo-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/prs/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/prAccountsInfo", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Parse account id
   ($accountId) = getXmlValue($httpResponseBody, ':prAccountId');

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test TODO - disable until can get SecurityToken
#######################################################
if (0)
{
   #Set Test Name
   $testName = 'getOffers-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/prs/v2/fis/$vars{$env}{'fiid'}/accounts/$accountId/offers", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Parse account id
   ($accountId) = getXmlValue($httpResponseBody, ':prAccountId');

   #Validate Response
   $testResult = validateResponse($testName, '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getSampleAccountFile-v2';

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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/prs/v2/fis/$vars{$env}{'fiid'}/sampleAccountFile", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

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
