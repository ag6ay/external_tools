#!/usr/bin/perl -w

#-------------------------------------------------------------------------------
#
# File:			automateOps.pl
#
# Dependencies:		strict
#
# Description: Automation script for operations performance test of SRT
#
#
#Other Notes:
#-------------------------------------------------------------------------------
#The perl logic is very simple and could stand a revision. The difficult part
#to grasp here is all the SRT, Database, and simulator Logic and what the script
#is trying to accomplish
#-------------------------------------------------------------------------------
#Functions, logging and error haneling are things that need to be added.
#-------------------------------------------------------------------------------
#Operator needs to make sure SrtMaint.cfg's for both versions are configured for the
#Same product!
#-------------------------------------------------------------------------------
#The Operator really need to make sure that the memory monitoring script is running
#or the test needs to be restarted and a ton of time could be waisted.
#-------------------------------------------------------------------------------
#It is assumed that port 40038 will always contain the next candidate
#-------------------------------------------------------------------------------
#It is assumed that port 40048 will always contain the current prod version
#-------------------------------------------------------------------------------
#It is also assumed that onlineserv is the current prod version
#-------------------------------------------------------------------------------
#It is also assumed that preprod is the next candidate
#-------------------------------------------------------------------------------
#The script is developed to take the operator error our of the ops performance test
#-------------------------------------------------------------------------------
#The script still requires some intervention
#-------------------------------------------------------------------------------
#Once the script has completed all it's tasks the operator need to calculate the runtimes
#for each run processed. Including graphing the memory usage if so desired.
#-------------------------------------------------------------------------------
#It is recommended to run the script early in the day to avoid any issues with a 
#midnight clock roll
#-------------------------------------------------------------------------------
#The operator need to prepare the SRT Migrate load files before running this script
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
#	initialize script
#-------------------------------------------------------------------------------
$VERSION = "0.1";
use strict;

#-------------------------------------------------------------------------------#
# Pre-defined path from CM for the current version of SRT Migrate:
#-------------------------------------------------------------------------------#
my $onlineservToolDir		= "/opt/di/region/onlineserv/tool/SRTMigrate_BE_40038";
my $preprodToolDir		= "/opt/di/region/preprod/tool/SRTMigrate_BE_40048";

#-------------------------------------------------------------------------------#
# Pre-defined path from CM for the each instance of SRT run scripts:
#-------------------------------------------------------------------------------#
my $onlineservJobDir		= "/opt/di/region/onlineserv/job/SRTMaint_BE_40038";
my $preprodJobDir		= "/opt/di/region/preprod/job/SRTMaint_BE_40048";

#-------------------------------------------------------------------------------#
# User defined path for existing SRT Migrate load files:
#-------------------------------------------------------------------------------#
my $srtLoadFilePath		= "/home/amho3827/SRT/srt_performance";
#my $srtLoadFilePath		= "/hb/bin/util/iqa/SCRIPTS/srtload/operations";
#my $srtLoadFilePath		= "/hb/bin/util/iqa/SCRIPTS/srtload/infrastructure";

#-------------------------------------------------------------------------------#
# Database information for SRT and FI database simulator:
#-------------------------------------------------------------------------------#
my $onlineservSRTdb		= "disrt_be\@db_comm";
my $preprodSRTdb		= "disrt_pp_be\@db_comm";
my $simulatorDB			= "fisimulator1\@qa1";

#-------------------------------------------------------------------------------#
# User defined date for maturity and loan next payment alert notifications:
#-------------------------------------------------------------------------------#
my $currentDatePrvMo		= "05/16/2009";
my $currentDatePrvMoNextYr	= "05/16/2010";

#-------------------------------------------------------------------------------#
# Path of where to log script output. "Path" and "filename" should match that of memMonitor.sh
#-------------------------------------------------------------------------------#
#my $loggingPath			= "/home/user/process.txt";
my $loggingPath			= "/home/amho3827/SRT/srt_performance/performance/process.txt";


#-------------------------------------------------------------------------------#
# User defined DI number for site being used to test:
#-------------------------------------------------------------------------------#
my $siteNumber			= "DI1846";

#-------------------------------------------------------------------------------#
# Email address to send the end of run stats to (Make sure to escape the \@):
# For large batches...make sure to use this email- testmail@qa.digitalinsight.com;
#-------------------------------------------------------------------------------#
my $FIendOfRunEmail		= "amzad.hossain\@digitalinsight.com";
#my $FIendOfRunEmail		= "testmail\@qa.digitalinsight.com";

