#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##  sgpInTests.pl - Tests to help validate Services Gateway Proxy.            ##
##                                                                            ##
##                  Created by: David Schwab                                  ##
##                  Last Updated: DS - 11/20/2012 Ver. 1.2                    ##
##                                                                            ##
################################################################################
################################################################################
use strict;
system('clear');




################################################################################
#Set Configurations Below
################################################################################

#################################################
# Environment Type Options:                     #
#                                               #
# QA          = qal                             #
# Performance = prf                             #
# Production  = prd                             #
#################################################
my $envName           = 'prd';

#################################################
# Path to file with FI ID list
#################################################
my $fileNamePath      = './prodFiIdList.txt';

#################################################
# Set $intuit_tid
#################################################
my $intuit_tid        = 'fc86db2a-7b62-4ffb-a26a-1b5fd7872037';

#################################################
# Set $intuit_offeringId
#################################################
my $intuit_offeringId = 'SGPTEST00001';

#################################################
# Set $writeLogWithFailureDetail
#################################################
my $writeLogWithFailureDetail = 'true';

#################################################
# Set $debugLogging
#################################################
our $debugLogging = 'false';

################################################################################
#End of Configurations
################################################################################



#################################################
#Subroutine Prototype
#################################################
sub parseCNameSwimLaneInfo($$);
sub readFileIntoHash($$);
sub runCBSTest_getFinancialInstitutionV2($$$$$$);
sub runCASTest_getFIEffectiveBrandV2($$$$$$);
sub runCNameTest($$$);
sub processResult($$$$$$$);
sub printResults($$$);


#################################################
#Define Variables
#################################################
my $version             = '1.1';
my $parameter1          = (lc($ARGV[0]) || '');
my $parameter2          = ($ARGV[1] || '');
my $status              = '';
my $msg                 = '';
my %allowedArgHash      = ();
my %fiIdHash            = ();
my %testResultsHash     = ();
my $fiIdCount           = 0;
my $cbsFiIdPrefix       = 'DI';
my $nonCbsFiIdPrefix    = '0';
my $totalFiCount        = 0;
my %sgpEnvUrl           = ();
my $argKey              = '';
my $fiIdKey             = '';
my %authorizationEnv    = ();
my $testId              = '';
my $expectedResult      = '';
my $response            = '';



#################################################
#Set Allowed PARAM1 Commands
#################################################
$allowedArgHash{'1'}    = 'getFinancialInstitutionV2 (CBS) API Test with FI ID';
$allowedArgHash{'2'}    = 'getFIEffectiveBrandV2 (CAS) API Test with FI ID';
$allowedArgHash{'3'}    = 'CName Test';
$allowedArgHash{'a'}    = 'ALL Tests';



#################################################
#Set SGP Environment URLs
#################################################
$sgpEnvUrl{'qal'}       = 'http://services-qal.banking.intuit.net';
$sgpEnvUrl{'prf'}       = 'http://services-prf.banking.intuit.net';
$sgpEnvUrl{'prd'}       = 'http://services.banking.intuit.net';


#################################################
#Set Authorization Environment Keys
#################################################
$authorizationEnv{'SDP'}{'qal'}                  = '33737ecd8d64d24b226cc09a9ccfd33';
$authorizationEnv{'AdminPlatform'}{'qal'}        = 'c1ae7aed44054565800fb9356040867f';
$authorizationEnv{'SDP'}{'prf'}                  = '33737ecd8d64d24b226cc09a9ccfd33';
$authorizationEnv{'AdminPlatform'}{'prf'}        = 'c1ae7aed44054565800fb9356040867f';
$authorizationEnv{'SDP'}{'prd'}                  = 'bc1f2337a8864b61a6c37f2597c38e1c';
$authorizationEnv{'AdminPlatform'}{'prd'}        = 'edd868fe08b244f4bb4dffd0a00a8fc0';





################################################################################
#Start Program
################################################################################

#Check usage
if (! exists($allowedArgHash{$parameter1}) )
{
   $msg =  "****************************************************************************************************\n" .
           "                            Services Gateway Proxy Internal Tests Ver. $version\n" .
           "\n" .
           "                            Tests to help validate Services Gateway Proxy.\n" .
           "****************************************************************************************************\n\n\n" .
           '   USAGE:  $ ./sgpInTests.pl PARAM1 [fileNamePath]' . "\n\n" .
           '         PARAM1  -  Required.  Valid PARAM1 values are:' . "\n\n";

           for $argKey (sort keys %allowedArgHash)
           {
              $msg .= "             $argKey   = $allowedArgHash{$argKey}\n";
           }

   $msg .= "\n  fileNamePath   - Optional.  Overrides \$fileNamePath.\n\n" .
           "****************************************************************************************************\n\n\n";


   print $msg;
   exit 0;
}

