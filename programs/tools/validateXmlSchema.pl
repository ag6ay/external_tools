#!/usr/bin/perl -w
################################################################################
################################################################################
##                                                                            ##
##   validateXmlSchema.pl - This script will recursively search for xml       ##
##                          files and validate against an xml schema          ##
##                          definition file.                                  ##
##                                                                            ##
##                          Created by: David Schwab                          ##
##                          Last Updated: DS - 03/03/2011 Ver. 1.00           ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use File::Find;
system('clear');

#################################################
#Set Configurations Below
#################################################
our $searchDir      = '/home/jboss/qa/temp/';
our $searchForFiles = '.xml';
our $xsdFilePath    = '/opt/jboss/cbs2-V1.1.0.4-home/server/default/configs/config/schemas/cbs2-config.xsd';


find(\&fileFound, $searchDir);


########################################
#
# sub fileFound
#
########################################
sub fileFound()
{
   #This is a file (skip over directories)
   if (-f)
   {
      my $filePath = $File::Find::name;

     #Filter xml files to validate based on $searchForFiles value
     if ($filePath =~ $searchForFiles)
     {
        my $command = "xmllint --noout --schema $xsdFilePath $filePath";
        my $result = `$command`;
     }
   }
}