#-------------------------------------------------------------------------------#
# Use percentage configuration for parallel processing (1 = 1%, 50 = 50%, etc.(work with OPS) :
# OPS Comment:- I would set the use_percentage to 100 for test sites (this is what most production sites have).  Then we are using 1#00% of the -min number of #slaves.  In production we really use -min to control end-users in parallel. I would do the surpress_usrv#er enabled and disabled, with 100% use_percentage and # I #would test both 2.6.0 and 2.6.1 for these cases.
#-------------------------------------------------------------------------------#
my $usePercentage               = "100";

#-------------------------------------------------------------------------------#
# Suppress USRVER setting. 1 = Enable or 0 = Disable set here for consistency(work with OPS):
# OPS Comment: Try with both 0 and 1.
#-------------------------------------------------------------------------------#
my $suppressUsrver		= "0";


#-------------------------------------------------------------------------------#
#Delete existing test site transactions from next candidate version:
#-------------------------------------------------------------------------------#

print `su - disrt -c "echo \\"delete from action where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from summaryusage where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from executelog where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from schtxalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from txswalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
#Update FI entry in the SRT database to standardize settings for next candidate:
#-------------------------------------------------------------------------------#

print `su - disrt -c "echo \\"update fi set intport='0', email='$FIendOfRunEmail', timezone=null, rege_desc=null, dbaddress=null, feature_email=null, summary_email=null, rep_month=null, suppress_usrver='$suppressUsrver', use_percentage='$usePercentage', failed_reqst_limit='5', sprs_host_err_msg='FALSE' where id='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
# End of run message:
#-------------------------------------------------------------------------------#
print "REMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO START MEMORY MONITOR SCRIPT!!!!!!\n";


#-------------------------------------------------------------------------------#
#Begin loading SRT Alerts for next candidate:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $onlineservToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Alerts.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Begin loading SRT Transfers for next candidate:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $onlineservToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Trans.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Refresh simulatror balances and reset ratio of unsuccessful transactions:
#-------------------------------------------------------------------------------#

print `su - informix -c "echo \\"
update idata set imatdt='$currentDatePrvMo' where anum='465855';
update ldata set lnxtpt='$currentDatePrvMo' where anum='365179';
update ldata set pddtpr='$currentDatePrvMo' where anum='365077';
update adata set abal='99999999999', aabal='9999999999999999' where anum='2758248117'; 
update adata set abal='99999999999', aabal='9999999999999999' where anum='717550591';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365077';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365179';
update idata set abal='99999999999', aabal='9999999999999999' where anum='465855';
update idata set abal='99999999999', aabal='9999999999999999' where anum='688779';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%9';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%9';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%9';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%9';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%8';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%8';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%8';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%8';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%7';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%7';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%7';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%7';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%7';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%7';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%7';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%7';
\\" | dbaccess $simulatorDB"`;


#-------------------------------------------------------------------------------#
#Kick off SRT for an ALERTS only run for next candidate:
#-------------------------------------------------------------------------------#

print "Running SRT ALERT Only....\n";
print `su - disrt -c "cd $onlineservJobDir;runSRT $siteNumber ALERT ;cd -;"`;


#-------------------------------------------------------------------------------#
#Update memory usage log file to show end of run:
#-------------------------------------------------------------------------------#

print `echo "END OF NEXT CANDIDATE ALERT ONLY RUN\n\n\n" >> $loggingPath"`;


#-------------------------------------------------------------------------------#
#Kick off SRT for an TRANSFER only run for next candidate:
#-------------------------------------------------------------------------------#

print "Running SRT TRANSFER Only....\n";
print `su - disrt -c "cd $onlineservJobDir;runSRT $siteNumber TRANSFER ;cd -;"`;


#-------------------------------------------------------------------------------#
#Update memory usage log file to show end of run:
#-------------------------------------------------------------------------------#

print `echo "END OF NEXT CANDIDATE TRANSFER ONLY RUN\n\n\n" >> $loggingPath"`;


#-------------------------------------------------------------------------------#
#Delete existing test site transactions from next candidate version:
#-------------------------------------------------------------------------------#

