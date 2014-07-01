#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   atiMSSQL.pl - This program makes SQL requests to a MS SQL Server and     ##
##                 retrieves the response.                                    ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: AH - 07/29/2011 Ver. 1.00                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use MSSQL_lib;
use GLOBAL_lib;
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
my $request             = '';
my $response            = '';
my $showRaw             = '';
my %parsedRes           = ();



################################################################################
# Host, Port Configuration
################################################################################
$vars{'HOST'}        = 'hera1a.star.dev.diginsite.com';          #Required (DEV-QA Environment)
#$vars{'HOST'}       = 'hera3a.data.qa.diginsite.com';           #Required (FORMAL-QA Environment)
$vars{'PORT'}        = '1433';          #Required
$vars{'DATABASE'}    = 'SDP_OPS_2_4';          #Required
$vars{'USERNAME'}    = 'OpsUser';          #Required
$vars{'PASSWORD'}    = 'C8rd';          #Required (DEV-QA Environment)
#$vars{'PASSWORD'}   = 'C8rd123';       #Required (FORMAL-QA Environment)


################################################################################
# SQL String
################################################################################
$vars{'SQL_STRING'}         = "select * from dbo.Portfolio where SourcePortfolioId='DI9909'";
#$vars{'SQL_STRING'}         = "Select * from FI.BlackWhite";











################################################################################
# Usage / Command Line Arguments
################################################################################
#Display Usage
if ($arg0 ne 'sql')
{
   $errMsg = "Usage: \$ ./atiMSSQL.pl sql [\"sql string\"] [raw]\n\n" .
             "Options:\n\n" .
             "    sql              - Required.\n" .
             "    [\"sql string\"]   - Optional. If provided will override SQL_STRING within atiMSSQL.pl.\n" .
             "    [raw]            - Optional. If provided will include the raw request.\n\n";
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
#Send Request to ATI and Retrieve Response
################################################################################
($status, $request, $response) = MSSQL_lib::mssqlATI(\%vars, \%parsedRes);
if ( $status ne 'OK' ) { print $response; exit 1; }



################################################################################
#Display Output
################################################################################
#Display Raw Request
if (lc($showRaw) eq 'true')
{
   #Print Raw Request
   print "Raw Request:\n$request\n\n";

   print "Response:\n";
}

#Print Parsed Response
($status) = GLOBAL_lib::print3DHash2Screen(\%parsedRes);


