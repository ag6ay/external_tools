#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   fsgUpdateConfigs.pl - Updates FSG configuration files to facilitate      ##
##                         switching back and forth between live services     ##
##                         and the httpsim.                                   ##
##                                                                            ##
##                         Created by: David Schwab                           ##
##                         Last updated: DS - 03/07/2013 Ver. 1.4             ##
##                                                                            ##
##                         FSG Version: 3.8                                   ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
system('clear');



###################################
#Subroutine Prototype
###################################
sub updateConfigFile($$$);


###################################
#Declare Variables Below
###################################
my $parameter1              = (lc($ARGV[0]) || '');
my $parameter2              = (lc($ARGV[1]) || '');
my $parameter3              = (lc($ARGV[2]) || '');
my $parameter4              = ($ARGV[3] || '');
my $versionNumber           = '1.4';
my $param1                  = '';
my $param2                  = '';
my $param3                  = '';
my $status                  = '';





################################################################################
#                         Set Configurations Below
################################################################################
my $env                    = 'qa';   #qa or pte
my $muleShortName          = 'servicesgateway-inst1-onlineserv';       #WLV QA Short Name
#my $muleShortName          = 'servicesgateway';                       #QDC QA Short Name
my $qaCbsLivePort          = '8180';
my $qaMockServer           = 'mariner1a.web.qa.diginsite.com:8880';    #WLV QA HTTP SIM
#my $qaMockServer           = 'pqalfsgas100.corp.intuit.net:8880';     #QDC QA HTTP SIM
my $perfMockServer         = 'matrix1a.web.qa.diginsite.com:8780';
my %servicesgatewayConfigs = ();
my %configsConfigs         = ();
my %endpointsConfigs       = ();