print `su - disrt -c "echo \\"delete from action where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from summaryusage where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from executelog where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from schtxalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from txswalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
#Begin loading SRT Alerts for next candidate in prep for runtype ALL:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $onlineservToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Alerts.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Begin loading SRT Transfers for next candidate in prep for runtype ALL:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $onlineservToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Trans.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Refresh simulatror balances and reset ratio of unsuccessful transactions:
#-------------------------------------------------------------------------------#

print `su - informix -c "echo \\"
update idata set imatdt='$currentDatePrvMo' where anum='465855';
update ldata set lnxtpt='$currentDatePrvMo' where anum='365179';
update ldata set pddtpr='$currentDatePrvMo' where anum='365077';
update adata set abal='99999999999', aabal='9999999999999999' where anum='2758248117';
update adata set abal='99999999999', aabal='9999999999999999' where anum='717550591';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365077';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365179';
update idata set abal='99999999999', aabal='9999999999999999' where anum='465855';
update idata set abal='99999999999', aabal='9999999999999999' where anum='688779';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%9';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%9';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%9';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%9';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%8';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%8';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%8';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%8';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%7';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%7';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%7';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%7';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%7';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%7';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%7';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%7';
\\" | dbaccess $simulatorDB"`;


#-------------------------------------------------------------------------------#
#Kick off SRT for an ALL types run for next candidate:
#-------------------------------------------------------------------------------#

print "Running SRT Runtype ALL....\n";
print `su - disrt -c "cd $onlineservJobDir;runSRT $siteNumber;cd -;"`;


#-------------------------------------------------------------------------------#
#Update memory usage log file to show end of run:
#-------------------------------------------------------------------------------#

print `echo "END OF NEXT CANDIDATE RUN TYPE ALL\n\n\n" >> $loggingPath"`;

#-------------------------------------------------------------------------------#
#Perform cleanup of and transactions remaining:
#-------------------------------------------------------------------------------#

print "Cleaning up SRT Database...\n";
print `su - disrt -c "echo \\"delete from action where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from summaryusage where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from executelog where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from schtxalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from txswalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#Repeat the process for the current production version of SRT:
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------#



#-------------------------------------------------------------------------------#
#Delete existing test site transactions from current production version version:
#-------------------------------------------------------------------------------#

print `su - disrt -c "echo \\"delete from action where fi='$siteNumber'\\" | dbaccess $preprodSRTdb"`;

print `su - disrt -c "echo \\"delete from summaryusage where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from executelog where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from schtxalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from txswalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
#Update FI entry in the SRT database to standardize settings for current production version:
#-------------------------------------------------------------------------------#

print `su - disrt -c "echo \\"update fi set intport='0', email='$FIendOfRunEmail', timezone=null, rege_desc=null, dbaddress=null, feature_email=null, summary_email=null, rep_month=null, suppress_usrver='$suppressUsrver', use_percentage='$usePercentage', failed_reqst_limit='5', sprs_host_err_msg='FALSE' where id='$siteNumber'\\" | dbaccess $preprodSRTdb"`;



#-------------------------------------------------------------------------------#
#Begin loading SRT Alerts for current production version:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $preprodToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Alerts.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Begin loading SRT Transfers for current production version:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $preprodToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Trans.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Refresh simulatror balances and reset ratio of unsuccessful transactions:
#-------------------------------------------------------------------------------#

print `su - informix -c "echo \\"
update idata set imatdt='$currentDatePrvMo' where anum='465855';
update ldata set lnxtpt='$currentDatePrvMo' where anum='365179';
update ldata set pddtpr='$currentDatePrvMo' where anum='365077';
update adata set abal='99999999999', aabal='9999999999999999' where anum='2758248117'; 
update adata set abal='99999999999', aabal='9999999999999999' where anum='717550591';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365077';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365179';
update idata set abal='99999999999', aabal='9999999999999999' where anum='465855';
update idata set abal='99999999999', aabal='9999999999999999' where anum='688779';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%9';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%9';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%9';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%9';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%8';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%8';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%8';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%8';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%7';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%7';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%7';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%7'; 
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%7'; 
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%7'; 
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%7'; 
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%7';
\\" | dbaccess $simulatorDB"`; 

#-------------------------------------------------------------------------------#
#Kick off SRT for an ALERTS only run for current production version:
#-------------------------------------------------------------------------------#

print "Running SRT ALERT only run....\n";
print `su - disrt -c "cd $preprodJobDir;runSRT $siteNumber ALERT ;cd -;"`;


#-------------------------------------------------------------------------------#
#Update memory usage log file to show end of run:
#-------------------------------------------------------------------------------#

print `echo "END OF CURRENT PRODUCTION VERSION ALERT ONLY RUN\n\n\n" >> $loggingPath"`; 