#Set override for $fileNamePath
if ($parameter2 ne '')
{
   $fileNamePath = $parameter2;
}

#Open $fileNamePath and read into %fiIdHash
($status, $response) = readFileIntoHash($fileNamePath, \%fiIdHash);
if ($status ne 'OK')
{
   print $response;
   exit 1;
}

#Turn auto flush on
$| = 1;

#Print message that tests are running
print "Running: \"$allowedArgHash{$parameter1}\" (option $parameter1)...";

#Loop through hash and execute specified tests
for $fiIdKey (sort keys %fiIdHash)
{
   #Increment $fiIdCount
   $fiIdCount++;

   #############################################################################
   #Test 1 - CBS API Test with FI ID.
   #############################################################################
   if ( ($parameter1 eq '1') || ($parameter1 eq 'a') )
   {
      #Set test values
      $testId         = '1';
      $expectedResult = "\> \r\n\< HTTP\/1\.1 200 OK\r\n";

      #Execute Test
      ($status, $response) = runCBSTest_getFinancialInstitutionV2($cbsFiIdPrefix . $fiIdKey, $sgpEnvUrl{$envName}, $authorizationEnv{'SDP'}{$envName}, $intuit_tid, $intuit_offeringId, $expectedResult);

      #Process Test Result
      processResult(\%testResultsHash, $testId, $fiIdKey, $status, $expectedResult, $response, $writeLogWithFailureDetail);
   }

   #############################################################################
   #Test 2 - CAS API Test with FI ID.
   #############################################################################
   if ( ($parameter1 eq '2') || ($parameter1 eq 'a') )
   {
      #Set test values
      $testId         = '2';
      $expectedResult = "\> \r\n\< HTTP\/1\.1 200 OK\r\n";

      #Execute Test
      ($status, $response) = runCASTest_getFIEffectiveBrandV2($nonCbsFiIdPrefix . $fiIdKey, $sgpEnvUrl{$envName}, $authorizationEnv{'AdminPlatform'}{$envName}, $intuit_tid, $intuit_offeringId, $expectedResult);

      #Process Test Result
      processResult(\%testResultsHash, $testId, $fiIdKey, $status, $expectedResult, $response, $writeLogWithFailureDetail);
   }

   #############################################################################
   #Test 3 - CName Test.
   #############################################################################
   if ( ($parameter1 eq '3') || ($parameter1 eq 'a') )
   {
      #Set test values
      $testId         = '3';
      $expectedResult = $fiIdHash{$fiIdKey}{'swim_lane'};

      #Execute Test
      ($status, $response) = runCNameTest($nonCbsFiIdPrefix . $fiIdKey, $envName, $expectedResult);

      #Process Test Result
      processResult(\%testResultsHash, $testId, $fiIdKey, $status, $expectedResult, $response, $writeLogWithFailureDetail);
   }
}


#Print message that tests are running
print "Completed.\n";

#Print out test results
printResults(\%testResultsHash, $fiIdCount, \%allowedArgHash);

################################################################################
#End of Program
################################################################################














################################################################################
#All Subroutines Below
################################################################################

################################################################################
# sub parseCNameSwimLaneInfo
################################################################################
sub parseCNameSwimLaneInfo($$)
{
   my $input        = $_[0];
   my $envName      = $_[1];

   #Declare Variables
   my $errMsg       = '';
   my $startStr     = "Name:\tservices-int-";
   my $endStr       = "-$envName-banking.ilb.intuit.com\n";
   my $parseValue   = '';
   my $pos1         = 0;
   my $pos2         = 0;



   #Locate beginning parse string in $input
   $pos1 = index($input, $startStr);
   if ($pos1 < 1)
   {
      $errMsg = "ERROR (parseCNameSwimLaneInfo): Unable to locate start string value ($startStr) in provided input string ($input).\n";
      return ('ERROR', $errMsg);
   }

   #Locate end parse string in $input
   $pos2 = index($input, $endStr, $pos1 + 1);
   if ($pos2 < 1)
   {
      $errMsg = "ERROR (parseCNameSwimLaneInfo): Unable to locate end string value ($endStr) in provided search string ($input).\n";
      return ('ERROR', $errMsg);
   }


   #Finally parse out value
   $parseValue = substr($input, $pos1 + length($startStr), $pos2 - ($pos1 + length($startStr) ) );


   return ('OK', $parseValue);
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
   my $fiId         = '';
   my $swimLane     = '';


   if (! open (FILE, $filePath) )
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

         #Split values out of file
         ($fiId, $swimLane) = split(',', $_);

         #Add record to hash
         $hashRef->{$fiId}->{'swim_lane'} = $swimLane;
      }
   }
   close (FILE);



   return ('OK', $msg);
}



