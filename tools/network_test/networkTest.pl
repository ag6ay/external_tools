#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##    networkTest.pl - Validate network connectivity.                         ##
##                                                                            ##
##                     Created by: David Schwab                               ##
##                     Last Updated: DS (05/15/2014) Ver. 1.0                 ##
##                                                                            ##
################################################################################
################################################################################
use warnings;
use strict;
use IO::Socket;
use Cwd;


################################################################################
#Set Configurations Below                                                      #
################################################################################
my $timeout = '5';
################################################################################
#End of Configurations                                                         #
################################################################################











#################################################
#Subroutine Prototype
#################################################
sub readFileIntoArray($$);
sub httpRequestCurl($$$$);
sub headerString2Hash($$);


#################################################
#Define Variables
#################################################
my $version                  = '1.0';
my $parameter1               = (lc($ARGV[0]) || '');
my $status                   = '';
my $msg                      = '';
my $failedFlag               = 'false';
my $fileNamePath             = '';
my @networkArray             = ();
my $testSocket               = '';
my $url                      = '';
my $outboundProxy            = '';
my $requestHeaders           = '';
my $expectedHttpResponseCode = '';
my $host                     = '';
my $port                     = '';
my $actualHttpResponseCode   = '';



################################################################################
#Start Program
################################################################################

#Check usage
if ( $parameter1 eq '' )
{
   $msg =  "****************************************************************************************************\n" .
           "                                   Network Test Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 fileName\n\n" .
           "         fileName  -  Required. Input file containing list of host:port dependencies to test.\n\n" .
           "****************************************************************************************************\n\n\n";


   print $msg;
   exit 0;
}



#Set $fileNamePath
$fileNamePath = cwd . "/$parameter1";

#Open $fileNamePath and read into @networkArray
($status, $msg) = readFileIntoArray($fileNamePath, \@networkArray);
if ($status ne 'OK')
{
   print $msg;
   exit 1;
}


#Turn auto flush on
$| = 1;


#Starting tests
print "Running network tests...";


#Test network
foreach (@networkArray)
{
   #http test
   if (substr($_, 0, 4) eq 'http')
   {
      #Split $url, $outboundProxy, $requestHeaders, $expectedHttpResponseCode
      ($url, $outboundProxy, $requestHeaders, $expectedHttpResponseCode) = split(',', $_);

      $actualHttpResponseCode = httpRequestCurl($url, $requestHeaders, $timeout, $outboundProxy);
      if ($actualHttpResponseCode ne $expectedHttpResponseCode)
      {
         #Http test failed
         $failedFlag = 'true';
         print "\n    FAILED: $url - Expected: $expectedHttpResponseCode, instead got: $actualHttpResponseCode";
      }
      else
      {
         #Nothing to do
      }
   }
   #Socket Test
   else
   {
      #Split host and port
      ($host, $port) = split(':', $_);

      $testSocket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port, Timeout => $timeout);
      if (! $testSocket )
      {
         #Socket test failed
         $failedFlag = 'true';
         print "\n    FAILED: $host:$port - $!";
      }
      else
      {
         #Socket test passed
         close($testSocket);
      }
   }
}

if ($failedFlag eq 'true')
{
   print "\nNetwork test failed.\n";
}
else
{
   print "PASSED\n";
}
################################################################################
#End Program
################################################################################
















################################################################################
#All Subroutines Below
################################################################################

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

         #Trim leading/trailing spaces
         $line =~ s/^\s+|\s+$//g;

         #Skip empty lines and comments
         if ( ($line eq '') || (substr($line, 0, 1) eq '#') )
         {
            next;
         }

         #Perform file format checks
         if (substr($line, 0, 4) eq 'http')
         {
            #Format here should be: http[s]://domain[:port]/resource,[proxy],[request_headers],expected_http_response_code
            @count = $line =~ /\,/g;
            $stringCount = @count;
            if ($stringCount != 3)
            {
               $msg = "ERROR (readFileIntoArray): File format error (line $lineNumber): Expected 3 comma delimiters, instead got $stringCount. $line\n";
               close (FILE);
               return ('ERROR', $msg);
            }
         }
         else
         {
            #Format here should be hostname:port
            @count = $line =~ /\:/g;
            $stringCount = @count;
            if ($stringCount != 1)
            {
               $msg = "ERROR (readFileIntoArray): File format error (line $lineNumber): Expected 1 colon delimiter, instead got $stringCount. $line\n";
               close (FILE);
               return ('ERROR', $msg);
            }
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



################################################################################
# httpRequestCurl -
################################################################################
sub httpRequestCurl($$$$)
{
   my $url                 = $_[0];
   my $headerData          = $_[1];
   my $timeoutVal          = $_[2];
   my $outboundProxy       = $_[3];

   my $status              = '';
   my $curlRequest         = '';
   my $curlProxy           = '';
   my $curlHttpBody        = '';
   my $httpResCode         = '';
   my %requestHeaderHash   = ();
   my $key                 = '';
   my $value               = '';
   my $curlHeaderString    = '';


   #Set $headerData
   if ($headerData ne '')
   {
      $status = headerString2Hash($headerData, \%requestHeaderHash);

      foreach $key (keys %requestHeaderHash)
      {
         $curlHeaderString .= "-H \"$key: $requestHeaderHash{$key}\" "
      }
   }

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


   #Construct $curlRequest
   $curlRequest = "curl -sL -w \"%{http_code}\" -m $timeoutVal $curlProxy $curlHeaderString $url -o /dev/null 2>&1";


   #Execute command
   chomp($httpResCode = `$curlRequest`);


   return ($httpResCode);
}


################################################################################
# headerString2Hash - $headerString format: key1=value1;key2=value2
#                     where = and ; are url encoded as %3D and %3B respectively
################################################################################
sub headerString2Hash($$)
{
   my $headerString = $_[0];
   my $hashRef      = $_[1];

   my $numHeaders   = 0;
   my $i            = 0;
   my $strPos       = 0;
   my $keyValue     = '';
   my $key          = '';
   my $value        = '';


   if ( $headerString ne '' )
   {
      while ($headerString =~ m/;/g)
      {
         $numHeaders++;
      }

      for ( $i = 1; $i <= $numHeaders + 1; $i++ )
      {
         #Get $keyValue
         $strPos = index($headerString, ';');
         if ( $strPos >= 0 )
         {
            #Get $keyValue from $headerString
            $keyValue = substr($headerString, 0, $strPos);

            #Strip $keyValue out of $headerString
            $headerString = substr($headerString, $strPos + length(';'));
         }
         else
         {
            $keyValue = $headerString;
         }

         #Parse $keyValue into $hashRef
         $strPos = index($keyValue, '=');
         if ( $strPos >= 0 )
         {
            $key = substr($keyValue, 0, $strPos);
            $value = substr($keyValue, $strPos + length('='));

            #Search and replace %3D and %3B
            $key =~ s/%3D/=/g;
            $key =~ s/%3B/;/g;
            $value =~ s/%3D/=/g;
            $value =~ s/%3B/;/g;

            $hashRef->{$key} = $value;
         }
      }
   }


   return ('OK');
}