###################################
#Set QA configurations below
###################################
if ($env eq 'qa')
{
   #############################################################################
   #Web Tier Configurations Below
   #############################################################################
   if ($parameter3 eq 'web')
   {
      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/
      #############################################################################
      $servicesgatewayConfigs{'security-config.xml'}{'live'}{'cbs_url'}                     = "http://cbs2-vip.app.qa.diginsite.com:$qaCbsLivePort/cbs2";
      $servicesgatewayConfigs{'security-config.xml'}{'mock'}{'cbs_url'}                     = "http://$qaMockServer/cbs2";

      $servicesgatewayConfigs{'security-config.xml'}{'live'}{'cas_url'}                     = "http://services-qal.banking.intuit.net";
      $servicesgatewayConfigs{'security-config.xml'}{'mock'}{'cas_url'}                     = "http://$qaMockServer/cas-web";


      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/configs/
      #############################################################################
      $configsConfigs{'client-security-config.xml'}{'live'}{'oauth_url'}                    = "https://10.144.23.113";
      $configsConfigs{'client-security-config.xml'}{'mock'}{'oauth_url'}                    = "http://$qaMockServer";


      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/configs/endpoints/
      #############################################################################
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'live'}{'cas_url'}                   = "http://services-qal.banking.intuit.net";
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'mock'}{'cas_url'}                   = "http://$qaMockServer/cas-web";

      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'live'}{'cbs_url'}                   = "http://cbs2-vip.app.qa.diginsite.com:$qaCbsLivePort/cbs2";
      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'mock'}{'cbs_url'}                   = "http://$qaMockServer/cbs2";

      $endpointsConfigs{'cc_2_3-endpoint-config.xml'}{'live'}{'ccbp_url'}                   = "https://butest.ccbp.intuit.com/CCBillPay/services";
      $endpointsConfigs{'cc_2_3-endpoint-config.xml'}{'mock'}{'ccbp_url'}                   = "http://$qaMockServer/CCBillPay/services";

      $endpointsConfigs{'cc_2_3-endpoint-config.xml'}{'live'}{'ccbp_pen'}                   = "<proxyEnabled>true</proxyEnabled>";
      $endpointsConfigs{'cc_2_3-endpoint-config.xml'}{'mock'}{'ccbp_pen'}                   = "<proxyEnabled>false</proxyEnabled>";

      $endpointsConfigs{'idfed_1_0-endpoint-config.xml'}{'live'}{'idfed_url'}               = "https://10.144.23.114";
      $endpointsConfigs{'idfed_1_0-endpoint-config.xml'}{'mock'}{'idfed_url'}               = "http://$qaMockServer";

      $endpointsConfigs{'locatorsearch_1_0-endpoint-config.xml'}{'live'}{'ls_url'}          = "http://ifsapi.locatorsearch.com/LocatorSearchAPI.asmx";
      $endpointsConfigs{'locatorsearch_1_0-endpoint-config.xml'}{'mock'}{'ls_url'}          = "http://$qaMockServer/LocatorSearchAPI.asmx";

      $endpointsConfigs{'locatorsearch_1_0-endpoint-config.xml'}{'live'}{'ls_pen'}          = "<proxyEnabled>true</proxyEnabled>";
      $endpointsConfigs{'locatorsearch_1_0-endpoint-config.xml'}{'mock'}{'ls_pen'}          = "<proxyEnabled>false</proxyEnabled>";

      $endpointsConfigs{'oauth_1_0-endpoint-config.xml'}{'live'}{'oauth_url'}               = "https://10.144.23.113";
      $endpointsConfigs{'oauth_1_0-endpoint-config.xml'}{'mock'}{'oauth_url'}               = "http://$qaMockServer";

      $endpointsConfigs{'prs_1_0-endpoint-config.xml'}{'live'}{'prs_url'}                   = "http://prs-vip.web.qa.diginsite.com:8680/prs";
      $endpointsConfigs{'prs_1_0-endpoint-config.xml'}{'mock'}{'prs_url'}                   = "http://$qaMockServer/prs";

      $endpointsConfigs{'rdc_2_0-endpoint-config.xml'}{'live'}{'vertifi_url'}               = "https://test.vertifi.com/rdc/sso";
      $endpointsConfigs{'rdc_2_0-endpoint-config.xml'}{'mock'}{'vertifi_url'}               = "http://$qaMockServer/rdc/sso";

      $endpointsConfigs{'rdc_2_0-endpoint-config.xml'}{'live'}{'vertifi_pen'}               = "<proxyEnabled>true</proxyEnabled>";
      $endpointsConfigs{'rdc_2_0-endpoint-config.xml'}{'mock'}{'vertifi_pen'}               = "<proxyEnabled>false</proxyEnabled>";

      $endpointsConfigs{'vertifi_3_0-endpoint-config.xml'}{'live'}{'vertifi_url'}               = "https://test.vertifi.com/rdc/sso";
      $endpointsConfigs{'vertifi_3_0-endpoint-config.xml'}{'mock'}{'vertifi_url'}               = "http://$qaMockServer/rdc/sso";

      $endpointsConfigs{'vertifi_3_0-endpoint-config.xml'}{'live'}{'vertifi_pen'}               = "<proxyEnabled>true</proxyEnabled>";
      $endpointsConfigs{'vertifi_3_0-endpoint-config.xml'}{'mock'}{'vertifi_pen'}               = "<proxyEnabled>false</proxyEnabled>";

      $endpointsConfigs{'ensenta_3_0-endpoint-config.xml'}{'live'}{'vertifi_url'}               = "https://webdeposit.test.ensenta.com/PartnerAPI";
      $endpointsConfigs{'ensenta_3_0-endpoint-config.xml'}{'mock'}{'vertifi_url'}               = "http://$qaMockServer/rdc/sso";

      $endpointsConfigs{'ensenta_3_0-endpoint-config.xml'}{'live'}{'vertifi_pen'}               = "<proxyEnabled>true</proxyEnabled>";
      $endpointsConfigs{'ensenta_3_0-endpoint-config.xml'}{'mock'}{'vertifi_pen'}               = "<proxyEnabled>false</proxyEnabled>";
   }
   #############################################################################
   #App Tier Configurations Below
   #############################################################################
   elsif ($parameter3 eq 'app')
   {
      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/configs/endpoints/
      #############################################################################
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'live'}{'cas_url'}                   = "http://services-qal.banking.intuit.net";
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'mock'}{'cas_url'}                   = "http://$qaMockServer/cas-web";

      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'live'}{'cbs_url'}                   = "http://cbs2-vip.app.qa.diginsite.com:$qaCbsLivePort/cbs2";
      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'mock'}{'cbs_url'}                   = "http://$qaMockServer/cbs2";
   }
}
###################################
#Set PERF configurations below
###################################
elsif($env eq 'pte')
{
   #############################################################################
   #Web Tier Configurations Below
   #############################################################################
   if ($parameter3 eq 'web')
   {
      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/
      #############################################################################
      $servicesgatewayConfigs{'security-config.xml'}{'live'}{'cbs_url'}                     = "http://cbs2-pte-vip.app.qa.diginsite.com:8180/cbs2";
      $servicesgatewayConfigs{'security-config.xml'}{'mock'}{'cbs_url'}                     = "http://$perfMockServer/cbs2";

      $servicesgatewayConfigs{'security-config.xml'}{'live'}{'cas_url'}                     = "http://perf.cas.intuit.net/cas-web";
      $servicesgatewayConfigs{'security-config.xml'}{'mock'}{'cas_url'}                     = "http://$perfMockServer/cas-web";


      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/configs/
      #############################################################################
      $configsConfigs{'client-security-config.xml'}{'live'}{'oauth_url'}                    = "https://10.144.24.110";
      $configsConfigs{'client-security-config.xml'}{'mock'}{'oauth_url'}                    = "http://$perfMockServer";


      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/configs/endpoints/
      #############################################################################
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'live'}{'cas_url'}                   = "http://perf.cas.intuit.net/cas-web";
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'mock'}{'cas_url'}                   = "http://$perfMockServer/cas-web";

      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'live'}{'cbs_url'}                   = "http://cbs2-pte-vip.app.qa.diginsite.com:8180/cbs2";
      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'mock'}{'cbs_url'}                   = "http://$perfMockServer/cbs2";

      $endpointsConfigs{'idfed_1_0-endpoint-config.xml'}{'live'}{'idfed_url'}               = "https://10.144.24.117";
      $endpointsConfigs{'idfed_1_0-endpoint-config.xml'}{'mock'}{'idfed_url'}               = "http://$perfMockServer";

      $endpointsConfigs{'oauth_1_0-endpoint-config.xml'}{'live'}{'oauth_url'}               = "https://10.144.24.110";
      $endpointsConfigs{'oauth_1_0-endpoint-config.xml'}{'mock'}{'oauth_url'}               = "http://$perfMockServer";

      $endpointsConfigs{'prs_1_0-endpoint-config.xml'}{'live'}{'prs_url'}                   = "http://prs-pte-vip.web.qa.diginsite.com:8680/prs";
      $endpointsConfigs{'prs_1_0-endpoint-config.xml'}{'mock'}{'prs_url'}                   = "http://$perfMockServer/prs";
   }
   #############################################################################
   #App Tier Configurations Below
   #############################################################################
   elsif ($parameter3 eq 'app')
   {
      #############################################################################
      #Set all configurations within <MULE_HOME>/apps/servicesgateway/configs/endpoints/
      #############################################################################
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'live'}{'cas_url'}                   = "http://perf.cas.intuit.net/cas-web";
      $endpointsConfigs{'cas_4_0-endpoint-config.xml'}{'mock'}{'cas_url'}                   = "http://$perfMockServer/cas-web";

      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'live'}{'cbs_url'}                   = "http://cbs2-vip.app.qa.diginsite.com:$qaCbsLivePort/cbs2";
      $endpointsConfigs{'cbs_2_0-endpoint-config.xml'}{'mock'}{'cbs_url'}                   = "http://$perfMockServer/cbs2";
   }
}









