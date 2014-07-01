#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   atiCBS2.pl - This program generates and sends a request to a CBS2        ##
##                server and then returns the response.                       ##
##                                                                            ##
##                Created by: DSinha                                          ##
##                Last Updated: JF - 06/08/13 Ver. 1.61                         ##
##                CBS2 Version: 3.30.0                                        ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use GLOBAL_lib;
use CBS2_lib;
use DIIS_lib;
use MIME::Base64;
system('clear');


#######################################
# Declare Variables
#######################################
my @configArray   = ();
my $envType       = 0;
my $reqType       = '';
my $showRaw       = '';
my $status        = '';
my %vars          = ();
my $request       = '';
my $httpRC        = '';
my $httpResHeader = '';
my $response      = '';
my %parsedRes     = ();

my $responseInput = '';
my $diisReqType   = '';

#Entitlements
my $entitlement_enable = 0; #set to 1 to enable account filtering

##################################
#SPLIT APP ARGS AND CONFIG ARGS
##################################
GLOBAL_lib::splitConfigArgs(\@ARGV, \@configArray);

##################################
#INITIALIZE VARIABLES
##################################
$reqType          = ($ARGV[0] || '');
$showRaw          = ($ARGV[1] || '');

##################################
# GET CONFIGURABLE VARIABLES
##################################
$envType = GLOBAL_lib::getAppConfigValue('envType', 'env.cfg', \@configArray);





################################################################################
# Choose CBS2 Server
################################################################################
$vars{'SERVER'}            = 'b';


################################################################################
# Set HTTP Request Variables (all are optional)
################################################################################
$vars{'HTTP_HEADERS'}          = 'Authorization=cbs2testclient;intuit_originatingip=1.1.1.1;intuit_tid=1234abcd;intuit_offeringid=autoTest;intuit_sessionid=sessionId00001;intuit_appid=autoTest';
#$vars{'HTTP_HEADERS'}          = 'Authorization=cbs2testclient;intuit_originatingip=1.1.1.1;intuit_tid=1234abcd;intuit_offeringid=autoTest;intuit_sessionid=sessionId00001;intuit_appid=ABS'; # Only for ABS Client.
$vars{'HTTP_AGENT'}            = '';
$vars{'HTTP_TIMEOUT'}          = '';
$vars{'HTTP_CTYPE'}            = '';
$vars{'HTTP_RTYPE'}            = '';

################################################################################
# Read this WIKI how to use  GetFICustomer() request as "Cache-Control=no-cache" ==>  http://wikis.intuit.com/afe/index.php/By_Passing_CBS2_cache_for_no-cache_header 
# shellPrompt#  CBS2_ADD_HTTP_HEADERS='Cache-Control=no-cache' ./atiCBS2.pl getFICustomerV2 x
################################################################################
if ( $ENV{CBS2_ADD_HTTP_HEADERS} ) {
	$vars{'HTTP_HEADERS'}         .= ';'.$ENV{CBS2_ADD_HTTP_HEADERS};
}

################################################################################
# Set Client Certificate Request Variables (all are optional)
################################################################################
$vars{'CERT_PATH'}          = '';
$vars{'CERT_PASS'}          = '';


################################################################################
# CBS2 VARIABLES
################################################################################
$vars{'CBS2INTERFACE'}         = 'rest';
#$vars{'requestId'}             = 'testRequestId0001';
#$vars{'sessionId'}             = 'testSessionId0001';
#$vars{'clientIP'}              = '90.90.90.90';
$vars{'fiId'}                  = 'DI0508';
#$vars{'fiId'}                  = 'DI6525';
$vars{'userGuid'}              = 'c0a8e326003ef07a4b5e12Intra0FI00';	#AKA fiCustomerId
#$vars{'userGuid'}              = 'c0a8e326006150864x85xxxx12345x00';	#AKA fiCustomerId
$vars{'loginId'}               = '778921';
$vars{'userPass'}              = '1111';
$vars{'fiCustomerIdType'}      = 'GUID';   #OPTIONAL - Valid values are GUID and hostLoginId

#For entitlements 
$vars{'authId'} = 456;
$vars{'onBehalfOfUser'} = 'CBS2ENTITLE003';

################################################################################
## HTTP Headers for Entitlements APIs
################################################################################


if (($reqType eq 'createUserEntitlementsV2') or ($reqType eq 'getUserEntitlementsV2') or ($reqType eq 'entitlementDecisionV2') or ($reqType eq 'deleteEntitlementV2'))
{
	$vars{'HTTP_HEADERS'}          = 'Authorization=gateway2testclient;intuit_originatingip=127.0.0.1;intuit_tid=12346;intuit_offeringid=CustomerCentral;intuit_appid=CustomerCentral;intuit_IFS_userType=entitled;intuit_authid=' . $vars{'authId'} .';intuit_loginId=' . $vars{'loginId'} . ';intuit_IFS_onBehafOfUser=' . $vars{'userGuid'}; 
}	
elsif (($entitlement_enable == 1) and ($reqType eq 'getAccountsV2'))
{
        $vars{'HTTP_HEADERS'}         .= ';'.'intuit_authid='. $vars{'authId'} . ';intuit_IFS_onBehalfOfUser=' .$vars{'onBehalfOfUser'} . ';intuit_loginId=' . $vars{'loginId'} . ';intuit_IFS_userType=ENTITLED';
}


