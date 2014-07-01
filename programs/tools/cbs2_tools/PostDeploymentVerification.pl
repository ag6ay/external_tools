#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##  PostDeploymentVerification.pl -                                           ##
##                    Post Deployment Verification.     					  ##
##                                                                            ##
##                   Created by:   Baba Venkat Ram Raju Mahagosaivar          ##
##                   Last updated: Raju M- 10/31/2012 Ver. 1.0                ##
##                                                                            ##
##                   CBS2 Version: 2.3.0                                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
system('clear');

################################################################################
# Configure $env Variable. Possible $env values are:
#
# dev_dev_qdc_100  - http://pdevcbsas100.corp.intuit.net:8080
# dev_prod_qdc_101 - http://pdevcbsao101.corp.intuit.net:8080
# dev_qa_qdc_102   - http://pdevcbsas102.corp.intuit.net:8080
# dev_ite_qdc_103  - http://pdevcbsas103.corp.intuit.net:8080
# dev_alt_qdc_100  - http://pdevcbsao100.corp.intuit.net:8080
#
# qa_qdc_300        - http://pqalcbsas300.ie.intuit.net:8080
# qa_qdc_301        - http://pqalcbsas301.ie.intuit.net:8080
# qa_qdc_302        - http://pqalcbsas302.ie.intuit.net:8080
# qa_qdc_303        - http://pqalcbsas303.ie.intuit.net:8080
#
# perf_qdc_300      - http://pprfcbsas300.ie.intuit.net:8080
# perf_qdc_301      - http://pprfcbsas301.ie.intuit.net:8080
#
# beta_qdc_300      - http://pprdcbsas300.ie.intuit.net:8080
# beta_qdc_301      - http://pprdcbsas301.ie.intuit.net:8080
#
# uat_qdc_300       - http://pe2ecbsas300.ie.intuit.net:8080
# uat_qdc_301       - http://pe2ecbsas301.ie.intuit.net:8080
#
# prod_qdc_302      - http://pprdcbsas302.ie.intuit.net:8080
# prod_qdc_303      - http://pprdcbsas303.ie.intuit.net:8080
# prod_qdc_306      - http://pprdcbsas306.ie.intuit.net:8080
# prod_qdc_304      - http://pprdcbsas304.ie.intuit.net:8080
# prod_qdc_305      - http://pprdcbsas305.ie.intuit.net:8080
# prod_qdc_30b      - http://pprdcbsas30b.ie.intuit.net:8080
# prod_qdc_30c      - http://pprdcbsas30c.ie.intuit.net:8080
# prod_qdc_30d      - http://pprdcbsas30d.ie.intuit.net:8080
# prod_qdc_30e      - http://pprdcbsas30e.ie.intuit.net:8080
# prod_qdc_30s      - http://pprdcbsas30s.ie.intuit.net:8080
# prod_qdc_30t      - http://pprdcbsas30t.ie.intuit.net:8080
# prod_qdc_30u      - http://pprdcbsas30u.ie.intuit.net:8080
#
# prod_lvdc_40b     - http://pprdcbsas40b.corp.intuit.net:8080
# prod_lvdc_40c     - http://pprdcbsas40c.corp.intuit.net:8080
# prod_lvdc_40h     - http://pprdcbsas40h.corp.intuit.net:8080
# prod_lvdc_40d     - http://pprdcbsas40d.corp.intuit.net:8080
# prod_lvdc_40e     - http://pprdcbsas40e.corp.intuit.net:8080
# prod_lvdc_40i     - http://pprdcbsas40i.corp.intuit.net:8080
# prod_lvdc_40k     - http://pprdcbsas40k.corp.intuit.net:8080
# prod_lvdc_40l     - http://pprdcbsas40l.corp.intuit.net:8080
# prod_lvdc_40m     - http://pprdcbsas40m.corp.intuit.net:8080
# prod_lvdc_40n     - http://pprdcbsas40n.corp.intuit.net:8080
# prod_lvdc_40o     - http://pprdcbsas40o.corp.intuit.net:8080
# prod_lvdc_40p     - http://pprdcbsas40p.corp.intuit.net:8080
#
# stagg_lvdc_400    - http://ppdscbsas400.ie.intuit.net:8080
# 
# qa_wlv_1a_8180    - phoenix1a.app.qa.diginsite.com:8180
# qa_wlv_1b_8180    - phoenix1b.app.qa.diginsite.com:8180
# qa_wlv_1a_8280    - phoenix1a.app.qa.diginsite.com:8280
# qa_wlv_1a_8280    - phoenix1b.app.qa.diginsite.com:8280
#
# pte_wlv_8180      - http://cbs2-pte-vip.app.qa.diginsite.com:8180
# pte_wlv_8280      - http://cbs2-pte-vip.app.qa.diginsite.com:8280
#
# beta_wlv          -  http://phoenix88a.app.prod.diginsite.com:8180
#
# preprod_wlv       - http://phoenix88a.app.prod.diginsite.com:8380
# 
# prod_wlv_VIP      - http://cbs2-vip.live.diginsite.com:8180
# prod_wlv_1c       - http://phoenix1c.app.prod.diginsite.com:8180
# prod_wlv_1d       - http://phoenix1d.app.prod.diginsite.com:8180
# prod_wlv_1e       - http://phoenix1e.app.prod.diginsite.com:8180
# prod_wlv_1f       - http://phoenix1f.app.prod.diginsite.com:8180
#
#
#
#  APIs
#  -------------------------
#  getServiceStatusV2
################################################################################
my $env = '';

