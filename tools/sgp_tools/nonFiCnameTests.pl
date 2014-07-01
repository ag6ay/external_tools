#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##  nonFiCnameTests.pl - Tests to help validate SGP non-fi cnames.            ##
##                                                                            ##
##                       Created by: David Schwab                             ##
##                       Last Updated: DS - 06/07/2014 Ver. 1.0               ##
##                                                                            ##
################################################################################
################################################################################
use warnings;
use strict;
use Cwd;



################################################################################
#Set Configurations Below
################################################################################
my %nonFiCName                       = ();
#qal1 environment
$nonFiCName{'qal1'}{'intuit'}        = 'services-nonfi-qal.banking.intuit.net';
$nonFiCName{'qal1'}{'intuit2'}       = 'services-int-qal.banking.intuit.net';
$nonFiCName{'qal1'}{'di'}            = 'fsg-nonfi.qal1.diginsite.net';
#prd1 environment
$nonFiCName{'prd1'}{'intuit'}        = 'services-nonfi-prd.banking.intuit.net';
$nonFiCName{'prd1'}{'intuit2'}       = 'services-int-prd.banking.intuit.net';
$nonFiCName{'prd1'}{'di'}            = 'fsg-nonfi.prd1.diginsite.net';
my %nonFiWip                         = ();
#qal1 environment
$nonFiWip{'qal1'}{'intuit'}          = 'services-nonfi-qal-banking.ilb.intuit.com';
$nonFiWip{'qal1'}{'intuit2'}         = 'services-int-qal-banking.ilb.intuit.com';
$nonFiWip{'qal1'}{'di'}              = 'fsg-nonfi.qal1.lb.diginsite.net';
#prd1 environment
$nonFiWip{'prd1'}{'intuit'}          = 'services-nonfi-prd-banking.ilb.intuit.com';
$nonFiWip{'prd1'}{'intuit2'}         = 'services-int-prd-banking.ilb.intuit.com';
$nonFiWip{'prd1'}{'di'}              = 'fsg-nonfi.prd1.lb.diginsite.net';
my %isgpDomain                       = ();
#qal1 environment
$isgpDomain{'qal1'}{'di'}            = 'api.qal1.diginsite.net';
#prd1 environment
$isgpDomain{'prd1'}{'di'}            = 'api.prd1.diginsite.net';
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
my $parameter2               = (lc($ARGV[1]) || '');
my $status                   = '';
my $msg                      = '';
my $output                   = '';
my $envType                  = '';
my $state                    = '';
my $failedFlag               = 'false';
my $cname1                   = '';
my $cname2                   = '';




################################################################################
#Start Program
################################################################################

#Check usage
if ( ( ($parameter1 ne 'qal1') && ($parameter1 ne 'prd1') ) && ( ($parameter2 ne '1') || ($parameter2 ne '2') || ($parameter2 ne '3') ) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                   nonFiCName Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <environment> <state>\n\n" .
           "         <environment>  -  Required. Valid environment values:\n" .
           "                   qal1 -  qal1 environment.\n" .
           "                   prd1 -  prd1 environment.\n\n" .
           "               <state>  -  Required. Valid state values:\n" .
           "                      1 -  intuit non-fi -> intuit wip. di non-fi -> intuit wip.\n" .
           "                      2 -  intuit non-fi -> di sgp.     di non-fi -> intuit wip.\n" .
           "                      3 -  intuit non-fi -> di sgp.     di non-fi -> di wip.\n\n" .
           "****************************************************************************************************\n\n\n";


   print $msg;
   exit 0;
}



$status = writeLog("#####################################################################");
$status = writeLog("Start of run.");
$status = writeLog("#####################################################################");



#Set $envType
$envType = $parameter1;

#Set $state
$state = $parameter2;


#Starting tests
print "Running non fi cname tests...";


#State 1 - intuit non-fi -> intuit wip. di non-fi -> intuit wip.
if ($state == 1)
{
   ###############################
   # intuit non-fi -> intuit wip
   ###############################

   #Lookup intuit non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'intuit'});

   #Validate expected result with $cname1
   if ($nonFiWip{$envType}{'intuit'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'intuit'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...FAILED.";
   }



   ###############################
   # intuit2 non-fi-int -> intuit2 wip
   ###############################

   #Lookup intuit non-fi-int cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'intuit2'});

   #Validate expected result with $cname1
   if ($nonFiWip{$envType}{'intuit2'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit2'} - expected: $nonFiWip{$envType}{'intuit2'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit2'} - expected: $nonFiWip{$envType}{'intuit2'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'intuit2'} - expected: $nonFiWip{$envType}{'intuit2'}, actual: $cname1, ...FAILED.";
   }



   ###############################
   # di non-fi -> intuit wip
   ###############################

   #Lookup di non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'di'});

   #Validate expected result with $cname1
   if ($nonFiWip{$envType}{'intuit'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...FAILED.";
   }
}
#State 2 - intuit non-fi -> di sgp. di non-fi -> intuit wip.
elsif ($state == 2)
{
   ###############################
   # intuit non-fi -> di sgp
   ###############################

   #Lookup intuit non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'intuit'});

   #Validate expected result with $cname1
   if ($isgpDomain{$envType}{'di'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'intuit'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED.";
   }



   ###############################
   # intuit2 non-fi-int -> di sgp
   ###############################

   #Lookup intuit2 non-fi-int cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'intuit2'});

   #Validate expected result with $cname1
   if ($isgpDomain{$envType}{'di'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit2'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit2'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'intuit2'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED.";
   }



   ###############################
   # di non-fi -> intuit wip
   ###############################

   #Lookup di non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'di'});

   #Validate expected result with $cname1
   if ($nonFiWip{$envType}{'intuit'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'intuit'}, actual: $cname1, ...FAILED.";
   }
}
#State 3 - intuit non-fi -> di sgp. di non-fi -> di wip.
elsif ($state == 3)
{
   ###############################
   # intuit non-fi -> di sgp
   ###############################

   #Lookup intuit non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'intuit'});

   #Validate expected result with $cname1
   if ($isgpDomain{$envType}{'di'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'intuit'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED.";
   }



   ###############################
   # intuit2 non-fi-int -> di sgp
   ###############################

   #Lookup intuit2 non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'intuit2'});

   #Validate expected result with $cname1
   if ($isgpDomain{$envType}{'di'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit2'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'intuit2'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'intuit2'} - expected: $isgpDomain{$envType}{'di'}, actual: $cname1, ...FAILED.";
   }



   ###############################
   # di non-fi -> di wip
   ###############################

   #Lookup di non-fi cname
   ($cname1, $cname2) = getCName($nonFiCName{$envType}{'di'});

   #Validate expected result with $cname1
   if ($nonFiWip{$envType}{'di'} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'di'}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'di'}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$nonFiCName{$envType}{'di'} - expected: $nonFiWip{$envType}{'di'}, actual: $cname1, ...FAILED.";
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
   my $logFile   = 'nonFiCnameTests.log';


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
