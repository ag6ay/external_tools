#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   wlvFsgSgpTest.pl - Simple test to validate FSG WLV to SGP connectivity.  ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 10/24/2012 Ver. 1.0                   ##
##                                                                            ##
##                   FSG Version: 3.5                                         ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
system('clear');



#################################################################
# Configure $env Variable. Possible $env values are:
#  qa
#  prod
#
#################################################################
my $env = 'prod';


#################################################################
#Test Definitions Set Below
#################################################################
my %vars     = ();
my $response = '';
my $debug    = 'false';



#################################################################
#Define qa Variables below
#################################################################
$vars{'qa'}{'fiid'}             = 'DI0508';
$vars{'qa'}{'loginid'}          = 'FSGCCBPFIS001';
$vars{'qa'}{'pass'}             = '11111';
$vars{'qa'}{'url'}              = 'http://services-qal.banking.intuit.net';
$vars{'qa'}{'sgp_auth'}         = '67bbfd3b-c52f-484d-a58f-e983d85abf62';


#################################################################
#Define prod Variables below
#################################################################
$vars{'prod'}{'fiid'}           = 'DI1018';
$vars{'prod'}{'loginid'}        = 'FSGCCBPFIS001';
$vars{'prod'}{'pass'}           = '11111';
$vars{'prod'}{'url'}            = 'http://services.banking.intuit.net';
$vars{'prod'}{'sgp_auth'}       = '91a74dae-7186-4752-83dd-207de4003d25';


#######################################################
#Test 1. Execute FSG Status Service
#######################################################
$response = `curl -vN -X POST -H "Accept: application/xml" -H "Content-Type: application/xml" -H "Authorization: $vars{$env}{'sgp_auth'}" -H "intuit_offeringId: WLVSGPTEST" -H "intuit_appId: ServicesGatewayApp" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: f47ac10b-58cc-4372-a567-0e02b2c3d479" -d '<?xml version="1.0" encoding="UTF-8"?><tns:AuthToken xmlns:tns="http://schema.intuit.com/platform/integration/identity/authToken/v2" xmlns:cm="http://schema.intuit.com/fs/common/v2" xmlns:tns3="http://schema.intuit.com/domain/banking/fiCustomer/v2"><tns:requestChannel>MOBILE_WEB</tns:requestChannel><tns:credential><cm:loginId>$vars{$env}{'loginid'}</cm:loginId><cm:password>$vars{$env}{'pass'}</cm:password></tns:credential></tns:AuthToken>' $vars{$env}{'url'}/v4/fis/$vars{$env}{'fiid'}/identity/authToken 2>&1`;

#Validate Response
if ($response !~ /HTTP\/1\.1 501 Not Implemented/)
{
   print "WLV SGP 'CAS-createAuthTokenV4' service test result: FAILED\n";
   print 'Expected: < HTTP/1.1 200 OK' . "\n";
   print "Instead we got: $response\n\n";
}
else
{
   print "WLV SGP 'CAS-createAuthTokenV4' service test result:            PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }
