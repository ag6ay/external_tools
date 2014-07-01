#!/usr/bin/perl 
################################################################################
################################################################################
##                                                                            ##
##    automation.pl - Automated functional tesing program that executes test  ##
##                    cases stored in a central Oracle IATF database.         ##
##                                                                            ##
##                    Created by: David Schwab                                ##
##                    Last updated: DS - 05/20/2013 Ver. 5.90                 ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
use English;
use IO::Pipe;
use POSIX ':sys_wait_h';
use POSIX 'strftime';
use lib '../../qa_lib';
use GLOBAL_lib;
use AUTO_lib;
use ABS_lib;
use ABSScheduler_lib;
use AXIS_lib;
use CARD_lib;
use CARD25_lib;
use CBS2_lib;
use DIIS_lib;
use FSG_lib;
use GL_lib;
use MSSQL_lib;
use OFX_lib;
use ORACLE_lib;
use PRADMIN_lib;
use QOL_lib;
use HTTP_lib;
use RDB_lib;
use SRT_lib;
use MAIS_lib;
use CAPS_lib;
use CAS_lib;
use CAPS_Client_lib;
use Data::Dumper;
use ABSHttpSim_lib;
use IPC::SysV qw(IPC_CREAT IPC_RMID);	# Semaphore considerations
system('clear') unless $ENV{AUTOMATION_SUPPRESS_CLEAR};




##################################
#DECLARE VARIABLES
##################################
my @configArray         = ();
my $parameter1          = '';
my $parameter2          = '';
my $startTime           = '';
my $startTimeString     = '';
my $timeDiffSeconds     = 0;
my $runDuration         = '';
my $status              = '';
my $errMsg              = '';
my %allTCHash           = ();
my %allERHash           = ();
my %parentTCList        = ();
my %forkTCList          = ();
my $testResult          = '';
my $totalTestPass       = 0;
my $totalTestFail       = 0;
my $totalTestProtErr    = 0;
my $numClients          = 0;
my $numTCPerClient      = 0;
my $versionNumber       = '';
my $displayLogString    = '';
my $auditLogString      = '';
my $endFlag             = '';
my $screenDisplay       = 0;
my $stepId              = '';
my $testCaseIdList      = '';
my $testCaseIdExclude   = '';
my $testCasesExecuted   = '';
my $emailDetailPlain    = '';
my $emailDetailHtml     = '';
my $emailBodyPlain      = '';
my $emailBodyHtml       = '';
my $basicLogPath        = '';
my $detailLogPath       = '';
my $auditLogPath        = '';
my $appInstanceName     = '';
my $displayLogsInEmail  = '';
my $webBasicLogPath     = '';
my $webDetailLogPath    = '';
my $webAuditLogPath     = '';


# Child process considerations
my $parentPid = 0;
my $child_exit=0;
my $child_exit_count=0;
my $child_sig_count=0;
my $child_proc_header="";
my $donepidcount = 0;
my $childrenLeft = 0;
my %pidHash = ();
my $sem_key = 0;
my $sem_id  = 0;
my $showCallersAtEnd=1;
my $exitReason="UNDEFINED";



##################################
#SPLIT APP ARGS AND CONFIG ARGS
##################################
GLOBAL_lib::splitConfigArgs(\@ARGV, \@configArray);




##################################
#INITIALIZE VARIABLES
##################################
$parameter1          = ($ARGV[0] || '');
$parameter2          = ($ARGV[1] || '');
$versionNumber       = $AUTO_lib::iatfVersion;
$endFlag             = 'FALSE';
$screenDisplay       = 1;




##################################
# GET CONFIGURABLE VARIABLES
##################################
my $server = GLOBAL_lib::getAppConfigValue('server', 'automation.cfg', \@configArray);
my $maxClients = GLOBAL_lib::getAppConfigValue('maxClients', 'automation.cfg', \@configArray);
my $automationLog = GLOBAL_lib::getAppConfigValue('automationLog', 'automation.cfg', \@configArray);
my $minusOneOnFail = GLOBAL_lib::getAppConfigValue('minusOneOnFail', 'automation.cfg', \@configArray);
my $testCaseFilter = GLOBAL_lib::getAppConfigValue('testCaseFilter', 'automation.cfg', \@configArray);
my $envType = GLOBAL_lib::getAppConfigValue('envType', 'env.cfg', \@configArray);
my $sendEmailResults = GLOBAL_lib::getAppConfigValue('sendEmailResults', 'email.cfg', \@configArray);
my $sendOnlyOnFailure = GLOBAL_lib::getAppConfigValue('sendOnlyOnFailure', 'email.cfg', \@configArray);
my $emailFormat = GLOBAL_lib::getAppConfigValue('emailFormat', 'email.cfg', \@configArray);
my $fromEmailAddress = GLOBAL_lib::getAppConfigValue('fromEmailAddress', 'email.cfg', \@configArray);
my $replyEmailAddress = GLOBAL_lib::getAppConfigValue('replyEmailAddress', 'email.cfg', \@configArray);
my $webServerHostname = GLOBAL_lib::getAppConfigValue('webServerHostname', 'webServer.cfg', \@configArray);
my $webServerUsername = GLOBAL_lib::getAppConfigValue('webServerUsername', 'webServer.cfg', \@configArray);
my $webServerBaseDir = GLOBAL_lib::getAppConfigValue('webServerBaseDir', 'webServer.cfg', \@configArray);
my $uploadLogsToWebServer = GLOBAL_lib::getAppConfigValue('uploadLogsToWebServer', 'automation.cfg', \@configArray);
my $EMAIL_LIST_GLOBAL = GLOBAL_lib::getAppConfigValue('EMAIL_LIST_GLOBAL', 'email.cfg', \@configArray);
my $emailRefList = GLOBAL_lib::getAppConfigValue('emailRefList', 'email.cfg', \@configArray);
my $EMAIL_LIST_GROUP = GLOBAL_lib::getAppConfigValue($emailRefList, 'email.cfg', \@configArray);





