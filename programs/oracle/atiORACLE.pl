#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   atiORACLE.pl - This program makes SQL requests to an Oracle Server and   ##
##                  retrieves the response.                                   ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: DS - 08/19/2011 Ver. 1.00                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use ORACLE_lib;
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
# Oracle Configuration
################################################################################
$vars{'TNSNAME'}     = 'EDB1X';          #Required
$vars{'USERNAME'}    = 'dev2admin';          #Required
$vars{'PASSWORD'}    = 'dev2admin123';          #Required


################################################################################
# SQL String
################################################################################
$vars{'SQL_STRING'}         = "SELECT UNIQUE TEST_CASE_ID FROM TEST_CASES";











################################################################################
# Usage / Command Line Arguments
################################################################################
#Display Usage
if ($arg0 ne 'sql')
{
   $errMsg = "Usage: \$ ./atiORACLE.pl sql [\"sql string\"] [raw]\n\n" .
             "Options:\n\n" .
             "    sql              - Required.\n" .
             "    [\"sql string\"]   - Optional. If provided will override SQL_STRING within atiORACLE.pl.\n" .
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
($status, $request, $response) = ORACLE_lib::oracleATI(\%vars, \%parsedRes);
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