my @servers = (
#    Server     Flag
#   --------   ------
[qw/ dev_dev_qdc_100   n   /],
[qw/ dev_prod_qdc_101  n   /],
[qw/ dev_qa_qdc_102    n   /],
[qw/ dev_ite_qdc_103   n   /],
[qw/ dev_alt_qdc_100   n   /],
[qw/ qa_qdc_300        n   /],
[qw/ qa_qdc_301        n   /],
[qw/ qa_qdc_302        n   /],
[qw/ qa_qdc_303        n   /],
[qw/ perf_qdc_300      n   /],
[qw/ perf_qdc_301      n   /],
[qw/ beta_qdc_300      n   /],
[qw/ beta_qdc_301      n   /],
[qw/ uat_qdc_300       n   /],
[qw/ uat_qdc_301       n   /],
[qw/ prod_qdc_302      n   /],
[qw/ prod_qdc_303      n   /],
[qw/ prod_qdc_306      n   /],
[qw/ prod_qdc_304      n   /],
[qw/ prod_qdc_305      n   /],
[qw/ prod_qdc_30b      n   /],
[qw/ prod_qdc_30c      n   /],
[qw/ prod_qdc_30d      n   /],
[qw/ prod_qdc_30e      n   /],
[qw/ prod_qdc_30s      n   /],
[qw/ prod_qdc_30t      n   /],
[qw/ prod_qdc_30u      n   /],
[qw/ prod_lvdc_40b     n   /],
[qw/ prod_lvdc_40c     n   /],
[qw/ prod_lvdc_40h     n   /],
[qw/ prod_lvdc_40d     n   /],
[qw/ prod_lvdc_40e     n   /],
[qw/ prod_lvdc_40i     n   /],
[qw/ prod_lvdc_40k     n   /],
[qw/ prod_lvdc_40l     n   /],
[qw/ prod_lvdc_40m     n   /],
[qw/ prod_lvdc_40n     n   /],
[qw/ prod_lvdc_40o     n   /],
[qw/ prod_lvdc_40p     n   /],
[qw/ stagg_lvdc_400    n   /],
[qw/ qa_wlv_1a_8180    n   /],
[qw/ qa_wlv_1b_8180    n   /],
[qw/ qa_wlv_1a_8280    n   /],
[qw/ qa_wlv_1b_8280    n   /],
[qw/ pte_wlv_8180      n   /],
[qw/ pte_wlv_8280      n   /],
[qw/ beta_wlv          n   /],
[qw/ preprod_wlv       n   /],
[qw/ prod_wlv_VIP      n   /],
[qw/ prod_wlv_1c       n   /],
[qw/ prod_wlv_1d       n   /],
[qw/ prod_wlv_1e       n   /],
[qw/ prod_wlv_1f       n   /],
);

