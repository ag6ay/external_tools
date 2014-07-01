#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   genHttpSimData.pl - This script will generate httpsim test data based    ##
##                       template files stored in $templateDirPath.           ##
##                                                                            ##
##                       Created by: David Schwab                             ##
##                       Last Updated: DS - 03/20/2012 Ver. 1.00              ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
system('clear');




#####################################
#Subroutine prototype
#####################################
sub replaceParams($$$$$$$);
sub printFiApiHash($$);
sub printUserApiHash($$);




#####################################
#Set Configurations Below
#####################################
my $printFiUserInfo = 'false';
my $templateDirPath = './genHttpSimData/';   #Include trailing / character
my $fiIdPrefix      = 'DI1';
my $userIdPrefix    = 'PERF';
my $password        = '11111';  #__PASSWORD__
my $userGuidPrefix  = 'c0a8e440000375fa4f4ffde43b1b0f';
my $acct1Prefix     = 'ACCTID_ID_CHK';
my $acct2Prefix     = 'ACCTID_ID_SAV';
my $numOfFIs        = 10;
my $numOfUsersPerFI = 5;






#####################################
#Set Remaining Variables Below
#####################################
my $templateName    = '';
my $template        = '';
my %templateHash    = ();
my $fiCount         = 0;
my $userCount       = 0;
my $totalUserCount  = 0;
my $fiId            = '';
my $locateFiId      = '';
my $userId          = '';
my $userGuid        = '';
my $acct1           = '';
my $acct2           = '';
my %fiApiHash       = ();
my %userApiHash     = ();





#Read all template files into hash
opendir(DIR, $templateDirPath);
foreach $templateName (readdir(DIR))
{
   if (-f $templateDirPath . $templateName)
   {
      #Read template file
      open(FILE, $templateDirPath . $templateName) or die "Can't read file $templateName [$!]\n";
      $template = '';
      while (<FILE>)
      {
         $template .= $_;
      }
      close (FILE);

      #Add $template to %templateHash
      $templateHash{$templateName} = $template;
   }
}
closedir(DIR);




