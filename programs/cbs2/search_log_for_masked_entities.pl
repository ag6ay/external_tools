#!/usr/bin/perl
#
#
#
# search_log_for_masked_entities.pl
#
# using the log configuration file as the guide look at (an extract of) cbs2_req_res.log 
# and examine the extract to ensure fields that are to be masked are properly masked.
#
#
#

use strict;
use warnings;

use English;

use Getopt::Long;

use Data::Dumper;

# use XML;	# Okay, I had a dream...

my $Version = "0.00.04";

my $infile="DEFAULT";
my $infilestring="";
my @infilearray=();
my $logconfigfile="DEFAULT";
my $logconfigstring="";
my %logconfighash=();
my %logconfigtestcount=();
my %logconfigmatchcount=();

my $logXmlLinesChecked=0;
my $logLinesRead=0;

my %emptyTags=();	# top key Container, lower key fieldname, value instance count
my %maskErrors=();	# top key Container, middle key fieldname, lower key bad value, value instance count

my $result="";
my $helpout=0;

my $xmlwithnewlinesappends=0;

my $xmlNonMatches=0;

my $debugflag = 0;

sub usage() {
	print "\n";
	print "\n";
	print "$0\n";
	print "\n";
	print "\tUsage:\n";
	print "\n";
	print "\n";
	print "\t\t--help\t\t\t\tThis help message.\n";
	print "\t\t--debug\t\t\t\tScript debugging info.\n";
	print "\t\t--version\t\t\tprint script version.\n";
	print "\t\t--infile=filename\t\tInput log extract file name.\n";
	print "\t\t--logconfigfile=filename\tLog mask configuation file name.\n";
	print "\n";
}

$result = GetOptions(	
			'help' => sub { $helpout++ } ,
			'debug' => sub {$debugflag++;},
			'version' => sub {print STDERR "$0 version $Version.\n";},
		     	'infile=s' => \$infile,
		     	'logconfigfile=s' => \$logconfigfile,
			);

if ( $helpout > 0 ) {
	usage();
	exit 0;
}

#print "Parse result = '$result'.\n";
print "infile = '$infile'.\n";
print "logconfigfile= = '$logconfigfile'.\n";

if ( ! -f $infile ) {
	warn "input log file '$infile' does not exist.\n";
	$result=0;
	}

if ( ! -f $logconfigfile ) {
	warn "log mask config file '$logconfigfile' does not exist.\n";
	$result=0;
	}

die ("\nCommand line argument(s) error.  Script exiting.\n") unless $result == 1;

open INFILE, $logconfigfile or die "Unable to open log mask config file '$logconfigfile', error: $!";
	{
	local $/ = undef;	# undef the line terminator causes whole file to be read at once...
	$logconfigstring=<INFILE>;
	}
close INFILE;

open INFILE, $infile or die "Unable to open log input file '$infile', error: $!";
	{
	#local $/ = undef;
	#$infilestring=<INFILE>;
	@infilearray=<INFILE>;
	chomp @infilearray;
	}
close INFILE;

#
#
# Parse the control file into a hash, keyed off of objectNames
#
#

print "length of data in logconfig file = ", length $logconfigstring,".\n";
print "log mask control xml = '$logconfigstring'.\n";

$logconfigstring =~ s/<\?.*\?>//;
$logconfigstring =~ s/<[\/]{0,1}maskObjects>//g;
$logconfigstring =~ s/\n\n/\n/g;
$logconfigstring =~ s/[[:space:]]{2,}/ /g;
$logconfigstring =~ s/> </></g;

#print "logconfigstring partially parsed = '$logconfigstring'\n";


while (length $logconfigstring) {
	my $pos = index $logconfigstring, "</maskObject>";
	if ( not defined $pos ) {
		print STDERR "logconfigstring = '$logconfigstring'.\n";
		die "Unable to find ='</maskObject>'";
	}
	my $substr = substr $logconfigstring, 1, $pos - 1;
	last if length($substr) < 13;
	$logconfigstring = substr $logconfigstring, $pos+12;	# len </maskObject>
	my $objectKey;
	my $entityKey;
	my $entity;
	my $object;
	$substr =~ s/^.*<maskObject id="([-A-Za-z0-9_.]{1,})">[[:space:]]{0,}//;
	$objectKey = $1;
	print "Object Key = '$objectKey'.\n" unless $debugflag < 8;
	print "Start object: '$substr'.\n" unless $debugflag < 8;
	$substr =~ s/[[:space:]]{1,}$//;
	$object = $substr;
	while (length $object) {
		my $conceal=0;
		$object =~ s.(<maskField[> ]{1}[^<]{1,}</maskField>)..;
		$entity = $1;
		#print "object = '$object'.\n";
		$entity =~ s.<[/]{0,1}maskField[ >]{1}..g;
		#print "entity = '$entity'.\n";
		$entity =~ s/(conceal="true">)//;
		$conceal=1 unless not defined $1;
		#print "entity = '$entity', conceal = $conceal.\n";
		$logconfighash{$objectKey}{$entity} = $conceal;
	}
}

