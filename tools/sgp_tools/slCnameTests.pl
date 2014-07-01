#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##  slCnameTests.pl - Tests to help validate SGP sl cnames.                   ##
##                                                                            ##
##                    Created by: David Schwab                                ##
##                    Last Updated: DS - 06/03/2014 Ver. 1.0                  ##
##                                                                            ##
################################################################################
################################################################################
use warnings;
use strict;
use Cwd;



################################################################################
#Set Configurations Below
################################################################################
my %activeSwimLaneDC                 = ();
#qal1 environment
$activeSwimLaneDC{'qal1'}{'1'}       = 'di';
$activeSwimLaneDC{'qal1'}{'2'}       = 'di';
$activeSwimLaneDC{'qal1'}{'11'}      = 'intuit';
$activeSwimLaneDC{'qal1'}{'12'}      = 'intuit';
#prd1 environment
$activeSwimLaneDC{'prd1'}{'1'}       = 'intuit';
$activeSwimLaneDC{'prd1'}{'2'}       = 'intuit';
$activeSwimLaneDC{'prd1'}{'3'}       = 'intuit';
$activeSwimLaneDC{'prd1'}{'4'}       = 'intuit';
$activeSwimLaneDC{'prd1'}{'5'}       = 'intuit';
$activeSwimLaneDC{'prd1'}{'6'}       = 'intuit';
$activeSwimLaneDC{'prd1'}{'11'}      = 'di';
$activeSwimLaneDC{'prd1'}{'12'}      = 'di';
$activeSwimLaneDC{'prd1'}{'13'}      = 'di';
$activeSwimLaneDC{'prd1'}{'14'}      = 'di';
$activeSwimLaneDC{'prd1'}{'15'}      = 'di';
$activeSwimLaneDC{'prd1'}{'16'}      = 'di';
my %slCName                          = ();
#qal1 environment
$slCName{'qal1'}{'1'}{'dca'}         = 'fsg-sl1a.qal1.diginsite.net';
$slCName{'qal1'}{'1'}{'dcb'}         = 'fsg-sl1b.qal1.diginsite.net';
$slCName{'qal1'}{'2'}{'dca'}         = 'fsg-sl2a.qal1.diginsite.net';
$slCName{'qal1'}{'2'}{'dcb'}         = 'fsg-sl2b.qal1.diginsite.net';
$slCName{'qal1'}{'11'}{'dca'}        = 'fsg-sl11a.qal1.diginsite.net';
$slCName{'qal1'}{'11'}{'dcb'}        = 'fsg-sl11b.qal1.diginsite.net';
$slCName{'qal1'}{'12'}{'dca'}        = 'fsg-sl12a.qal1.diginsite.net';
$slCName{'qal1'}{'12'}{'dcb'}        = 'fsg-sl12b.qal1.diginsite.net';
#prd1 environment
$slCName{'prd1'}{'1'}{'dca'}         = 'fsg-sl1a.prd1.diginsite.net';
$slCName{'prd1'}{'1'}{'dcb'}         = 'fsg-sl1b.prd1.diginsite.net';
$slCName{'prd1'}{'2'}{'dca'}         = 'fsg-sl2a.prd1.diginsite.net';
$slCName{'prd1'}{'2'}{'dcb'}         = 'fsg-sl2b.prd1.diginsite.net';
$slCName{'prd1'}{'3'}{'dca'}         = 'fsg-sl3a.prd1.diginsite.net';
$slCName{'prd1'}{'3'}{'dcb'}         = 'fsg-sl3b.prd1.diginsite.net';
$slCName{'prd1'}{'4'}{'dca'}         = 'fsg-sl4a.prd1.diginsite.net';
$slCName{'prd1'}{'4'}{'dcb'}         = 'fsg-sl4b.prd1.diginsite.net';
$slCName{'prd1'}{'5'}{'dca'}         = 'fsg-sl5a.prd1.diginsite.net';
$slCName{'prd1'}{'5'}{'dcb'}         = 'fsg-sl5b.prd1.diginsite.net';
$slCName{'prd1'}{'6'}{'dca'}         = 'fsg-sl6a.prd1.diginsite.net';
$slCName{'prd1'}{'6'}{'dcb'}         = 'fsg-sl6b.prd1.diginsite.net';
$slCName{'prd1'}{'11'}{'dca'}        = 'fsg-sl11a.prd1.diginsite.net';
$slCName{'prd1'}{'11'}{'dcb'}        = 'fsg-sl11b.prd1.diginsite.net';
$slCName{'prd1'}{'12'}{'dca'}        = 'fsg-sl12a.prd1.diginsite.net';
$slCName{'prd1'}{'12'}{'dcb'}        = 'fsg-sl12b.prd1.diginsite.net';
$slCName{'prd1'}{'13'}{'dca'}        = 'fsg-sl13a.prd1.diginsite.net';
$slCName{'prd1'}{'13'}{'dcb'}        = 'fsg-sl13b.prd1.diginsite.net';
$slCName{'prd1'}{'14'}{'dca'}        = 'fsg-sl14a.prd1.diginsite.net';
$slCName{'prd1'}{'14'}{'dcb'}        = 'fsg-sl14b.prd1.diginsite.net';
$slCName{'prd1'}{'15'}{'dca'}        = 'fsg-sl15a.prd1.diginsite.net';
$slCName{'prd1'}{'15'}{'dcb'}        = 'fsg-sl15b.prd1.diginsite.net';
$slCName{'prd1'}{'16'}{'dca'}        = 'fsg-sl16a.prd1.diginsite.net';
$slCName{'prd1'}{'16'}{'dcb'}        = 'fsg-sl16b.prd1.diginsite.net';
my %slWip                            = ();
#qal1 environment
$slWip{'qal1'}{'1'}{'qdc'}           = 'services-sl1a-qal-banking.ilb.intuit.com';
$slWip{'qal1'}{'2'}{'qdc'}           = 'services-sl2a-qal-banking.ilb.intuit.com';
$slWip{'qal1'}{'1'}{'dca'}           = 'fsg-sl1a.qal1.lb.diginsite.net';
$slWip{'qal1'}{'2'}{'dca'}           = 'fsg-sl2a.qal1.lb.diginsite.net';
$slWip{'qal1'}{'1'}{'dcb'}           = 'fsg-sl1b.qal1.lb.diginsite.net';
$slWip{'qal1'}{'2'}{'dcb'}           = 'fsg-sl2b.qal1.lb.diginsite.net';
#prd1 environment
$slWip{'prd1'}{'1'}{'qdc'}           = 'services-sl1a-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'2'}{'qdc'}           = 'services-sl2a-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'3'}{'qdc'}           = 'services-sl3a-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'4'}{'qdc'}           = 'services-sl4a-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'5'}{'qdc'}           = 'services-sl5a-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'6'}{'qdc'}           = 'services-sl6a-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'1'}{'lvdc'}          = 'services-sl1b-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'2'}{'lvdc'}          = 'services-sl2b-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'3'}{'lvdc'}          = 'services-sl3b-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'4'}{'lvdc'}          = 'services-sl4b-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'5'}{'lvdc'}          = 'services-sl5b-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'6'}{'lvdc'}          = 'services-sl6b-prd-banking.ilb.intuit.com';
$slWip{'prd1'}{'1'}{'dca'}           = 'fsg-sl1a.prd1.lb.diginsite.net';
$slWip{'prd1'}{'2'}{'dca'}           = 'fsg-sl2a.prd1.lb.diginsite.net';
$slWip{'prd1'}{'3'}{'dca'}           = 'fsg-sl3a.prd1.lb.diginsite.net';
$slWip{'prd1'}{'4'}{'dca'}           = 'fsg-sl4a.prd1.lb.diginsite.net';
$slWip{'prd1'}{'5'}{'dca'}           = 'fsg-sl5a.prd1.lb.diginsite.net';
$slWip{'prd1'}{'6'}{'dca'}           = 'fsg-sl6a.prd1.lb.diginsite.net';
$slWip{'prd1'}{'1'}{'dcb'}           = 'fsg-sl1b.prd1.lb.diginsite.net';
$slWip{'prd1'}{'2'}{'dcb'}           = 'fsg-sl2b.prd1.lb.diginsite.net';
$slWip{'prd1'}{'3'}{'dcb'}           = 'fsg-sl3b.prd1.lb.diginsite.net';
$slWip{'prd1'}{'4'}{'dcb'}           = 'fsg-sl4b.prd1.lb.diginsite.net';
$slWip{'prd1'}{'5'}{'dcb'}           = 'fsg-sl5b.prd1.lb.diginsite.net';
$slWip{'prd1'}{'6'}{'dcb'}           = 'fsg-sl6b.prd1.lb.diginsite.net';
my %mappedSwimLane                   = ();
$mappedSwimLane{'1'}                 = '1';
$mappedSwimLane{'2'}                 = '2';
$mappedSwimLane{'3'}                 = '3';
$mappedSwimLane{'4'}                 = '4';
$mappedSwimLane{'5'}                 = '5';
$mappedSwimLane{'6'}                 = '6';
$mappedSwimLane{'11'}                = '1';
$mappedSwimLane{'12'}                = '2';
$mappedSwimLane{'13'}                = '3';
$mappedSwimLane{'14'}                = '4';
$mappedSwimLane{'15'}                = '5';
$mappedSwimLane{'16'}                = '6';
my %mappedDC                         = ();
#qal1 environment
$mappedDC{'qal1'}{'intuit'}{'dca'}   = 'qdc';
$mappedDC{'qal1'}{'intuit'}{'dcb'}   = 'qdc';
$mappedDC{'qal1'}{'di'}{'dca'}       = 'dca';
$mappedDC{'qal1'}{'di'}{'dcb'}       = 'dcb';
#prd1 environment
$mappedDC{'prd1'}{'intuit'}{'dca'}   = 'lvdc';
$mappedDC{'prd1'}{'intuit'}{'dcb'}   = 'qdc';
$mappedDC{'prd1'}{'di'}{'dca'}       = 'dca';
$mappedDC{'prd1'}{'di'}{'dcb'}       = 'dcb';
################################################################################
#End of Configurations
################################################################################














