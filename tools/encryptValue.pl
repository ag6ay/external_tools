#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   encryptValue.pl - Encrypts a sensitve data value which can later         ##
##                     decrypted using the following IATF DYNAMIC function:   ##
##                     __DYNAMIC(DECRYPT{encrypted_valued})__                 ##
##                                                                            ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: DS - 12/13/2011 Ver. 1.00                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib '../../qa_lib';
use GLOBAL_lib;
system('clear');


##################################
#INITIALIZE VARIABLES
##################################
my $inString       = ($ARGV[0] || '');
my $encryptedValue = '';


##################################
#USAGE
##################################
if ($inString eq '')
{
   print "USAGE:  \$ ./encryptValue.pl \"<value_to_encrypt>\"\n\n";
}
##################################
# ENCRYPT VALUE
##################################
else
{
   $encryptedValue = GLOBAL_lib::encryptValue($inString);
   print "Encrypted Value:\n$encryptedValue\n\n";
}