my @logConfigKeys = ( keys %logconfighash );

# print "Log config hashed: ", Dumper(\%logconfighash);

print "length of data in log file = ", length $infilestring,".\n";

my $xmlstring='';
my $searchstate='';
my $outerContainerName='';
my $searchstr='((Response|Request) XML --> <\\?xml([^\n]{1,}))$';
foreach my $originalMatch ( @infilearray ) {
	$logLinesRead++;
	print "Log Line $logLinesRead searchstate = '$searchstate' Original Match = '$originalMatch'.\n" unless $debugflag < 4;
	$searchstate eq '' and do {
		if ( $originalMatch =~  m/$searchstr/ ) {
			$logXmlLinesChecked++;
			if ( $originalMatch =~ m/\?>$/ ) {	# only the <?xml line?
				$searchstate='1';
				next;
			}
			$xmlstring = $originalMatch;
			#$xmlstring =~ s/^[^<]{0,}<\\?xml(^\\?>){0,}\\?>//;
			$xmlstring =~ s/^[^<]{0,}<\?xml[^\?]{0,}\?>//;	# remove <?xml... ?> #### and no, I don't like this regexp...
		} else {
			next;
		}
	};
	$searchstate eq '1' and do {
		next unless length $originalMatch > 0;
		if ( $originalMatch =~ m/^[^<]{0,}<([^> ]+)(>| [A-Za-z][^>]{0,}>)/ ) {
			$outerContainerName=$1;			# have the outercontainer name !!!  
			# print "outerContainerName='$outerContainerName'.\n";
			$xmlstring = $originalMatch;
			$searchstate='2';
		}
		next;
	};
	$searchstate eq '2' and do {
		$xmlstring .= $originalMatch;
		my $matchstr="</$outerContainerName>";
		# print "outerContainerName='$outerContainerName', matchstr='$matchstr'.\n";
		if ( not defined $outerContainerName ) {
			print "Undefined outerContainerName logLinesRead = $logLinesRead, XML line $logXmlLinesChecked.\n";
		}
		if ( $originalMatch =~ m&$matchstr& ) {
			$searchstate='';		# found end of XML string with new lines in it... WHEW!
		} else {
			next;
		}
	};
	print "Checking XML Line $logXmlLinesChecked.\n" if ($logXmlLinesChecked % 100) == 1;
	$xmlstring =~ s/^[[:space:]]{1,}//g;
	$xmlstring =~ s/\n[[:space:]]{1,}</\n</g;
	$xmlstring =~ s/>[[:space:]]{1,}</></g;
	$xmlstring =~ s/>[\n]{1,}</></g;
	chomp $xmlstring;
	print "xml string = '$xmlstring'.\n" unless $debugflag < 4;

	my $orig_xmlstring = $xmlstring;

	#
	# we have the XML string for the request/response... now parse it!!!
	#

	my $index = index $xmlstring, ' ';
	my $containerName = substr $xmlstring, 0, $index ;

	print "containerName = '$containerName'.\n" unless $debugflag < 8;

	my $foundName='';

	foreach my $name ( @logConfigKeys ) {
		$foundName='';
		if ( $containerName =~ m/<(.*${name}[^[:space:]>]*)/ ) {
			$foundName=$1;
			my @namespaces=();

			print "Found a container type $name for $containerName foundName = '$foundName'.\n" unless $debugflag < 8;

			$xmlstring =~ s&<[/]{0,1}$foundName[^<]{0,}>&&g;
			$xmlstring =~ s&<([/]{0,1})[A-Za-z][-A-Za-z0-9_.]{0,}:&<$1&g;
			$xmlstring =~ s&^\n&&;
			chomp $xmlstring;
			
			print "xmlstring sans container and namespaces = '$xmlstring'.\n" unless $debugflag < 8;

			# ************* DOES NOT YET HANDLE:  xmlstring sans container and namespaces = '<account xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns6:DepositAccount">

			my $xmlcheckcount=10000;
			while ( length $xmlstring ) {
				print "xml string leading = '", substr($xmlstring, 0, 30), "'\n" unless $debugflag < 8;
				$xmlstring =~ m&^</& and do {
					# found an end tag by itself... better make sure it is the one to be popped from @namespaces
					# and remove it from xmlstring...
					$xmlstring =~ s&^</([^>]{1,})>&&;
					chomp $xmlstring;
					my $lclfound = $1;
					# print "Solo end tag... '$lclfound'\n";
					my $offstack = pop @namespaces;
					if ( $lclfound ne $offstack ) {
						print "( $lclfound ne $offstack ).\n";
						}
					next;
					};
				$xmlstring =~ m&^<& and do { # ah... an entity to look at...
					$xmlstring =~ m&^<([A-Za-z][-A-Za-z0-9._]{0,})([/ >])&;
					my $fieldname = $1;
					my $indication = $2;
					my $fieldvalue="";
					if ( not defined $fieldname ) {
						print "Container '$containerName' fieldname not defined, xml='$xmlstring'.\n";
					}
					print "Found front tag... fieldname == '$fieldname', indication '$indication'.\n" unless $debugflag < 8;
					if ($xmlstring =~ m&^<$fieldname/>& ) {
						# an empty tag that we allegedly will never see (HA!!!)
						print "Container '$containerName' empty tag '$fieldname'.\n" unless $debugflag < 2;
						$emptyTags{$containerName}{$fieldname}++;
						$xmlstring =~ s&^<$fieldname/>&&;
						next;
					}
					if ($xmlstring =~ m&^<$fieldname[^>]{0,}><[^/]& ) {
						# A subcontainer name... how quaint...
						print "Subcontainer $fieldname.\n" unless $debugflag < 8;
						push @namespaces, $fieldname;
						$xmlstring =~ s&^<$fieldname[^>]{0,}>&&;
						next;
					}
					$xmlstring =~ m&^<$fieldname[^>]{0,}>([^<>]{0,})</$fieldname>&;
					$fieldvalue = $1;
					if ( defined $logconfighash{$name}{$fieldname} ) {
						print "Have a masked field $fieldname in $name ($foundName), value $fieldvalue, conceal = $logconfighash{$name}{$fieldname}.\n" unless $debugflag < 4;
						my $testvalue=$fieldvalue;
						if ( $logconfighash{$name}{$fieldname} ) {
							# full value must be masked...
						} else {
							$testvalue = substr $testvalue, 0, -4;	# chop off right hand 4 characters... those are in the clear...
						}
						$testvalue =~ s/\*//g;				# remove mask
						print "Container '$containerName' Field '$fieldname' value '$fieldvalue' testvalue '$testvalue' conceal '$logconfighash{$name}{$fieldname}'!!!\n" unless $debugflag < 4;
					if ( $testvalue ne '' ) {
							print "ERROR:  Field '$fieldname' value '$fieldvalue' not properly masked!!!\n" unless $debugflag < 1;
							$maskErrors{$containerName}{$fieldname}{$fieldvalue}++;
						}
						
					} else {
						print "Have an umasked field $fieldname in $name ($foundName), value $fieldvalue.\n" unless $debugflag < 32;
					}

					print "Removing '$fieldname' from xmlstring...\n" unless $debugflag < 4;
					$xmlstring =~ s&^<$fieldname[^>]{0,}>[^<]{0,}</$fieldname>[\n]{0,}&&;
					$xmlstring =~ s&^[^<]{1,}<&<&;
					print "xmlstring is now '$xmlstring'.\n" unless $debugflag < 4;
					last unless $xmlstring =~ m/</;		# when we are out of <, we are out of here...
					};
			}
			last;		# don't bother with the other hash keys...
		}
	}
	if ( $foundName eq '' ) {
		$xmlNonMatches++;
	}
}

END {
	print "\n$0 version $Version.\n";
	if ( $result != 1 or $helpout > 0 ) {
		return;
	}
	print "Number of lines read into array: ", scalar @infilearray, "\n";
	print "Number of lines in log file looked at: ", $logLinesRead, "\n";
	print "Number of XML 'lines' checked:  $logXmlLinesChecked.\n";
	print "Number of XML 'lines' with non-matching containers: $xmlNonMatches.\n";
	print "Empty tags '<xyzzy/>' found: ", Dumper(\%emptyTags) unless not scalar keys %emptyTags ;
	print "Number of masked errors found: ", scalar keys %maskErrors, "\n";
	print "Masked field errors found: ", Dumper(\%maskErrors) unless not scalar keys %maskErrors ;
}