################################################################################

################################################################################
################################################################################
##                       CBS2 REQUEST TYPES                                   ##
################################################################################
################################################################################

################################################################################
# V2 API's Below
################################################################################

################################################################################
# createUserEntitlementsV2 (V2)
################################################################################
if ($reqType eq 'createUserEntitlementsV2')
{
   $vars{'idResource'}                  = 'BANKING_ACCOUNT,BANKING_ACCOUNT'; #Required value - id value for resource 
   #$vars{'idResource'}                  = 'BANKING_ACCOUNT_TRANSFER,BANKING_ACCOUNT_TRANSFER'; #Required value - id value for resource 
   $vars{'descResource'}                = 'banking/account/tU4VbdQ6qnl3yMjM9qJERFcfj46vJEZxzIOx0rgRXHI,banking/account/dSHMo3iNdIGETvWAIS3OWtLXLsBQHfcTHR_8LnTSCxE'; #Required value - description value for resource - for multiple accounts use ',' as separator
   #$vars{'descResource'}                = 'banking/account/tU4VbdQ6qnl3yMjM9qJERFcfj46vJEZxzIOx0rgRXHI/transfer,banking/account/dSHMo3iNdIGETvWAIS3OWtLXLsBQHfcTHR_8LnTSCxE/transfer'; #Required value - description value for resource - for multiple accounts use ',' as separator
   $vars{'idAction'}                    = 'VIEW,VIEW'; #Optional value - id value for action
   #$vars{'idAction'}                    = 'CREATE,CREATE'; #Optional value - id value for action
   $vars{'descAction'}                  = 'Account, Account2'; #Optional value - description value for action - for multiple accounts use ',' as separator
   delete $vars{'fiCustomerIdType'};
}

################################################################################
# getUserEntitlementsV2 (V2)
################################################################################
#No Variables

################################################################################
# entitlementDecisionV2 (V2)
################################################################################
if ($reqType eq 'entitlementDecisionV2')
{
   $vars{'idResource'}                  = 'BANKING_ACCOUNT_TRANSFER'; #Required value - id value for resource 
   $vars{'descResource'}                = 'banking/account/dSHMo3iNdIGETvWAIS3OWtLXLsBQHfcTHR_8LnTSCxE/transfer'; #Required value - description value for resource
   $vars{'idAction'}                    = 'CREATE'; #Optional value - id value for action
   $vars{'descAction'}                  = 'Transfer create en'; #Optional value - description value for action
   delete $vars{'fiCustomerIdType'};
}

################################################################################
# deleteEntitlementV2 (V2)
################################################################################
if ($reqType eq 'deleteEntitlementV2')
{
   $vars{'entitlementId'}               = ''; #Single entitlment to delete - empty value will delete all entitlements
   delete $vars{'fiCustomerIdType'};
}

################################################################################
# getFinancialInstitutionV2 (V2)
################################################################################
#No Variables

################################################################################
# getProductV2 (V2)
################################################################################
#No Variables

################################################################################
# getProductsV2 (V2)
################################################################################
#No Variables

################################################################################
################################################################################
# getFinancialInfoV2 (V2)
################################################################################
if ($reqType eq 'getFinancialInfoV2')
{
   $vars{'filterAccounts'}                  = '';
   $vars{'operation'}                       = 'retrieveUserInfo'; #Optional Value = retrieveUserInfo
   delete $vars{'fiCustomerIdType'};
}

################################################################################
# UpdateUserLastActivityV2 (V2)
################################################################################
if ($reqType eq 'UpdateUserLastActivityV2')
{
   $vars{'appCode'}                         = 'IPHONEBANKING';
}

################################################################################
# updateUserLastMobileV2 (V2)
################################################################################
if ($reqType eq 'updateUserLastMobileV2')
{
   $vars{'lastMobileLoginDateTime'}         = '__DYNAMIC(DATE{0, "%Y-%m-%dT08:03:01%zz"})__';
}

################################################################################
# getAccountUSRSUMV2 (V2)
################################################################################
#No Variables

################################################################################
# deleteAccountUSRSUMV2 (V2)
################################################################################
#No Variables


################################################################################
# getFICustomerV2 (V2)
################################################################################
#No Variables
#
# NOTE:  For testing the 'Cache-Control=no-cache' HTTP_HEADERS field please
#        see the long missive above (a few lines after the initial setting
#        of the HTTP_HEADERS value) on how to do this and why manually
#        adding/editing that control to HTTP_HEADERS here as one would the any other
#        field value probably will not work all of the time.
#

################################################################################
# getCustomerCentralTransactionsV2
################################################################################
if ($reqType eq 'getCustomerCentralTransactionsV2')
{
   $vars{'fiCustomerId'}                   = 'c0a8e326003ef07a4b5e12AuthT98675';
   $vars{'fiCustomerIdType'}               = 'GUID';
   $vars{'accountNumber'}                  = '77,88';
   $vars{'accountNumberType'}              = 'hostValue,displayValue';
   $vars{'accountType'}                    = 'CHECKING,CREDIT_CARD_LOAN';
   $vars{'startDate'}                      = '2013-04-01,2013-04-01';
   $vars{'endDate'}                        = '2013-06-06,2013-06-06';
   $vars{'primaryHolderId'}                = '1367009494,1367009494';
   $vars{'sortOrder'}                      = 'ASCENDING,ASCENDING';
}