################################################################################
# sub runCBSTest_getFinancialInstitutionV2
################################################################################
sub runCBSTest_getFinancialInstitutionV2($$$$$$)
{
   my $fiId              = $_[0];
   my $sgpUrl            = $_[1];
   my $authKey           = $_[2];
   my $intuit_tid        = $_[3];
   my $intuit_offeringId = $_[4];
   my $expectedResult    = $_[5];

   #Declare Variables
   my $request      = '';
   my $response     = '';
   my $result       = '';


   #Set $request
   $request = "-H 'Authorization: $authKey' -H 'intuit_offeringId: $intuit_offeringId' -H 'intuit_appId: SDP' -H 'intuit_originatingIp: 1.1.1.1' -H 'intuit_tid: $intuit_tid' $sgpUrl/v2/fis/$fiId";

   #Execute request
   $response = `curl -vN $request 2>&1`;

   if ($debugLogging eq 'true')
   {
      writeLog("\nDEBUG: request: $request\n\n");
      writeLog("\nDEBUG: response: $response\n\n");
   }

   #Validate Response
   if ($response !~ /$expectedResult/)
   {
      #Failed
      $result = 'FAILED';
   }
   else
   {
      #Passed
      $result = 'PASSED';
   }


   return ($result, $response);
}




################################################################################
# sub runCASTest_getFIEffectiveBrandV2
################################################################################
sub runCASTest_getFIEffectiveBrandV2($$$$$$)
{
   my $fiId              = $_[0];
   my $sgpUrl            = $_[1];
   my $authKey           = $_[2];
   my $intuit_tid        = $_[3];
   my $intuit_offeringId = $_[4];
   my $expectedResult    = $_[5];

   #Declare Variables
   my $request      = '';
   my $response     = '';
   my $result       = '';


   #Set $request
   $request = "-H 'Authorization: $authKey' -H 'intuit_offeringId: $intuit_offeringId' -H 'intuit_appId: AdminPlatform' -H 'intuit_originatingIp: 1.1.1.1' -H 'intuit_tid: $intuit_tid' $sgpUrl/v2/fis/$fiId/fiEffectiveBrand";

   #Execute request
   $response = `curl -vN $request 2>&1`;

   if ($debugLogging eq 'true')
   {
      writeLog("\nDEBUG: request: $request\n\n");
      writeLog("\nDEBUG: response: $response\n\n");
   }

   #Validate Response
   if ($response !~ /$expectedResult/)
   {
      #Failed
      $result = 'FAILED';
   }
   else
   {
      #Passed
      $result = 'PASSED';
   }


   return ($result, $response);
}



################################################################################
# sub runCNameTest
################################################################################
sub runCNameTest($$$)
{
   my $fiId              = $_[0];
   my $envName           = $_[1];
   my $expFiSwimLane     = $_[2];

   #Declare Variables
   my $request           = '';
   my $response          = '';
   my $result            = '';
   my $actFiSwimLane     = '';


   #Set $request
   $request = "services-int-$fiId-$envName.banking.intuit.net";

   #Execute request
   $response = `nslookup $request 2>&1`;

   if ($debugLogging eq 'true')
   {
      writeLog("\nDEBUG: request: $request\n\n");
      writeLog("\nDEBUG: response: $response\n\n");
   }

   #Parse out $actFiSwimLane
   ($status, $actFiSwimLane) = parseCNameSwimLaneInfo($response, $envName);

   #Validate Response
   if ($expFiSwimLane ne $actFiSwimLane)
   {
      #Failed
      $result = 'FAILED';
   }
   else
   {
      #Passed
      $result = 'PASSED';
   }


   return ($result, $response);
}