##################################
#Subroutine Prototype
##################################
sub forkTests($$$$$$);
sub executeTestCases($$$$$$$$);



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
               "                               IATF Automated Functional Testing Ver. $versionNumber\n" .
               "\n" .
               "              This program makes use of the Infrastructure Automation Framework (IATF) to execute\n" .
               "              automated functional test cases stored in a central Oracle IATF database.\n" .
               "\n" .
               "****************************************************************************************************\n\n\n" .
               '   USAGE:  $ ./automation.pl PARAM1 [stepId] [-CFG_KEY CFG_VAL]' . "\n\n\n" .
               '   PARAM1 - Required.  Valid PARAM1 values are:' . "\n\n" .
               '            g[et]    - GET a list of all active test cases filtered under the "testCaseFilter" config.' . "\n" .
               '            a[ll]    - execute ALL active test cases filtered under the "testCaseFilter" config.' . "\n" .
               '        <testCaseId> - execute a SINGLE test case identified by the test case id value.' . "\n" .
               '    <testCaseIdList> - execute a LIST of test case id values as configured in testCaseIdList.cfg.' . "\n" .
               ' <testCaseIdExclude> - execute all active test cases except those configured for EXCLUDE in testCaseIdExclude.cfg.' . "\n" .
               '            r[eport] - generate a summary test case REPORT filtered under the "testCaseFilter" config.' . "\n\n\n" .
               '    stepId - Optional.  Use this to execute a SINGLE step id from a SINGLE test case id. PARAM1 must' . "\n" .
               '                        be a testCaseId.' . "\n\n" .
               '    -CFG_KEY CFG_VAL - Optional.  Any number of configuration overrides.' . "\n\n" .
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

   #Clear $parameter2 (stepId) since this is not valid here
   $parameter2 = '';

   #Get Test Case Info
   ($status, $errMsg) = AUTO_lib::getTestCaseListInfo(\%tcListHash, $testCaseFilter);
   if ($status ne 'OK')
   {
      print $errMsg;
      exit 1;
   }

   #Generate Report
   $tcListReport = AUTO_lib::genTestCaseReport(\%tcListHash);

   #Print Report to Screen and Exit
   print $tcListReport;
   exit 0;
}
################################################################################
#Generate Test Case Report
################################################################################
elsif( (lc($parameter1) eq 'r') || (lc($parameter1) eq 'report') )
{
   my $reportHeader     = '';
   my $detailedTCReport = '';
   my $reportFooter     = '';

   #Clear $parameter2 (stepId) since this is not valid here
   $parameter2 = '';

   #Set $reportHeader
   $reportHeader = "==========================================================================================\n" .
                   "                       IATF Summary Report of Automated Test Cases\n\n" .
                   "                         Test Case Filter(s):   $testCaseFilter\n" .
                   "                         Date Report Generated: " .  GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n\n" .
                   "                    (Please be patient while report is being generated)\n\n" .
                   "==========================================================================================\n\n";

   #Print $reportHeader
   print $reportHeader;

   #Generate Detailed Report
   $detailedTCReport = AUTO_lib::genDetailedTCReport($testCaseFilter, 'plain');

   #Set $reportFooter
   $reportFooter = "\n==========================================================================================\n";

   #Print Detailed Report to Screen and Exit
   print $detailedTCReport;
   print $reportFooter;
   exit 0;
}
################################################################################
#Execute All Automated Test Cases Filtered Under the "testCaseFilter" Config
################################################################################
elsif( (lc($parameter1) eq 'a') || (lc($parameter1) eq 'all') )
{
   #Clear $parameter2 (stepId) since this is not valid here
   $parameter2 = '';

   #Set $testCasesExecuted
   $testCasesExecuted = "ALL filtered under $testCaseFilter";

   ################################################################################
   #Get List of ALL Test Case IDs within $testCaseFilter
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getTestCaseID($testCaseFilter, \%parentTCList);
   if ($status ne 'OK')
   {
      print "Error retrieving test cases from automation database under Test Case Filter: $testCaseFilter\n\n";
      print "$errMsg\n\n";
      exit 1;
   }
}
################################################################################
#Execute a LIST of Defined Automated Test Cases From testCaseIdList.cfg
################################################################################
elsif( substr(lc($parameter1), 0, 5) eq 'list_' )
{
   #Clear $parameter2 (stepId) since this is not valid here
   $parameter2 = '';

   #Set $testCasesExecuted
   $testCasesExecuted = $parameter1;

   ################################################################################
   #Check that $parameter1 matches a LIST configuration from testCaseIdList.cfg
   ################################################################################
   $testCaseIdList = GLOBAL_lib::getAppConfigValue($parameter1, 'testCaseIdList.cfg', \@configArray);
   if (substr($testCaseIdList, 0, 5) eq 'ERROR')
   {
      print "ERROR: Unable to locate '$parameter1' in testCaseIdList.cfg\n";
      exit 1;
   }

   ################################################################################
   #Split comma seperated list of test case ids into %parentTCList
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getTestCaseIDsFromList($testCaseIdList, \%parentTCList);
   if ($status ne 'OK')
   {
      print "Error retrieving test cases from automation database using the following test case id list: $testCaseIdList\n\n";
      print "$errMsg\n\n";
      exit 1;
   }
}
################################################################################
#Execute all active test cases except those configured for EXCLUDE in testCaseIdExclude.cfg
################################################################################
elsif( substr(lc($parameter1), 0, 8) eq 'exclude_' )
{
   #Clear $parameter2 (stepId) since this is not valid here
   $parameter2 = '';

   #Set $testCasesExecuted
   $testCasesExecuted = "ALL filtered under $testCaseFilter except those configured for EXCLUDE in $parameter1.";


   ################################################################################
   #Get List of ALL Test Case IDs within $testCaseFilter
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getTestCaseID($testCaseFilter, \%parentTCList);
   if ($status ne 'OK')
   {
      print "Error retrieving test cases from automation database under Test Case Filter: $testCaseFilter\n\n";
      print "$errMsg\n\n";
      exit 1;
   }

   ################################################################################
   #Check that $parameter1 matches a EXCLUDE configuration from testCaseIdExclude.cfg
   ################################################################################
   $testCaseIdExclude = GLOBAL_lib::getAppConfigValue($parameter1, 'testCaseIdExclude.cfg', \@configArray);
   if (substr($testCaseIdExclude, 0, 5) eq 'ERROR')
   {
      print "ERROR: Unable to locate '$parameter1' in testCaseIdExclude.cfg\n";
      exit 1;
   }

   ################################################################################
   #Delete testCaseIdExclude set from %parentTCList
   ################################################################################
   ($status, $errMsg) = AUTO_lib::deleteTestCaseIDsFromExcludeSet($testCaseIdExclude, \%parentTCList);
   if ($status ne 'OK')
   {
      print "Error deleting the following test case id exclude set: $testCaseIdExclude\n\n";
      print "$errMsg\n\n";
      exit 1;
   }
}
################################################################################
#Execute Single Automated Test Case
################################################################################
else
{
   #Set $testCasesExecuted
   $testCasesExecuted = $parameter1;

   ################################################################################
   #Validate Single Test Case ID
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getSingleTestCaseID(\%parentTCList, $parameter1);
   if ($status ne 'OK')
   {
      print "Error retrieving single Test Case ID from automation database: $parameter1\n\n";
      print "$errMsg\n\n";
      exit 1;
   }

   ################################################################################
   #Validate Single Step ID
   ################################################################################
   if ($parameter2 ne '')
   {
      #Check that $parameter2 is a positive integer
      if ($parameter2 =~ /^\d+$/)
      {
         my $numOfSteps = $parentTCList{$parameter1};

         #Check that stepId is valid for provided testCaseId
         if ($parameter2 <= $numOfSteps)
         {
            #OK to proceed - set $stepId
            $stepId = $parameter2;
         }
         else
         {
            print "Provided stepId ($parameter2) is invalid for provided testCaseId.  Valid stepId values for testCaseId ($parameter1) are between 1 and " .  $numOfSteps . ".\n\n";
            exit 1;
         }

         #Set $testCasesExecuted
         $testCasesExecuted .= ", single step: $stepId";
      }
      else
      {
         print "Provided stepId ($parameter2) is invalid.\n\n";
         exit 1;
      }
   }
}


################################################################################
################################################################################
##                                                                            ##
##                          START OF AUTOMATION                               ##
##                                                                            ##
################################################################################
################################################################################




################################################################################
#Set log file symlink to archive folder and get absolute path
################################################################################
# $0 is used to display the 'state' of the automation 'thread' to either ps(1) or top(1)
$0 = "Automation Setup: archive basic Summary log";
($status, $basicLogPath) = AUTO_lib::archiveLog('basicSum');
if ($status ne 'OK')
{
   print "$basicLogPath\n\n";
   exit 1;
}

$0 = "Automation Setup: archive detailed Summary log";
($status, $detailLogPath) = AUTO_lib::archiveLog('detailedSum');
if ($status ne 'OK')
{
   print "$detailLogPath\n\n";
   exit 1;
}