#Loop through FIs
for ($fiCount = 1; $fiCount <= $numOfFIs; $fiCount++)
{
   #Set $fiId __FIID__
   $fiId = $fiIdPrefix . ('0' x (3 - length($fiCount))) . $fiCount;


   #Only print out FI and user info
   if (lc($printFiUserInfo) eq 'true')
   {
      print "$fiId\n";
   }



   #Generate FI level API responses
   $fiApiHash{'getFinancialInstitutionV2'}{$fiId} = replaceParams($templateHash{'getFinancialInstitutionV2'}, $fiId, 'null', 'null', 'null', 'null', 'null');
   $locateFiId = '0' . substr($fiId, 2);
   $fiApiHash{'getFILocations'}{$fiId}            = replaceParams($templateHash{'getFILocations'}, $locateFiId, 'null', 'null', 'null', 'null', 'null');




   #Loop through users
   for ($userCount = 1; $userCount <= $numOfUsersPerFI; $userCount++)
   {
      $totalUserCount++;

      #Set $userId __USER_ID__
      $userId = $userIdPrefix . ('0' x (4 - length($totalUserCount))) . $totalUserCount;

      #Set $userGuid __USER_GUID__
      $userGuid = $userGuidPrefix . ('0' x (2 - length($totalUserCount))) . $totalUserCount;

      #Set $acct1 __ACCT_1__
      $acct1 = $acct1Prefix . ('0' x (4 - length($totalUserCount))) . $totalUserCount;

      #Set $acct2 __ACCT_2__
      $acct2 = $acct2Prefix . ('0' x (4 - length($totalUserCount))) . $totalUserCount;



      #Only print out FI and user info
      if (lc($printFiUserInfo) eq 'true')
      {
         print "   $userId,$password,$userGuid,$acct1,$acct2\n";
      }



      #Generate User level API responses
      $userApiHash{'AuthenticateUserV2'}{$fiId}{$userGuid}              = replaceParams($templateHash{'AuthenticateUserV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'validateChallangeQuestionInfoV2'}{$fiId}{$userGuid} = replaceParams($templateHash{'validateChallangeQuestionInfoV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getTransactionsV2'}{$fiId}{$userGuid}               = replaceParams($templateHash{'getTransactionsV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getAccountsV2'}{$fiId}{$userGuid}                   = replaceParams($templateHash{'getAccountsV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'createTransferV2'}{$fiId}{$userGuid}                = replaceParams($templateHash{'createTransferV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'createScheduledTransferV2'}{$fiId}{$userGuid}       = replaceParams($templateHash{'createScheduledTransferV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getScheduledTransfersV2'}{$fiId}{$userGuid}         = replaceParams($templateHash{'getScheduledTransfersV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'updateScheduledTransferV2'}{$fiId}{$userGuid}       = replaceParams($templateHash{'updateScheduledTransferV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'deleteScheduledTransferV2'}{$fiId}{$userGuid}       = replaceParams($templateHash{'deleteScheduledTransferV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getFICustomerV2'}{$fiId}{$userGuid}                 = replaceParams($templateHash{'getFICustomerV2'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getFundingAccounts'}{$fiId}{$userGuid}              = replaceParams($templateHash{'getFundingAccounts'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getPayees'}{$fiId}{$userGuid}                       = replaceParams($templateHash{'getPayees'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getBillPayments'}{$fiId}{$userGuid}                 = replaceParams($templateHash{'getBillPayments'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'createBillPayment'}{$fiId}{$userGuid}               = replaceParams($templateHash{'createBillPayment'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'deleteBillPayment'}{$fiId}{$userGuid}               = replaceParams($templateHash{'deleteBillPayment'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'getCheckImageRegistration'}{$fiId}{$userGuid}       = replaceParams($templateHash{'getCheckImageRegistration'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'updateCheckImageRegistration'}{$fiId}{$userGuid}    = replaceParams($templateHash{'updateCheckImageRegistration'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'createCheckImage'}{$fiId}{$userGuid}                = replaceParams($templateHash{'createCheckImage'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
      $userApiHash{'updateCheckImage'}{$fiId}{$userGuid}                = replaceParams($templateHash{'updateCheckImage'}, $fiId, $userId, $userGuid, $acct1, $acct2, $password);
   }
}




#####################################
#Print out httpsim test data
#####################################
if (lc($printFiUserInfo) ne 'true')
{

   print "\n\n\n\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "##\n";
   print "## ALL CBS RESPONSES BELOW\n";
   print "##\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "\n\n\n\n";


   ##########################################
   #First print out user level responses
   ##########################################
   printUserApiHash('AuthenticateUserV2', \%userApiHash);
   printUserApiHash('validateChallangeQuestionInfoV2', \%userApiHash);
   printUserApiHash('getTransactionsV2', \%userApiHash);
   printUserApiHash('getAccountsV2', \%userApiHash);
   printUserApiHash('createTransferV2', \%userApiHash);
   printUserApiHash('createScheduledTransferV2', \%userApiHash);
   printUserApiHash('getScheduledTransfersV2', \%userApiHash);
   printUserApiHash('updateScheduledTransferV2', \%userApiHash);
   printUserApiHash('deleteScheduledTransferV2', \%userApiHash);
   printUserApiHash('getFICustomerV2', \%userApiHash);


   ##########################################
   #Then print out all FI level responses
   ##########################################
   printFiApiHash('getFinancialInstitutionV2', \%fiApiHash);



   print "\n\n\n\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "##\n";
   print "## ALL CCBP RESPONSES BELOW\n";
   print "##\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "\n\n\n\n";


   ##########################################
   #Print out all user level responses
   ##########################################
   printUserApiHash('getFundingAccounts', \%userApiHash);
   printUserApiHash('getPayees', \%userApiHash);
   printUserApiHash('getBillPayments', \%userApiHash);
   printUserApiHash('createBillPayment', \%userApiHash);
   printUserApiHash('deleteBillPayment', \%userApiHash);



   print "\n\n\n\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "##\n";
   print "## ALL LOCATORSEARCH RESPONSES BELOW\n";
   print "##\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "\n\n\n\n";


   ##########################################
   #Print out all FI level responses
   ##########################################
   printFiApiHash('getFILocations', \%fiApiHash);


   print "\n\n\n\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "##\n";
   print "## ALL VERTIFI RESPONSES BELOW\n";
   print "##\n";
   print "################################################################################\n";
   print "################################################################################\n";
   print "\n\n\n\n";


   ##########################################
   #Print out all user level responses
   ##########################################
   printUserApiHash('getCheckImageRegistration', \%userApiHash);
   printUserApiHash('updateCheckImageRegistration', \%userApiHash);
   printUserApiHash('createCheckImage', \%userApiHash);
   printUserApiHash('updateCheckImage', \%userApiHash);
}









###############################################
# sub replaceParams -
###############################################
sub replaceParams($$$$$$$)
{
   my $inputString  = $_[0];
   my $fiId         = $_[1];
   my $userId       = $_[2];
   my $userGuid     = $_[3];
   my $acct1        = $_[4];
   my $acct2        = $_[5];
   my $password     = $_[6];

   my $outputString = $inputString;

   #Search and replace all parameters
   $outputString =~ s/__FIID__/$fiId/g;
   $outputString =~ s/__USER_ID__/$userId/g;
   $outputString =~ s/__USER_GUID__/$userGuid/g;
   $outputString =~ s/__ACCT_1__/$acct1/g;
   $outputString =~ s/__ACCT_2__/$acct2/g;
   $outputString =~ s/__PASSWORD__/$password/g;


   return $outputString;
}



###############################################
# sub printFiApiHash -
###############################################
sub printFiApiHash($$)
{
   my $apiName     = $_[0];
   my $hashRef     = $_[1];

   my $fiIdKey     = '';


   for $fiIdKey (sort keys %{$hashRef->{$apiName}})
   {
      print $hashRef->{$apiName}{$fiIdKey} . "\n\n";
   }
}



###############################################
# sub printUserApiHash -
###############################################
sub printUserApiHash($$)
{
   my $apiName     = $_[0];
   my $hashRef     = $_[1];

   my $fiIdKey     = '';
   my $userGuidKey = '';

   for $fiIdKey (sort keys %{$hashRef->{$apiName}})
   {
      for $userGuidKey (sort keys %{$hashRef->{$apiName}->{$fiIdKey}})
      {
         print $hashRef->{$apiName}{$fiIdKey}{$userGuidKey} . "\n\n";
      }
   }
}
