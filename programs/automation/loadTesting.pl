#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##  loadTesting.pl - Load program that load-tests application products using  ##
##                   test cases stored in an Oracle IA database.              ##
##                                                                            ##
##                 Created by: David Schwab                                   ##
##                 Last updated: DS - 04/01/2012 Ver. 1.54                    ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
use Time::HiRes 'time','sleep';
use IO::Pipe;
use POSIX ':sys_wait_h';
use lib '../../qa_lib';
use GLOBAL_lib;
use AUTO_lib;
use CARD_lib;
use CBS2_lib;
use DIIS_lib;
use FSG_lib;
use OFX_lib;
use PRADMIN_lib;
use QOL_lib;
use HTTP_lib;
use RDB_lib;
use SRT_lib;
system('clear');






##################################
#DECLARE VARIABLES
##################################
my @configArray         = ();
my $parameter1          = '';
my $versionNumber       = '';
my $status              = '';
my $errMsg              = '';
my %allTCHash           = ();
my %allERHash           = ();
my %parentTCList        = ();
my $displayString       = '';
my $testCaseId          = '';
my $stepId              = '';
my %statHash            = ();
my $lastStatPrint       = 0;
my $testCasesRunMsg     = '';



##################################
#SPLIT APP ARGS AND CONFIG ARGS
##################################
GLOBAL_lib::splitConfigArgs(\@ARGV, \@configArray);



##################################
#INITIALIZE VARIABLES
##################################
$parameter1          = ($ARGV[0] || '');
$versionNumber       = '1.54';




##################################
# GET CONFIGURABLE VARIABLES
##################################
my $server              = GLOBAL_lib::getAppConfigValue('server', 'loadTesting.cfg', \@configArray);
my $concurrentRequests  = GLOBAL_lib::getAppConfigValue('concurrentRequests', 'loadTesting.cfg', \@configArray);
my $runDuration         = GLOBAL_lib::getAppConfigValue('runDuration', 'loadTesting.cfg', \@configArray);
my $randomize           = GLOBAL_lib::getAppConfigValue('randomize', 'loadTesting.cfg', \@configArray);
my $refreshStats        = GLOBAL_lib::getAppConfigValue('refreshStats', 'loadTesting.cfg', \@configArray);
my $statLog             = GLOBAL_lib::getAppConfigValue('statLog', 'loadTesting.cfg', \@configArray);
my $clientDetail        = GLOBAL_lib::getAppConfigValue('clientDetail', 'loadTesting.cfg', \@configArray);
my $reqResLog           = GLOBAL_lib::getAppConfigValue('reqResLog', 'loadTesting.cfg', \@configArray);
my $validateAssertion   = GLOBAL_lib::getAppConfigValue('validateAssertion', 'loadTesting.cfg', \@configArray);
my $logAssertionFailure = GLOBAL_lib::getAppConfigValue('logAssertionFailure', 'loadTesting.cfg', \@configArray);
my $testCaseFilter      = GLOBAL_lib::getAppConfigValue('testCaseFilter', 'loadTesting.cfg', \@configArray);
my $envType = GLOBAL_lib::getAppConfigValue('envType', 'env.cfg', \@configArray);



##################################
#Subroutine Prototype
##################################
sub executeTCStep($$$$$$$$$);
sub printStats($$$$);
sub interuptSub;



##################################
#Override CTRL+C
##################################
$SIG{'INT'} = 'interuptSub';



##################################
#Turn auto flush on
##################################
$| = 1;