################################################################################
# getContactInfoV2 (V2)
################################################################################
if ($reqType eq 'getContactInfoV2')
{
   delete $vars{'fiCustomerIdType'};
}


################################################################################
# updateContactInfoV2
################################################################################
if ($reqType eq 'updateContactInfoV2')
{

   $vars{'oldEmailAddress'}                          = '';  
   $vars{'newEmailAddress'}                          = 'test@mail.diginsite.com';   
}


################################################################################
# getFIConfigurationV2 (V2)
################################################################################
if ($reqType eq 'getFIConfigurationV2')
{
   $vars{'unsecure_secure'}         = 'securedConfig'; #Values can only be securedConfig or unsecuredConfig
   #$vars{'unsecure_secure'}         = 'unsecuredConfig'; #Values can only be securedConfig or unsecuredConfig
}

################################################################################
# hostCredentialV2 (V2)
################################################################################
if ($reqType eq 'hostCredentialV2')
{
   $vars{'newLoginId'}                   = 'ALPHA5510'; 
   $vars{'password'}                   = '11111'; 
}
################################################################################
# unlockUserV2 (V2)
################################################################################
#No Variables

################################################################################
# resetMfaV2 (V2)
################################################################################
#No Variables

################################################################################
# getUserPreferenceV2
################################################################################
#No Variables

################################################################################
# resetPasswordV2 (V2)
################################################################################
if ($reqType eq 'resetPasswordV2')
{
   $vars{'channelType'}                = 'WEB';   #Optional
   $vars{'newPassword'}                = '1111';
   $vars{'loginId'}                    = 'LukeSkyWalker';
   $vars{'userPass'}                   = '';
   $vars{'userGuid'}                   = 'c0a8ehiMatVar00h4e83447010i55f00';	#AKA fiCustomerId
   delete $vars{'requestId'};
}

################################################################################
# V2 authenticateUserV2
################################################################################
if ($reqType eq 'authenticateUserV2')
{
   $vars{'channelType'}                     = '';   #Optional
   $vars{'updateLoginAttributes'}           = '';
   $vars{'USPconversion'}                   = ''; #Optional
}

################################################################################
# validateChallangeQuestionInfoV2 (V2) # incorrect spelling
# validateChallengeQuestionInfoV2 (V2)
################################################################################
if ($reqType eq 'validateChallangeQuestionInfoV2' or $reqType eq 'validateChallengeQuestionInfoV2' )
{
   $vars{'challengeAnswer1'}                = 'answer1';
   $vars{'challengeAnswer2'}                = 'answer5';
   $vars{'challengeAnswer3'}                = 'answer9';
}

################################################################################
# challengeQuestionsV2 (V2)
################################################################################
if ($reqType eq 'challengeQuestionsV2' )
{
   $vars{'challengeAnswers1'}               = 'tree';
   $vars{'challengeAnswers2'}               = 'trunk';
   $vars{'challengeAnswers3'}               = 'roots';
   $vars{'challengeQuestionsSelected1'}     = '1';
   $vars{'challengeQuestionsSelected2'}     = '5';
   $vars{'challengeQuestionsSelected3'}     = '9';
   $vars{'optedOut'}                        = 'false';
}

################################################################################
# getAchIdV2 (V2)
################################################################################
if ($reqType eq 'getAchIdV2')
{
   $vars{'usr'}                             = 'SMOKETEST001';   #Required

   $vars{'ausr'}                            = '';
   $vars{'anum'}                            = '2';   #Required
   $vars{'atyp'}                            = '1';   #Required
}

################################################################################
# getAchIdsV2 (V2)
################################################################################
if ($reqType eq 'getAchIdsV2')
{
   $vars{'usr'}                             = 'SMOKETEST001';   #Required

   $vars{'ausr'}                            = '';
   $vars{'anum'}                            = '2';   #Required
   $vars{'atyp'}                            = '1';   #Required
}

################################################################################
# batchCurrentBalanceV2
################################################################################
if ($reqType eq 'batchCurrentBalanceV2')
{
   #$vars{'requestedDate'}                   = '__DYNAMIC(DATE{-10000, "%Y-%m-%d"})__';   #Required
   #$vars{'requestedDate'}                   = '__DYNAMIC(DATE{0, "%Y%m%d%"})__';   #Required
   $vars{'requestedDate'}                   = '__DYNAMIC(DATE{0, "%Y-%m-%d%zz"})__';   #Required
   $vars{'batchRecordsCount'}               = '1';    #Required
   $vars{'accountType'}                     = 'SAVINGS';   #Required
   #$vars{'accountType'}                     = 'CHECKING,savings';   #Required
   #$vars{'accountType'}                     = 'CHECKING,SAVINGS,MONEY MARKET';   #Required
}

################################################################################
# checkImageV2
################################################################################
if ($reqType eq 'checkImageV2')
{
   $vars{'EXPORT_BIN_IMAGE'}                = 'false';
   $vars{'acctId'}                          = 'LMkomqMm9tUz_17N8UfiC_DtShrcta23CCpiJya6pBw';
   $vars{'transDt'}                         = '__DYNAMIC(DATE{0, "%Y-%m-%d"})__';       #__DYNAMIC(DATE{0, "%Y-%m-%d"})__
   $vars{'chkNum'}                          = '4321';
   $vars{'acctIdType'}                      = 'IB';
}

