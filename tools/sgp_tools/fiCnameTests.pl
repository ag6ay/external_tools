#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##  fiCnameTests.pl - Tests to help validate SGP fi cnames.                   ##
##                                                                            ##
##                    Created by: David Schwab                                ##
##                    Last Updated: DS - 06/06/2014 Ver. 1.0                  ##
##                                                                            ##
################################################################################
################################################################################
use warnings;
use strict;
use Cwd;



################################################################################
#Set Configurations Below
################################################################################
my $p4port                           = 'p4.diginsite.com:1780';
my $p4user                           = 'dschwab';
my $p4client                         = 'dschwab-datagroups';
my $p4passwordFile                   = 'p4pass.txt';
my %swimlaneActiveDC                 = ();
#qal1 environment
$swimlaneActiveDC{'qal1'}{'1'}       = 'api.qal1.diginsite.net';
$swimlaneActiveDC{'qal1'}{'2'}       = 'api.qal1.diginsite.net';
$swimlaneActiveDC{'qal1'}{'11'}      = 'api.qal1.diginsite.net';
$swimlaneActiveDC{'qal1'}{'12'}      = 'api.qal1.diginsite.net';
#prd1 environment
$swimlaneActiveDC{'prd1'}{'1'}       = 'services-int-sl1x-prd-banking.ilb.intuit.com';
$swimlaneActiveDC{'prd1'}{'2'}       = 'services-int-sl2x-prd-banking.ilb.intuit.com';
$swimlaneActiveDC{'prd1'}{'3'}       = 'services-int-sl3x-prd-banking.ilb.intuit.com';
$swimlaneActiveDC{'prd1'}{'4'}       = 'services-int-sl4x-prd-banking.ilb.intuit.com';
$swimlaneActiveDC{'prd1'}{'5'}       = 'api.prd1.diginsite.net';
$swimlaneActiveDC{'prd1'}{'6'}       = 'services-int-sl6x-prd-banking.ilb.intuit.com';
$swimlaneActiveDC{'prd1'}{'11'}      = 'api.prd1.diginsite.net';
$swimlaneActiveDC{'prd1'}{'12'}      = 'api.prd1.diginsite.net';
$swimlaneActiveDC{'prd1'}{'13'}      = 'api.prd1.diginsite.net';
$swimlaneActiveDC{'prd1'}{'14'}      = 'api.prd1.diginsite.net';
$swimlaneActiveDC{'prd1'}{'15'}      = 'api.prd1.diginsite.net';
$swimlaneActiveDC{'prd1'}{'16'}      = 'api.prd1.diginsite.net';
################################################################################
#End of Configurations
################################################################################














###################################
# Subroutine Prototype
###################################
sub writeLog($);
sub getCurDateTime($);
sub readFileIntoHash($$);
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
my $dataGroupFilePath        = '';
my %dataGroupHash            = ();
my $fiid                     = '';
my $swimlane                 = '';
my $failedFlag               = 'false';
my $p4passwordFilePath       = '';
my $fiCName                  = '';
my $cname1                   = '';
my $cname2                   = '';




################################################################################
#Start Program
################################################################################