################################################################################
#Usage
################################################################################
if($parameter1 eq '')
{
   my $usage = "****************************************************************************************************\n" .
               "                                        IATF Load Testing Ver $versionNumber\n" .
               "\n" .
               "              This program makes use of the Infrastructure Automation Framework (IATF) to execute\n" .
               "              load tests stored in a central Oracle IATF database.\n" .
               "\n" .
               "****************************************************************************************************\n\n\n" .
               '   USAGE:  $ ./loadTesting.pl PARAM1 [-CFG_KEY CFG_VAL]' . "\n\n" .
               '   PARAM1 - Required. Valid PARAM1 values are:' . "\n\n" .
               '           g[et] - GET a list of all active test cases filtered under the "testCaseFilter" config.' . "\n" .
               '           a[ll] - load ALL active test cases filtered under the "testCaseFilter" config.' . "\n" .
               '      testCaseId - load  a SINGLE test case identified by the test case id value.' . "\n\n" .
               '   -CFG_KEY CFG_VAL - Optional.  Any number of configuration overrides.' . "\n\n" .
               "****************************************************************************************************\n\n\n";

   print $usage;
   exit 0;
}
################################################################################
#Get List Of Test Cases
################################################################################
elsif( (lc($parameter1) eq 'g') || (lc($parameter1) eq 'get') )
{
   my %tcListHash   = ();
   my $tcListReport = '';

   #Get Test Case Info
   ($status, $errMsg) = AUTO_lib::getTestCaseListInfo(\%tcListHash, $testCaseFilter);
   if ($status ne 'OK')
   {
      print "$errMsg\n";
      exit 1;
   }

   #Generate Report
   $tcListReport = AUTO_lib::genTestCaseReport(\%tcListHash);

   #Print Report to Screen and Exit
   print $tcListReport;
   exit 0;
}
################################################################################
#Load All Test Cases
################################################################################
elsif( (lc($parameter1) eq 'a') || (lc($parameter1) eq 'all') )
{
   ################################################################################
   #Get List of ALL Test Case IDs within $testCaseFilter
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getTestCaseID($testCaseFilter, \%parentTCList);
   if ($status ne 'OK')
   {
      print "Error retrieving test cases from database under Test Case Filter: $testCaseFilter\n\n";
      print "$errMsg\n\n";
      exit 1;
   }

   $testCasesRunMsg = "Running all test cases under: $testCaseFilter";
}
################################################################################
#Load Single Test Case
################################################################################
else
{
   ################################################################################
   #Load Single Test Case ID
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getSingleTestCaseID(\%parentTCList, $parameter1);
   if ($status ne 'OK')
   {
      print "Error retrieving single Test Case ID from database: $parameter1\n\n";
      print "$errMsg\n\n";
      exit 1;
   }

   $testCasesRunMsg = "Running single test case: $parameter1";
}




################################################################################
################################################################################
##                                                                            ##
##                          START OF LOAD TESTING                             ##
##                                                                            ##
################################################################################
################################################################################


################################################################################
#Check for and archive any existing log files
################################################################################
($status, $errMsg) = AUTO_lib::archiveLog('loadReqRes');
if ($status ne 'OK')
{
   print "$errMsg\n\n";
   exit 1;
}
($status, $errMsg) = AUTO_lib::archiveLog('loadStat');
if ($status ne 'OK')
{
   print "$errMsg\n\n";
   exit 1;
}


################################################################################
#Create $runFilePath
################################################################################
my $runFilePath = "../../logs/.autoLoadRunning_$$";
if (! open(FILE, ">$runFilePath") )
{
   print "ERROR: Unable to create $runFilePath. $!\n";
   exit 1;
}
else
{
   close(FILE);
}


################################################################################
#Log & Print Screen Msg
################################################################################
$displayString = "\n****************************************************************************************************\n" .
                    "                                        IATF Load Testing Ver $versionNumber\n" .
                    "****************************************************************************************************\n" .
                    "Initializing load data from database...";
if ($statLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $displayString);
}
print $displayString;



################################################################################
#Write Request Response Log Header
################################################################################
if ($reqResLog > 0)
{
   $displayString = "\n****************************************************************************************************\n" .
                    "                                        IATF Request Response Log\n" .
                    "****************************************************************************************************\n";
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadReqRes', $displayString);
}


################################################################################
#Get All Test Cases from IA Database
################################################################################
($status, $errMsg) = AUTO_lib::getAllTestCases(\%allTCHash, \%parentTCList);
($status) = AUTO_lib::remapAllTestCaseReq(\%allTCHash);
($status) = AUTO_lib::staticSearchReplace4DHash(\%allTCHash, $envType);