###############################################################################
# checkImageIdV2
################################################################################
if ($reqType eq 'checkImageIdV2')
{
   $vars{'EXPORT_BIN_IMAGE'}                = 'false';
   $vars{'acctId'}                          = 'smQD8_kjgUWTn0GCM5U2uhYeJWTl4qTyUpTEijrvdTQ';
   $vars{'transDt'}                         = '__DYNAMIC(DATE{0, "%Y-%m-%d"})__';       #__DYNAMIC(DATE{0, "%Y-%m-%d"})__
   $vars{'checkImageIdentifier'}            = 'CfDolTXvbormNJ8Qs3UeCRJK1z5JVxC79rcq13Lit_U';
   $vars{'chkNum'}                          = '11';
   $vars{'acctIdType'}                      = 'IB';
}  


################################################################################
# depositSlipImageV2
################################################################################
if ($reqType eq 'depositSlipImageV2')
{

   $vars{'EXPORT_BIN_IMAGE'}                = 'false';
   $vars{'acctId'}                          = 'kFTtOZg7Diyokp0BBWIWQS9WikdiWwY_wXx2IHVSnbI';
   $vars{'transDt'}                         = '2009-12-07';       #__DYNAMIC(DATE{0, "%Y-%m-%d"})__
   $vars{'chkNum'}                          = '001';
   $vars{'acctIdType'}                      = 'IB';
}

################################################################################
# depositSlipImageIdV2
################################################################################
if ($reqType eq 'depositSlipImageIdV2')
{

   $vars{'EXPORT_BIN_IMAGE'}                = 'false';
   $vars{'acctId'}                          = 'exUzlo-bdhgUSMy4T6x8zBuNRwhSB6ijr1XXtv4KHj4';
   $vars{'transDt'}                         = '2012-09-20';       #__DYNAMIC(DATE{0, "%Y-%m-%d"})__
   $vars{'depositSlipIdentifier'}           = 'zG93afOqu8kkqGqpuu8pg9CcC0QdQr60sq5BIwAhcgc';
   $vars{'acctIdType'}                      = 'IB';
}


################################################################################
# getAccountsV2 (V2)
################################################################################

if ($reqType eq 'getAccountsV2')
{
   $vars{'getCrossAccts'}                    = 'true'; #OPTIONAL - It can be True or False. Any value other than 'true' or '', an XUSER request will not be sent.
   $vars{'getExportAcctNum'}                 = 'true'; #OPTIONAL - It can be True or False. Any value other than 'true', an exportAccountNumber request will be sent and if it is False then it will not sent.
}

################################################################################
# getAccountV2 (V2)
################################################################################
if ($reqType eq 'getAccountV2')
{
   $vars{'getCrossAccts'}                    = 'false'; #OPTIONAL - It can be True or False. Any value other than 'true' or '', an XUSER request will not be sent.
   $vars{'accountId'}                        = 'MJEh8pRsygsVgShZfPYwbKQj28u_Xox6fNrJ58DnhZU';
   $vars{'getExportAcctNum'}                 = 'false'; #OPTIONAL - It can be True or False. Any value other than 'true', an exportAccountNumber request will be sent and if it is False then it will not sent.
}

################################################################################
# getTransactionsV2 (V2)
################################################################################
if ($reqType eq 'getTransactionsV2')
{
   $vars{'accountId'}                       = 'NiFoPtz6_fr_AMeQuNg-tteYafVf7In0Zm1uXJBZnGk';
   #$vars{'accountId'}                       = 'tU4VbdQ6qnl3yMjM9qJERFcfj46vJEZxzIOx0rgRXHI';
   $vars{'accountIdType'}                   = '';
   $vars{'startDate'}                       = '__DYNAMIC(DATE{-9, "%Y-%m-%dT00:00:00%zz"})__';
   $vars{'endDate'}                         = '__DYNAMIC(DATE{0, "%Y-%m-%dT00:00:00%zz"})__';
   $vars{'maxRecords'}                      = '';
   $vars{'retrievePending'}                 = '';
   $vars{'sortOrder'}                       = ''; #Optional. Value can be empty. descending or ascending
   $vars{'futureTranactions'}               = 'true'; # optional -- false is default
}

################################################################################
# getTransactionsPostV2 (V2)
################################################################################
if ($reqType eq 'getTransactionsPostV2')
{
   $vars{'accountNumber'}                   = '8382392021^GARBAGE';
   $vars{'accountType'}                   = 'CHECKING';
   $vars{'primaryHolderId'}                 = '383722912';
   $vars{'startDate'}                       = '__DYNAMIC(DATE{-30, "%Y-%m-%d"})__';   # YYYY-MM-DD (Defaults to current date - 30) __DYNAMIC(DATE{-100, "%Y-%m-%d"})__
   $vars{'endDate'}                         = '__DYNAMIC(DATE{+5, "%Y-%m-%d"})__';   # YYYY-MM-DD (Defaults to current date + 5) __DYNAMIC(DATE{+5, "%Y-%m-%d"})__
}

################################################################################
# updateUserPreferenceV2
################################################################################
if ($reqType eq 'updateUserPreferenceV2')
{

   $vars{'prefId'}                          = 'com.intuit.ifs.sdp.HISTORY_RANGE';   #Values are historyRange or historySortOrder
   $vars{'value'}                           = 'currentMonth';   #values are 10, 30 or currentMonth for historyRange and ascending or desceding for historySortOrder
}

