#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##    automation.pl - Automated functional tesing program that executes test  ##
##                    cases stored in a central Oracle IATF database.         ##
##                                                                            ##
##                    Created by: David Schwab                                ##
##                    Last updated: DS - 01/29/2012 Ver. 5.66                 ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
use English;			# because some things are really worth reading...
use IO::Pipe;
use POSIX ':sys_wait_h';
use lib '../../qa_lib';
use GLOBAL_lib;
use AUTO_lib;
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

use IPC::SysV qw(IPC_CREAT IPC_RMID);	# Semaphore considerations


use Data::Dumper;

system('clear');






##################################
#DECLARE VARIABLES
##################################
my @configArray         = ();
my $parameter1          = '';
my $parameter2          = '';
my $startTime           = '';
my $status              = '';
my $errMsg              = '';
my %allTCHash           = ();
my %allERHash           = ();
my %parentTCList        = ();
my %forkTCList          = ();
my $testResult          = '';
my $totalTestPass       = 0;
my $totalTestFail       = 0;
my $numClients          = 0;
my $numTCPerClient      = 0;
my $versionNumber       = '';
my $displayLogString    = '';
my $auditLogString      = '';
my $endFlag             = '';
my $screenDisplay       = 0;
my $stepId              = '';


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

# semaphore considerations
#
# a semaphore is used to keep multiple child processes from writing to auditAutomation.log at the same instant.

my $semnum = 0;
my $semop = 0;
my $semopget = 1;
my $semoptfree = -1;
my $semflag = 0;
my $sem_stat = 0;
my $semop_getauditlog = pack("s!s!s!", $semnum, $semop, $semflag) . pack("s!s!s!", $semnum, $semopget, $semflag);
my $semop_freeauditlog = pack("s!s!s!", $semnum, $semoptfree, $semflag);


##################################
#SPLIT APP ARGS AND CONFIG ARGS
##################################
GLOBAL_lib::splitConfigArgs(\@ARGV, \@configArray);



##################################
#INITIALIZE VARIABLES
##################################
$parameter1          = ($ARGV[0] || '');
$parameter2          = ($ARGV[1] || '');
$versionNumber       = '5.66';
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



