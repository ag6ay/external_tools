#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##  sgpTests.pl - Tests to help validate Services Gateway Proxy.              ##
##                                                                            ##
##                  Created by: David Schwab                                  ##
##                  Last Updated: DS - 06/07/2014 Ver. 2.0                    ##
##                                                                            ##
################################################################################
################################################################################
use warnings;
use strict;
use Cwd;



################################################################################
#Set Configurations Below
################################################################################
my $timeout                          = '10';
my $p4port                           = 'p4.diginsite.com:1780';
my $p4user                           = 'dschwab';
my $p4client                         = 'dschwab-datagroups';
my $p4passwordFile                   = 'p4pass.txt';
my $debugLogging                     = 'false';
my $intuit_appId                     = 'SDP';
my $intuit_tid                       = 'fc86db2a-7b62-4ffb-a26a-1b5fd7872037';
my $intuit_offeringId                = 'SGPTEST00001';
my $intuit_originatingIp             = '10.10.10.10';
my $userAgent                        = 'sgpTests - Internal DI Testing';
my $contentType                      = 'application/xml';
my $runTestsWithDiFiidPrefix         = 'true';
my $outboundProxy                    = '';
my $isgpUrlToUse                     = 'di'; #values can be: (1) 'intuit' or (2) 'di'
my %swimlaneActiveDC                 = ();
#qal1 environment
$swimlaneActiveDC{'qal1'}{'1'}       = 'a';
$swimlaneActiveDC{'qal1'}{'2'}       = 'a';
$swimlaneActiveDC{'qal1'}{'11'}      = 'q';
$swimlaneActiveDC{'qal1'}{'12'}      = 'q';
#qal2 environment
$swimlaneActiveDC{'qal2'}{'1'}       = 'a';
$swimlaneActiveDC{'qal2'}{'2'}       = 'a';
#prd1 environment
$swimlaneActiveDC{'prd1'}{'1'}       = 'l';
$swimlaneActiveDC{'prd1'}{'2'}       = 'l';
$swimlaneActiveDC{'prd1'}{'3'}       = 'l';
$swimlaneActiveDC{'prd1'}{'4'}       = 'l';
$swimlaneActiveDC{'prd1'}{'5'}       = 'l';
$swimlaneActiveDC{'prd1'}{'6'}       = 'l';
$swimlaneActiveDC{'prd1'}{'11'}      = 'a';
$swimlaneActiveDC{'prd1'}{'12'}      = 'a';
$swimlaneActiveDC{'prd1'}{'13'}      = 'a';
$swimlaneActiveDC{'prd1'}{'14'}      = 'a';
$swimlaneActiveDC{'prd1'}{'15'}      = 'a';
$swimlaneActiveDC{'prd1'}{'16'}      = 'a';
my %mappedSwimLane                   = ();
$mappedSwimLane{'1'}                 = '1';
$mappedSwimLane{'2'}                 = '2';
$mappedSwimLane{'3'}                 = '3';
$mappedSwimLane{'4'}                 = '4';
$mappedSwimLane{'5'}                 = '5';
$mappedSwimLane{'6'}                 = '6';
$mappedSwimLane{'11'}                = '1';
$mappedSwimLane{'12'}                = '2';
$mappedSwimLane{'13'}                = '3';
$mappedSwimLane{'14'}                = '4';
$mappedSwimLane{'15'}                = '5';
$mappedSwimLane{'16'}                = '6';
my %mappedEnvironment                = ();
$mappedEnvironment{'qal1'}{'a'}      = 'qal1';
$mappedEnvironment{'qal1'}{'b'}      = 'qal1';
$mappedEnvironment{'qal2'}{'a'}      = 'qal2';
$mappedEnvironment{'qal2'}{'b'}      = 'qal2';
$mappedEnvironment{'qal1'}{'q'}      = 'qal';
$mappedEnvironment{'qal1'}{'w'}      = 'qal';
$mappedEnvironment{'prd1'}{'a'}      = 'prd1';
$mappedEnvironment{'prd1'}{'b'}      = 'prd1';
$mappedEnvironment{'prd1'}{'q'}      = 'prd';
$mappedEnvironment{'prd1'}{'l'}      = 'prd';
$mappedEnvironment{'prd1'}{'w'}      = 'prd';
my %authHash                         = ();
$authHash{'qal1'}{'SDP'}             = '33737ecd8d64d24b226cc09a9ccfd33';
$authHash{'qal2'}{'SDP'}             = '33737ecd8d64d24b226cc09a9ccfd33';
$authHash{'prd1'}{'SDP'}             = 'bc1f2337a8864b61a6c37f2597c38e1c';
my %isgpUrlHash                      = ();
#qal1 environment
$isgpUrlHash{'qal1'}{'intuit'}       = 'http://services-qal.banking.intuit.net';
$isgpUrlHash{'qal1'}{'di'}           = 'http://api.qal1.diginsite.net';
#qal2 environment
$isgpUrlHash{'qal2'}{'intuit'}       = 'n/a';
$isgpUrlHash{'qal2'}{'di'}           = 'http://api.qal2.diginsite.net';
#prd1 environment
$isgpUrlHash{'prd1'}{'intuit'}       = 'http://services.banking.intuit.net';
$isgpUrlHash{'prd1'}{'di'}           = 'http://api.prd1.diginsite.net';
################################################################################
#End of Configurations
################################################################################