################################################################################
# validateTxRecipientV2 (V2)
################################################################################
if ($reqType eq 'validateTxRecipientV2')
{
   #$vars{'fromAccountId'}                     = '7777777333'; #required
   $vars{'fromAccountId'}                     = 'tU4VbdQ6qnl3yMjM9qJERFcfj46vJEZxzIOx0rgRXHI'; #required
   #$vars{'fromAccountId'}                     = ''; #required
   #$vars{'toAccountId'}                     = '99999999999999999'; #required
   $vars{'toAccountId'}                     = '972628729'; #required
   $vars{'methodValue'}                     = 'validate';
   $vars{'providerType'}                    = 'generic'; #only generic is supported now
   $vars{'toCustomerId'}                    = 'CBS2VALTX001'; #required - mem_number
   $vars{'toAccountType'}                   = 'SAVINGS'; #required : SAVINGS, CHECKING, MONEY_MARKET, ...
   $vars{'txPasscode'}                      = 'GRE'; #required - Last three digits of Last name (or less as applies)
}

################################################################################
# createTransferV2 (V2)
################################################################################
if ($reqType eq 'createTransferV2')
{
   $vars{'fromAccountId'}                   = 'wBmN71ZBxFKuoxwV22SxN656l6-KcCQiYDGsoF9Qpgo';
   $vars{'toAccountId'}                     = '';
   $vars{'recipientId'}                     = '7ad03f1415424805b325577850ff8cff'; # required for IntraFI transfers, but not required in other transfers.
   $vars{'amount'}                          = '3.21';
   $vars{'transferType'}                    = 'TEST_LUCKY_TRANSFER'; #optional: TRANSFER_TO_GL, TEST_TRANSFER_TO_GL
   $vars{'paymentOptionType'}               = '';
   $vars{'transferMemo'}                    = '';
   $vars{'toAcctType'}			    = ''; #optional: GENERAL_LEDGER_ACCOUNT, GENERAL_LEDGER_CODE
   $vars{'goodFundsTransfer'}               =''; #optional: set to true/false otherwise this feature is assumed to be false by the API
   $vars{'updateTransferDateTime'}          =''; #optional: if true and RC=0,10 or 16,  last_trnsf_dttm and last_srt_date columns are updated with latest time stamp.
}

################################################################################
# createRecipientV2 (V2)
################################################################################
if ($reqType eq 'createRecipientV2')
{
   $vars{'providerType'}                    = 'generic'; # generic or nonGeneric
   $vars{'accountId'}                       = '9990001002';
   $vars{'customerId'}                      = 'CBS2INTRAFI001';  # Mandatory if providerType = generic
   $vars{'accountType'}                     = 'CHECKING';  # Mandatory if providerType = generic
   $vars{'txPasscode'}                      = 'abc'; 
   $vars{'emailAddress'}                    = 'testmail@intuit.com';
   $vars{'nickName'}                        = 'nickName123'; 
}

################################################################################
# getRecipientV2 (V2)
################################################################################
if ($reqType eq 'getRecipientV2')
{
   $vars{'id'}                              = '486ee102a1fc4be992ded13d0c344be8'; # required 
}

################################################################################
# getRecipientsV2 (V2)
################################################################################
#No Variables

################################################################################
# updateRecipientV2 (V2)
################################################################################
if ($reqType eq 'updateRecipientV2')
{
   $vars{'id'}                              = '486ee102a1fc4be992ded13d0c344be8';
   $vars{'emailAddress'}                    = 'test2mail@intuit.com';
   $vars{'nickName'}                        = 'nickName456';
}

################################################################################
# deleteRecipientV2 (V2)
################################################################################
if ($reqType eq 'deleteRecipientV2')
{
   $vars{'id'}                              = '486ee102a1fc4be992ded13d0c344be8';
}

################################################################################
# createScheduledTransferV2 (V2)
################################################################################
if ($reqType eq 'createScheduledTransferV2')
{
   $vars{'fromAccountId'}                   = 'tU4VbdQ6qnl3yMjM9qJERFcfj46vJEZxzIOx0rgRXHI';
   $vars{'toAccountId'}                     = 's2flI87dc-3yCP3CyyhQ6sRAK727-v-bQMxR8PDVnlo';
   $vars{'amount'}                          = '5.0';
   $vars{'transferType'}                    = 'TRANSFER';
   $vars{'frequency'}                       = 'ONE_TIME';
   $vars{'initialTransferDate'}             = '__DYNAMIC(DATE{+3, "%Y-%m-%d%zz"})__';
   $vars{'transferMemo'}                    = '';
}

################################################################################
# getScheduledTransfersV2 (V2)
################################################################################
#No Variables

################################################################################
# updateScheduledTransferV2 (V2)
################################################################################
if ($reqType eq 'updateScheduledTransferV2')
{
   $vars{'fromAccountId'}                   = 'smQD8_kjgUWTn0GCM5U2uhYeJWTl4qTyUpTEijrvdTQ';
   $vars{'toAccountId'}                     = 'tU4VbdQ6qnl3yMjM9qJERFcfj46vJEZxzIOx0rgRXHI';
   $vars{'id'}                              = 'Calabasas57167';
   $vars{'amount'}                          = '5.0';
   $vars{'transferType'}                    = 'TRANSFER';
   $vars{'frequency'}                       = 'ONE_TIME';
   $vars{'initialTransferDate'}             = '__DYNAMIC(DATE{+3, "%Y-%m-%dT23:59:00%zz"})__';
   $vars{'transferMemo'}                    = '';
}