##################################
#Subroutine Prototype
##################################
sub forkTests($$$$$$);
sub executeTestCases($$$$$$$$);
sub audit_allow();		# allow write to auditAutomation.log
sub audit_free();		# let some other process write to auditAutomation.log
sub childWaitLoop();		# reap dead child processes


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
               '           g[et]    - GET a list of all active test cases filtered under the "testCaseFilter" config.' . "\n" .
               '           a[ll]    - execute ALL active test cases filtered under the "testCaseFilter" config.' . "\n" .
               '           r[eport] - generate a summary test case REPORT filtered under the "testCaseFilter" config.' . "\n" .
               '         testCaseId - execute a SINGLE test case identified by the test case id value.' . "\n\n\n" .
               '   stepId - Optional.  Use this to execute a SINGLE step id from a SINGLE test case id. PARAM1 must' . "\n" .
               '                       be a testCaseId.' . "\n\n" .
               '   -CFG_KEY CFG_VAL - Optional.  Any number of configuration overrides.' . "\n\n" .
               "****************************************************************************************************\n\n\n";

   print $usage;
   $exitReason="usage()";
   $showCallersAtEnd = 0;
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
      $showCallersAtEnd = 0;
      $exitReason="List TCs only -- error accessing TC List Info";
      exit 1;
   }

   #Generate Report
   $tcListReport = AUTO_lib::genTestCaseReport(\%tcListHash);

   #Print Report to Screen and Exit
   print $tcListReport;
   $exitReason="List TCs only -- normal exit";
   $showCallersAtEnd = 0;
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
   $detailedTCReport = AUTO_lib::genDetailedTCReport($testCaseFilter);

   #Set $reportFooter
   $reportFooter = "\n==========================================================================================\n";

   #Print Detailed Report to Screen and Exit
   print $detailedTCReport;
   print $reportFooter;
   $showCallersAtEnd = 0;
   $exitReason="Report Generation";
   exit 0;
}
################################################################################
#Execute All Automated Test Cases
################################################################################
elsif( (lc($parameter1) eq 'a') || (lc($parameter1) eq 'all') )
{
   #Clear $parameter2 (stepId) since this is not valid here
   $parameter2 = '';

   ################################################################################
   #Get List of ALL Test Case IDs within $testCaseFilter
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getTestCaseID($testCaseFilter, \%parentTCList);
   if ($status ne 'OK')
   {
      $exitReason= "Error retrieving test cases from automation database under Test Case Filter: $testCaseFilter";
      print "\n$exitReason\n\n";
      print "$errMsg\n\n";
      $showCallersAtEnd = 0;
      exit 1;
   }
}
################################################################################
#Execute Single Automated Test Case
################################################################################
else
{
   ################################################################################
   #Validate Single Test Case ID
   ################################################################################
   ($status, $errMsg) = AUTO_lib::getSingleTestCaseID(\%parentTCList, $parameter1);
   if ($status ne 'OK')
   {
      $exitReason="Error retrieving single Test Case ID from automation database: $parameter1";
      print "\n$exitReason\n\n";
      print "$errMsg\n\n";
      $showCallersAtEnd = 0;
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
            $exitReason= "Provided stepId ($parameter2) is invalid for provided testCaseId.  Valid stepId values for testCaseId ($parameter1) are between 1 and " .  $numOfSteps;
            print "\n", $exitReason, "\n\n";
	    $showCallersAtEnd = 0;
            exit 1;
         }
      }
      else
      {
         $exitReason = "Provided stepId ($parameter2) is invalid.";
         print "\n", $exitReason, "\n\n";
	 $showCallersAtEnd = 0;
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
#Check for and archive any existing log files
################################################################################
#
#
# $0 is used to display the 'state' of the automation 'thread' to either ps(1) or top(1)
#
$0 = "Automation Setup: archive basic Summary log";
($status, $errMsg) = AUTO_lib::archiveLog('basicSum');
if ($status ne 'OK')
{
   print "$errMsg\n\n";
   $exitReason = $0 . " -- " . $errMsg;
   $showCallersAtEnd = 0;
   exit 1;
}
$0 = "Automation Setup: archive detailed Summary log";
($status, $errMsg) = AUTO_lib::archiveLog('detailedSum');
if ($status ne 'OK')
{
   print "$errMsg\n\n";
   $exitReason = $0 . " -- " . $errMsg;
   $showCallersAtEnd = 0;
   exit 1;
}
$0 = "Automation Setup: archive audit log";
audit_allow();
($status, $errMsg) = AUTO_lib::archiveLog('audit');
audit_free();
if ($status ne 'OK')
{
   print "$errMsg\n\n";
   $exitReason = $0 . " -- " . $errMsg;
   $showCallersAtEnd = 0;
   exit 1;
}

################################################################################
#Log & Print Screen Msg
################################################################################
$displayLogString = "\n**************************************************************************************************************\n" .
                    "                          IATF Automated Functional Testing Ver. $versionNumber\n" .
                    "**************************************************************************************************************\n" .
                    "Initializing test case data from automation database at ". AUTO_lib::getCurTime(time) . "...";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('basicSum', $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog('detailedSum', $displayLogString);
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
if ($status ne 'OK') { print "$errMsg\n\n"; $showCallersAtEnd = 0; $exitReason = $0 . " -- " . $errMsg ; exit 1; }
$0 = "Automation Setup: staticSearchReplace4DHash()" . " at " . AUTO_lib::getCurTime(time) ;
($status) = AUTO_lib::staticSearchReplace4DHash(\%allTCHash, $envType);

################################################################################
#Get All Test Cases from Automation Database
################################################################################
$0 = "Automation Setup: getAllExpectedResults()" . " at " . AUTO_lib::getCurTime(time) ;
($status, $errMsg) = AUTO_lib::getAllExpectedResults(\%allERHash, \%parentTCList);
$0 = "Automation Setup: remapAllExpResultsRes()" . " at " . AUTO_lib::getCurTime(time) ;
($status, $errMsg) = AUTO_lib::remapAllExpResultsRes(\%allERHash, \%allTCHash);
if ($status ne 'OK') { print "$errMsg\n\n"; $showCallersAtEnd = 0; $exitReason = $0 . " -- " . $errMsg ; exit 1; }
$0 = "Automation Setup: staticSearchReplace5DHash()" . " at " . AUTO_lib::getCurTime(time) ;
($status) = AUTO_lib::staticSearchReplace5DHash(\%allERHash, $envType);

$0 = "Automation Setup: Log headers" . " at " . AUTO_lib::getCurTime(time) ;

################################################################################
#Log & Print Screen Msg
################################################################################
$displayLogString = "Done at " . AUTO_lib::getCurTime(time) . ".\n";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('basicSum', $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog('detailedSum', $displayLogString);
}
if ($screenDisplay > 0)
{
   print $displayLogString;
}

################################################################################
#Beginning Automation, Write Audit Log Header
################################################################################
$startTime = time;
$auditLogString = "********************************************************************\n" .
                  "****************** Beginning Automated Test ************************\n" .
                  "********************************************************************\n" .
                  "TEST BEGIN TIME: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n";
if ($automationLog > 0)
{
   audit_allow();
   ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', $auditLogString);
   audit_free();
}

################################################################################
#Get count of test cases to execute, Write Audit Log Msg
################################################################################
my $testCaseCount = keys %parentTCList;
if ($automationLog > 0)
{
   audit_allow();
   ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', "TOTAL COUNT OF TEST CASES TO RUN: $testCaseCount\n");
   ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', "TESTING AGAINST SERVER          : $server\n\n");
   audit_free();
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

################################################################################
#Log & Print Screen Msg
################################################################################
$displayLogString = "Total count of test cases to run: $testCaseCount\n" .
                    "Number of multi-threaded clients: $numClients\n" .
                    "Running on server               : $server\n" .
                    "Beginning run of automated tests at: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n" .
                    "**************************************************************************************************************\n" .
                    "                                     Automation Testing Results\n" .
                    "**************************************************************************************************************\n";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('basicSum', $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog('detailedSum', $displayLogString);
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
   ($status, $errMsg) = AUTO_lib::writeAutoLog('basicSum', $displayLogString);
}
if ($screenDisplay == 2)
{
   print $displayLogString;
}

#AUTO_lib::closeTCDB();

############################################
#Only One Client - Don't multi-process
############################################
if ($numClients <= 1)
{
   $0 = "Automation Setup: Single Client" . " at " . AUTO_lib::getCurTime(time) ;

   $child_proc_header = "Automated Test: ";

   ($status, $totalTestPass, $totalTestFail) = executeTestCases(\%parentTCList, \%allTCHash, \%allERHash, 1, $screenDisplay, $automationLog, $stepId, $envType);
}
############################################
#Multiple Clients - Multi-process
############################################
else
{
   $0 = "Automation Setup: Test Thread Setup" . " at " . AUTO_lib::getCurTime(time) ;

   #
   # Set up the semaphore to guard auditAutomation.log
   #

   $sem_key = $PID;
   $sem_id  = semget ( $sem_key, 10, 0666 | IPC_CREAT );
   defined ( $sem_id ) or die "auditAutomation.log semget: $!";

   #print STDERR "sem_key = $sem_key, sem_id = $sem_id.\n";


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
   ($status, $totalTestPass, $totalTestFail) = forkTests(\%forkTCList, \%allTCHash, \%allERHash, $numClients, $screenDisplay, $automationLog);
}





$0 = "Automation Wrapup" . " at " . AUTO_lib::getCurTime(time) ;

#########################################
#Write final test results to logs
#########################################
if ($totalTestFail == 0) { $testResult = 'PASSED'; }
else { $testResult = 'FAILED'; }
$auditLogString = "**************************************************************************************\n" .
                  "Test Final Results Summary: Total Test Cases: $testCaseCount, Total Passed: $totalTestPass, Total Failed: $totalTestFail\n" .
                  "Test Final Result: $testResult\n" .
                  "**************************************************************************************\n\n";
if ($automationLog > 0)
{
   audit_allow();
   ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', $auditLogString);
   audit_free();
}


$displayLogString = "\n**************************************************************************************************************\n" .
                    "SUMMARY:\n" .
                    "TOTAL TEST CASES: $testCaseCount, TOTAL PASSED: $totalTestPass, TOTAL FAILED: $totalTestFail\n" .
                    "TEST FINAL RESULT: $testResult\n" .
                    "TOTAL TEST RUN TIME: " . AUTO_lib::timeDiff($startTime, time). "\n" .
                    "**************************************************************************************************************\n" .
                    "Completed automated tests at: " . GLOBAL_lib::dynamicDate('0, "%m-%d-%Y %H:%M:%S"') . "\n\n";
if ($automationLog > 0)
{
   ($status, $errMsg) = AUTO_lib::writeAutoLog('basicSum', $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog('detailedSum', $displayLogString);
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
   audit_allow();
   ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', $auditLogString);
   audit_free();
}


#########################################
#Write out ending TIMESTAMP_TAG to logs
#########################################
if ($automationLog > 0)
{
   $displayLogString = "<TIMESTAMP_TAG>" . GLOBAL_lib::dynamicDate('0, "%Y-%m-%d_%H%M%S"') . "</TIMESTAMP_TAG>";
   ($status, $errMsg) = AUTO_lib::writeAutoLog('basicSum', $displayLogString);
   ($status, $errMsg) = AUTO_lib::writeAutoLog('detailedSum', $displayLogString);
   audit_allow();
   ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', $displayLogString);
   audit_free();
}


#########################################
# Option to exit with -1 on test failures
# (e.g. used by Hudson)
#########################################
if (uc($minusOneOnFail) eq 'TRUE')
{
   if ( $testResult ne 'PASSED' )
   {
      $showCallersAtEnd = 0;
      $exitReason = "Normal Exit with Test Case Failures";
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
#
# auditAutomation.log file access control subs
#
#
################################################################################
sub audit_allow() {
	return if $sem_key == 0 or $sem_id == 0 ;
	# print STDERR "in audit_allow()\n";
	semop($sem_id, $semop_getauditlog)   or die "semop: audit_allow: $!";
	# print STDERR "leaving audit_allow()\n";
	$sem_stat++;
}
sub audit_free() {
	return if $sem_key == 0 or $sem_id == 0 ;
	# print STDERR "in audit_free()\n";
	semop($sem_id, $semop_freeauditlog)   or die "semop: audit_free: $!";
	# print STDERR "leaving audit_free()\n";
	$sem_stat--;
}

#
# The END block
#
# Report, as necessary and relevent, some data about the work.
#
# Also, if needed, remove the semaphore from the system.
# If this is not done, eventually the system runs out of semaphores.
#
# (been there, done that, got the error message... :-) )
#
END {
	if ( $parentPid == $PID ) {				# stuff for only the parent of threads...
		audit_allow();
		(undef, undef) = AUTO_lib::writeAutoLog('audit', "\n\n\n" );
		if ( defined $showCallersAtEnd and $showCallersAtEnd ) {
			my $index=0;
			my $package;
			my $filename;
			my $line;
			my $subroutine;
			my $hasargs;
			my $wantarray;
			my $evaltext;
			my $is_require;
			my $hints;
			my $bitmask;
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "\nUnexpected Parent Process Termination -- reason '$exitReason'\n\n" );
			
			while ( ( $package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask ) = caller($index) ) {
				(undef, undef) = AUTO_lib::writeAutoLog('audit', "\tLevel $index: package $package, filename $filename\n" );
				(undef, undef) = AUTO_lib::writeAutoLog('audit', "\t\t\tline $line, sub $subroutine, hasargs $hasargs, wantarray $wantarray\n" );
				(undef, undef) = AUTO_lib::writeAutoLog('audit', "\t\t\tevaltext $evaltext, is_require $is_require, hints $hints, bitmask $bitmask\n" );
			}
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "\n");
		} else {
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "Expected exit -- reason '$exitReason'\n");
		}
		if ( scalar keys %pidHash > 0 ) {
			# Dumper is not pretty,  but the data is saved...
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "\nChild Pid Stats:\n\n" . Dumper(\%pidHash) . "\n" );
		} else {
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "scalar keys \%pidHash <= 0\n");
		}
		if ( $child_sig_count > 0 ) {
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "There were $child_sig_count child exit signals detected.\n");
			print STDERR  "There were $child_sig_count child exit signals detected.\n";
		}
		if ( $donepidcount > 0 ) {
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "There were $donepidcount child exits recorded.\n");
		}
		if ( $child_exit_count > 0 ) {
			(undef, undef) = AUTO_lib::writeAutoLog('audit', "There were $child_exit_count child exit waits performed.\n");
		}
		audit_free();
		if ( $sem_key == $PID and $sem_id > 0 ) {	# only when in the 'parent'
			print STDERR "Parent in END block removing semaphore key = $sem_key, id = $sem_id.\n";
			my $lclstat;
			$lclstat = semctl($sem_id, 0, IPC_RMID, 0);
			print STDERR "\t$lclstat = semctl($sem_id, 0, IPC_RMID, 0);\n" unless $lclstat == 0;;
		}
	}
}

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
   my $ascii30             = chr(30);
   my $ascii31             = chr(31);



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

      %clientTCList = ();
      for my $key (keys %$forkTCListHashRef)
      {
            if ($forkTCListHashRef->{$key} == $i)
            {
               #Add test case list to clientTCListHash
               $clientTCList{$key} = $i;
            }
      }

      #This is the Parent process block
      if ($kidpid)
      {
         #Nothing to do -- well, almost...

         $pidHash{$kidpid}{STARTORDER} = $i;
         $pidHash{$kidpid}{STARTTIME} = AUTO_lib::getCurTime(time);	# test thread started at ???
         %{$pidHash{$kidpid}{TEST_CASES}} = %clientTCList;		# test thread TCs

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

         #Execute client
         ($status, undef, undef) = executeTestCases(\%clientTCList, $allTCHashRef, $allERHashRef, $numClients, $screenDisplay, $automationLog, $stepId, $envType);

	 $showCallersAtEnd = 0;
         $exitReason = "Child Exit";
         exit 0;
      }
   }

   $0 = "Automation Boss: waiting on all Children";
   $parentPid = $PID;


   #############################################################
   #Wait for all children to complete
   #############################################################

   childWaitLoop();
   $SIG{CHLD} = sub { $child_exit++; $child_sig_count++; };                   #- Handle child death proc.

   #############################################################
   #Parent reads all of the children results
   #############################################################
   $pipe->reader;
   $| = 1;

   #
   # Considerations for the select statement.
   #
   # select and sysread() replaced the file system read because the sigchld
   # signal will interrupt sysread and allow the wait() to be processed 
   # immediately.
   #
   my $rin = '';
   my $rout = '';
   my $win = '';
   my $wout = '';
   my $ein = '';
   my $eout = '';
   my $readcount = 0;
   $childrenLeft =  $numClients - $donepidcount;
   vec($rin, fileno($pipe), 1) = 1;
   $ein = $rin;

   
   #while ( $childrenLeft > 0 or defined $readcount ) 
   while ( $childrenLeft > 0 ) 
   {
      my $nfound = select($rout=$rin, $wout=$win, $eout=$ein, undef);
      if ( $child_exit > 0 ) { 
		$child_exit=0;
		childWaitLoop();
      }

      $childrenLeft =  $numClients - $donepidcount;
      if ( $childrenLeft == 0 ) {
	   $0 = 'Automation Boss: waiting on no Children.';
           $rin='';	   # very important... no I/O ... just wait for interrupt...
      } elsif ( $childrenLeft == 1 ) {
	   $0 = 'Automation Boss: waiting on one Child.';
      } else {
	   $0 = "Automation Boss: waiting on $childrenLeft Children.";
      }

      #
      # sysread
      #
      # doing this requires emulating the line splitting done by perl's input.
      #
      $readcount = sysread $pipe, $_, ( $numTCPerClient+20 ) * 133;  # rough guess at buffer size...
      next if not defined $readcount;	# ugly... yes...
      next if $readcount == 0;
      my @pipeStringArray = split  /\n/, $_;	# split what we got back into lines
      chomp @pipeStringArray;			# and get rid of line termination

      #print "readcount=$readcount\n";
      #print "read string = '$_'\n";

      foreach $rawPipeString ( @pipeStringArray ) 
      {
         #print "rawPipeString = '$rawPipeString'.\n";

         #Parse out Test Result and Screen Message
         $delPos = index($rawPipeString, $ascii30);
         if ($delPos < 0)
         {
            $screenPrint = 'ERROR(forkTests): Child message protocol error.';
         }
         else
         {
            $testResult = substr($rawPipeString, 0, $delPos);
            $screenPrint = substr($rawPipeString, $delPos + 1);
         }
   
         #Tally Test Result
         if ($testResult eq 'PASSED')
         {
            $totalTestPass++;
         }
         else
         {
            $totalTestFail++;
         }

         #Format Test Case Counter for $screenDisplay = 2
         $tcCount++;
         if ($screenDisplay == 2)
         {
            $printCount = (' ' x (4 - length($tcCount))) . $tcCount;

            print $printCount . ' ';
         }

         #Convert all $ascii31 characters back to newlines
         $screenPrint =~ s/$ascii31/\n/g;

         #Write screen output back to parent
         print $screenPrint;
      }

   }


   childWaitLoop();	# make sure all child stats are saved before reporting them.
   print "\n";

   return ('OK', $totalTestPass, $totalTestFail);
}