################################################################################
#Usage
################################################################################
if($parameter1 eq '')
{
   my $usage = "****************************************************************************************************\n" .
               "                               fsgUpdateConfigs Ver. $versionNumber\n" .
               "\n" .
               "            This script will switch FSG back and forth between live and mocked services.\n" .
               "****************************************************************************************************\n\n" .
               '   USAGE:  $ ./fsgUpdateConfigs.pl PARAM1 PARAM2 PARAM3 [MULE_SHORTNAME]' . "\n\n\n" .
               '   PARAM1 - Required.  Valid PARAM1 values are:' . "\n\n" .
               '           l[ive]    - switch to live services.' . "\n" .
               '           m[ock]    - switch to mock services.' . "\n\n" .
               '   PARAM2 - Required.  Valid PARAM2 values are:' . "\n\n" .
               '           j[mx]     - reload configurations using jmx reload (does not restart FSG).' . "\n" .
               '           r[estart] - reload by doing a hard restart of FSG.' . "\n\n" .
               '   PARAM3 - Required.  Valid PARAM3 values are:' . "\n\n" .
               '           web       - update configurations for web tier.' . "\n" .
               '           app       - update configurations for app tier.' . "\n\n" .
               '   MULE_SHORTNAME - Optional.  Overwrites $muleShortName.  Example: servicesgateway-inst1-onlineserv' . "\n\n" .
               "****************************************************************************************************\n\n\n";

   print $usage;
   exit 0;
}




################################################################################
#Check for valid $parameter1 values
################################################################################
if( (lc($parameter1) eq 'l') || (lc($parameter1) eq 'live') || (lc($parameter1) eq 'm') || (lc($parameter1) eq 'mock') )
{
   $param1 = substr($parameter1, 0, 1);
}
else
{
   print "Error: Invalid PARAM1 value: $parameter1. See usage.\n";
   exit 1;
}


################################################################################
#Check for valid $parameter2 values
################################################################################
if( (lc($parameter2) eq 'j') || (lc($parameter2) eq 'jmx') || (lc($parameter2) eq 'r') || (lc($parameter2) eq 'restart') )
{
   $param2 = substr($parameter2, 0, 1);
}
else
{
   print "Error: Invalid PARAM2 value: $parameter2. See usage.\n";
   exit 1;
}