###################################
# Subroutine Prototype
###################################
sub writeLog($);
sub getCurDateTime($);
sub readFileIntoHash($$);
sub httpRequestCurl($$$$$$$$);
sub parseServerHeaderResponseValue($);
sub runISgpTest($$$$$$$$$$$);



#################################################
#Define Variables
#################################################
my $version                  = '2.0';
my $parameter1               = (lc($ARGV[0]) || '');
my $status                   = '';
my $msg                      = '';
my $output                   = '';
my $envType                  = '';
my $dataGroupFilePath        = '';
my %dataGroupHash            = ();
my $fiid                     = '';
my $diFiid                   = '';
my $swimlane                 = '';
my $isgpUrl                  = '';
my %requestHeaders           = ();
my $expectedFsgLocation      = '';
my $failedFlag               = 'false';
my $p4passwordFilePath       = '';




################################################################################
#Start Program
################################################################################

#Check usage
if ( ($parameter1 ne 'qal1') && ($parameter1 ne 'qal2') && ($parameter1 ne 'prd1') )
{
   $msg =  "****************************************************************************************************\n" .
           "                                   SGP Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <environment>\n\n" .
           "         <environment>  -  Required. Valid environment values:\n" .
           "                   qal1 -  qal1 environment.\n" .
           "                   qal2 -  qal2 environment.\n" .
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


#Set $isgpUrl
if (exists $isgpUrlHash{$envType}{$isgpUrlToUse})
{
   $isgpUrl = $isgpUrlHash{$envType}{$isgpUrlToUse};
}
else
{
   print "ERROR: Unable to lookup isgpUrl for specified environment ($envType) and isgpUrlToUse ($isgpUrlToUse).\n";
   exit 1;
}


#Turn auto flush on
$| = 1;


#Starting tests
print "Running isgp tests...";


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


   #Set %requestHeaders
   $requestHeaders{'Authorization'}        = $authHash{$envType}{$intuit_appId};
   $requestHeaders{'intuit_offeringId'}    = $intuit_offeringId;
   $requestHeaders{'intuit_appId'}         = $intuit_appId;
   $requestHeaders{'intuit_originatingIp'} = $intuit_originatingIp;
   $requestHeaders{'intuit_tid'}           = $intuit_tid;


   #Set $expectedFsgLocation
   $expectedFsgLocation = "$swimlaneActiveDC{$envType}{$swimlane}-$mappedEnvironment{$envType}{$swimlaneActiveDC{$envType}{$swimlane}}-$mappedSwimLane{$swimlane}";


   #Run test using all numeric fiid
   ($status) = runISgpTest($fiid, $swimlane, \%requestHeaders, $userAgent, $timeout, $contentType, 'GET', '', $outboundProxy, $expectedFsgLocation, \$failedFlag);


   #Run test using DI prefix fiid
   if ($runTestsWithDiFiidPrefix eq 'true')
   {
      if ( substr($fiid, 0, 1) eq '0' )
      {
         #Set $diFiid
         $diFiid = 'DI' . substr($fiid, 1);

         ($status) = runISgpTest($diFiid, $swimlane, \%requestHeaders, $userAgent, $timeout, $contentType, 'GET', '', $outboundProxy, $expectedFsgLocation, \$failedFlag);
      }
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
   my $logFile   = 'sgpTests.log';


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
# httpRequestCurl -
################################################################################
sub httpRequestCurl($$$$$$$$)
{
   my $url                 = $_[0];
   my $headerDataHashRef   = $_[1];
   my $agent               = $_[2];
   my $timeoutVal          = $_[3];
   my $contentType         = $_[4];
   my $requestType         = $_[5];
   my $requestData         = $_[6];
   my $outboundProxy       = $_[7];

   my $curlRequest         = '';
   my $curlHeaders         = '';
   my $curlProxy           = '';
   my $curlHttpBody        = '';
   my $httpResCode         = 'NA';
   my $httpResponseHeader  = 'NA';
   my $httpResponseBody    = '';
   my $key                 = '';


   #Set $curlProxy
   if ($outboundProxy ne '')
   {
      if ( substr(lc($outboundProxy), 0, 7) eq 'http://' )
      {
         $curlProxy = '-x ' . substr($outboundProxy, 7);
      }
      else
      {
         $curlProxy = '-x ' . $outboundProxy;
      }
   }


   #Get size of $headerDataHashRef
   if (keys(%$headerDataHashRef) > 0)
   {
      #Generate curl header string
      for $key (sort keys %$headerDataHashRef)
      {
         $curlHeaders .= "-H '$key: $headerDataHashRef->{$key}' ";
      }
   }
   

   #Set $curlHttpBody
   if (lc($requestData) ne '')
   {
      $curlHttpBody = "-d $requestData";
   }


   #Construct $curlRequest
   $curlRequest = "curl -vsSN -m $timeoutVal -X $requestType $curlHttpBody $curlProxy -H 'User-Agent: $agent' $curlHeaders $url 2>&1";

   #Execute command
   chomp($httpResponseBody = `$curlRequest`);


   return ($httpResCode, $httpResponseHeader, $httpResponseBody);
}



################################################################################
# parseServerHeaderResponseValue -
################################################################################
sub parseServerHeaderResponseValue($)
{
   my $input                 = $_[0];

   my $status                = '';
   my $value                 = '';
   my $strPos1               = 0;
   my $strPos2               = 0;


   #Search and replace "\r\n" with "\n"
   $input =~ s/\r\n/\n/g;


   $strPos1 = index(lc($input), '< server: financialservicesgateway.');
   if ($strPos1 >= 0)
   {
      $strPos2 = index($input, "\n", $strPos1 + length('< server: financialservicesgateway.'));
      if ($strPos2 >= 0)
      {
         #Parse fsg <data_center>-<env>[-<swim_lane>]
         $value = substr($input, $strPos1 + length('< server: financialservicesgateway.'), $strPos2 - $strPos1 - length('< server: financialservicesgateway.'));

         $status = 'OK';
      }
      else
      {
         $status = 'ERROR';
      }
   }
   else
   {
      $status = 'ERROR';
   }


   return ($status, $value);
}



################################################################################
# runISgpTest -
################################################################################
sub runISgpTest($$$$$$$$$$$)
{
   my $fiid                  = $_[0];
   my $swimlane              = $_[1];
   my $reqHeadersHashRef     = $_[2];
   my $userAgent             = $_[3];
   my $timeout               = $_[4];
   my $contentType           = $_[5];
   my $requestMethod         = $_[6];
   my $requestData           = $_[7];
   my $outboundProxy         = $_[8];
   my $expectedFsgLocation   = $_[9];
   my $failedFlagRef         = $_[10];

   my $status                = '';
   my $httpResCode           = '';
   my $httpResponseHeader    = '';
   my $httpResponseBody      = '';
   my $actualFsgLocation     = '';


   #Make getFI request
   ($httpResCode, $httpResponseHeader, $httpResponseBody) = httpRequestCurl("$isgpUrl/v2/fis/$fiid", \%requestHeaders, "$userAgent sl$swimlane", $timeout, $contentType, 'GET', '', $outboundProxy);


   #Parse out $actualFsgLocation from Server header response
   ($status, $actualFsgLocation) = parseServerHeaderResponseValue($httpResponseBody);
   if ($status ne 'OK')
   {
      #Write error to log
      $status = writeLog("Testing $fiid (sl$swimlane)...ERROR - Bad http response.\n$httpResponseBody\n");

      $$failedFlagRef = 'true';
      print "\n$fiid (sl$swimlane), got bad http response (see logs), ...FAILED.";
   }
   else
   {
      #Validate $actualFsgLocation with $expectedFsgLocation
      if ($actualFsgLocation eq $expectedFsgLocation)
      {
         #Write results to log
         $status = writeLog("$fiid (sl$swimlane), expected: $expectedFsgLocation, actual: $actualFsgLocation, ...PASSED");
      }
      else
      {
         #Write results to log
         $status = writeLog("$fiid (sl$swimlane), expected: $expectedFsgLocation, actual: $actualFsgLocation, ...FAILED");

         #Write full response to log
         $status = writeLog("\n$httpResponseBody");

         $$failedFlagRef = 'true';
         print "\n$fiid (sl$swimlane), expected: $expectedFsgLocation, actual: $actualFsgLocation, ...FAILED.";
      }
   }


   return ('OK');
}