################################################################################
#Get All Expected Results from IA Database
################################################################################
($status, $errMsg) = AUTO_lib::getAllExpectedResults(\%allERHash, \%parentTCList);
($status, $errMsg) = AUTO_lib::remapAllExpResultsRes(\%allERHash, \%allTCHash);
if ($status ne 'OK') { print "$errMsg\n\n"; exit 1; }
($status) = AUTO_lib::staticSearchReplace5DHash(\%allERHash, $envType);




################################################################################
#Log & Print Screen Msg
################################################################################
$displayString = "Done.\n";
if ($statLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $displayString);
}
print $displayString;


################################################################################
#Log & Print Screen Msg
################################################################################
my $testCaseCount = keys %parentTCList;
$displayString = "Total count of test cases to run: $testCaseCount\n" .
                 "$testCasesRunMsg\n" .
                 "Number of concurrent requests: $concurrentRequests\n" .
                 "Beginning run of load tests at: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n" .
                 "TO STOP LOAD TEST PRESS: CTRL+C\n" .
                 "****************************************************************************************************\n" .
                 "                                        Load Testing Results\n" .
                 "****************************************************************************************************\n";
if ($statLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $displayString);
}
print $displayString;


####################################################################################################
#Set Load Test Start Time 
####################################################################################################
my $loadTestStartTime = time;


####################################################################################################
#   Begin Multi-processing
####################################################################################################

#############################################################
#Open a pipe so that child processes can send results to parent
#############################################################
my $pipe = IO::Pipe->new || die "ERROR(loadTesting.pl): Unable to open pipe: $!";

####################################################################################################
#Fork process for each virtual user
####################################################################################################
for (my $i = 1; $i <= $concurrentRequests; $i++)
{
   #Split the program into two processes: Parent and Child
   die "ERROR(loadTesting.pl): Unable to Fork: $!" unless defined(my $kidpid = fork());

   #This is the Parent process block
   if ($kidpid)
   {
      #Nothing to do
   }
   #This is the Child process block
   else
   {
      $pipe->writer;
      select $pipe;
      $| = 1;

      #Keep sending requests until user selects CTRL+C
      while (-e $runFilePath)
      {
         #####################################
         #Send requests in random order
         #####################################
         if ($randomize == 1)
         {
            #TODO - finish the randomize logic here...
            #$status = executeTCStep($i, $testCaseId, $stepId, \%allTCHash, \%allERHash, $reqResLog, $validateAssertion, $logAssertionFailure, $envType);
         }
         #####################################
         #Send requests in sequential order
         #####################################
         else
         {
            #TEST_CASE_ID LOOP
            for $testCaseId (sort keys (%parentTCList))
            {
               #STEP_ID LOOP
               for $stepId (sort {$a <=> $b} keys %{$allTCHash{$testCaseId}})
               {
                  #Keep sending requests until user selects CTRL+C
                  if (-e $runFilePath)
                  {
                     $status = executeTCStep($i, $testCaseId, $stepId, \%allTCHash, \%allERHash, $reqResLog, $validateAssertion, $logAssertionFailure, $envType);
                  }
                  else
                  {
                     exit 0;
                  }
               }
            }
         }
      }

      exit 0;
   }
}


#############################################################
#Wait for all children to complete
#############################################################
do {} while ( waitpid(-1, WNOHANG) > 0 );


#############################################################
#Parent reads all of the children results
#############################################################
my $cClientId     = 0;
my $cResponseTime = 0;
my $cBytes        = 0;
my $cAssertion    = '';
my $sRequestCount = 0;
my $sClientId     = 0;
my $sResponseTime = 0;
my $sBytes        = 0;
my $sPeakResTime  = 0;