################################################################################
# sub processResult
################################################################################
sub processResult($$$$$$$)
{
   my $testResultsHashRef = $_[0];
   my $testId             = $_[1];
   my $fiIdKey            = $_[2];
   my $status             = $_[3];
   my $expectedResult     = $_[4];
   my $response           = $_[5];
   my $writeLogFailDetail = $_[6];

   my $logLine            = '';


   ######################################################################
   # %testResultsHash has the following data construct:
   #
   # {<test_id>}{'pass_count'}
   # {<test_id>}{'fail_count'}
   # {<test_id>}{'expected_result'}{<fi_id>}
   # {<test_id>}{'actual_result'}{<fi_id>}
   # {<test_id>}{'failed_list_of_fi_ids'}
   #
   ######################################################################


   #Set {<test_id>}{'expected_result'}{<fi_id>}
   $testResultsHashRef->{$testId}->{'expected_result'}->{$fiIdKey} = $expectedResult;

   #Set {<test_id>}{'actual_result'}{<fi_id>}
   $testResultsHashRef->{$testId}->{'actual_result'}->{$fiIdKey} = $response;

   #Print response if failed
   if ($status ne 'PASSED')
   {
      #Increment {<test_id>}{'fail_count'}
      $testResultsHashRef->{$testId}->{'fail_count'} += 1;

      #Update {<test_id>}{'failed_list_of_fi_ids'}
      $testResultsHashRef->{$testId}->{'failed_list_of_fi_ids'} .= "DI$fiIdKey ";

      #Write log failure detail
      if (lc($writeLogFailDetail) eq 'true')
      {
         #Write failure log detail here (sgpInTests.log)
         $logLine  = "##########################################\n";
         $logLine .= "Test $testId for FI ID $fiIdKey FAILED.\n";
         $logLine .= "##########################################\n";
         $logLine .= "   EXPECTED RESULT:\n$expectedResult\n\n";
         $logLine .= "   ACTUAL RESULT:\n$response\n\n\n";
         writeLog($logLine);
      }
   }
   else
   {
      #Increment {<test_id>}{'pass_count'}
      $testResultsHashRef->{$testId}->{'pass_count'} += 1;
   }
}




################################################################################
# sub writeLog
################################################################################
sub writeLog($)
{
   my $line     = $_[0];

   my $errMsg   = '';
   my $logFile  = './sgpInTests.log';

   if(!open(OUT, ">>" . $logFile))
   {
      #Could not open
      $errMsg = "ERROR(writeLog) Unable to open log file: $logFile\n";
      print $errMsg;
      exit 1;
   }
   else
   {
      print OUT $line;
      close(OUT);
   }
}




################################################################################
# sub printResults
################################################################################
sub printResults($$$)
{
   my $testResultsHashRef     = $_[0];
   my $fiIdCount              = $_[1];
   my $testIdHashRef          = $_[2];

   #Declare Variables
   my $testKey                = '';
   my $testPassCount          = 0;
   my $testFailCount          = 0;
   my $listOfFailedFIs        = '';



   print "\n********************************************************************************\n";
   print "*                            Summary Results                                   *\n";
   print "********************************************************************************\n";

   print "Total number of FIs validated: $fiIdCount\n";

   for $testKey (sort keys %$testResultsHashRef)
   {
      #Reset Variables
      $testPassCount   = 0;
      $testFailCount   = 0;
      $listOfFailedFIs = '';

      #Set $testPassCount
      if (exists $testResultsHashRef->{$testKey}{'pass_count'})
      {
         $testPassCount = $testResultsHashRef->{$testKey}{'pass_count'};
      }

      #Set $testFailCount
      if (exists $testResultsHashRef->{$testKey}{'fail_count'})
      {
         $testFailCount = $testResultsHashRef->{$testKey}{'fail_count'};
      }

      #Set $listOfFailedFIs
      if (exists $testResultsHashRef->{$testKey}{'failed_list_of_fi_ids'})
      {
         $listOfFailedFIs = $testResultsHashRef->{$testKey}{'failed_list_of_fi_ids'};
      }

      print "\n********************************************************************************\n";
      print "Results for: Test $testKey - $testIdHashRef->{$testKey}\n";
      print "   Total # FIs that PASSED: $testPassCount\n";
      print "   Total # FIs that FAILED: $testFailCount\n";

      if ($listOfFailedFIs ne '')
      {
         print "   List of FI IDs that failed: $listOfFailedFIs\n";
      }
      print "********************************************************************************\n";
   }

}