################################################################################
# Definitions Set Below
################################################################################
my %vars     = ();
my $response = '';
my $debug    = 'true';
my $isWLV = 'n';
my $WLV_inst_home = 'cbs2-inst1-prod-home';
my $request  = '';
my $dsfileLocation        = '';
my $fiSymlinkLocation     = '';
my $defaultsfileLocation  = '';
    
#WLV
if ($isWLV  eq 'y')	{
     $dsfileLocation        = "/opt/jboss/$WLV_inst_home/server/default/deploy/cbs2/cbs2-ds.xml";
     $fiSymlinkLocation     = "/opt/jboss/$WLV_inst_home/server/default/configs/config/fi";
     $defaultsfileLocation  = "/opt/jboss/$WLV_inst_home/server/default/configs/config/defaults/cbs2-defaults.xml";
}
#QDC/LVDC
else {
	 $dsfileLocation        = "/usr/local/whp-jboss/server/default/deploy/cbs2-ds.xml";
	 $fiSymlinkLocation     = "/usr/local/whp-jboss/server/default/env/config/fi";
	 $defaultsfileLocation  = "/usr/local/whp-jboss/server/default/env/config/defaults/cbs2-defaults.xml";
}

my $colValue = "\$2, \"\\t\\t\\t\\t\\t\", \$4";

my $header =
"################################################################################
#                    Post Deployment Verification                              #                                                                                         
################################################################################\n"; 

my $footer =
"\n################################################################################\n\n";

my $step1Header = 
"\n################################################################################
Step 1: Data Source replacement status
################################################################################\n";

my $step2Header = 
"\n################################################################################
Step 2: Defaults security header replacement status
################################################################################\n";

my $step3Header = 
"\n################################################################################
Step3: FI Symlinks verification
################################################################################\n";

my $step4Header = 
"\n################################################################################
Step4: JBOSS status
################################################################################\n";

my  $step5Header = 
"\n################################################################################
#CBS2 getServiceStatusV2
################################################################################\n";

my $colHeader = 
"===============================================================================\\n Header Name \\t\\t\\t\\t\\t  Header Value \\n ===============================================================================";

my $colFooter = 
"===============================================================================";