$0 = "Automation Setup: archive audit log";
($status, $auditLogPath) = AUTO_lib::archiveLog('audit');
if ($status ne 'OK')
{
   print "$auditLogPath\n\n";
   exit 1;
}

################################################################################
#Log & Print Screen Msg
################################################################################
$displayLogString = "\n**************************************************************************************************************\n" .
                    "                          IATF Automated Functional Testing Ver. $versionNumber\n" .
                    "**************************************************************************************************************\n" .
                    "Initializing test case data from automation database...";
$emailBodyPlain .= $displayLogString;
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($basicLogPath, $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog($detailLogPath, $displayLogString);
}
if ($screenDisplay > 0)
{
   print $displayLogString;
}

################################################################################
#Get All Test Cases from Automation Database
################################################################################
$0 = "Automation Setup: getAllTestCases()" . " at " . AUTO_lib::getCurTime(time) ;
($status, $errMsg) = AUTO_lib::getAllTestCases(\%allTCHash, \%parentTCList);

$0 = "Automation Setup: remapAllTestCaseReq()" . " at " . AUTO_lib::getCurTime(time) ;
($status, $errMsg) = AUTO_lib::remapAllTestCaseReq(\%allTCHash);
if ($status ne 'OK') { print "$errMsg\n\n"; exit 1; }

$0 = "Automation Setup: staticSearchReplace4DHash()" . " at " . AUTO_lib::getCurTime(time) ;
($status) = AUTO_lib::staticSearchReplace4DHash(\%allTCHash, $envType);

################################################################################
#Get All Test Cases from Automation Database
################################################################################
$0 = "Automation Setup: getAllExpectedResults()" . " at " . AUTO_lib::getCurTime(time) ;
($status, $errMsg) = AUTO_lib::getAllExpectedResults(\%allERHash, \%parentTCList);

$0 = "Automation Setup: remapAllExpResultsRes()" . " at " . AUTO_lib::getCurTime(time) ;
($status, $errMsg) = AUTO_lib::remapAllExpResultsRes(\%allERHash, \%allTCHash);
if ($status ne 'OK') { print "$errMsg\n\n"; exit 1; }

$0 = "Automation Setup: staticSearchReplace5DHash()" . " at " . AUTO_lib::getCurTime(time) ;
($status) = AUTO_lib::staticSearchReplace5DHash(\%allERHash, $envType);

$0 = "Automation Setup: Log headers" . " at " . AUTO_lib::getCurTime(time) ;

################################################################################
#Log & Print Screen Msg
################################################################################
$displayLogString = "Done.\n";
$emailBodyPlain .= $displayLogString;
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($basicLogPath, $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog($detailLogPath, $displayLogString);
}
if ($screenDisplay > 0)
{
   print $displayLogString;
}

################################################################################
#Beginning Automation, Write Audit Log Header
################################################################################
$startTime = time;
$startTimeString = GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"');
$auditLogString = "********************************************************************\n" .
                  "****************** Beginning Automated Test ************************\n" .
                  "********************************************************************\n" .
                  "TEST BEGIN TIME: $startTimeString\n";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($auditLogPath, $auditLogString);
}

################################################################################
#Get count of test cases to execute, Write Audit Log Msg
################################################################################
my $testCaseCount = keys %parentTCList;
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($auditLogPath, "TOTAL COUNT OF TEST CASES TO RUN: $testCaseCount\n\n");
}

################################
#Determine $numClients
################################
if ($maxClients >= $testCaseCount)
{
   $numClients = $testCaseCount;
}
else
{
   $numClients = $maxClients;
}

################################
#Determine Screen Display Type
#
# no screen output: 0
# detailed summary screen output: 1
# basic summary screen output: 2
#
################################
if ($testCaseCount > 1)
{
   #basic summary
   $screenDisplay = 2;
}
else
{
   #detailed summary
   $screenDisplay = 1;
}

################################
#Set $appInstanceName
################################
$appInstanceName = AUTO_lib::getAppInstance($envType, $server, $testCaseFilter);

################################################################################
#Log & Print Screen Msg
################################################################################
$displayLogString = "Total count of test cases to run: $testCaseCount\n" .
                    "Number of parallel clients: $numClients\n" .
                    "Test case(s) to execute: $testCasesExecuted\n" .
                    "Environment: $envType\n" .
                    "Server: $server\n" .
                    "Application instance: $appInstanceName\n" .
                    "Beginning run of automated tests at: $startTimeString\n" .
                    "**************************************************************************************************************\n" .
                    "                                     Automation Testing Results\n" .
                    "**************************************************************************************************************\n";
$emailBodyPlain .= $displayLogString;
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($basicLogPath, $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog($detailLogPath, $displayLogString);
}
if ($screenDisplay > 0)
{
   print $displayLogString;
}

$displayLogString = "                                                                        Test     Total Steps Steps\n" .
                    "TC # Test Case ID                                                     Run Time   Steps  Pass  Fail  Result\n" .
                    "---- ---------------------------------------------------------------- -------- ------- ----- -----  ---------\n";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($basicLogPath, $displayLogString);
}
if ($screenDisplay == 2)
{
   print $displayLogString;
   $emailBodyPlain .= $displayLogString;
}



############################################
#Only One Client - Don't multi-process
############################################
if ($numClients <= 1)
{

   $0 = "Automation Setup: Single Client" . " at " . AUTO_lib::getCurTime(time) ;

   $child_proc_header = "Automated Test: ";

   $totalTestProtErr = 0;
   ($status, $totalTestPass, $totalTestFail, $emailDetailPlain, $emailDetailHtml) = executeTestCases(\%parentTCList, \%allTCHash, \%allERHash, 1, $screenDisplay, $automationLog, $stepId, $envType);

   $emailBodyPlain .= $emailDetailPlain;
}
############################################
#Multiple Clients - Multi-process
############################################
else
{
   $0 = "Automation Setup: Test Thread Setup" . " at " . AUTO_lib::getCurTime(time) ;

   #############################################################
   #Determine $numTCPerClient - only care about whole number
   #############################################################
   $numTCPerClient = int($testCaseCount / $numClients);

   #############################################################
   #Create %forkTCList Hash
   #############################################################
   my $i = 1;
   my $j = 1;
   $endFlag = 'FALSE';
   for my $key (sort keys %parentTCList)
   {
      $forkTCList{$key} = $j;

      if ($endFlag eq 'TRUE')
      {
         $j++;
      }
      else
      {
         if ($i == $numTCPerClient)
         {
            #Reset $i
            $i = 1;

            if ($j < $maxClients)
            {
               $j++;
            }
            else
            {
               #Hit the end, reset $j = 1 and just start incrementing remaining test cases
               #Reset $j
               $j = 1;
               $endFlag = 'TRUE';
            }
         }
         else
         {
            $i++;
         }
      }
   }


   $0 = "Automation Setup: Test Thread Execution" . " at " . AUTO_lib::getCurTime(time) ;

   #############################################################
   #forkTests
   #############################################################
   ($status, $totalTestPass, $totalTestFail, $totalTestProtErr, $emailDetailPlain, $emailDetailHtml) = forkTests(\%forkTCList, \%allTCHash, \%allERHash, $numClients, $screenDisplay, $automationLog);

   $emailBodyPlain .= $emailDetailPlain;
   $emailBodyHtml .= $emailDetailHtml;
}





$0 = "Automation Wrapup" . " at " . AUTO_lib::getCurTime(time) ;

#########################################
#Write final test results to logs
#########################################
if ($totalTestFail == 0) { $testResult = 'PASSED'; }
else { $testResult = 'FAILED'; }
$auditLogString  = "**************************************************************************************\n" .
                   "Test Final Results Summary: Total Test Cases: $testCaseCount, Total Passed: $totalTestPass, Total Failed: $totalTestFail\n"; 
