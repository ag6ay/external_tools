#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   atiRDB.pl - This program makes SQL requests to an RDB Broker/Slave and   ##
##               retrieves the response.                                      ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: DS - 12/18/2009 Ver. 1.02                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use RDB_lib;
system('clear');


#######################################
# Declare Variables
#######################################
my $arg0                = ($ARGV[0] || '');
my $arg1                = ($ARGV[1] || '');
my $arg2                = ($ARGV[2] || '');
my $errMsg              = '';
my $status              = '';
my %vars                = ();
my $rdbRequest          = '';
my $rdbResponse         = '';
my $brkReqHeader        = '';
my $brkResHeader        = '';
my $brkReqHeaderString  = '';
my $brkResHeaderString  = '';
my $showRaw             = '';
my %parsedRes           = ();



################################################################################
# Host, Port Configuration
################################################################################
$vars{'RDB_HOST'}        = 'fusion5';          #Required
$vars{'RDB_PORT'}        = '70041';          #Required


################################################################################
# DI Broker Request Message Header (7.x compatible)
#
# Request Type   : 2 Bytes (16 bits) brkHostnameBit + brkXheader7Bit + brkRequestType
# Message Id     : 4 Bytes (32 bits) brkRequestMsgId
# Message Length : 4 Bytes (32 bits) brkRequestMsgLength
# ---------------------------------------------------------------
# pre 7.x Total  : 10 Bytes (80 bits)
#
# Priority       : 1 Byte (8 bits) brkRequestPriority (xheader 7)
# Load Factor    : 1 Byte (8 bits) brkRequestLoadFactor (xheader 7)
# Batch          : 1 Byte (8 bits) brkRequestBatch (xheader 7)
# ---------------------------------------------------------------
# post 7.x Total : 13 Bytes (104 bits)
#
################################################################################
#The below two bits will combine as 1 zero-filled byte (8 bits)
$vars{'brkHostnameBit'}               = '0';   #Set to 1 to return hostname
$vars{'brkXheader7Bit'}               = '0';   #Set to 1 to flag 7.x functionality
$vars{'brkRequestType'}               = '1';   #8 bits - 0 = broker query (c2b_broker), 1 = normal slave request (c2b_req), 2 = normal slave request with persitant connection (c2b_reqp)
$vars{'brkRequestMsgId'}              = '12329281';    #32 bits - broker message id for request
$vars{'brkRequestMsgLength'}          = '';    #32 bits - leave empty to calculate automatically
$vars{'brkRequestPriority'}           = '0';    #8 bits - used when brkXheader7Bit flag set to 1
$vars{'brkRequestLoadFactor'}         = '0';    #8 bits - used when brkXheader7Bit flag set to 1
$vars{'brkRequestBatch'}              = '0';    #8 bits - used when brkXheader7Bit flag set to 1

################################################################################
# Show DI Broker Response Header (true/false)
################################################################################
$vars{'SHOW_BRK_HEADER'} = 'true';




################################################################################
# SQL String
################################################################################
$vars{'SQL_STRING'}         = "SELECT MEM_NUMBER FROM MEMBER";







################################################################################
# Usage / Command Line Arguments
################################################################################
#Display Usage
if ($arg0 ne 'sql')
{
   $errMsg = "Usage: \$ ./atiRDB.pl sql [\"sql string\"] [raw]\n\n" .
             "Options:\n\n" .
             "    sql              - Required.\n" .
             "    [\"sql string\"]   - Optional. If provided will override SQL_STRING within atiRDB.pl.\n" .
             "    [raw]            - Optional. If provided will display raw request/response broker header.\n\n";
   print $errMsg;
   exit 0;
}
#Set command line arguments
if ($arg1 ne '' || $arg2 ne '')
{
   if ($arg1 eq 'raw' || $arg2 eq 'raw') { $showRaw = 'true'; }
   if ($arg1 ne 'raw') { $vars{'SQL_STRING'} = $arg1; }
}






################################################################################
#Send Request to RDB ATI and Retrieve Response
################################################################################
($status, $rdbRequest, $rdbResponse, $brkReqHeader, $brkResHeader) = RDB_lib::rdbReqATI(\%vars);
if ( $status ne 'OK' ) { print $rdbResponse; exit 1; }



################################################################################
#Display Output
################################################################################
#Display Raw request/response broker header
if (lc($showRaw) eq 'true')
{
   #Convert DI Broker Header Request/Response to String
   ($status, $brkReqHeaderString) = GLOBAL_lib::diBrokerReqHeader2String($brkReqHeader);
   ($status, $brkResHeaderString) = GLOBAL_lib::diBrokerResHeader2String($brkResHeader);

   #Print Raw Request/Response
   print "DI Broker Request Header:\n$brkReqHeaderString\n\n";
   print "Raw RDB Request:\nBINARY_FORMAT\n\n";
   print "DI Broker Response Header:\n$brkResHeaderString\n\n";
   print "Raw RDB Response:\nBINARY_FORMAT\n\n";
}
#Display full RDB response in parsed form
else
{
   #Parse and Show DI Broker Response Header
   if (lc($vars{'SHOW_BRK_HEADER'}) eq 'true')
   {
      $status = GLOBAL_lib::parseDiBrokerResHeader($brkResHeader, \%parsedRes);
   }

   #Parse RDB Response
   ($status, $rdbResponse) = RDB_lib::rdbParse($rdbResponse, \%parsedRes);

   #Print Parsed RDB Response
   ($status) = GLOBAL_lib::print3DHash2Screen(\%parsedRes);
}