###################################
# Subroutine Prototype
###################################
sub writeLog($);
sub getCurDateTime($);
sub getCName($);




#################################################
#Define Variables
#################################################
my $version                  = '1.0';
my $parameter1               = (lc($ARGV[0]) || '');
my $status                   = '';
my $msg                      = '';
my $output                   = '';
my $envType                  = '';
my $swimLane                 = '';
my $dataCenter               = '';
my $failedFlag               = 'false';
my $cname1                   = '';
my $cname2                   = '';
my $slCnameValue             = '';
my $expectedWip              = '';




################################################################################
#Start Program
################################################################################

#Check usage
if ( ($parameter1 ne 'qal1') && ($parameter1 ne 'prd1') )
{
   $msg =  "****************************************************************************************************\n" .
           "                                   slCname Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <environment>\n\n" .
           "         <environment>  -  Required. Valid environment values:\n" .
           "                   qal1 -  qal1 environment.\n" .
           "                   prd1 -  prd1 environment.\n\n" .
           "****************************************************************************************************\n\n\n";


   print $msg;
   exit 0;
}



$status = writeLog("#####################################################################");
$status = writeLog("Start of run.");
$status = writeLog("#####################################################################");



#Set $envType
$envType = $parameter1;


#Starting tests
print "Running sl cname tests...";


