#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   atiHTTP.pl - This program generates and sends an http request to any     ##
##                http server and then returns the response.                  ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: DS - 08/15/2011 Ver. 1.00                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use GLOBAL_lib;
use HTTP_lib;
system('clear');


#######################################
# Declare Variables
#######################################
my $arg0          = ($ARGV[0] || '');
my @configArray   = ();
my $envType       = 0;
my $errMsg        = '';
my $status        = '';
my %vars          = ();
my $request       = '';
my $httpRC        = '';
my $httpResHeader = '';
my $response      = '';


##################################
#SPLIT APP ARGS AND CONFIG ARGS
##################################
GLOBAL_lib::splitConfigArgs(\@ARGV, \@configArray);

##################################
# GET CONFIGURABLE VARIABLES
##################################
$envType = GLOBAL_lib::getAppConfigValue('envType', 'env.cfg', \@configArray);




################################################################################
# Set Client Certificate Request Variables (optional)
################################################################################
$vars{'CERT_PATH'}           = '';
$vars{'CERT_PASS'}           = '';



################################################################################
# Set HTTP Server URL (required)
################################################################################
$vars{'HTTP_SERVER_URL'}     = 'http://c00000007313.pharos.intuit.com:8889/v2/fis/DI0508?testqueryparamter=testing';


################################################################################
# Set HTTP Headers (optional)
################################################################################
$vars{'HTTP_HEADERS'}        = 'intuit_originatingip=1.1.1.1;intuit_tid=9f8318e3-3595-44ee-a758-054ecb811842;intuit_offeringid=SDP;intuit_sessionid=xyz;intuit_appid=SDP;Authorization=gateway2testclient';


################################################################################
# Set HTTP Timeout (in seconds - defaults to 900)
################################################################################
$vars{'HTTP_TIMEOUT'}        = '';


################################################################################
# Set HTTP User Agent (optional)
################################################################################
$vars{'HTTP_AGENT'}          = '';


################################################################################
# Set HTTP Content Type (e.g. application/xml)
################################################################################
$vars{'HTTP_CTYPE'}          = 'application/xml';


################################################################################
# Set HTTP Method (e.g. GET, POST, PUT, DELETE)
################################################################################
$vars{'HTTP_METHOD'}         = 'GET';


################################################################################
# Set HTTP Body (optional)
################################################################################
$vars{'HTTP_BODY'}           =
<<__HTTP_BODY__;
__HTTP_BODY__



################################################################################
# Usage / Command Line Arguments
################################################################################
#Display Usage
if ($arg0 eq '')
{
   $errMsg = "Usage: \$ ./atiHTTP.pl ANY_VALUE\n\n" .
             "Options:\n\n" .
             "    ANY_VALUE    - Required.  Any value will execute atiHTTP.pl and send request to server.\n\n";
   print $errMsg;
   exit 0;
}




################################################################################
# Make use of staticSearchReplaceString
################################################################################
($status) = GLOBAL_lib::staticSearchReplace2DHash(\%vars, $envType);


################################################################################
#Post Request to the FSG and Retrieve Response
################################################################################
($httpRC, $httpResHeader, $request, $response) = HTTP_lib::httpATI(\%vars, $envType);
if ( $httpRC eq 'UNKNOWN' ) { print $response; exit 1; }



################################################################################
# Print HTTP Raw Request and Raw Response
################################################################################
print "Raw HTTP Request:\n$request\n\n";
print "Raw HTTP Response:\n\nHTTP Response Code:\n$httpRC\n\nHTTP Response Headers:\n$httpResHeader\n\nHTTP Response Body:\n$response\n\n";