################################################################################
#
# childWaitLoop
#
#   Reap the child processes (after grabbing their stats???)...
#
################################################################################

sub childWaitLoop()
{
   my $donepid = 0;

    foreach my $pid ( keys %pidHash ) {
	next if defined $pidHash{$pid}{ENDTIME};	# skip if already reaped
	my $procfile;
	my $procstat;
	my @statarray=();
	#
	# Stats must be saved before the reap (wait())
	# otherwise the stats are lost
	#
	open $procfile, "</proc/$pid/stat" or warn "Unable to open /proc/$pid/stat.";
	$procstat = <$procfile>;
	close $procfile;
	@statarray=split /[[:space:]]/, $procstat, 4;
	if ( $statarray[2] eq 'Z' ) {
		# Zombie killer...
		$pidHash{$pid}{ENDTIME} = AUTO_lib::getCurTime(time);
		$pidHash{$pid}{ENDSTATS} = $procstat;			# format left as an exercise...
		$donepidcount++;
		$pidHash{$pid}{EXITORDER} = $donepidcount;
		$donepid = waitpid($pid, WNOHANG);
		$child_exit_count++;
	}
    }
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
   my $ascii30            = chr(30);
   my $ascii31            = chr(31);


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

	 $0 = $child_proc_header . $testCaseKey . " Step " . $stepKey;

         $auditLogString1 .= "\n\t\t***********************************\n";
         $auditLogString1 .= "\t\tSTEP_ID: $stepKey\n";
         $auditLogString1 .= "\t\tSTEP_DESCRIPTION: $testCaseActionHash{$stepKey}{'STEP_DESC'}\n";
         if ( exists $testCaseActionHash{$stepKey}{'STEP_DEFECTS'} )
         {
            $auditLogString1 .= "\t\tKNOWN_DEFECTS: $testCaseActionHash{$stepKey}{'STEP_DEFECTS'}\n";
         }
	 $auditLogString1 .= "\t\tINITIATED_AT: " . GLOBAL_lib::dynamicDate('0, "%Y-%m-%d %H:%M:%S"')."\n";
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
               ($status) = GLOBAL_lib::dynamicResults(\%stepExpResHash, \%stepActResHash, \%testCaseActionHash, \%testCaseExpResHash, $stepKey);


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
      $screenString2 .= "$testCaseKey" . (' ' x (64 - length($testCaseKey)));
      $screenString2 .= ' ';
      $screenString2 .= AUTO_lib::timeDiff($testCaseStart, time);
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
         audit_allow();
         ($status, $errMsg) = AUTO_lib::writeAutoLog('audit', $auditLogString1);
         audit_free();
         ($status, $errMsg) = AUTO_lib::writeAutoLog('detailedSum', $screenString1);

         if ($numClients > 1)
         {
            AUTO_lib::writeAutoLog('basicSum', 'XXXX ' . $screenString2);
         }
         else
         {
            $printCount = (' ' x (4 - length($tcCount))) . $tcCount . ' ';
            AUTO_lib::writeAutoLog('basicSum', $printCount . $screenString2);
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

            $screenString2 .= "\n";
         }
         else
         {
            $printCount = (' ' x (4 - length($tcCount))) . $tcCount . ' ';
            print $printCount;
         }

         print $screenString2;
      }
   }
   ################################################################################
   #      END OF TEST_CASE_ID LOOP
   ################################################################################



   return ('OK', $countTestPass, $countTestFail);
}
################################################################################
#                         End of All Subroutines                               #
################################################################################
