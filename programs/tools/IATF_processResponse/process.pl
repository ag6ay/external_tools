#!/usr/bin/perl -w
#------------------------------------------------------------
#
#	Script to parse out the automation "actual results"
#	 and format them so that you can copy and paste into
#	 IATF excel "expected results"
#
#
#	v1.0 - Alex Bryan 
#		-Created
#
#------------------------------------------------------------

use strict;
use Getopt::Std;


#---------------------------------------
# Get the option for the file name. 
#---------------------------------------
getopts('f:');
our($opt_f);


#---------------------------------------
# Create a hash of arrays to store the
#---------------------------------------
my @AoH;



#---------------------------------------
# Verify that a file was given
# Then process the file splitting up 
# each line 
# ----------
# Sample of line to process:
# accountId=2152 accountName=Star One Creditnew1 accountNickname=Star One Creditnew1 amount=123 autoPayment=false billPaymentDate=2013-03-22 billPaymentId=106132 categoryId=2624 categoryName=None confirmationNumber=WBWB7Z94 createdTime=2013-03-01T10:35:48.713-08:00 currencyCode=USD deliveryMethod=STANDARD_ELECTRONIC expectedDeliveryDate=2013-03-22 lastUpdatedTime=2013-03-01T10:35:48.713-08:00 memo=test payeeAccountNumber=****2347 payeeId=79762 payeeName=Toyota Financial Services payeeNickname=Toyota Financial Services revision=1 status=SCHEDULED
# ----------
# Resulting hash:
# values $AoH[0]{accountId} = 2152
# ----------
#---------------------------------------
if ( defined $opt_f ) {
	open( my $fh, "<$opt_f") || die "$opt_f does not open: $!\n";
	while (<$fh>) { 
		# processResponse with return a hash. Splitting all the values from accountId=2152 to { accountId => 2152 }
		# Then we push the hash of all the values into an array. This allows us to support
		# multi line responses.
		push @AoH, { &processResponse("$_") };
	}
	close ($fh);
} else { 
	&help();
}


#---------------------------------------
# Open up the iatfHeader file. This file
# should be the headers from IATF so
# that we can correctly map the response
# to the IATF columns
#---------------------------------------
my @iatfHeader;
open ( my $fh, "<./iatfHeader" ) || die "Couldn't open iatfHeader\n";
while (<$fh>) {
	#print;
	@iatfHeader = split(/\t/, $_);
}
close ($fh);



#---------------------------------------
# Print the header line to keep things
# in order when pasing into excel.
#---------------------------------------
foreach my $h (@iatfHeader) {
	print "$h\t";
}
print "\n";




#---------------------------------------
# Get the number of lines in the response
#---------------------------------------
my $dataLines = @AoH;
my $count = 0;

#---------------------------------------
# For every line in the response print
# in the correct order according to the
# defined headers
#---------------------------------------
until ($count > $dataLines){
	foreach my $header (@iatfHeader) {
		if ( (defined $header) && ($header ne "") ) {
			if (defined $AoH[$count]{$header}) {
				print "$AoH[$count]{$header}\t";
			} else {
				print "\t";
			}
		} else {
			print "\t";
		}
	}

	print "\n";
	$count++
}



#---------------------------------------
# In some caes values are returned that
# are not mapped in the IATF. This will
# display the mappings that will need to
# be added. 
#---------------------------------------
my $lineCount = 1;
for my $href ( @AoH ) {
my %exists;
	for my $role ( keys %$href ) {
		$exists{$role} = 0;
		foreach my $header (@iatfHeader) {
			if ("$role" eq "$header") {
				$exists{$role} = 1;
			}	
		}
	}


	print "Line $lineCount need to add mapping for:\t";
	for my $value ( keys %exists ) {
		if ( $exists{$value} != 1 ) {
			print "$value($href->{$value})\t";
		}
	}
	print "\n";
	$lineCount++;
}


#---------------------------------------
# SUBROUTINES
#---------------------------------------
sub processResponse
{
	my %valueHash;
	chomp $_[0];

	# This is where the magic happens. 
	# The parentheses in the split command create a backreference.
	# This backreference is then added to the array "returnedValues.
	# The resulting array looks like this:
	# ("accountId=", "2152", "accountName=", "Star One Creditnew1", "accountNickname=", "Star One Creditnew1", "amount=", "123")
	my @returnedValues = split(/(\w*=)/, $_[0]);

	while (@returnedValues) {
		# in some cases $returnedValues[0] is empty. This removes that empty value from the array.
		if ( (! defined $returnedValues[0]) || ($returnedValues[0] eq "") ) {
			shift @returnedValues;
		}

		# shifting off the first value of the array and setting it to the key. (for the hash key later)
		# shifting off the next value and setting it to the value. (again for the hash that will be created)
		my $key = shift(@returnedValues);
		my $value = shift(@returnedValues);

		# Remove the equal(=) sign
		$key =~ s/=$//;
		# Remove space at the end of the value
		$value =~ s/ $//;
		
		# Push the value into the hash
		# ex: $valueHash{accountId} = 2152
		$valueHash{$key} = $value;
	}

	# Once we're done building the hash return it. 
	return %valueHash;
	
}

sub help
{
	print "Usage: $0 -f <datafile>\n";
	print "ex: $0 -f data.txt\n";
	exit 0
}