################################################################################
#Define dev_dev_qdc_100 Variables below
################################################################################
$vars{'dev_dev_qdc_100'}{'url'}           = 'http://pdevcbsas100.corp.intuit.net:8080';
$vars{'dev_dev_qdc_100'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define dev_prod_qdc_101 Variables below
################################################################################
$vars{'dev_prod_qdc_101'}{'url'}         = 'http://pdevcbsao101.corp.intuit.net:8080';
$vars{'dev_prod_qdc_101'}{'ap_auth'}     = 'cbs2testclient';

################################################################################
#Define dev_qa_qdc_102 Variables below
################################################################################
$vars{'dev_qa_qdc_102'}{'url'}         	= 'http://pdevcbsas102.corp.intuit.net:8080';
$vars{'dev_qa_qdc_102'}{'ap_auth'}     	= 'cbs2testclient';

################################################################################
#Define dev_ite_qdc_103 Variables below
################################################################################
$vars{'dev_ite_qdc_103'}{'url'}         = 'http://pdevcbsas103.corp.intuit.net:8080';
$vars{'dev_ite_qdc_103'}{'ap_auth'}     = 'cbs2testclient';

################################################################################
#Define dev_alt_qdc_100 Variables below
################################################################################
$vars{'dev_alt_qdc_100'}{'url'}         = 'http://pdevcbsao100.corp.intuit.net:8080';
$vars{'dev_alt_qdc_100'}{'ap_auth'}     = 'cbs2testclient';

################################################################################
#Define qa_qdc_300 Variables below
################################################################################
$vars{'qa_qdc_300'}{'url'}             = 'http://pqalcbsas300.ie.intuit.net:8080';
$vars{'qa_qdc_300'}{'ap_auth'}         = 'cbs2testclient';

################################################################################
#Define qa_qdc_301 Variables below
################################################################################
$vars{'qa_qdc_301'}{'url'}             = 'http://pqalcbsas301.ie.intuit.net:8080';
$vars{'qa_qdc_301'}{'ap_auth'}         = 'cbs2testclient';

################################################################################
#Define qa_qdc_302 Variables below
################################################################################
$vars{'qa_qdc_302'}{'url'}             = 'http://pqalcbsas302.ie.intuit.net:8080';
$vars{'qa_qdc_302'}{'ap_auth'}         = 'cbs2testclient';

################################################################################
#Define qa_qdc_303 Variables below
################################################################################
$vars{'qa_qdc_303'}{'url'}             = 'http://pqalcbsas303.ie.intuit.net:8080';
$vars{'qa_qdc_303'}{'ap_auth'}         = 'cbs2testclient';

################################################################################
#Define perf_qdc_300 Variables below
################################################################################
$vars{'perf_qdc_300'}{'url'}           = 'http://pprfcbsas300.ie.intuit.net:8080';
$vars{'perf_qdc_300'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define perf_qdc_301 Variables below
################################################################################
$vars{'perf_qdc_301'}{'url'}           = 'http://pprfcbsas301.ie.intuit.net:8080';
$vars{'perf_qdc_301'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define beta_qdc_300 Variables below
################################################################################
$vars{'beta_qdc_300'}{'url'}           = 'http://pprdcbsas300.ie.intuit.net:8080';
$vars{'beta_qdc_300'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define beta_qdc_301 Variables below
################################################################################
$vars{'beta_qdc_301'}{'url'}           = 'http://pprdcbsas301.ie.intuit.net:8080';
$vars{'beta_qdc_301'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define uat_qdc_300 Variables below
################################################################################
$vars{'uat_qdc_300'}{'url'}            = 'http://pe2ecbsas300.ie.intuit.net:8080';
$vars{'uat_qdc_300'}{'ap_auth'}        = 'cbs2testclient';

################################################################################
#Define uat_qdc_301 Variables below
################################################################################
$vars{'uat_qdc_301'}{'url'}            = 'http://pe2ecbsas301.ie.intuit.net:8080';
$vars{'uat_qdc_301'}{'ap_auth'}        = 'cbs2testclient';

################################################################################
#Define prod_qdc_302 Variables below
################################################################################
$vars{'prod_qdc_302'}{'url'}           = 'http://pprdcbsas302.ie.intuit.net:8080';
$vars{'prod_qdc_302'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_303 Variables below
################################################################################
$vars{'prod_qdc_303'}{'url'}           = 'http://pprdcbsas303.ie.intuit.net:8080';
$vars{'prod_qdc_303'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_306 Variables below
################################################################################
$vars{'prod_qdc_306'}{'url'}           = 'http://pprdcbsas306.ie.intuit.net:8080';
$vars{'prod_qdc_306'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_304 Variables below
################################################################################
$vars{'prod_qdc_304'}{'url'}           = 'http://pprdcbsas304.ie.intuit.net:8080';
$vars{'prod_qdc_304'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_305 Variables below
################################################################################
$vars{'prod_qdc_305'}{'url'}           = 'http://pprdcbsas305.ie.intuit.net:8080';
$vars{'prod_qdc_305'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30b Variables below
################################################################################
$vars{'prod_qdc_30b'}{'url'}           = 'http://pprdcbsas30b.ie.intuit.net:8080';
$vars{'prod_qdc_30b'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30c Variables below
################################################################################
$vars{'prod_qdc_30c'}{'url'}           = 'http://pprdcbsas30c.ie.intuit.net:8080';
$vars{'prod_qdc_30c'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30d Variables below
################################################################################
$vars{'prod_qdc_30d'}{'url'}           = 'http://pprdcbsas30d.ie.intuit.net:8080';
$vars{'prod_qdc_30d'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30e Variables below
################################################################################
$vars{'prod_qdc_30e'}{'url'}           = 'http://pprdcbsas30e.ie.intuit.net:8080';
$vars{'prod_qdc_30e'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30s Variables below
################################################################################
$vars{'prod_qdc_30s'}{'url'}           = 'http://pprdcbsas30s.ie.intuit.net:8080';
$vars{'prod_qdc_30s'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30t Variables below
################################################################################
$vars{'prod_qdc_30t'}{'url'}           = 'http://pprdcbsas30t.ie.intuit.net:8080';
$vars{'prod_qdc_30t'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_qdc_30u Variables below
################################################################################
$vars{'prod_qdc_30u'}{'url'}           = 'http://pprdcbsas30u.ie.intuit.net:8080';
$vars{'prod_qdc_30u'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40b Variables below
################################################################################
$vars{'prod_lvdc_40b'}{'url'}          = 'http://pprdcbsas40b.corp.intuit.net:8080';
$vars{'prod_lvdc_40b'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40c Variables below
################################################################################
$vars{'prod_lvdc_40c'}{'url'}          = 'http://pprdcbsas40c.corp.intuit.net:8080';
$vars{'prod_lvdc_40c'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40h Variables below
################################################################################
$vars{'prod_lvdc_40h'}{'url'}          = 'http://pprdcbsas40h.corp.intuit.net:8080';
$vars{'prod_lvdc_40h'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40d Variables below
################################################################################
$vars{'prod_lvdc_40d'}{'url'}          = 'http://pprdcbsas40d.corp.intuit.net:8080';
$vars{'prod_lvdc_40d'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40e Variables below
################################################################################
$vars{'prod_lvdc_40e'}{'url'}          = 'http://pprdcbsas40e.corp.intuit.net:8080';
$vars{'prod_lvdc_40e'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40i Variables below
################################################################################
$vars{'prod_lvdc_40i'}{'url'}          = 'http://pprdcbsas40i.corp.intuit.net:8080';
$vars{'prod_lvdc_40i'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40k Variables below
################################################################################
$vars{'prod_lvdc_40k'}{'url'}          = 'http://pprdcbsas40k.ie.intuit.net:8080';
$vars{'prod_lvdc_40k'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40l Variables below
################################################################################
$vars{'prod_lvdc_40l'}{'url'}          = 'http://pprdcbsas40l.ie.intuit.net:8080';
$vars{'prod_lvdc_40l'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40m Variables below
################################################################################
$vars{'prod_lvdc_40m'}{'url'}          = 'http://pprdcbsas40m.ie.intuit.net:8080';
$vars{'prod_lvdc_40m'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40n Variables below
################################################################################
$vars{'prod_lvdc_40n'}{'url'}          = 'http://pprdcbsas40n.ie.intuit.net:8080';
$vars{'prod_lvdc_40n'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40o Variables below
################################################################################
$vars{'prod_lvdc_40o'}{'url'}          = 'http://pprdcbsas40o.ie.intuit.net:8080';
$vars{'prod_lvdc_40o'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define prod_lvdc_40p Variables below
################################################################################
$vars{'prod_lvdc_40p'}{'url'}          = 'http://pprdcbsas40p.ie.intuit.net:8080';
$vars{'prod_lvdc_40p'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define stagg_lvdc_400 Variables below
################################################################################
$vars{'stagg_lvdc_400'}{'url'}          = 'http://ppdscbsas400.ie.intuit.net:8080';
$vars{'stagg_lvdc_400'}{'ap_auth'}      = 'cbs2testclient';

################################################################################
#Define qa_wlv_1a_8180 Variables below
################################################################################
$vars{'qa_wlv_1a_8180'}{'url'}             = 'http://phoenix1a.app.qa.diginsite.com:8180';
$vars{'qa_wlv_1a_8180'}{'ap_auth'}         = 'cbs2testclient';

################################################################################
#Define qa_wlv_1b_8180 Variables below
################################################################################
$vars{'qa_wlv_1b_8180'}{'url'}             = 'http://phoenix1b.app.qa.diginsite.com:8180';
$vars{'qa_wlv_1b_8180'}{'ap_auth'}         = 'cbs2testclient';

#################################################################################
#Define qa_wlv_1a_8280 Variables below
#################################################################################
$vars{'qa_wlv_1a_8280'}{'url'}             = 'http://phoenix1a.app.qa.diginsite.com:8280';
$vars{'qa_wlv_1a_8280'}{'ap_auth'}         = 'cbs2testclient';

#################################################################################
#Define qa_wlv_1b_8280 Variables below
#################################################################################
$vars{'qa_wlv_1b_8280'}{'url'}             = 'http://phoenix1b.app.qa.diginsite.com:8280';
$vars{'qa_wlv_1b_8280'}{'ap_auth'}         = 'cbs2testclient';

#################################################################################
#Define pte_wlv_8180 Variables below
#################################################################################
$vars{'pte_wlv_8180'}{'url'}           = 'http://cbs2-pte-vip.app.qa.diginsite.com:8180';
$vars{'pte_wlv_8180'}{'ap_auth'}       = 'cbs2testclient';

#################################################################################
#Define pte_wlv_8280 Variables below
#################################################################################
$vars{'pte_wlv_8280'}{'url'}           = 'http://cbs2-pte-vip.app.qa.diginsite.com:8280';
$vars{'pte_wlv_8280'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define beta_wlv Variables below
################################################################################
$vars{'beta_wlv'}{'url'}           = 'http://phoenix88a.app.prod.diginsite.com:8180';
$vars{'beta_wlv'}{'ap_auth'}       = 'cbs2testclient';

################################################################################
#Define preprod_wlv Variables below
################################################################################
$vars{'preprod_wlv'}{'url'}        = 'http://phoenix88a.app.prod.diginsite.com:8380';
$vars{'preprod_wlv'}{'ap_auth'}    = 'cbs2testclient';

################################################################################
#Define prod_wlv_VIP Variables below
################################################################################
$vars{'prod_wlv_VIP'}{'url'}           = 'http://cbs2-vip.live.diginsite.com:8180';
$vars{'prod_wlv_VIP'}{'ap_auth'}       = 'cbs2testclient';

###############################################################################
#Define prod_wlv_1c Variables below
###############################################################################
$vars{'prod_wlv_1c'}{'url'}           = 'http://phoenix1c.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1c'}{'ap_auth'}       = 'cbs2testclient';

##############################################################################
#Define prod_wlv_1d Variables below
##############################################################################
$vars{'prod_wlv_1d'}{'url'}           = 'http://phoenix1d.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1d'}{'ap_auth'}       = 'cbs2testclient';

###############################################################################
#Define prod_wlv_1e Variables below
###############################################################################
$vars{'prod_wlv_1e'}{'url'}           = 'http://phoenix1e.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1e'}{'ap_auth'}       = 'cbs2testclient';

##############################################################################
#Define prod_wlv_1f Variables below
##############################################################################
$vars{'prod_wlv_1f'}{'url'}           = 'http://phoenix1f.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1f'}{'ap_auth'}       = 'cbs2testclient';


################################################################################
#Execute Tasks Below
################################################################################
my $isServerSelected = 'false';

for (my $i=0; $i<$#servers+1 ; $i++) {  
  #Match the Selected Server/Target host environment
  $env = $servers[$i]->[0];
  my $envURL = $vars{$env}{'url'};
  my $hostname = $ENV{'HOSTNAME'};

if ($servers[$i]->[1] eq 'y' && $envURL =~ m/$hostname/){
 # Set the isSelected flag to true,
 # if the selected server and target host are same 
 $isServerSelected = 'true';

print "$header";
print "Environment          	              :$envURL \n";

################################################################################
#Step 1: Data Source replacement status
################################################################################
print "$step1Header";
print "File Path: [$dsfileLocation] \n";

if(-e $dsfileLocation) {
    my $dsResponse = system("grep -q \"__\" $dsfileLocation >> /dev/null");
    
	if ($dsResponse !~ 0)	{
    	print "Status                                               :PASSED \n";
    	print "Replaced all parameters successfully";
	} else  {
   		my $dsresult = `grep "__" $dsfileLocation`;
   		print "Status                                                :FAILED \n" ;
   		if ($debug eq 'true') { 
     		print "ERROR: Unreplaced parameters:  \n";
     		 print "$dsresult"; 
   		}
	}
	
} else {
		 print "ERROR: File Doesn't Exist! \n";
} 
################################################################################
#Step 2: Defaults security header replacement status
################################################################################
print "$step2Header";
print "File Path: [$defaultsfileLocation] \n";

if(-e $defaultsfileLocation) {
	my $defaultResponse = system("grep -q \"__\" $defaultsfileLocation >> /dev/null");
	
	if($defaultResponse !~ 0)	{
  		 print "Status                                                :PASSED \n" ;
  		 print "Replaced security headers successfully. \n";
    	if ($debug eq 'true') 
    	{
			system("awk -F'\"' 'BEGIN {print \" $colHeader \"\;}  /<headerValue/ {print $colValue}  END {print \" $colFooter \"\;}' $defaultsfileLocation"); 
 		}
 	} else  {
 	  	my $result = `grep "__" $defaultsfileLocation `;
  	 	print "Status:                                                :FAILED \n" ;
  		 print "ERROR: Unreplaced parameters:  \n";
  		 print "$result";
	}
} else {
		 print "ERROR: File Doesn't Exist! \n";
}

################################################################################
#Step3: FI Symlinks verification
################################################################################
print "$step3Header";
print "FI Symlink Directory Path: [$fiSymlinkLocation] \n";

if(-d $fiSymlinkLocation) {
	my $response = system("find -L $fiSymlinkLocation >> /dev/null");
	
	if($response !~ 0)	{
  	  	print "Status                                                :FAILED \n";
    	print "ERROR: FI symlinks are not created.";
	}
	else  {
  	 	print "Status                                                :PASSED \n" ;
   		if ($debug eq 'true') { 
   			 `find -L $fiSymlinkLocation > FI_SymLink_Verification.txt`;
   		}
	}
} else {
		 print "ERROR: FI symlinks directory is not created! \n";
}

################################################################################
#Check JBOSS is running or not
################################################################################
print "$step4Header";

if (`ps -elf | grep jboss | grep server | grep -v findprocess`)	{
    print "JBOSS process status          	                      :Running \n";
    print "Process id          	                              :$$ \n";
} else	{
     print "ERROR: JBOSS is not up/running!!! \n";
}

################################################################################
#Execute CBS2 getServiceStatusV2
################################################################################
print "$step5Header";

$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: CustomerCentral" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" $vars{$env}{'url'}/cbs2/status 2>&1`;
    
#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)	{
    print "ERROR: CBS2 getServiceStatusV2: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
} else {
    print "CBS2 getServiceStatusV2 result          	      :PASSED\n";
}
    
if ($debug eq 'true') { print "\n $response\n\n"; }
print "$footer"; 
}
}  
# Show error in case if no (or) wrong sever is selected 
if ($isServerSelected eq 'false') {
	print "$colFooter \n ERROR: No/Wrong server selected \n$colFooter \n\n"; 
}