$auditLogString .= "                                                              Total automation.pl protocol errors: $totalTestProtErr\n" unless $totalTestProtErr <= 0;
$auditLogString .= "Test Final Result: $testResult\n" .
                   "**************************************************************************************\n\n";

if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($auditLogPath, $auditLogString);
}


$displayLogString = "\n**************************************************************************************************************\n" .
                    "SUMMARY:\n" .
                    "TOTAL TEST CASES: $testCaseCount, TOTAL PASSED: $totalTestPass, TOTAL FAILED: $totalTestFail\n" .
                    "TEST FINAL RESULT: $testResult\n" .
                    "TOTAL TEST RUN TIME: " . AUTO_lib::timeDiff($startTime, time). "\n" .
                    "**************************************************************************************************************\n" .
                    "Completed automated tests at: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n\n";
$timeDiffSeconds = (time - $startTime);
$runDuration = GLOBAL_lib::convertSecondsToReadableFormat($timeDiffSeconds);
$emailBodyPlain .= $displayLogString;
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($basicLogPath, $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog($detailLogPath, $displayLogString);
}
if ($screenDisplay > 0)
{
   print $displayLogString;
}

$auditLogString = "\nTEST END TIME: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n" .
                  "TOTAL ELAPSED TIME: " . AUTO_lib::timeDiff($startTime, time) . "\n" .
                  "*******************************************************************\n" .
                  "********************* End Of Automated Test ***********************\n" .
                  "*******************************************************************\n\n";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog($auditLogPath, $auditLogString);
}


#########################################
#Upload log files to web server
#########################################
($status, $errMsg, $displayLogsInEmail, $webBasicLogPath, $webDetailLogPath, $webAuditLogPath) = AUTO_lib::uploadLogFilesToWebServer($basicLogPath, $detailLogPath, $auditLogPath, $webServerHostname, $webServerUsername, $webServerBaseDir, $uploadLogsToWebServer, $automationLog, $testCaseFilter, $envType);
if ($status ne 'OK') { print "$errMsg\n"; }

#########################################
#Construct HTML Results
#########################################
$emailBodyHtml = AUTO_lib::constructHtmlResults($emailFormat, $emailDetailHtml, $testCaseFilter, $testResult, $testCaseCount, $totalTestPass, $totalTestFail, $startTimeString, $runDuration, $testCasesExecuted, $numClients, $versionNumber, $webServerHostname, $envType, $server, \%allTCHash, \%allERHash, $displayLogsInEmail, $webBasicLogPath, $webDetailLogPath, $webAuditLogPath);


#########################################
#Send Results By Email
#########################################
AUTO_lib::sendResultsByEmail($sendEmailResults, $sendOnlyOnFailure, $emailRefList, $EMAIL_LIST_GLOBAL, $EMAIL_LIST_GROUP, $emailFormat, $fromEmailAddress, $replyEmailAddress, $emailBodyPlain, $emailBodyHtml, $testCaseFilter, $testResult);


#########################################
# Option to exit with -1 on test failures
# (e.g. used by Jenkins)
#########################################
if (uc($minusOneOnFail) eq 'TRUE')
{
   if ( $testResult ne 'PASSED' )
   {
      exit -1;
   }
}
################################################################################
################################################################################
##                                                                            ##
##                            END OF AUTOMATION                               ##
##                                                                            ##
################################################################################
################################################################################








################################################################################
#                         All Subroutines Below                                #
################################################################################

################################################################################
#
# forkTests subroutine -
#
#
################################################################################
sub forkTests($$$$$$)
{
   my $forkTCListHashRef   = $_[0];
   my $allTCHashRef        = $_[1];
   my $allERHashRef        = $_[2];
   my $numClients          = $_[3];
   my $screenDisplay       = $_[4];
   my $automationLog       = $_[5];


   my $status              = '';
   my $errMsg              = '';
   my %clientTCList        = ();
   my $i                   = 0;
   my $delPos              = 0;
   my $rawPipeString       = '';
   my $testResult          = '';
   my $screenPrint         = '';
   my $tcCount             = 0;
   my $printCount          = '';
   my $totalTestPass       = 0;
   my $totalTestFail       = 0;
   my $totalTestProtErr    = 0;
   my $throwAway1          = 0;
   my $throwAway2          = 0;
   my $throwAway3          = 0;
   my $throwAway4          = 0;
   my $ascii29             = chr(29);
   my $ascii30             = chr(30);
   my $ascii31             = chr(31);
   my $emailDetailPlain    = '';
   my $emailDetailHtml     = '';
   my $pipeTestCaseId      = '';
   my $pipeTestRunTime     = '';
   my $pipeNumSteps        = '';
   my $pipeStepsPass       = '';
   my $pipeStepsFail       = '';


   #Construct $emailDetailHtml
   $emailDetailHtml = AUTO_lib::constructHtmlDetailHeader($screenDisplay);


   #############################################################
   #Open a pipe so that child processes can send results to parent
   #############################################################
   my $pipe = IO::Pipe->new || die "ERROR(automation.pl): Unable to open pipe: $!";

   $0 = "Automation Boss:  forking...";

   #############################################################
   #Start forking automated test cases
   #############################################################
   for ($i = 1; $i <= $numClients; $i++)
   {
      #Split the program into two processes: Parent and Child
      die "ERROR(automation.pl): Unable to Fork: $!" unless defined(my $kidpid = fork());

      #This is the Parent process block
      if ($kidpid)
      {
         #Nothing to do
      }
      #This is the Child process block
      else
      {

         my $space = '';
         $space = ' ' if $i < 10;
	 $child_proc_header = "Automation Thread ${space}$i: ";
	 $0 = $child_proc_header . "Starting...";

         $pipe->writer;
         select $pipe;

         %clientTCList = ();
         for my $key (keys %$forkTCListHashRef)
         {
            if ($forkTCListHashRef->{$key} == $i)
            {
               #Add test case list to clientTCListHash
               $clientTCList{$key} = $i;
            }
         }

         #Execute client
         ($status, $throwAway1, $throwAway2, $throwAway3, $throwAway4) = executeTestCases(\%clientTCList, $allTCHashRef, $allERHashRef, $numClients, $screenDisplay, $automationLog, $stepId, $envType);

         exit 0;
      }
   }

   $0 = "Automation Boss: waiting on all Children";

   #############################################################
   #Wait for all children to complete
   #############################################################
   do {} while ( waitpid(-1, WNOHANG) > 0 );


   #############################################################
   #Parent reads all of the children results
   #############################################################
   $pipe->reader;
   $| = 1;
   my $prevread='';
   my $lastread='';
   my $lastReadLength = -1;
   my $thisReadLength = -1;
   my $wasLastError   = 0;

   while (<$pipe>)
   {

      $lastread = $prevread;

      $lastReadLength = $thisReadLength;
      $thisReadLength = length $_;
      $prevread = $_;

      ##FUTURE##$childrenLeft =  $numClients - $donepidcount;
      ##FUTURE##if ( $childrenLeft == 0 ) {
      ##FUTURE##   $0 = 'Automation Boss: waiting on no Children.';
      ##FUTURE##   $rin='';	   # very important... no I/O ... just wait for interrupt...
      ##FUTURE##} elsif ( $childrenLeft == 1 ) {
      ##FUTURE##  $0 = 'Automation Boss: waiting on one Child.';
      ##FUTURE##} else {
      ##FUTURE##  $0 = "Automation Boss: waiting on $childrenLeft Children.";
      ##FUTURE##}

      #
      chomp;
      $rawPipeString = $_;

      #Parse out Test Result and Screen Message
      $delPos = index($rawPipeString, $ascii30);
      if ($delPos < 0)
      {
         # $tcCount--;		                                                      # this line is not a TC, do not count it as such... autoincrement now guarded below...
         $testResult  = 'PROTOCOL_ERROR';
         $screenPrint = 'ERROR(forkTests): Child message protocol error @ '. GLOBAL_lib::dynamicDate('0, "%Y%m%d_%H%M%S"') . 
				( $wasLastError == 0 ? ", last line read: $lastread," : '' ) .
				" lastReadLength = $lastReadLength: '$rawPipeString'\n";       # note the hiccup
         # now to skip over the hiccup
         $wasLastError ++;
      }
      else
      {
         #Split out variables from $rawPipeString
         ($rawPipeString, $pipeTestCaseId, $pipeTestRunTime, $pipeNumSteps, $pipeStepsPass, $pipeStepsFail) = split($ascii29, $rawPipeString);

         $wasLastError = 0;
         $testResult  = substr($rawPipeString, 0, $delPos);
         $screenPrint = substr($rawPipeString, $delPos + 1);
      }

      #Tally Test Result
      if ($testResult eq 'PASSED')
      {
         $totalTestPass++;
      }
      elsif ($testResult eq 'FAILED')
      {
         $totalTestFail++;
      }
      else
      {
         $totalTestProtErr++;
      }



      if ($testResult ne 'PROTOCOL_ERROR')	# skip PROTOCOL_ERROR lines...
      {
         #Format Test Case Counter for $screenDisplay = 2
         $tcCount++;
         if ($screenDisplay == 2)
         {
            $printCount = (' ' x (4 - length($tcCount))) . $tcCount;
   
            print $printCount . ' ';
            $emailDetailPlain .= $printCount . ' ';
         }
      }

      #Convert all $ascii31 characters back to newlines
      $screenPrint =~ s/$ascii31/\n/g;

      #Write screen output back to parent
      print $screenPrint;

      #Create $emailDetailPlain
      $emailDetailPlain .= $screenPrint;

      #Add $emailDetailHtml record
      $emailDetailHtml .= "<tr>\n" .
                          "<td>$tcCount</td>\n" .
                          "<td>$pipeTestCaseId</td>\n" .
                          "<td>$pipeTestRunTime</td>\n" .
                          "<td>$pipeNumSteps</td>\n" .
                          "<td>$pipeStepsPass</td>\n" .
                          "<td>$pipeStepsFail</td>\n" .
                          "<td>$testResult</td>\n" .
                          "</tr>\n";
   }

   #Close $emailDetailHtml
   $emailDetailHtml .= "</table>\n" .
                       "<br><br><br><br>\n";


   return ('OK', $totalTestPass, $totalTestFail, $totalTestProtErr, $emailDetailPlain, $emailDetailHtml);
}