#Loop over %slCName
for $swimLane (sort { $a <=> $b } keys %{ $slCName{$envType} })
{
   for $dataCenter (sort keys %{ $slCName{$envType}{$swimLane} })
   {
      $slCnameValue = $slCName{$envType}{$swimLane}{$dataCenter};

      #Lookup sl cname
      ($cname1, $cname2) = getCName($slCnameValue);

      #Set $expectedWip
      $expectedWip = $slWip{$envType}{$mappedSwimLane{$swimLane}}{$mappedDC{$envType}{$activeSwimLaneDC{$envType}{$swimLane}}{$dataCenter}};

      #TODO Validate expected result with $cname1
      if ($expectedWip eq $cname1)
      {
         #PASSED

         #Write results to log
         $status = writeLog("$slCnameValue - expected: $expectedWip, actual: $cname1, ...PASSED");
      }
      else
      {
         #FAILED

         #Write results to log
         $status = writeLog("$slCnameValue - expected: $expectedWip, actual: $cname1, ...FAILED MSL: $mappedSwimLane{$swimLane} MDC: $mappedDC{$envType}{$activeSwimLaneDC{$envType}{$swimLane}}{$dataCenter}");

         $failedFlag = 'true';
         print "\n$slCnameValue - expected: $expectedWip, actual: $cname1, ...FAILED.";
      }
   }
}