################################################################################
# deleteScheduledTransferV2 (V2)
################################################################################
if ($reqType eq 'deleteScheduledTransferV2')
{
   $vars{'id'}                              = 'Calabasas57169';
}

################################################################################
# updateIBStartupPageV2 (V2)
################################################################################
if ($reqType eq 'updateIBStartupPageV2')
{
   
   $vars{'ibStartupPage'}                   = 'SingleSignon.cgi';   
   delete $vars{'requestId'};
   delete $vars{'sessionId'};
   delete $vars{'clientIP'};
   delete $vars{'fiCustomerIdType'};
}
################################################################################
# invalidateUserCacheV2 and invalidateUserCacheDelV2 (V2)
################################################################################
if ($reqType eq 'invalidateUserCacheV2' or $reqType eq 'invalidateUserCacheDelV2' )
{
   delete $vars{'requestId'};
   delete $vars{'sessionId'};
   delete $vars{'clientIP'};
   delete $vars{'fiCustomerIdType'};
}

################################################################################
# getServiceStatusV2
################################################################################
if ($reqType eq 'getServiceStatusV2')
{
   $vars{'minimal'}                          = ''; # OPTIONAL
}

################################################################################
# getFiConnectivityStatusV2
################################################################################
if ($reqType eq 'getFiConnectivityStatusV2')
{
   $vars{'minimal'}                          = ''; # OPTIONAL
}
	
################################################################################
# getCheckClearStatusV2
################################################################################
if ($reqType eq 'getCheckClearStatusV2')
{
   $vars{'accountId'}                        = 'ri1DwdX82u_n-MCLMEQQXOOaK8aIBkpKRZYhinNdTP4';
   $vars{'checkId'}                          = '0001'; # CHKNM Check Number
   $vars{'checkAmount'}                      = ''; #OPTIONAL
   $vars{'checkMadeDate'}                    = ''; #OPTIONAL
}
################################################################################
# updateFICustomerWithUserInfoV2
################################################################################
if ($reqType eq 'updateFICustomerWithUserInfoV2')
{
   $vars{'operation'}              ='retrieveUserInfo';
   $vars{'newUser'}                ='false';    
   $vars{'pin'}                    ='11111';
   $vars{'fiCustomerIdType'}       ='MEMNUMBER';
}
################################################################################
# End of V2 API's
################################################################################



################################################################################
# V1 API's Below
################################################################################

################################################################################
# GetFinancialInstitution
################################################################################
#No Variables

################################################################################
# GetPrincipalEndUserDetails
################################################################################
#No Variables

################################################################################
# AuthenticateUser
################################################################################
if ($reqType eq 'AuthenticateUser')
{
   $vars{'channelType'}                     = '';   #Optional
   $vars{'updateLoginAttributes'}           = '';
}

################################################################################
# UpdateUserLastMobile
################################################################################
if ($reqType eq 'UpdateUserLastMobile')
{
   $vars{'lastMobileLogin'}                 = '__DYNAMIC(DATE{0, "%Y-%m-%dT08:03:01%zz"})__';
}

################################################################################
# UpdateUserLastActivity
################################################################################
if ($reqType eq 'UpdateUserLastActivity')
{
   $vars{'appCode'}                         = 'IPHONEBANKING';
}

################################################################################
# ValidateChallengeQuestions
################################################################################
if ($reqType eq 'ValidateChallengeQuestions')
{
   $vars{'challengeAnswer1'}                = 'tree';
   $vars{'challengeAnswer2'}                = 'trunk';
   $vars{'challengeAnswer3'}                = 'root';
}

################################################################################
# ChallengeQuestions
################################################################################
if ($reqType eq 'ChallengeQuestions')
{
   $vars{'challengeAnswer1'}                = 'tree';
   $vars{'challengeAnswer2'}                = 'trunk';
   $vars{'challengeAnswer3'}                = 'roots';
   $vars{'challengeQuestionsSelected1'}     = '1';
   $vars{'challengeQuestionsSelected2'}     = '5';
   $vars{'challengeQuestionsSelected3'}     = '9';
   $vars{'optedOut'}                        = 'false';
}

################################################################################
# UpdateIBStartupPage
################################################################################
if ($reqType eq 'UpdateIBStartupPage')
{
   $vars{'ibStartupPage'}                   = 'SingleSignon.cgi';
}

################################################################################
# InvalidateUserCache
################################################################################
#No Variables

################################################################################
# GetAccountList
################################################################################
if ($reqType eq 'GetAccountList')
{
   $vars{'getCrossAccts'}                    = 'false'; #OPTIONAL - It can be True or False. Any value other than 'true', an XUSER request will not be sent.
}
################################################################################
# GetAccount
################################################################################
if ($reqType eq 'GetAccount')
{
   $vars{'acctId'}                          = 's2flI87dc-3yCP3CyyhQ6sRAK727-v-bQMxR8PDVnlo';
   $vars{'getCrossAccts'}                   = 'false'; #OPTIONAL - It can be True or False. Any value other than 'true', an XUSER request will not be sent.
}

