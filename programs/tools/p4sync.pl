#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   p4sync.pl - This script can be used on a QA Linux or Windows machine to  ##
##               keep your IATF workspace up to date in the QA environment.   ##
##                                                                            ##
##               Created by: David Schwab                                     ##
##               Last Updated: DS - 4/14/2011 Ver. 1.00                       ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;


system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/automation-framework/dbConnect/...');
system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/testing-software/...');
system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/test-plan_test-results/...');
system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/test-cases/...');
system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/test-data/...');
system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/httpsim/...');
system('p4 -u qa-infrastructure-auto -P "qa@ut0!@#" sync //depot/QA/autop4sync/...');