$pipe->reader;
$| = 1;
while (<$pipe>)
{
   chomp;
   ($cClientId, $cResponseTime, $cBytes, $cAssertion) = split("\t");

   #Tally Stats
   $sRequestCount++;
   $sResponseTime += $cResponseTime;
   $sBytes += $cBytes;
   if ($cResponseTime > $sPeakResTime)
   {
      $sPeakResTime = $cResponseTime;
   }

   #Update Stats Hash
   $statHash{'TOTAL_COUNT'}                   = $sRequestCount;
   $statHash{'TOTAL_RES_TIME'}                = $sResponseTime;
   $statHash{'TOTAL_BYTES'}                   = $sBytes;
   $statHash{'PEAK_RES_TIME'}                 = $sPeakResTime;
   $statHash{'CLIENT_REQ_COUNT'}{$cClientId} += 1;
   if ($cAssertion ne '')
   {
      $statHash{'ASSERTION'}{$cAssertion}    += 1;
   }

   #Print Stats to Screen 
   ($status) = printStats(\%statHash, $refreshStats, $statLog, $clientDetail);

   #Check if $runDuration is over
   if ($runDuration > 0)
   {
      if ( ((time - $loadTestStartTime) > ($runDuration * 60)) )
      {
         unlink($runFilePath);
      }
   }
}
####################################################################################################
#  End of Multi-processing
####################################################################################################













#########################################
#Load Testing Complete
#########################################
$displayString = "****************************************************************************************************\n" .
                 "                                        End of Results\n" .
                 "****************************************************************************************************\n" .
                 "Completed Load Tests at: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n" .
                 "Run Duration: " . substr(AUTO_lib::timeDiff($loadTestStartTime, time), 0, 8) . "\n\n\n";
if ($statLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $displayString);
}
print $displayString;


#########################################
#Write out ending TIMESTAMP_TAG to logs
#########################################
if ($statLog > 0)
{
   $displayString = "<TIMESTAMP_TAG>" . GLOBAL_lib::dynamicDate('0, "%Y-%m-%d_%H%M%S"') . "</TIMESTAMP_TAG>";
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $displayString);
}
if ($reqResLog > 0)
{
   $displayString = "<TIMESTAMP_TAG>" . GLOBAL_lib::dynamicDate('0, "%Y-%m-%d_%H%M%S"') . "</TIMESTAMP_TAG>";
   ($status, $errMsg) = AUTO_lib::writeAutoLog('loadReqRes', $displayString);
}
################################################################################
################################################################################
##                                                                            ##
##                        END OF LOAD TESTING                                 ##
##                                                                            ##
################################################################################
################################################################################






################################################################################
#                         All Subroutines Below                                #
################################################################################