################################################################################
# GetAccount_PostSupport
################################################################################
if ($reqType eq 'GetAccount_Post')
{
   $vars{'accountNumber'}                   = '9900001001';
   $vars{'diAccountType'}                   = '1';
   $vars{'primaryOwner'}                    = 'true';
   $vars{'primaryHolderId'}                 = '';
   $vars{'getCrossAccts'}                   = 'false'; #OPTIONAL - It can be True or False. Any value other than 'true', an XUSER request will not be sent.
}

################################################################################
# GetTransactionList
################################################################################
if ($reqType eq 'GetTransactionList')
{
   $vars{'acctId'}                          = 'MpyBPIsy13dHQZMHY8ulSjAF2Fg2zp-EEZYFN8OZUP0';
   $vars{'startDt'}                         = '__DYNAMIC(DATE{-105, "%Y-%m-%dT00:00:00%zz"})__';   # YYYY-MM-DD (Defaults to current date - 30)
   $vars{'endDt'}                           = '__DYNAMIC(DATE{10, "%Y-%m-%dT00:00:00%zz"})__';   # YYYY-MM-DD (Defaults to TODAY)
   $vars{'userIdType'}                      = '';   #Optional. Value can be empty or 'hostLoginId'
   $vars{'sortOrder'}                       = ''; #Optional. Value can be empty. descending or ascending
   $vars{'futureTranactions'}               = 'false'; # optional -- false is default
}

################################################################################
# GetTransactionList_PostSupport
################################################################################
if ($reqType eq 'GetTransactionList_Post')
{
   $vars{'accountNumber'}                   = '6789';
   $vars{'diAccountType'}                   = '1';
   $vars{'primaryOwner'}                    = 'true';
   $vars{'primaryHolderId'}                 = '';
   $vars{'startDate'}                       = '';   # YYYY-MM-DD (Defaults to current date - 30) __DYNAMIC(DATE{-100, "%Y-%m-%d"})__
   $vars{'endDate'}                         = '';   # YYYY-MM-DD (Defaults to current date + 5) __DYNAMIC(DATE{+5, "%Y-%m-%d"})__
   $vars{'retrievePending'}                 = 'false';
   $vars{'userIdType'}                      = 'hostLoginId';   #Optional. Value can be empty or 'hostLoginId'
}

################################################################################
# CreateTransfer
################################################################################
if ($reqType eq 'CreateTransfer')
{
   $vars{'fromAccountId'}                   = 'nRx94orFMAdsaBWIPk1gZum526v3Lhj59Gck2f0E0EU';
   $vars{'toAccountId'}                     = 'MJs0KUbaDq01bry6GpaYZxeZQmH-8T-cuopj8n-ICGs';
   $vars{'amount'}                          = '10.19';
   $vars{'transferType'}                    = 'TRANSFER';
   $vars{'paymentOptionType'}               = '3';
   $vars{'transferMemo'}                    = 'Transfer Chking to Sav.';
}

################################################################################
# ScheduledTransfer
################################################################################
if ($reqType eq 'ScheduledTransfer')
{
   $vars{'fromAccountId'}                   = 'ZcqFlr9_kReCzwn7c4mKytQftBDAHKp62i3Gs42gNIU';
   $vars{'toAccountId'}                     = 'oCe-NZj0GNpss3y0NwKD5S3WpnLHnUo14LJi0bE5WDc';
   $vars{'amount'}                          = '10.21';
   $vars{'transferType'}                    = 'TRANSFER';
   $vars{'date'}                            = '__DYNAMIC(DATE{+3, "%Y-%m-%dT00:00:00%zz"})__';   # YYYY-MM-DD
}

################################################################################
# ScheduledTransferSelectList
################################################################################
#No Variables

################################################################################
# ScheduledTransferEdit
################################################################################
if ($reqType eq 'ScheduledTransferEdit')
{
   $vars{'transferId'}                      = 'Calabasas1896';   #Required
   $vars{'date'}                            = '__DYNAMIC(DATE{+5, "%m-%d-%Y"})__';   # MM-DD-YYYY
   $vars{'fromAccountId'}                   = '40000000837328292-0';
   $vars{'fromPrimaryOwner'}                = 'true';
   $vars{'toAccountId'}                     = '20000000202384721-1';
   $vars{'toPrimaryOwner'}                  = 'true';
   $vars{'amount'}                          = '1.0';
}

################################################################################
# ScheduledTransferDelete
################################################################################
if ($reqType eq 'ScheduledTransferDelete')
{
   $vars{'transferId'}                      = 'Calabasas31788';
}

################################################################################
# CheckImage
################################################################################
if ($reqType eq 'CheckImage')
{
   $vars{'EXPORT_BIN_IMAGE'}                = 'true';
   $vars{'acctId'}                          = 'kFTtOZg7Diyokp0BBWIWQS9WikdiWwY_wXx2IHVSnbI';
   $vars{'transDt'}                         = '__DYNAMIC(DATE{0, "%Y-%m-%d"})__';	#__DYNAMIC(DATE{0, "%Y-%m-%d"})__
   $vars{'chkNum'}                          = '4321';
   $vars{'acctIdType'}                      = 'IB';
}

################################################################################
# GetAchId
################################################################################
if ($reqType eq 'GetAchId')
{
   $vars{'usr'}                             = 'SMOKETEST001';   #Required

   $vars{'ausr'}                            = '';
   $vars{'anum'}                            = '2';   #Required
   $vars{'atyp'}                            = '1';   #Required
}