#Check usage
if ( ($parameter1 ne 'qal1') && ($parameter1 ne 'prd1') )
{
   $msg =  "****************************************************************************************************\n" .
           "                                   fiCName Tests Ver. $version\n" .
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
$status = writeLog("#####################################################################\n\n");



#Set $envType
$envType = $parameter1;

#Set $p4passwordFilePath
$p4passwordFilePath = cwd . "/$p4passwordFile";

#Set $dataGroupFilePath
$dataGroupFilePath = cwd . "/$envType/ifs-$envType-fiServiceInfo.class";


#Log into perforce depot
$output = `export P4PORT=$p4port;export P4USER=$p4user;export P4CLIENT=$p4client;p4 login < $p4passwordFilePath 2>&1`;
if ($output !~ m/User $p4user logged in./)
{
   $status = writeLog("Error: $output");
   exit 1;
}


#Perform a perforce sync
$output = `export P4PORT=$p4port;export P4USER=$p4user;export P4CLIENT=$p4client;p4 login < $p4passwordFilePath;p4 sync -f 2>&1`;
$status = writeLog("$output");


#Read data group file into hash
($status, $msg) = readFileIntoHash($dataGroupFilePath, \%dataGroupHash);
if ($status ne 'OK')
{
   print $msg;
   exit 1;
}



#Starting tests
print "Running fi cname tests...";


#Loop over %dataGroupHash
for $fiid (sort keys %dataGroupHash)
{
   #Set $swimlane
   $swimlane = $dataGroupHash{$fiid};


   #Skip swim lanes greater than or equal to 90
   if ($swimlane >= 90)
   {
      next;
   }


   #Set $fiCName
   if ($envType eq 'qal1')
   {
      $fiCName = "services-$fiid-qal.banking.intuit.net";
   }
   elsif ($envType eq 'prd1')
   {
      $fiCName = "services-int-$fiid-prd.banking.intuit.net";
   }


   #Lookup cname for $fiCName
   ($cname1, $cname2) = getCName($fiCName);


   #Search and replace 'a/b-prd-banking.ilb.intuit.com' with 'x-prd-banking.ilb.intuit.com' (don't care about dc affinity)
   $cname1 =~ s/a-prd-banking.ilb.intuit.com/x-prd-banking.ilb.intuit.com/;
   $cname1 =~ s/b-prd-banking.ilb.intuit.com/x-prd-banking.ilb.intuit.com/;


   #Validate expected result with $cname1
   if ($swimlaneActiveDC{$envType}{$swimlane} eq $cname1)
   {
      #PASSED

      #Write results to log
      $status = writeLog("$fiid (sl$swimlane), $fiCName - expected: $swimlaneActiveDC{$envType}{$swimlane}, actual: $cname1, ...PASSED");
   }
   else
   {
      #FAILED

      #Write results to log
      $status = writeLog("$fiid (sl$swimlane), $fiCName - expected: $swimlaneActiveDC{$envType}{$swimlane}, actual: $cname1, ...FAILED");

      $failedFlag = 'true';
      print "\n$fiid (sl$swimlane), $fiCName - expected: $swimlaneActiveDC{$envType}{$swimlane}, actual: $cname1, ...FAILED.";
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
   my $logFile   = 'fiCnameTests.log';


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
# sub readFileIntoHash
################################################################################
sub readFileIntoHash($$)
{
   my $filePath     = $_[0];
   my $hashRef      = $_[1];

   #Declare Variables
   my $msg          = '';
   my $line         = '';
   my $lineNumber   = 0;
   my @count        = ();
   my $stringCount  = 0;
   my $key          = '';
   my $value        = '';
   my $strPos1      = 0;
   my $strPos2      = 0;
   my $diid         = '';
   my $srvc         = '';
   my $SRVCSTATUS   = '';
   my $TTL          = '';
   my $SWIMLANE     = '';
   my $LBMETHOD     = '';
   my $FALLBACK     = '';
   my $WIP          = '';



   if (-B $filePath)
   {
      $msg = "ERROR (readFileIntoHash): $filePath is not plain text.\n";
      return ('ERROR', $msg);
   }
   elsif (! open (FILE, $filePath) )
   {
      $msg = "ERROR (readFileIntoHash): Unable to open file ($filePath): $!\n";
      return ('ERROR', $msg);
   }
   else
   {
      while (<FILE>)
      {
         #Remove ending newline
         chomp;

         #Set $line
         $line = $_;

         #Increment $lineNumber
         $lineNumber++;

         #Skip first line
         if ($lineNumber == 1)
         {
            next;
         }

         #Trim leading/trailing spaces
         $line =~ s/^\s+|\s+$//g;

         #Skip empty lines and comments
         if ( ($line eq '') || (substr($line, 0, 1) eq '#') )
         {
            next;
         }

         #Format must be: "diid:srvc" := "SRVCSTATUS:TTL:SWIMLANE:LBMETHOD:FALLBACK:WIP",
         @count = $line =~ /:/g;
         $stringCount = @count;
         if ($stringCount != 7)
         {
            $msg = "ERROR (readFileIntoHash): File format error (line $lineNumber): Expected 7 : delimiters, instead got $stringCount. $line\n";
            close (FILE);
            return ('ERROR', $msg);
         }

         @count = $line =~ /\"/g;
         $stringCount = @count;
         if ($stringCount != 4)
         {
            $msg = "ERROR (readFileIntoHash): File format error (line $lineNumber): Expected 4 \" delimiters, instead got $stringCount. $line\n";
            close (FILE);
            return ('ERROR', $msg);
         }


         #Parse out diid:srvc ($key)
         $strPos1 = index($line, '"');
         if ($strPos1 >= 0)
         {
            $strPos2 = index($line, '"', $strPos1 + 1);
            if ($strPos2 >= 0)
            {
               #Parse out diid:srvc
               $key = substr($line, $strPos1 + 1, $strPos2 - $strPos1 - 1);

               #Done with diid:srvc, strip from $line
               $line = substr($line, $strPos2 + 1);
            }
            else
            {
               $msg = "ERROR (readFileIntoHash): File format error (line $lineNumber): Unable to locate 2nd \" char. $line\n";
               return ('ERROR', $msg);
            }
         }
         else
         {
            $msg = "ERROR (readFileIntoHash): File format error (line $lineNumber): Unable to locate 1st \" char. $line\n";
            return ('ERROR', $msg);
         }


         #Parse out SRVCSTATUS:TTL:SWIMLANE:LBMETHOD:FALLBACK:WIP ($value)
         $strPos1 = index($line, '"');
         if ($strPos1 >= 0)
         {
            $strPos2 = index($line, '"', $strPos1 + 1);
            if ($strPos2 >= 0)
            {
               #Parse out SRVCSTATUS:TTL:SWIMLANE:LBMETHOD:FALLBACK:WIP
               $value = substr($line, $strPos1 + 1, $strPos2 - $strPos1 - 1);
            }
            else
            {
               $msg = "ERROR (readFileIntoHash): File format error (line $lineNumber): Unable to locate 4th \" char. $line\n";
               return ('ERROR', $msg);
            }
         }
         else
         {
            $msg = "ERROR (readFileIntoHash): File format error (line $lineNumber): Unable to locate 3rd \" char. $line\n";
            return ('ERROR', $msg);
         }


         #Split $diid, $srvc from $key
         ($diid, $srvc) = split(':', $key);


         #Split $SRVCSTATUS, $TTL, $SWIMLANE, $LBMETHOD, $FALLBACK, $WIP from $value
         ($SRVCSTATUS, $TTL, $SWIMLANE, $LBMETHOD, $FALLBACK, $WIP) = split(':', $value);


         #Filter for TOB (i.e. exclude external/mobile)
         if ($srvc eq '0')
         {
            #Filter for non-disabled (i.e. non-zero)
            if ($SRVCSTATUS ne '0')
            {
               #Add record to hash
               $hashRef->{$diid} = $SWIMLANE;
            }
         }
      }
   }
   close (FILE);

   #Check for empty hash
   if ( keys(%$hashRef) == 0)
   {
      $msg = "ERROR (readFileIntoHash): Zero fiids are enabled in file.\n";
      return ('ERROR', $msg);
   }

   return ('OK', $msg);
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