if ($failedFlag eq 'true')
{
   print "\nFAILED\n";
}
else
{
   print "PASSED\n";
}

$status = writeLog("#####################################################################");
$status = writeLog("End of run.");
$status = writeLog("#####################################################################\n\n");
################################################################################
#End Program
################################################################################









###################################
# All Subroutines Below
###################################

################################################################################
# writeLog subroutine - Writes line to log file
################################################################################
sub writeLog($)
{
   my $line  = $_[0];

   my $date = getCurDateTime(time);
   my $errMsg    = '';
   my $logFile   = 'slCnameTests.log';


   if(!open(OUT, ">>" . $logFile))
   {
      #Could not open
      $errMsg = "Unable to open log file: $logFile\n";
      return ($errMsg);
      exit 1;
   }
   else
   {
      print OUT $date . ": " . $line . "\n";
      close(OUT);
   }

   return ('OK');
}



################################################################################
# getCurDateTime subroutine - Returns Current Date
################################################################################
sub getCurDateTime($)
{
   my $rawTime = $_[0];

   (my $Second, my $Minute, my $Hour, my $Day, my $Month, my $Year)
                                               = localtime($rawTime);

   #Fix Date
   $Month = $Month +1;
   $Year = $Year + 1900;
   if ( $Second < 10 ) { $Second = "0" . $Second; }
   if ( $Minute < 10 ) { $Minute = "0" . $Minute; }
   if ( $Hour   < 10 ) { $Hour   = "0" . $Hour;   }
   if ( $Day    < 10 ) { $Day    = "0" . $Day;    }
   if ( $Month  < 10 ) { $Month  = "0" . $Month;  }

   return ("$Month-$Day-$Year $Hour:$Minute:$Second");
}



################################################################################
# sub getCName
################################################################################
sub getCName($)
{
   my $domainName   = $_[0];

   my $response     = '';
   my $strPos1      = 0;
   my $strPos2      = 0;
   my $cname1       = '';
   my $cname2       = '';

   $response = `nslookup $domainName 2>&1`;

   $strPos1 = index($response, 'canonical name = ');
   if ($strPos1 >= 0)
   {
      $strPos2 = index($response, "\n", $strPos1 + length('canonical name = ') + 1);
      if ($strPos2 >= 0)
      {
         $cname1 = substr($response, $strPos1 + length('canonical name = '), $strPos2 - $strPos1 - length('canonical name = '));

         #Remove ending '.' char
         if ( substr($cname1, length($cname1) - 1) eq '.')
         {
            $cname1 = substr($cname1, 0, length($cname1) - 1);
         }
      }
   }
   else
   {
      #TODO Handle errors
   }



   return ($cname1, $cname2);
}
