#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##    cnameTest.pl - Validate cnames.                                         ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last Updated: DS (06/17/2014) Ver. 1.0                   ##
##                                                                            ##
################################################################################
################################################################################
use warnings;
use strict;
use Cwd;



#################################################
#Subroutine Prototype
#################################################
sub writeLog($);
sub getCurDateTime($);
sub readFileIntoArray($$);
sub getCName($);


#################################################
#Define Variables
#################################################
my $version                  = '1.0';
my $parameter1               = (lc($ARGV[0]) || '');
my $parameter2               = (lc($ARGV[1]) || '');
my $status                   = '';
my $msg                      = '';
my $failedFlag               = 'false';
my $fileNamePath             = '';
my $state                    = '';
my @cnameArray               = ();
my $applicationName          = '';
my $environment              = '';
my $diCName                  = '';
my $diWip                    = '';
my $intuitCName              = '';
my $intuitWip                = '';
my $onHold                   = '';
my $usedByWlv                = '';
my $migrated                 = '';
my $cname1                   = '';
my $cname2                   = '';


################################################################################
#Start Program
################################################################################

#Check usage
if ( $parameter1 eq '' || $parameter2 eq '')
{
   $msg =  "****************************************************************************************************\n" .
           "                                   CName Test Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 fileName <state>\n\n" .
           "         fileName  -  Required. Input file containing list of cname records to test.\n\n" .
           "         <state>   -  Required. Valid options are:\n" .
           "                 1 - intuit cnames point to intuit wips.\n" .
           "                 2 - di cnames point to intuit wips.\n" .
           "                 3 - intuit cnames point to di cnames.\n" .
           "                 4 - di cnames point to di wips.\n\n" .
           "****************************************************************************************************\n\n\n";


   print $msg;
   exit 0;
}



#Set $fileNamePath
$fileNamePath = cwd . "/$parameter1";


#Set $state
$state = $parameter2;

#Check for valid $state values
if ($state !~ /^\d+$/)
{
   print "<state> value needs to be value: 1 - 4.\n";
   exit 1;
}
if ( ($state < 1) || ($state > 4) )
{
   print "<state> value needs to be value: 1 - 4.\n";
   exit 1;
}


#Open $fileNamePath and read into @cnameArray
($status, $msg) = readFileIntoArray($fileNamePath, \@cnameArray);
if ($status ne 'OK')
{
   print $msg;
   exit 1;
}


$status = writeLog("#####################################################################");
$status = writeLog("Start of run.");
$status = writeLog("#####################################################################");


#Turn auto flush on
$| = 1;


#Starting tests
print "Running cname tests...";

#Test cnames
foreach (@cnameArray)
{
   #Split records
   ($applicationName, $environment, $intuitCName, $intuitWip, $diCName, $diWip, $onHold, $usedByWlv, $migrated) = split("\t", $_);

   if (lc($onHold) ne 'yes')
   {
      #State 1 - intuit cnames point to intuit wips
      if ($state == 1)
      {
         ($cname1, $cname2) = getCName($intuitCName);

         if ($cname1 ne $intuitWip)
         {
            #Failed

            $failedFlag = 'true';
            print "\nERROR: intuit cname ($intuitCName -> $cname1) did not match expected intuit wip: $intuitWip";

            #Write results to log
            $status = writeLog("intuit cname -> intuit wip, $intuitCName - expected: $intuitWip, actual: $cname1, ...FAILED");
         }
         else
         {
            #Passed

            #Write results to log
            $status = writeLog("intuit cname -> intuit wip, $intuitCName - expected: $intuitWip, actual: $cname1, ...PASSED");
         }
      }
      #State 2 - di cnames point to intuit wips
      elsif ($state == 2)
      {
         ($cname1, $cname2) = getCName($diCName);

         if ($cname1 ne $intuitWip)
         {
            #Failed

            $failedFlag = 'true';
            print "\nERROR: di cname ($diCName -> $cname1) did not match expected intuit wip: $intuitWip";

            #Write results to log
            $status = writeLog("di cname -> intuit wip, $diCName - expected: $intuitWip, actual: $cname1, ...FAILED");
         }
         else
         {
            #Passed

            #Write results to log
            $status = writeLog("di cname -> intuit wip, $diCName - expected: $intuitWip, actual: $cname1, ...PASSED");
         }
      }
      #State 3 - intuit cnames point to di cnames
      elsif ($state == 3)
      {
         ($cname1, $cname2) = getCName($intuitCName);

         if ($cname1 ne $diCName)
         {
            #Failed

            $failedFlag = 'true';
            print "\nERROR: intuit cname ($intuitCName -> $cname1) did not match expected di cname: $diCName";

            #Write results to log
            $status = writeLog("intuit cname -> di cname, $intuitCName - expected: $diCName, actual: $cname1, ...FAILED");
         }
         else
         {
            #Passed

            #Write results to log
            $status = writeLog("intuit cname -> di cname, $intuitCName - expected: $diCName, actual: $cname1, ...PASSED");
         }
      }
      #State 4 - di cnames point to di wips
      elsif ($state == 4)
      {
         ($cname1, $cname2) = getCName($diCName);

         if ($cname1 ne $diWip)
         {
            #Failed

            $failedFlag = 'true';
            print "\nERROR: di cname ($diCName -> $cname1) did not match expected di wip: $diWip";

            #Write results to log
            $status = writeLog("di cname -> di wip, $diCName - expected: $diWip, actual: $cname1, ...FAILED");
         }
         else
         {
            #Passed

            #Write results to log
            $status = writeLog("di cname -> di wip, $diCName - expected: $diWip, actual: $cname1, ...PASSED");
         }
      }
   }
}

if ($failedFlag eq 'true')
{
   print "\nCName test failed.\n";
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

















################################################################################
#All Subroutines Below
################################################################################



################################################################################
# writeLog subroutine - Writes line to log file
################################################################################
sub writeLog($)
{
   my $line  = $_[0];

   my $date = getCurDateTime(time);
   my $errMsg    = '';
   my $logFile   = 'appCnameTest.log';


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



################################################################################
# sub readFileIntoArray
################################################################################
sub readFileIntoArray($$)
{
   my $filePath     = $_[0];
   my $arrayRef     = $_[1];

   #Declare Variables
   my $msg          = '';
   my $line         = '';
   my $lineNumber   = 0;
   my @count        = ();
   my $stringCount  = 0;

   if (-B $filePath)
   {
      $msg = "ERROR (readFileIntoArray): $filePath is not plain text.\n";
      return ('ERROR', $msg);
   }
   elsif (! open (FILE, $filePath) )
   {
      $msg = "ERROR (readFileIntoArray): Unable to open file ($filePath): $!\n";
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

         #Format must be: (1) Application Name (2) Environment (3) INTUIT CNAME (4) INTUIT WIP (5) DI CNAME (6) DI WIP (7) On Hold (8) USED BY WLV FSG (9) Migrated
         @count = $line =~ /\t/g;
         $stringCount = @count;
         if ($stringCount != 8)
         {
            $msg = "ERROR (readFileIntoArray): File format error (line $lineNumber): Expected 8 tab delimiters, instead got $stringCount. $line\n";
            close (FILE);
            return ('ERROR', $msg);
         }

         #Add record to array
         push (@$arrayRef, $line);
      }
   }
   close (FILE);

   #Check for empty hash
   if (@$arrayRef == 0)
   {
      $msg = "ERROR (readFileIntoArray): Zero network tests are enabled in file.\n";
      return ('ERROR', $msg);
   }

   return ('OK', $msg);
}