################################################################################
#
# executeTestCases subroutine -
#
#
################################################################################
sub executeTestCases($$$$$$$$)
{
   my $testCaseIdHash     = $_[0];
   my $allTCHashRef       = $_[1];
   my $allERHashRef       = $_[2];
   my $numClients         = $_[3];
   my $screenDisplay      = $_[4];
   my $automationLog      = $_[5];
   my $stepId             = $_[6];
   my $envType            = $_[7];


   my $status             = '';
   my $errMsg             = '';
   my $httpRC             = '';
   my $httpResHeader      = '';
   my %testCaseActionHash = ();
   my %stepActionHash     = ();
   my %testCaseExpResHash = ();
   my %stepExpResHash     = ();
   my %stepActResHash     = ();
   my %stepActResHashGet  = ();
   my $stepResult         = '';
   my $parsedAction       = '';
   my $rawRequest         = '';
   my $rawResponse        = '';
   my $brkReqHeader       = '';
   my $brkResHeader       = '';
   my $parsedActResult    = '';
   my $parsedExpResult    = '';
   my $response           = '';
   my $countTestPass      = 0;
   my $countTestFail      = 0;
   my $tcCount            = 0;
   my $testDuration       = '';
   my $ascii29            = chr(29);
   my $ascii30            = chr(30);
   my $ascii31            = chr(31);
   my $emailDetailPlain   = '';
   my $emailDetailHtml    = '';
   my %stepDataHash       = ();
   my $stepDataHashRef    = \%stepDataHash;


   #Construct $emailDetailHtml
   $emailDetailHtml = AUTO_lib::constructHtmlDetailHeader($screenDisplay);


   ################################################################################
   #
   #      TEST_CASE_ID LOOP
   #
   ################################################################################
   for my $testCaseKey (sort keys (%$testCaseIdHash))
   {
      my $testCaseStart      = time;
      my $totalStepsPass     = 0;
      my $totalStepsFail     = 0;
      my $screenString1      = '';
      my $screenString2      = '';
      my $auditLogString1    = '';
      my $printCount         = '';


      #Increment Test Case Counter
      $tcCount++;


      #############################################################################
      #Retrieve Test Case Data for $testCaseKey
      #############################################################################
      %testCaseActionHash = ();
      ($status, $errMsg) = AUTO_lib::getTestCase(\%testCaseActionHash, $testCaseKey, $allTCHashRef);
      AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, "ERROR: Unable to retrieve Test Case - see logs for further detail.");


      ################################################################################
      #Retrieve Expected Results Data for $testCaseKey
      ################################################################################
      %testCaseExpResHash = ();
      ($status, $errMsg) = AUTO_lib::getExpectedResults(\%testCaseExpResHash, $testCaseKey, $allERHashRef);
      AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, "ERROR: Unable to retrieve Expected Results - see logs for further detail.");


      #Get count of number of steps for test case
      my $stepCount = keys %testCaseActionHash;


      #Print Testcase Header - audit log
      $auditLogString1 .= "\t*****************************************************************\n";
      $auditLogString1 .= "\tTEST_CASE_ID: $testCaseKey\n";
      $auditLogString1 .= "\tTEST_CASE_DESCRIPTION: $testCaseActionHash{1}{'TEST_CASE_DESC'}\n";
      $auditLogString1 .= "\tTEST_CASE_START_TIME: " . AUTO_lib::getCurTime($testCaseStart) . "\n";
      $auditLogString1 .= "\tTOTAL_STEPS: $stepCount\n";
      $auditLogString1 .= "\t*****************************************************************\n";


      #Print Testcase Header - screen output
      $screenString1 .= "\n----------------------------------------------------------------------------------------------------\n";
      $screenString1 .= "TEST_CASE_ID: $testCaseKey\n";
      $screenString1 .= "TEST_CASE_DESCRIPTION: $testCaseActionHash{1}{'TEST_CASE_DESC'}\n";
      $screenString1 .= "TOTAL_STEPS: $stepCount\n\n";

      GLOBAL_lib::setStepData($stepDataHashRef, "TEST_CASE_ID", $testCaseKey);

      #############################################################################
      #
      #      STEP_ID LOOP
      #
      #############################################################################
      for my $stepKey (sort {$a <=> $b} keys %testCaseActionHash)
      {
         my $stepStart      = time;


         #If stepId provided, only execute this SINGLE step (i.e. ./automation.pl <TEST_CASE_ID> stepId)
         if ( ($stepId ne '') && ($stepId != $stepKey) )
         {
            #Skip to next $stepKey
            next;
         }

	 $0 = $child_proc_header . $testCaseKey . " Step " . $stepKey . " at " . GLOBAL_lib::dynamicDate('0, "%Y%m%d_%H%M%S"') . " Description " . $testCaseActionHash{$stepKey}{'STEP_DESC'} ;
         $0 =~ s./. -- .g;     # the character after the s becomes the delimiter... it is somewhere in the Camel book...

         GLOBAL_lib::setStepData($stepDataHashRef, "STEP_ID", $stepKey);
         GLOBAL_lib::setStepData($stepDataHashRef, "STEP_DESC", $testCaseActionHash{$stepKey}{'STEP_DESC'});
         GLOBAL_lib::setStepData($stepDataHashRef, "STEP_DTG", strftime("%Y%m%d_%H%M%S", localtime(time)));
         GLOBAL_lib::setXdStepData($testCaseActionHash{$stepKey}, $stepDataHashRef, 'STEPDATA', $stepKey );

         $auditLogString1 .= "\n\t\t***********************************\n";
         $auditLogString1 .= "\t\tSTEP_ID: $stepKey\n";
         $auditLogString1 .= "\t\tSTEP_DESCRIPTION: $testCaseActionHash{$stepKey}{'STEP_DESC'}\n";
         if ( exists $testCaseActionHash{$stepKey}{'STEP_DEFECTS'} )
         {
            $auditLogString1 .= "\t\tKNOWN_DEFECTS: $testCaseActionHash{$stepKey}{'STEP_DEFECTS'}\n";
         }
         $auditLogString1 .= ("\t\t***********************************\n\n");


         $screenString1 .= "\tSTEP ID: $stepKey\tSTEP DESCRIPTION: $testCaseActionHash{$stepKey}{'STEP_DESC'}\n";
         if ( exists $testCaseActionHash{$stepKey}{'STEP_DEFECTS'} )
         {
            $screenString1 .= "\tKNOWN DEFECTS: $testCaseActionHash{$stepKey}{'STEP_DEFECTS'}\n";
         }


         ##########################################################################
         #Extract Step Action for this $stepKey
         ##########################################################################
         %stepActionHash = ();
         ($status, $errMsg) = AUTO_lib::extractStepAction(\%stepActionHash, \%testCaseActionHash, $stepKey);
         AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, "ERROR: Unable to extract Step Actions - see logs for further detail.");


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
         #RESET VALUES FOR STEP_ID LOOP
         #########################################################################a
         $httpRC         = '';
         $httpResHeader  = '';
         $rawRequest     = '';
         $rawResponse    = '';
         $response       = '';
         $brkReqHeader   = '';
         $brkResHeader   = '';
         %stepActResHash = ();



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
               #Send action data to CBS2 ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CBS2_lib::cbs2ATI($stepValue, \%stepActionHash, $envType);

               #Parse CBS2 response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = CBS2_lib::cbs2ParseXML($httpRC, $httpResHeader, $stepValue, $stepActionHash{'CBS2INTERFACE'}, $response, \%stepActResHash);
               
               #For USRSUM Response - Response is DIIS output
               if ($stepValue eq 'getAccountUSRSUMV2')
               {
                 %stepActResHashGet = ();
                 %stepActResHashGet = %stepActResHash;
                 ($status, $response) = DIIS_lib::diisParseRes($stepValue, $response, \%stepActResHash);
               }
            }
            ##########################################################################
            #STEP ACTION FOR CARDLYTICS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'aticard')
            {
               #Send action data to CARD ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CARD_lib::cardATI($stepValue, \%stepActionHash, $envType);

               #Parse CARD response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = CARD_lib::cardParseXML($httpRC, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR CARDLYTICS 2.5 APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'aticard25')
            {
               #Send action data to CARD ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CARD25_lib::card25ATI($stepValue, \%stepActionHash, $envType);

               #Parse CARD response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = CARD25_lib::card25ParseXML($httpRC, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR PRADMIN APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atipradmin')
            {
               #Send action data to CARD ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = PRADMIN_lib::pradminATI($stepValue, \%stepActionHash, $envType);

               #Parse CARD response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = PRADMIN_lib::pradminParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR FSG APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atifsg')
            {
               #Send action data to FSG ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = FSG_lib::fsgATI($stepValue, \%stepActionHash, $envType);

               #Parse FSG response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = FSG_lib::fsgParseXML($httpRC, $httpResHeader, $stepValue, 'rest', $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR GL APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atigl')
            {
               #Send action data to GL ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = GL_lib::glATI($stepValue, \%stepActionHash, $envType);

               #Parse GL response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = GL_lib::glParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR HTTP APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atihttp')
            {
               #Send action data to HTTP ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = HTTP_lib::httpATI(\%stepActionHash, $envType);

               #Nothing to parse for HTTP
               $response = $rawResponse;
            }
            ##########################################################################
            #STEP ACTION FOR METAVANTE XML APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atimv')
            {
               #Send action data to MV XML ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = MV_lib::mvXmlAPI($stepValue, \%stepActionHash, $envType);

               #Parse MV response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = MV_lib::mvParseXML($httpRC, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR OFX APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiofx')
            {
               #Send action data to OFX XML ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = OFX_lib::ofxXmlAPI($stepValue, \%stepActionHash, $envType);

               #Parse OFX response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = OFX_lib::ofxParseXML($httpRC, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR SRT APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atisrt')
            {
               #Send action data to SRT ATI and get response
               ($status, $rawRequest, $rawResponse, $brkReqHeader, $brkResHeader) = SRT_lib::srtATI($stepValue, \%stepActionHash);

               #Parse SRT response into ActualResponseHash
               $response = $rawResponse;
               if (lc($stepActionHash{'SHOW_BRK_HEADER'}) eq 'true')
               {             
                  $status = GLOBAL_lib::parseDiBrokerResHeader($brkResHeader, \%stepActResHash);
               }
               ($status, $response) = SRT_lib::srtParseRes($stepValue, $response, \%stepActResHash);

               #Set $rawResponse to empty to prevent binary info in logs
               $rawResponse = '';
            }
            ##########################################################################
            #STEP ACTION FOR DIIS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atidiis')
            {
               #Send action data to DIIS ATI and get response
               ($status, $rawRequest, $rawResponse, $brkReqHeader, $brkResHeader) = DIIS_lib::diisReqATI($stepValue, \%stepActionHash);

               #Parse DIIS response into ActualResponseHash
               $response = $rawResponse;
               if (lc($stepActionHash{'SHOW_BRK_HEADER'}) eq 'true')
               {
                  $status = GLOBAL_lib::parseDiBrokerResHeader($brkResHeader, \%stepActResHash);
               }
               ($status, $response) = DIIS_lib::diisParseRes($stepValue, $response, \%stepActResHash);

               #Set $rawResponse to empty to prevent binary info in logs
               $rawResponse = '';
            }
            ##########################################################################
            #STEP ACTION FOR RDB APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atirdb')
            {
               #Send action data to RDB ATI and get response
               ($status, $rawRequest, $rawResponse, $brkReqHeader, $brkResHeader) = RDB_lib::rdbReqATI(\%stepActionHash);

               #Parse RDB response into ActualResponseHash
               $response = $rawResponse;
               if (lc($stepActionHash{'SHOW_BRK_HEADER'}) eq 'true')
               {
                  $status = GLOBAL_lib::parseDiBrokerResHeader($brkResHeader, \%stepActResHash);
               }
               ($status, $response) = RDB_lib::rdbParse($response, \%stepActResHash);

               #Set $rawResponse to empty to prevent binary info in logs
               $rawResponse = '';
            }
            ##########################################################################
            #STEP ACTION FOR MSSQL APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atimssql')
            {
               #Send action data to MSSQL ATI and get response
               ($status, $rawRequest, $rawResponse) = MSSQL_lib::mssqlATI(\%stepActionHash, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR ORACLE APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atioracle')
            {
               #Send action data to ORACLE ATI and get response
               ($status, $rawRequest, $rawResponse) = ORACLE_lib::oracleATI(\%stepActionHash, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR QOL APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiqol')
            {
               #Send action data to QOL ATI and get response
               ($httpRC, my $issoReq, my $issoRes, $rawRequest, $rawResponse) = QOL_lib::qolATI($stepValue, \%stepActionHash, \%stepActResHash);

               #Parse QOL response into stepActResHash
               $response = $rawResponse;
               ($status, $response) = QOL_lib::ccParseXML($httpRC, $stepValue, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR MAIS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atimais')
            {
               #Send action data to MAIS ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = MAIS_lib::maisATI($stepValue, \%stepActionHash, $envType);

               #Parse MAIS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = MAIS_lib::maisParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }
            ##########################################################################
            #STEP ACTION FOR CAPS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'aticaps')
            {
               #Send action data to CAPS ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CAPS_lib::capsATI($stepValue, \%stepActionHash, $envType);

               #Parse CAPS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = CAPS_lib::capsParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }

            ##########################################################################
            #STEP ACTION FOR CAPS CLIENT APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'aticapsclient')
            {
               #Send action data to CAPS Client ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CAPS_Client_lib::capsClientATI($stepValue, \%stepActionHash, $envType);

               #Parse CAPS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = CAPS_Client_lib::capsclientParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }

            ##########################################################################
            #STEP ACTION FOR CAS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'aticas')
            {
               #Send action data to CAS ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = CAS_lib::casATI($stepValue, \%stepActionHash, $envType);

               #Parse CAPS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = CAS_lib::casParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }
            ##########################################################################
            #STEP ACTION FOR ABS APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiabs')
            {
               #Send action data to ABS ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = ABS_lib::absATI($stepValue, \%stepActionHash, $envType);

               #Parse ABS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = ABS_lib::ABSParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }
            ##########################################################################
            #STEP ACTION FOR ABS SCHEDULER APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiabsscheduler')
            {
               #Send action data to ABS SCHEDULER ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = ABSScheduler_lib::absATI($stepValue, \%stepActionHash, $envType);

               #Parse ABS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = ABSScheduler_lib::ABSParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }
            ##########################################################################
            #STEP ACTION FOR ABS SCHEDULER APPLICATION TESTING INTERFACE
            ##########################################################################
            elsif ($stepFunction eq 'atiabshttpsim')
            {
               #Send action data to ABS SCHEDULER ATI and get response
               ($httpRC, $httpResHeader, $rawRequest, $rawResponse) = ABSHttpSim_lib::absATI($stepValue, \%stepActionHash, $envType);

               #Parse ABS response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = ABSHttpSim_lib::ABSParseXML($httpRC, $httpResHeader, $stepValue, $response, \%stepActResHash);

            }
            ##########################################################################
            #STEP ACTION FOR GETTING AXIS.cfg VALUES
            ##########################################################################
            elsif ($stepFunction eq 'getcfg')
            {
               #Send STANZA to getAxisValues and get response
               ($httpRC, $rawRequest, $rawResponse) = AXIS_lib::getAxisValues($stepValue, \%stepActionHash, $envType);

               #Parse AXIS.cfg response into ActualResponseHash
               $response = $rawResponse;
               ($status, $response) = AXIS_lib::parseAxisValues($httpRC, $response, \%stepActResHash);
            }
            ##########################################################################
            #STEP ACTION FOR SETTING AXIS.cfg VALUES
            ##########################################################################
            elsif ($stepFunction eq 'setcfg')
            {
               #Send AXIS.cfg tags/values to be updated
               $response = $rawResponse;
               ($httpRC, $rawRequest, $rawResponse) = AXIS_lib::setAxisValues($stepValue, \%stepActionHash, \%stepActResHash, $envType);
            }
            ##########################################################################
            #STEP ACTION FOR WAIT
            ##########################################################################
            elsif ($stepFunction eq 'wait')
            {
               $rawRequest = $stepAction;

               ($status, $errMsg) = AUTO_lib::waitSeconds($stepValue);
               AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, "ERROR: Unexpected response from waitSeconds() function. See Logs for more detail.");
            }
            ##########################################################################
            #STEP ACTION FOR SYSTEM CALLS
            ##########################################################################
            elsif ($stepFunction eq 'system')
            {
               $rawRequest = $stepAction;

               AUTO_lib::systemCmd($stepValue);

            }
            ##########################################################################
            #STEP ACTION FOR BACKTICKS CALLS
            ##########################################################################
            elsif ($stepFunction eq 'backticks')
            {
               $rawRequest = $stepAction;

               ($rawResponse) = AUTO_lib::backticsCmd($stepValue);
            }
            ##########################################################################
            #UNKNOWN STEP ACTION
            ##########################################################################
            else
            {
               $errMsg = "ERROR: Undefined Step Function specified from Step Action: $stepFunction";
               $status = 'ERROR';
               AUTO_lib::exitOnError($status, $errMsg, $startTime, $screenDisplay, $errMsg);
            }



            ################################################################################
            #Extract Step Expected Results from %testCaseExpResHash
            ################################################################################
            %stepExpResHash = ();
            ($status, $errMsg) = AUTO_lib::extractStepExpResult(\%stepExpResHash, \%testCaseExpResHash, $stepKey);



            ##########################################################################
            #Generate Dynamic Results and Compare Expected/Actual Results
            ##########################################################################
            if ($validateStep eq 'Y')
            {
               #######################################################################
               #Generate dynamicResults here
               #######################################################################
               ($status) = GLOBAL_lib::dynamicResults(\%stepExpResHash, \%stepActResHash, \%testCaseActionHash, \%testCaseExpResHash, $stepKey, $stepDataHashRef);


               #######################################################################
               #Generate Audit Log Info
               #######################################################################
               $parsedAction    = AUTO_lib::convert2DHash2String(\%stepActionHash);
               #$rawRequest already set from above
               #$rawResponse - set HTTP Response Code, Response Headers, and Response Body
               if ($rawResponse ne '') { $rawResponse = "Response Body:\n$rawResponse\n"; }
               if ($httpResHeader ne '') { $rawResponse = "HTTP Response Headers:\n$httpResHeader\n" . $rawResponse; }
               if ($httpRC ne '') { $rawResponse = "HTTP Response Code:\n$httpRC\n\n" . $rawResponse; }
               $parsedExpResult = AUTO_lib::convert3DHash2String(\%stepExpResHash);
               $parsedActResult = AUTO_lib::convert3DHash2String(\%stepActResHash);


               #######################################################################
               #Do Basic Regex Validation
               #######################################################################
               if ( defined $stepExpResHash{1}{'REGEX_VALIDATION'} )
               {
                  #ATIs using http will log below.  ATIs using anything else will log parsed resposne.
                  if ($rawResponse ne '')
                  {
                     $parsedActResult = 'USING REGEX - SEE "RAW_RESPONSE" FOR THIS STEP.';
                  }

                  #Perform RegEx Validation
                  ($status, $stepResult) = AUTO_lib::regExValidation($httpRC, $httpResHeader, $brkResHeader, $rawResponse, \%stepActResHash, \%stepExpResHash);
               }
               #######################################################################
               #Do Full Parsing Validation
               #######################################################################
               else
               {
                  #######################################################################
                  #Compare Expected/Actual Result and Get Step Result
                  #######################################################################
                  ($status, $stepResult) = AUTO_lib::compExpActResults(\%stepExpResHash, \%stepActResHash);
               }


               ############################
               #Tally Up Step Pass or Fail
               ############################
               if ($stepResult eq 'PASSED') { $totalStepsPass++; }
               else { $totalStepsFail++; }
            }
            else
            {
               #######################################################################
               #Generate Audit Log Info
               #######################################################################
               $parsedAction    = AUTO_lib::convert2DHash2String(\%stepActionHash);
               $rawRequest      = 'STEP_NOT_VALIDATED';
               $rawResponse     = 'STEP_NOT_VALIDATED';
               $parsedExpResult = 'STEP_NOT_VALIDATED';
               $parsedActResult = 'STEP_NOT_VALIDATED';

               #Set $stepResult to STEP_NOT_VALIDATED
               $stepResult = 'STEP_NOT_VALIDATED';
            }
         }
         ##########################################################################
         #STEP IS NOT ACTIVE - DO NOT EXECUTE STEP
         ##########################################################################
         else
         {
            $parsedAction    = 'STEP_NOT_ACTIVE';
            $rawRequest      = 'STEP_NOT_ACTIVE';
            $rawResponse     = 'STEP_NOT_ACTIVE';
            $parsedExpResult = 'STEP_NOT_ACTIVE';
            $parsedActResult = 'STEP_NOT_ACTIVE';

            #Set $stepResult to STEP_NOT_ACTIVE
            $stepResult = 'STEP_NOT_ACTIVE';
         }


         ###########################################
         #Write to audit log
         ###########################################
         $auditLogString1 .= "\t\tSTEP_ACTION:\n"     . $parsedAction    . "\n\n";
         $auditLogString1 .= "\t\tRAW_REQUEST:\n"     . $rawRequest      . "\n\n";
         $auditLogString1 .= "\t\tRAW_RESPONSE:\n"    . $rawResponse     . "\n\n";
         $auditLogString1 .= "\t\tEXPECTED_RESULT:\n" . $parsedExpResult . "\n\n";
         $auditLogString1 .= "\t\tACTUAL_RESULT:\n"   . $parsedActResult . "\n\n";


         ###########################################
         #Write step result to audit log and screen
         ###########################################
         $auditLogString1 .= "\t\t--------------------------------\n";
         $auditLogString1 .= "\t\tStep Result: [" . AUTO_lib::timeDiff($stepStart, time) . "] $stepResult\n";
         $auditLogString1 .= "\t\t--------------------------------\n";
         #screen output
         $screenString1 .= "\tSTEP RESULT: [" . AUTO_lib::timeDiff($stepStart, time) . "] $stepResult\n";
      }
      #############################################################################
      #      END OF STEP_ID LOOP
      #############################################################################


      #########################################
      #Write test case result to log
      #########################################
      $auditLogString1 .= "\t******************************************************************************\n";
      $auditLogString1 .= "\tTest Case End Time: " . AUTO_lib::getCurTime(time) . "\n";
      $auditLogString1 .= "\tTest Case Time-Length: " . AUTO_lib::timeDiff($testCaseStart, time) . "\n";
      $auditLogString1 .= "\tTest Case Result Summary: Total Steps: $stepCount, Total Passed: $totalStepsPass, Total Failed: $totalStepsFail\n";
      if ($totalStepsFail == 0) { $testResult = "PASSED"; $countTestPass++; }
      else { $testResult = 'FAILED'; $countTestFail++; }
      $auditLogString1 .= "\tTest Case Final Result: $testResult\n";
      $auditLogString1 .= "\t******************************************************************************\n\n";


      $screenString1 .= "\nSTEPS_PASSED: $totalStepsPass\n";
      $screenString1 .= "STEPS_FAILED: $totalStepsFail\n";
      $screenString1 .= "TEST_CASE_FINAL_RESULT: [" . AUTO_lib::timeDiff($testCaseStart, time) . "] $testResult\n";
      $screenString1 .= "----------------------------------------------------------------------------------------------------\n\n";


      #Generate $screenString2
      $testDuration = AUTO_lib::timeDiff($testCaseStart, time);
      $screenString2 .= "$testCaseKey" . (' ' x (64 - length($testCaseKey)));
      $screenString2 .= ' ';
      $screenString2 .= $testDuration;
      $screenString2 .= ' ';
      $screenString2 .= (' ' x (7 - length($stepCount))) . $stepCount;
      $screenString2 .= ' ';
      $screenString2 .= (' ' x (5 - length($totalStepsPass))) . $totalStepsPass;
      $screenString2 .= ' ';
      $screenString2 .= (' ' x (5 - length($totalStepsFail))) . $totalStepsFail;
      $screenString2 .= '  ';
      $screenString2 .= "$testResult\n";



      #########################################
      #Write Automation Logs
      #########################################
      if ($automationLog == 1)
      {
         ($status, $errMsg) = AUTO_lib::writeAutoLog($auditLogPath, $auditLogString1);
         ($status, $errMsg) = AUTO_lib::writeAutoLog($detailLogPath, $screenString1);

         if ($numClients > 1)
         {
            AUTO_lib::writeAutoLog($basicLogPath, 'XXXX ' . $screenString2);
         }
         else
         {
            $printCount = (' ' x (4 - length($tcCount))) . $tcCount . ' ';
            AUTO_lib::writeAutoLog($basicLogPath, $printCount . $screenString2);
         }
      }


      #########################################
      #If multi-client need to pass back Test
      #Result delimited by ascii 30 char
      #########################################
      if ($numClients > 1)
      {
         print "$testResult" . $ascii30;
      }

      #########################################
      #Print detailed screen output
      #########################################
      if ($screenDisplay == 1)
      {
         if ($numClients > 1)
         {
            #Search and replace all new lines with ascii 31 chara
            $screenString1 =~ s/\n/$ascii31/g;

            $screenString1 .= "\n";
         }

         print $screenString1;
         $emailDetailPlain .= $screenString1;
      }
      #########################################
      #Print high-level screen output
      #########################################
      elsif ($screenDisplay == 2)
      {
         if ($numClients > 1)
         {
            #Search and replace all new lines with ascii 31 chara
            $screenString2 =~ s/\n/$ascii31/g;

            $screenString2 .= $ascii29 . $testCaseKey . $ascii29 . $testDuration . $ascii29 . $stepCount . $ascii29 . $totalStepsPass . $ascii29 . $totalStepsFail . "\n";
         }
         else
         {
            $printCount = (' ' x (4 - length($tcCount))) . $tcCount . ' ';
            print $printCount;
         }

         print $screenString2;
         $emailDetailPlain .= $screenString2;

         #Add $emailDetailHtml record
         $emailDetailHtml .= "<tr>\n" .
                             "<td>$tcCount</td>\n" .
                             "<td>$testCaseKey</td>\n" .
                             "<td>$testDuration</td>\n" .
                             "<td>$stepCount</td>\n" .
                             "<td>$totalStepsPass</td>\n" .
                             "<td>$totalStepsFail</td>\n" .
                             "<td>$testResult</td>\n" .
                             "</tr>\n";
      }
   }
   ################################################################################
   #      END OF TEST_CASE_ID LOOP
   ################################################################################


   #Close $emailDetailHtml
   $emailDetailHtml .= "</table>\n" .
                       "<br><br><br><br>\n";


   return ('OK', $countTestPass, $countTestFail, $emailDetailPlain, $emailDetailHtml);
}
################################################################################
#                         End of All Subroutines                               #
################################################################################