################################################################################
#Check for valid $parameter3 values
################################################################################
if( (lc($parameter3) eq 'web') || (lc($parameter3) eq 'app') )
{
   $param3 = substr($parameter3, 0, 1);
}
else
{
   print "Error: Invalid PARAM3 value: $parameter3. See usage.\n";
   exit 1;
}



################################################################################
#Check for valid $parameter4 values
################################################################################
if( $parameter4 ne '' )
{
   $muleShortName = $parameter4;
}






###################################
#Declare Remaining Variables Below
###################################
my $muleHomeName            = $muleShortName . '-home';
my $muleHome                = '/opt/mule/' . $muleHomeName . '/';
my $servicesgatewayPath     = $muleHome . 'apps/servicesgateway/';
my $configsPath             = $muleHome . 'apps/servicesgateway/configs/';
my $endpointsPath           = $muleHome . 'apps/servicesgateway/configs/endpoints/';
my $fsgCtlScript            = '/etc/init.d/' . $muleShortName;
my $fsgBin                  = $muleHome . 'bin/';









################################################################################
#Switch to live services (mock -> live)
################################################################################
if ($param1 eq 'l')
{
   $status = updateConfigFile(\%servicesgatewayConfigs, 'live', $servicesgatewayPath);
   if ($status ne 'OK') { print "$status\n"; exit 1; }

   $status = updateConfigFile(\%configsConfigs, 'live', $configsPath);
   if ($status ne 'OK') { print "$status\n"; exit 1; }

   $status = updateConfigFile(\%endpointsConfigs, 'live', $endpointsPath);
   if ($status ne 'OK') { print "$status\n"; exit 1; }
}
################################################################################
#Switch to mock services (live -> mock)
################################################################################
elsif ($param1 eq 'm')
{
   $status = updateConfigFile(\%servicesgatewayConfigs, 'mock', $servicesgatewayPath);
   if ($status ne 'OK') { print "$status\n"; exit 1; }

   $status = updateConfigFile(\%configsConfigs, 'mock', $configsPath);
   if ($status ne 'OK') { print "$status\n"; exit 1; }

   $status = updateConfigFile(\%endpointsConfigs, 'mock', $endpointsPath);
   if ($status ne 'OK') { print "$status\n"; exit 1; }
}








################################################################################
#Reload configurations using jmx reload (does not restart FSG)
################################################################################
if ($param2 eq 'j')
{
   #Turn auto flush on
   $| = 1;

   #Use Open Pipe Method
   open(CMD, "cd $fsgBin; ./jmxcmd.sh reload 2>&1 |") || die "Failed: $!\n";
   while (<CMD>)
   {
      print $_;
   }
   close(CMD);
}
################################################################################
#Reload by doing a hard restart of FSG
################################################################################
elsif ($param2 eq 'r')
{
   #Turn auto flush on
   $| = 1;

   #Use Open Pipe Method
   open(CMD, "$fsgCtlScript restart 2>&1 |") || die "Failed: $!\n";
   while (<CMD>)
   {
      print $_;
   }
   close(CMD);
}






################################################################################
#                         All Subroutines Below                                #
################################################################################

################################################################################
#
# updateConfigFile subroutine -
#
#
################################################################################
sub updateConfigFile($$$)
{
   my $hashRef        = $_[0];
   my $updateType     = $_[1];
   my $updatePath     = $_[2];


   my $errMsg         = '';
   my $searchValue    = '';
   my $replaceValue   = '';
   my $request        = '';
   my $response       = '';
   my $fileNameKey    = '';
   my $updateKey      = '';
   my $slashChar      = '/';
   my $escapeSlash    = '\/';
   my $dotChar        = '.';
   my $escapeDot      = '\.';
   my $colonChar      = ':';
   my $escapeColon    = '\:';
   my %invert         = ();
   $invert{'live'}    = 'mock';
   $invert{'mock'}    = 'live';

   for $fileNameKey (keys %$hashRef)
   {
      for $updateKey (keys %{$hashRef->{$fileNameKey}{$updateType}})
      {
         $searchValue = $hashRef->{$fileNameKey}{$invert{$updateType}}{$updateKey};
         $replaceValue = $hashRef->{$fileNameKey}{$updateType}{$updateKey};

         #Escape special characters in $searchValue
         $searchValue =~ s/\Q$slashChar\E/$escapeSlash/g;
         $searchValue =~ s/\Q$dotChar\E/$escapeDot/g;
         $searchValue =~ s/\Q$colonChar\E/$escapeColon/g;

         $request = "sed -i \"s#$searchValue#$replaceValue#g\" $updatePath" . $fileNameKey;
         $response = `$request 2>&1`;

         if ($response ne '')
         {
            $errMsg = "ERROR (updateConfigFile):\nCommand Request:\n$request\nCommand Response:\n$response\n";
            return ($errMsg);
            exit 1;
         }
      }
   }


   return ('OK');
}