################################################################################
#
# executeTestCases subroutine -
#
#
################################################################################
sub executeTCStep($$$$$$$$)
{
   my $clientId            = $_[0];
   my $testCaseId          = $_[1];
   my $stepId              = $_[2];
   my $allTCHashRef        = $_[3];
   my $allERHashRef        = $_[4];
   my $reqResLog           = $_[5];
   my $validateAssertion   = $_[6];
   my $logAssertionFailure = $_[7];
   my $envType             = $_[8];


   my $status             = '';
   my $errMsg             = '';
   my %testCaseActionHash = ();
   my %stepActionHash     = ();
   my %testCaseExpResHash = ();
   my %stepExpResHash     = ();
   my %stepActResHash     = ();
   my $httpRC             = '';
   my $rawRequest         = '';
   my $rawResponse        = '';
   my $brkReqHeader       = '';
   my $brkResHeader       = '';
   my $screenDisplay      = 1;
   my $startTime          = time;
   my $reqTime            = 0;
   my $resTime            = 0;
   my $statElapsedTime    = 0;
   my $statBytes          = 0;
   my $statAssertion      = '';
   my $logString          = '';
   my $httpResHeader      = '';


   #############################################################################
   #Retrieve Test Case Data for $testCaseId
   #############################################################################
   %testCaseActionHash = ();
   ($status, $errMsg) = AUTO_lib::getTestCase(\%testCaseActionHash, $testCaseId, $allTCHashRef);
   AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, $errMsg);

   ################################################################################
   #Retrieve Expected Results Data for $testCaseId
   ################################################################################
   %testCaseExpResHash = ();
   ($status, $errMsg) = AUTO_lib::getExpectedResults(\%testCaseExpResHash, $testCaseId, $allERHashRef);
   AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, $errMsg);

   ##########################################################################
   #Extract Step Action for $stepId
   ##########################################################################
   %stepActionHash = ();
   ($status, $errMsg) = AUTO_lib::extractStepAction(\%stepActionHash, \%testCaseActionHash, $stepId);
   AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, $errMsg);


   ##########################################################################
   #Set Load Server value within %stepActionHash
   ##########################################################################
   if ( (! defined($stepActionHash{'SERVER'}) || $stepActionHash{'SERVER'} eq '') )
   {
      #Server not specified - use default
      $stepActionHash{'SERVER'} = $server;
   }


   ##########################################################################
   # Get Step Action, Step Function, Step Value, and Validate Step
   #    Example:
   #          $stepAction   = atiCBS(addRecurringBillPayment)
   #          $stepFunction = atiCBS
   #          $stepValue    = addRecurringBillPayment
   ##########################################################################
   my $stepActive   = uc($stepActionHash{'STEP_ACTIVE'});
   my $stepAction   = $stepActionHash{'STEP_ACTION'};
   my $validateStep = $stepActionHash{'VALIDATE_STEP'};
   ($status, $errMsg, my $stepFunction, my $stepValue) = AUTO_lib::getStepFuncValue(\%stepActionHash);
   AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, $errMsg);


         ##########################################################################
         #STEP IS ACTIVE - EXECUTE STEP
         ##########################################################################
         if ( $stepActive ne 'N' )
         {
            ##########################################################################
            #STEP ACTION FOR CBS2 APPLICATION TESTING INTERFACE
            ##########################################################################
            if ($stepFunction eq 'aticbs2')
            {
               $reqTime = time;
               #Send action data to CBS2 ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CBS2_lib::cbs2ATI($stepValue, \%stepActionHash, $envType);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR CARDLYTICS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'aticard')
            {
               $reqTime = time;
               #Send action data to CARD ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CARD_lib::cardATI($stepValue, \%stepActionHash, $envType);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR PRADMIN APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atipradmin')
            {
               $reqTime = time;
               #Send action data to CARD ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = PRADMIN_lib::pradminATI($stepValue, \%stepActionHash, $envType);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR FSG APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atifsg')
            {
               $reqTime = time;
               #Send action data to CARD ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = FSG_lib::fsgATI($stepValue, \%stepActionHash, $envType);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR HTTP APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atihttp')
            {
               $reqTime = time;
               #Send action data to HTTP ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = HTTP_lib::httpATI(\%stepActionHash, $envType);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR OFX APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiofx')
            {
               $reqTime = time;
               #Send action data to OFX XML ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = OFX_lib::ofxXmlAPI($stepValue, \%stepActionHash, $envType);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR SRT APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atisrt')
            {
               $reqTime = time;
               #Send action data to SRT ATI and get response
               ($status, $rawRequest, $rawResponse, $brkReqHeader, $brkResHeader) = SRT_lib::srtATI($stepValue, \%stepActionHash);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse) + length($brkReqHeader) + length($brkResHeader);
            }
            ##########################################################################
            #STEP ACTION FOR DIIS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atidiis')
            {
               $reqTime = time;
               #Send action data to DIIS ATI and get response
               ($status, $rawRequest, $rawResponse, $brkReqHeader, $brkResHeader) = DIIS_lib::diisReqATI($stepValue, \%stepActionHash);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse) + length($brkReqHeader) + length($brkResHeader);
            }
            ##########################################################################
            #STEP ACTION FOR RDB APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atirdb')
            {
               $reqTime = time;
               #Send action data to RDB ATI and get response
               ($status, $rawRequest, $rawResponse, $brkReqHeader, $brkResHeader) = RDB_lib::rdbReqATI(\%stepActionHash);
               $resTime = time;

               $statBytes = length($rawRequest) + length($rawResponse) + length($brkReqHeader) + length($brkResHeader);
            }
            ##########################################################################
            #STEP ACTION FOR QOL APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiqol')
            {
               $reqTime = time;
               #Send action data to QOL ATI and get response
               ($httpRC, my $issoReq, my $issoRes, $rawRequest, $rawResponse) = QOL_lib::qolATI($stepValue, \%stepActionHash, \%stepActResHash);
               $resTime = time;

               $statBytes = length($issoReq) + length($issoRes) + length($rawRequest) + length($rawResponse);
            }
            ##########################################################################
            #STEP ACTION FOR WAIT
            ##########################################################################
            elsif ($stepFunction eq 'wait')
            {
               $reqTime = time;
               ($status, $errMsg) = AUTO_lib::waitSeconds($stepValue);
               $resTime = time;
            }
            ##########################################################################
            #STEP ACTION FOR SYSTEM CALLS
            ##########################################################################
            elsif ($stepFunction eq 'system')
            {
               $reqTime = time;
               ($status, $errMsg) = AUTO_lib::sysCmd($stepValue);
               $resTime = time;
               AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, "ERROR: Unexpected response from sysCmd() function. See Logs for more detail.");
            }
            ##########################################################################
            #UNKNOWN STEP ACTION
            ##########################################################################
            else
            {
               $errMsg = "ERROR: Undefined Step Function specified from Step Action: $stepFunction";
               AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, $errMsg);
            }


            ##########################################################################
            #Validate Assertion Check
            ##########################################################################
            if ( (lc($validateAssertion) eq 'true') && (lc($validateStep) eq 'y')  )
            {
               ################################################################################
               #Extract Step Expected Results from %testCaseExpResHash
               ################################################################################
               %stepExpResHash = ();
               ($status, $errMsg) = AUTO_lib::extractStepExpResult(\%stepExpResHash, \%testCaseExpResHash, $stepId);

               #######################################################################
               #Do Basic Regex Validation
               #######################################################################
               if ( defined $stepExpResHash{1}{'REGEX_VALIDATION'} )
               {
                  #Perform RegEx Validation
                  ($status, $statAssertion) = AUTO_lib::regExValidation($httpRC, $httpResHeader, $brkResHeader, $rawResponse, \%stepActResHash, \%stepExpResHash);

                  if ( $statAssertion ne 'PASSED'  )
                  {
                     #loadTesting.pl requires $statAssertion to be 'PASSED' or 'FAILED'
                     $statAssertion = 'FAILED';

                     #Log Failure if $logAssertionFailure set
                     if ( lc($logAssertionFailure) eq 'true' )
                     {
                        $logString = "ASSERTION FAILURE:\n" .
                                     "Client [$clientId] Response:\n\n\n$rawResponse\n" .
                                     "------------------------------------------------------------\n\n\n";
                        ($status, $errMsg) = AUTO_lib::writeAutoLog('loadReqRes', $logString);
                     }
                  }
               }
            }
         }

         ###########################################
         #Write out request/response logs
         ###########################################
         if ($reqResLog > 0)
         {
            #Log Request Only
            if ($reqResLog == 1)
            {
               $logString = "Client [$clientId] Request:\n\n\n$rawRequest\n" .
                            "------------------------------------------------------------\n\n\n";
               ($status, $errMsg) = AUTO_lib::writeAutoLog('loadReqRes', $logString);
            }
            #Log Response Only
            elsif ($reqResLog == 2)
            {
               $logString = "Client [$clientId] Response:\n\n\n$rawResponse\n" .
                            "------------------------------------------------------------\n\n\n";
               ($status, $errMsg) = AUTO_lib::writeAutoLog('loadReqRes', $logString);
            }
            #Log both Request and Response
            elsif ($reqResLog == 3)
            {
               $logString = "Client [$clientId] Request:\n\n\n$rawRequest\n\n\n" .
                            "Client [$clientId] Response:\n\n\n$rawResponse\n" .
                            "------------------------------------------------------------\n\n\n";
               ($status, $errMsg) = AUTO_lib::writeAutoLog('loadReqRes', $logString);
            }
         }


         ###########################################
         #Write result back to Parent
         ###########################################
         $statElapsedTime = $resTime - $reqTime;
         $| = 1;
         print "$clientId\t$statElapsedTime\t$statBytes\t$statAssertion\n";


   return ('OK');
}


################################################################################
#
# printStats subroutine -
#
#
################################################################################
sub printStats($$$$)
{
   my $statsHashRef = $_[0];
   my $refreshStats = $_[1];
   my $statLog      = $_[2];
   my $clientDetail = $_[3];

   my $avgResTime   = 0;
   my $peakResTime  = 0;
   my $concurrancy  = 0;
   my $throughput   = 0;
   my $totalBytes   = 0;
   my $totalResTime = 0;
   my $totalNumReq  = 0;
   my $elapsedTime  = '';
   my $printString  = '';
   my $detailString = '';


   if ($lastStatPrint == 0)
   {
      $lastStatPrint = time;
   }
   else
   {
      if ( (time - $lastStatPrint) > $refreshStats )
      {
         #Calculate stats
         $totalNumReq = $statsHashRef->{'TOTAL_COUNT'};
         $totalResTime = $statsHashRef->{'TOTAL_RES_TIME'};
         $totalBytes = $statsHashRef->{'TOTAL_BYTES'};
         $throughput = $totalBytes / (time - $loadTestStartTime);
         $peakResTime = $statsHashRef->{'PEAK_RES_TIME'};
         $avgResTime = $totalResTime / $totalNumReq;
         $concurrancy = ( ($totalNumReq / (time - $loadTestStartTime)) * $avgResTime );
         $elapsedTime = substr(AUTO_lib::timeDiff($loadTestStartTime, time), 0, 8);


         $printString = "        Average Response Time: "  . (' ' x (40 - 31)) . sprintf("%3.3f", $avgResTime) . " sec\n" .
                        "           Peak Response Time: "  . (' ' x (40 - 31)) . sprintf("%3.3f", $peakResTime) . " sec\n" .
                        "                  Concurrancy: "  . (' ' x (40 - 31)) . sprintf("%3.1f", $concurrancy) . " \n" .
                        "                   Throughput: "  . (' ' x (40 - 31)) . sprintf("%3.0f", $throughput) .  " bytes/sec\n" .
                        "    Total Bytes Sent/Received: "  . (' ' x (40 - 31)) . "$totalBytes bytes\n" .
                        "Total Number of Requests Sent: "  . (' ' x (40 - 31)) . "$totalNumReq\n" .
                        "                 Elapsed Time: "  . (' ' x (40 - 31)) . "$elapsedTime\n";

         #Assertion Results
         if (exists $statsHashRef->{'ASSERTION'})
         {
            #Print out Assertion Results
            for my $assertionKey (sort keys %{$statsHashRef->{'ASSERTION'}})
            {
               $printString .=  (' ' x (30 - length("Assertion $assertionKey:"))) .
                                "Assertion $assertionKey:          $statsHashRef->{'ASSERTION'}{$assertionKey}\n";
            }
         }

         #Client Detail
         if ($clientDetail > 0)
         {
            $detailString = "\nClient Detail - Number of Requests by Client:\n";

            #Print out number of requests by client
            for my $clientIdKey (sort {$a <=> $b} keys %{$statsHashRef->{'CLIENT_REQ_COUNT'}})
            {
               $detailString .= (' ' x (30 - length("Client Count [$clientIdKey]:"))) .
                                "Client Count [$clientIdKey]:          $statsHashRef->{'CLIENT_REQ_COUNT'}{$clientIdKey}\n";
            }
         }

         #Print out stat report to screen
         print "\033[14;0H";
         print $printString;

         #Write out stat report to log
         if ($statLog == 1)
         {
            ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $printString);
            if ($clientDetail > 0)
            {
               ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', $detailString);
            }
            ($status, $errMsg) = AUTO_lib::writeAutoLog('loadStat', "-----------------------------------------------------------------------\n");
         }

         #Reset Flag
         $lastStatPrint = 0;
      }
   }

   return ('OK');
}




################################################################################
#
# interuptSub subroutine -
#
#
################################################################################
sub interuptSub()
{
   unlink($runFilePath); 
}
################################################################################
#                         End of All Subroutines                               #
################################################################################