#-------------------------------------------------------------------------------# 
#Kick off SRT for an TRANSFER only run for current production version: 
#-------------------------------------------------------------------------------#

print "Running SRT TRANSFER only run....\n";
print `su - disrt -c "cd $preprodJobDir;runSRT $siteNumber TRANSFER ;cd -;"`;


#-------------------------------------------------------------------------------#
#Update memory usage log file to show end of run:
#-------------------------------------------------------------------------------#

print `echo "END OF CURRENT PRODUCTION VERSION TRANSFER ONLY RUN\n\n\n" >> $loggingPath"`;


#-------------------------------------------------------------------------------#
#Delete existing test site transactions from current production version version:
#-------------------------------------------------------------------------------#

print `su - disrt -c "echo \\"delete from action where fi='$siteNumber'\\" | dbaccess $preprodSRTdb"`;

print `su - disrt -c "echo \\"delete from summaryusage where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from executelog where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from schtxalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from txswalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
#Begin loading SRT Alerts for current production version in prep for runtype ALL:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $preprodToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Alerts.txt 0;cd -`;


#-------------------------------------------------------------------------------#
#Begin loading SRT Transfers for current production version in prep for runtype ALL:
#-------------------------------------------------------------------------------#

print "Loading SRT Database....\n";
print `cd $preprodToolDir;./SRTCreate.sh $siteNumber $srtLoadFilePath/IB-Trans.txt 0;cd -`;

#-------------------------------------------------------------------------------#
#Refresh simulatror balances and reset ratio of unsuccessful transactions:
#-------------------------------------------------------------------------------#

print `su - informix -c "echo \\"
update idata set imatdt='$currentDatePrvMo' where anum='465855';
update ldata set lnxtpt='$currentDatePrvMo' where anum='365179';
update ldata set pddtpr='$currentDatePrvMo' where anum='365077';
update adata set abal='99999999999', aabal='9999999999999999' where anum='2758248117';
update adata set abal='99999999999', aabal='9999999999999999' where anum='717550591';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365077';
update ldata set abal='99999999999', aabal='9999999999999999' where anum='365179';
update idata set abal='99999999999', aabal='9999999999999999' where anum='465855';
update idata set abal='99999999999', aabal='9999999999999999' where anum='688779';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%9';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%9';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%9';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%9';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%9';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%9';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%8';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%8';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%8';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%8';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%8';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%8';
update idata set imatdt='$currentDatePrvMoNextYr' where anum='465855' and usr like '33%7';
update ldata set lnxtpt='$currentDatePrvMoNextYr' where anum='365179' and usr like '33%7';
update ldata set pddtpr='$currentDatePrvMoNextYr' where anum='365077' and usr like '33%7';
update adata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='2758248117' and usr like '33%7';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365077' and usr like '33%7';
update ldata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='365179' and usr like '33%7';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='465855' and usr like '33%7';
update idata set abal='3100000009999999999', aabal='210000000999999999999999' where anum='688779' and usr like '33%7';
\\" | dbaccess $simulatorDB"`;


#-------------------------------------------------------------------------------#
#Kick off SRT for an ALL types run for current production version:
#-------------------------------------------------------------------------------#

print "Running SRT for ALL Runtypes....\n";
print `su - disrt -c "cd $preprodJobDir;runSRT $siteNumber;cd -;"`;


#-------------------------------------------------------------------------------#
#Perform cleanup of any transactions remaining:
#-------------------------------------------------------------------------------#

print "Cleaning up SRT Database...\n";
print `su - disrt -c "echo \\"delete from action where fi='$siteNumber'\\" | dbaccess $preprodSRTdb"`;

print `su - disrt -c "echo \\"delete from summaryusage where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from executelog where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from schtxalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;

print `su - disrt -c "echo \\"delete from txswalert_log where fi='$siteNumber'\\" | dbaccess $onlineservSRTdb"`;


#-------------------------------------------------------------------------------#
#Update memory usage log file to show end of run:
#-------------------------------------------------------------------------------#

print `echo "END OF CURRENT PRODUCTION VERSION RUN TYPE ALL\n\n\n REMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\n\n\n" >> $loggingPath"`;


#-------------------------------------------------------------------------------#
# End of run message:
#-------------------------------------------------------------------------------#
print "REMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\nREMEMBER TO STOP MEMORY MONITOR SCRIPT!!!!!!\n";


__END__