################################################################################
# updateUserPreference
################################################################################
if ($reqType eq 'updateUserPreference')
{
   $vars{'prefId'}                          = 'historyRange';   #Values are historyRange or historySortOrder
   $vars{'value'}                           = '30';   #values are 10, 30 or currentMonth for historyRange and ascending or desceding for historySortOrder
}

################################################################################
# End of V1 API's
################################################################################

################################################################################
################################################################################
##                     END OF CBS2 REQUEST TYPES                              ##
################################################################################
################################################################################







################################################################################
#Post Request to the CBS2 Server and Retrieve Response
################################################################################
($httpRC, $httpResHeader, $request, $response) = CBS2_lib::cbs2ATI($reqType, \%vars, $envType);
if ( $httpRC eq 'UNKNOWN' ) { print $response; exit 1; }

################################################################################
#Display Output
################################################################################
if ($showRaw ne '')
#Print request/response in raw form
{
   print "Raw CBS2 Request:\n$request\n\n";
   print "Raw CBS2 Response:\n\nHTTP Reponse Code:\n$httpRC\n\nHTTP Response Headers:\n$httpResHeader\n\nHTTP Reponse Body:\n$response\n\n";
}
else
#Print response in parsed form
{
   #CheckImage: Export binary image file
   if (lc($vars{'EXPORT_BIN_IMAGE'}) eq 'true')
   {
      my $encodedFront = '';
      my $encodedBack  = '';
      my $decodedFront = '';
      my $decodedBack  = '';

      if ($reqType eq 'CheckImage') {
        #Parse out $encodedFront and $encodedBack
        $encodedFront = CBS2_lib::returnXmlValue($response, 'chkImageFront', '', 'Y');
        $encodedBack  = CBS2_lib::returnXmlValue($response, 'chkImageBack', '', 'Y');

        #Decode and print out check image front
        if ($encodedFront ne '') {
          $decodedFront = MIME::Base64::decode($encodedFront);

          if(!open(OUT, ">" . 'bin_image_front.gif')) {
            #Could not open
              print "\nWARN: Unable to create front check image.\n";
          } else {
            print OUT $decodedFront;
            close(OUT);
          }
        }

        #Decode and print out check image back
        if ($encodedBack ne '') {
          $decodedBack = MIME::Base64::decode($encodedBack);

          if(!open(OUT, ">" . 'bin_image_back.gif')) {
            #Could not open
            print "\nWARN: Unable to create back check image.\n";
           } else {
            print OUT $decodedBack;
            close(OUT);
           }
         }
       } else {
         # For checkImageV2 & depositSlipImageV2???
            
         my $numCount = 0;
         my $matchString = ':checkImage>';
         my @checkImageArr = split(/$matchString/,$response);
         my $checkImageCount = @checkImageArr;
         $checkImageCount = ($checkImageCount - 1);

	 foreach my $string (@checkImageArr) {
		 
	   if ($string =~ 'FRONT') {
             #Parse out $encodedFront and $encodedBack
             $encodedFront = CBS2_lib::returnXmlValue($response, 'image>', '', 'Y');
        
             #Decode and print out check image front
             if ($encodedFront ne '') {
               $decodedFront = MIME::Base64::decode($encodedFront);

               if (!open(OUT, ">" . 'bin_image_front.gif')) {
                 #Could not open
                 print "\nWARN: Unable to create check image front.\n";
               } else {
                 print OUT $decodedFront;
                 close(OUT);
               }
             }
           } elsif ($string =~ 'BACK') {
            #Parse out $encodedFront and $encodedBack
             $encodedBack = CBS2_lib::returnXmlValue($response, 'image>', '', 'Y');

             #Decode and print out check image front
             if ($encodedBack ne '') {
               $decodedBack = MIME::Base64::decode($encodedBack);

               if (!open(OUT, ">" . 'bin_image_back.gif')) {
                 #Could not open
                 print "\nWARN: Unable to create check image back.\n";
               } else {
                 print OUT $decodedBack;
                 close(OUT);
               }
             }
           }
         }
       }
     }

   #Save response for getAccountUSRSUMV2 API before calling the parser since the response is DIIS data
   if ($reqType eq 'getAccountUSRSUMV2')
   {
     $responseInput = $response;
   }
   
   #Parse Response from CBS2 Server
   ($status, $response) = CBS2_lib::cbs2ParseXML($httpRC, $httpResHeader, $reqType, $vars{'CBS2INTERFACE'}, $response, \%parsedRes);

   #Print output response for all API except for getAccountUSRSUMV2 since it requires extra processing
   if ($reqType ne 'getAccountUSRSUMV2')
   {   
     #Print Results from %parsedRes Hash
     ($status, $response) = GLOBAL_lib::print3DHash2Screen(\%parsedRes);
   }
   #process data fro getAccountUSRSUMV2
   else
   {
     #Header only
     ($status, $response) = GLOBAL_lib::print3DHash2Screen(\%parsedRes);
     
     #parsing for the DIIS Data
     %parsedRes          = ();
     $diisReqType = 'USRSUM';

     #parser for the DIIS data
     ($status, $responseInput) = DIIS_lib::diisParseRes($diisReqType, $responseInput, \%parsedRes);

     #Print Results From %parsedRes Hash - DIIS Data parsed
     $status = GLOBAL_lib::print3DHash2aScreen(\%parsedRes);
   }
}

