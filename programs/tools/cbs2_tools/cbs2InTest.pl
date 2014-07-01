#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   cbs2InTests.pl - Very simple set of CBS2 app tier smoke tests.  Primary  ##
##                   use for Beta and Production deployment verification.     ##
##                                                                            ##
##                   Created by: Amzad Hossain                                ##
##                   Last updated: RM - 03/11/2013 Ver. 1.18                  ##
##                                                                            ##
##                   CBS2 Version: 3.10.1                                      ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use warnings;
system('clear');

#################################################################
# Configure $env Variable. Possible $env values are:
#
#  qa_wlv    	- http://cbs2-vip.app.qa.diginsite.com:8280
#               - http://cbs2-vip.app.qa.diginsite.com:8180
#
#  qa_qdc SL1	- http://cbs-sl1-qal-qydc.banking.intuit.net:80
#            	- http://pqalcbsas300.ie.intuit.net:8080
#            	- http://pqalcbsas301.ie.intuit.net:8080
#  qa_qdc SL2	- http://cbs-sl2-qal-qydc.banking.intuit.net:80
#            	- http://pqalcbsas302.ie.intuit.net:8080
#            	- http://pqalcbsas303.corp.intuit.net:8080
#
#  pte_wlv   	- http://cbs2-pte-vip.app.qa.diginsite.com:8180
#               - http://cbs2-pte-vip.app.qa.diginsite.com:8180
#
#  perf_qdc SL1 - http://cbs-sl1-prf-qydc.banking.intuit.net:80
#            	- http://pprfcbsas300.ie.intuit.net:8080
#            	- http://pprfcbsas301.ie.intuit.net:8080
#
#  LVDC_STAGG   - http://cbs-sl1-prf-lvdc.banking.intuit.net:80
#               - http://ppdscbsas400.ie.intuit.net:8080
#
#  uat_qdc_SL1  - http://cbs-sl1-e2e-qydc.banking.intuit.net:80
#            	- http://pprdcbsas300.ie.intuit.net:8080
#            	- http://pprdcbsas301.ie.intuit.net:8080
#
#  beta_wlv  	- http://cbs2-beta-vip.app.prod.diginsite.com:8180
#  beta_wlv_1c  - http://Phoenix1a.app.prod.diginsite.com
#
#  beta_qdc  	- http://cbs-sl1-bta-qydc.banking.intuit.net:80 
#            	- http://pprdcbsas300.ie.intuit.net:8080
#            	- http://pprdcbsas301.ie.intuit.net:8080
#
#  preprod_wlv 	- http://cbs2-preprod-vip.app.prod.diginsite.com:8380
#  preprod_wlv_1a- http://Phoenix1a.app.prod.diginsite.com
#
#  prod_wlv_VIP - http://cbs2-vip.live.diginsite.com:8180
#  prod_wlv_1c  - http://Phoenix1c.app.prod.diginsite.com
#  prod_wlv_1d  - http://Phoenix1d.app.prod.diginsite.com
#  prod_wlv_1e  - http://Phoenix1e.app.prod.diginsite.com
#  prod_wlv_1f  - http://Phoenix1f.app.prod.diginsite.com
#
#  prod_qdc SL1	- http://cbs-sl1-prd-qydc.banking.intuit.net:80
#            	- http://pprdcbsas302.ie.intuit.net:8080
#            	- http://pprdcbsas303.ie.intuit.net:8080
#            	- http://pprdcbsas306.ie.intuit.net:8080
#
#  prod_qdc SL2 - http://cbs-sl2-prd-qydc.banking.intuit.net:80
#            	- http://pprdcbsas304.ie.intuit.net:8080
#            	- http://pprdcbsas305.ie.intuit.net:8080
#            	- http://pprdcbsas30b.ie.intuit.net:8080
#
#  prod_qdc SL3 - http://cbs-sl3-prd-qydc.banking.intuit.net:80
#            	- http://pprdcbsas30c.ie.intuit.net:8080
#            	- http://pprdcbsas30d.ie.intuit.net:8080
#            	- http://pprdcbsas30e.ie.intuit.net:8080
#
#  prod_qdc SL4 - http://cbs-sl4-prd-qydc.banking.intuit.net:80
#            	- http://pprdcbsas30s.ie.intuit.net:8080
#            	- http://pprdcbsas30t.ie.intuit.net:8080
#            	- http://pprdcbsas30u.ie.intuit.net:8080
#
#  prod_qdc SL5 - http://cbs-sl5-prd-qydc.banking.intuit.net:80
#            	- http://pprdcbsas30v.ie.intuit.net:8080
#            	- http://pprdcbsas30w.ie.intuit.net:8080
#            	- http://pprdcbsas30z.ie.intuit.net:8080
#
#  prod_qdc SL6 - http://cbs-sl6-prd-qydc.banking.intuit.net:80
#            	- http://pprdcbsas310.ie.intuit.net:8080
#            	- http://pprdcbsas311.ie.intuit.net:8080
#
#  prod_lvdc SL1- http://cbs-sl1-prd-lvdc.banking.intuit.net:80
#            	- http://pprdcbsas40b.corp.intuit.net:8080
#            	- http://pprdcbsas40c.corp.intuit.net:8080
#            	- http://pprdcbsas40h.corp.intuit.net:8080
#
#  prod_lvdc SL2- http://cbs-sl2-prd-lvdc.banking.intuit.net:80
#            	- http://pprdcbsas40d.corp.intuit.net:8080
#            	- http://pprdcbsas40e.corp.intuit.net:8080
#            	- http://pprdcbsas40i.corp.intuit.net:8080
#
#  prod_lvdc SL3- http://cbs-sl3-prd-lvdc.banking.intuit.net:80
#            	- http://pprdcbsas40k.ie.intuit.net:8080
#            	- http://pprdcbsas40l.ie.intuit.net:8080
#            	- http://pprdcbsas40m.ie.intuit.net:8080
#
#  prod_lvdc SL4- http://cbs-sl4-prd-lvdc.banking.intuit.net:80
#            	- http://pprdcbsas40n.ie.intuit.net:8080
#            	- http://pprdcbsas40o.ie.intuit.net:8080
#            	- http://pprdcbsas40p.ie.intuit.net:8080
#
#  prod_lvdc SL5- http://cbs-sl5-prd-lvdc.banking.intuit.net:80
#            	- http://pprdcbsas40q.ie.intuit.net:8080
#            	- http://pprdcbsas40r.ie.intuit.net:8080
#            	- http://pprdcbsas40s.ie.intuit.net:8080
#
#  prod_lvdc SL6- http://cbs-sl6-prd-lvdc.banking.intuit.net:80
#            	- http://pprdcbsas40t.ie.intuit.net:8080
#            	- http://pprdcbsas40u.ie.intuit.net :8080
#            
#  Tested APIs
#  -------------------------
#  getServiceStatusV2
#  getFinancialInstitutionV2
#  getFICustomerV2
#  getAccountsV2
#  getFinancialInfoV2
#  getTransactionsV2
#  invalidateUserCacheDel
#  deleteAccountUSRSUM
#################################################################
my $env = '';

my @servers = (
#    Server     Test
#   --------   ------
[qw/ qa_wlv_8180       n   /],
[qw/ qa_wlv_8280       n   /],
[qw/ qa_qdc_SL1        y   /],
[qw/ qa_qdc_300        n  /],
[qw/ qa_qdc_301        n   /],
[qw/ qa_qdc_SL2        n   /],
[qw/ qa_qdc_302        n   /],
[qw/ qa_qdc_303        n   /],
[qw/ pte_wlv_8180      n   /],
[qw/ pte_wlv_8180      n   /],
[qw/ perf_qdc_SL1      n   /],
[qw/ perf_qdc_300      n   /],
[qw/ perf_qdc_301      n   /],
[qw/ stagg_lvdc_SL     n   /],
[qw/ stagg_lvdc_400    n   /],
[qw/ uat_qdc_SL1       n   /],
[qw/ uat_qdc_300       n   /],
[qw/ uat_qdc_301       n   /],
[qw/ beta_wlv          n   /],
[qw/ beta_qdc_SL1      n   /],
[qw/ beta_qdc_300      n   /],
[qw/ beta_qdc_301      n   /],
[qw/ preprod_wlv       n   /],
[qw/ prod_wlv_VIP      n   /],
[qw/ prod_wlv_1c       n   /],
[qw/ prod_wlv_1d       n   /],
[qw/ prod_wlv_1e       n   /],
[qw/ prod_wlv_1f       n   /],
[qw/ prod_qdc_SL1      n   /],
[qw/ prod_qdc_302      n   /],
[qw/ prod_qdc_303      n   /],
[qw/ prod_qdc_306      n   /],
[qw/ prod_qdc_SL2      n   /],
[qw/ prod_qdc_304      n   /],
[qw/ prod_qdc_305      n   /],
[qw/ prod_qdc_30b      n   /],
[qw/ prod_qdc_SL3      n   /],
[qw/ prod_qdc_30c      n   /],
[qw/ prod_qdc_30d      n   /],
[qw/ prod_qdc_30e      n   /],
[qw/ prod_qdc_SL4      n   /],
[qw/ prod_qdc_30s      n   /],
[qw/ prod_qdc_30t      n   /],
[qw/ prod_qdc_30u      n   /],
[qw/ prod_qdc_SL5      n   /],
[qw/ prod_qdc_30v      n   /],
[qw/ prod_qdc_30w      n   /],
[qw/ prod_qdc_30z      n   /],
[qw/ prod_qdc_SL6      n   /],
[qw/ prod_qdc_310      n   /],
[qw/ prod_qdc_311      n   /],
[qw/ prod_lvdc_SL1     n   /],
[qw/ prod_lvdc_40b     n   /],
[qw/ prod_lvdc_40c     n   /],
[qw/ prod_lvdc_40h     n   /],
[qw/ prod_lvdc_SL2     n   /],
[qw/ prod_lvdc_40d     n   /],
[qw/ prod_lvdc_40e     n   /],
[qw/ prod_lvdc_40i     n   /],
[qw/ prod_lvdc_SL3     n   /],
[qw/ prod_lvdc_40k     n   /],
[qw/ prod_lvdc_40l     n   /],
[qw/ prod_lvdc_40m     n   /],
[qw/ prod_lvdc_SL4     n   /],
[qw/ prod_lvdc_40n     n   /],
[qw/ prod_lvdc_40o     n   /],
[qw/ prod_lvdc_40p     n   /],
[qw/ prod_lvdc_SL5     n   /],
[qw/ prod_lvdc_40q     n   /],
[qw/ prod_lvdc_40r     n   /],
[qw/ prod_lvdc_40s     n   /],
[qw/ prod_lvdc_SL6     n   /],
[qw/ prod_lvdc_40t     n   /],
[qw/ prod_lvdc_40u     n   /],
);

#################################################################
#Test Definitions Set Below
#################################################################
my %vars     = ();
my $response = '';
my $debug    = 'false';
my $request  = '';

#################################################################
#Define qa_wlv_8180 Variables below
#################################################################
$vars{'qa_wlv_8180'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_wlv_8180'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_wlv_8180'}{'fiid'}            = 'DI0508';
$vars{'qa_wlv_8180'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_wlv_8180'}{'url'}             = 'http://cbs2-vip.app.qa.diginsite.com:8180';
$vars{'qa_wlv_8180'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_wlv_8280 Variables below
#################################################################
$vars{'qa_wlv_8280'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_wlv_8280'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_wlv_8280'}{'fiid'}            = 'DI0508';
$vars{'qa_wlv_8280'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_wlv_8280'}{'url'}             = 'http://cbs2-vip.app.qa.diginsite.com:8280';
$vars{'qa_wlv_8280'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_qdc_SL1 Variables below
#################################################################
$vars{'qa_qdc_SL1'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_SL1'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_qdc_SL1'}{'fiid'}            = 'DI0508';
$vars{'qa_qdc_SL1'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_qdc_SL1'}{'url'}             = 'http://cbs-sl1-qal-qydc.banking.intuit.net:80';
$vars{'qa_qdc_SL1'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_qdc_300 Variables below
#################################################################
$vars{'qa_qdc_300'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_300'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_qdc_300'}{'fiid'}            = 'DI0508';
$vars{'qa_qdc_300'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_qdc_300'}{'url'}             = 'http://pqalcbsas300.ie.intuit.net:8080';
$vars{'qa_qdc_300'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_qdc_301 Variables below
#################################################################
$vars{'qa_qdc_301'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_301'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_qdc_301'}{'fiid'}            = 'DI0508';
$vars{'qa_qdc_301'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_qdc_301'}{'url'}             = 'http://pqalcbsas301.ie.intuit.net:8080';
$vars{'qa_qdc_301'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_qdc_SL2 Variables below
#################################################################
$vars{'qa_qdc_SL2'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_SL2'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_qdc_SL2'}{'fiid'}            = 'DI0508';
$vars{'qa_qdc_SL2'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_qdc_SL2'}{'url'}             = 'http://cbs-sl2-qal-qydc.banking.intuit.net:80';
$vars{'qa_qdc_SL2'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_qdc_302 Variables below
#################################################################
$vars{'qa_qdc_302'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_302'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_qdc_302'}{'fiid'}            = 'DI0508';
$vars{'qa_qdc_302'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_qdc_302'}{'url'}             = 'http://pqalcbsas302.ie.intuit.net:8080';
$vars{'qa_qdc_302'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define qa_qdc_303 Variables below
#################################################################
$vars{'qa_qdc_303'}{'guid'}            = 'c0a8e3260016a0a44b7071c70b825c00';
$vars{'qa_qdc_303'}{'loginid'}         = 'CBS2PIN0001';
$vars{'qa_qdc_303'}{'fiid'}            = 'DI0508';
$vars{'qa_qdc_303'}{'accountId'}       = 'Rws6a2s-xiRlmhzg9GlV325Mdug4ZvmbKLzi3z3aP0o';
$vars{'qa_qdc_303'}{'url'}             = 'http://pqalcbsas303.corp.intuit.net:8080';
$vars{'qa_qdc_303'}{'ap_auth'}         = 'cbs2testclient';

#################################################################
#Define pte_wlv_8180 Variables below
#################################################################
$vars{'pte_wlv_8180'}{'guid'}          = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'pte_wlv_8180'}{'loginid'}       = '259474633';
$vars{'pte_wlv_8180'}{'fiid'}          = 'DI7033';
$vars{'pte_wlv_8180'}{'accountId'}     = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'pte_wlv_8180'}{'url'}           = 'http://cbs2-pte-vip.app.qa.diginsite.com:8180';
$vars{'pte_wlv_8180'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define pte_wlv_8280 Variables below
#################################################################
$vars{'pte_wlv_8280'}{'guid'}          = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'pte_wlv_8280'}{'loginid'}       = '259474633';
$vars{'pte_wlv_8280'}{'fiid'}          = 'DI7033';
$vars{'pte_wlv_8280'}{'accountId'}     = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'pte_wlv_8280'}{'url'}           = 'http://cbs2-pte-vip.app.qa.diginsite.com:8280';
$vars{'pte_wlv_8280'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define perf_qdc_SL1 Variables below
#################################################################
$vars{'perf_qdc_SL1'}{'guid'}          = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'perf_qdc_SL1'}{'loginid'}       = '259474633';
$vars{'perf_qdc_SL1'}{'fiid'}          = 'DI7033';
$vars{'perf_qdc_SL1'}{'accountId'}     = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'perf_qdc_SL1'}{'url'}           = 'http://cbs-sl1-prf-qydc.banking.intuit.net:80';
$vars{'perf_qdc_SL1'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define perf_qdc_300 Variables below
#################################################################
$vars{'perf_qdc_300'}{'guid'}          = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'perf_qdc_300'}{'loginid'}       = '259474633';
$vars{'perf_qdc_300'}{'fiid'}          = 'DI7033';
$vars{'perf_qdc_300'}{'accountId'}     = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'perf_qdc_300'}{'url'}           = 'http://pprfcbsas300.ie.intuit.net:8080';
$vars{'perf_qdc_300'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define perf_qdc_301 Variables below
#################################################################
$vars{'perf_qdc_301'}{'guid'}          = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'perf_qdc_301'}{'loginid'}       = '259474633';
$vars{'perf_qdc_301'}{'fiid'}          = 'DI7033';
$vars{'perf_qdc_301'}{'accountId'}     = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'perf_qdc_301'}{'url'}           = 'http://pprfcbsas301.ie.intuit.net:8080';
$vars{'perf_qdc_301'}{'ap_auth'}       = 'cbs2testclient';

################################################################
#Define stagg_lvdc_SL Variables below
#################################################################
$vars{'stagg_lvdc_SL'}{'guid'}         = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'stagg_lvdc_SL'}{'loginid'}      = '259474633';
$vars{'stagg_lvdc_SL'}{'fiid'}         = 'DI7033';
$vars{'stagg_lvdc_SL'}{'accountId'}    = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'stagg_lvdc_SL'}{'url'}          = 'http://cbs-sl1-prf-lvdc.banking.intuit.net:80';
$vars{'stagg_lvdc_SL'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define stagg_lvdc_400 Variables below
#################################################################
$vars{'stagg_lvdc_400'}{'guid'}         = 'c0a8f23a000059ba49b15a21190bae00';
$vars{'stagg_lvdc_400'}{'loginid'}      = '259474633';
$vars{'stagg_lvdc_400'}{'fiid'}         = 'DI7033';
$vars{'stagg_lvdc_400'}{'accountId'}    = 'w36G_bvs-FhNAf1jJCgcBWaWGpiT_HcCZq0WF1TIds0';
$vars{'stagg_lvdc_400'}{'url'}          = 'http://ppdscbsas400.ie.intuit.net:8080';
$vars{'stagg_lvdc_400'}{'ap_auth'}      = 'cbs2testclient';


#################################################################
#Define uat_qdc_SL1 Variables below
#################################################################
$vars{'uat_qdc_SL1'}{'guid'}           = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'uat_qdc_SL1'}{'loginid'}        = 'SMOKETEST001';
$vars{'uat_qdc_SL1'}{'fiid'}           = 'DI0508';
$vars{'uat_qdc_SL1'}{'accountId'}      = 'q-jqw1vU5CBBPeu1MZ1rKtulBq4xTspMFKN2xL3S3W8';
$vars{'uat_qdc_SL1'}{'url'}            = 'http://cbs-sl1-e2e-qydc.banking.intuit.net:80';
$vars{'uat_qdc_SL1'}{'ap_auth'}        = 'cbs2testclient';

#################################################################
#Define uat_qdc_300 Variables below
#################################################################
$vars{'uat_qdc_300'}{'guid'}           = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'uat_qdc_300'}{'loginid'}        = 'SMOKETEST001';
$vars{'uat_qdc_300'}{'fiid'}           = 'DI0508';
$vars{'uat_qdc_300'}{'accountId'}      = 'q-jqw1vU5CBBPeu1MZ1rKtulBq4xTspMFKN2xL3S3W8';
$vars{'uat_qdc_300'}{'url'}            = 'http://pe2ecbsas300.ie.intuit.net:8080';
$vars{'uat_qdc_300'}{'ap_auth'}        = 'cbs2testclient';

#################################################################
#Define uat_qdc_301 Variables below
#################################################################
$vars{'uat_qdc_301'}{'guid'}           = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'uat_qdc_301'}{'loginid'}        = 'SMOKETEST001';
$vars{'uat_qdc_301'}{'fiid'}           = 'DI0508';
$vars{'uat_qdc_301'}{'accountId'}      = 'q-jqw1vU5CBBPeu1MZ1rKtulBq4xTspMFKN2xL3S3W8';
$vars{'uat_qdc_301'}{'url'}            = 'http://pe2ecbsas301.ie.intuit.net:8080';
$vars{'uat_qdc_301'}{'ap_auth'}        = 'cbs2testclient';


#################################################################
#Define beta_wlv Variables below
#################################################################
$vars{'beta_wlv'}{'guid'}          = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_wlv'}{'loginid'}       = 'TESTING123';
$vars{'beta_wlv'}{'fiid'}          = 'DI5533';
$vars{'beta_wlv'}{'accountId'}     = 'pKNiDRch5C_5LSRy2EbUsnH5oWVxCTNauvWFP6gANGc';
$vars{'beta_wlv'}{'url'}           = 'http://cbs2-beta-vip.app.prod.diginsite.com:8180';
$vars{'beta_wlv'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define beta_qdc_SL1 Variables below
#################################################################
$vars{'beta_qdc_SL1'}{'guid'}          = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_qdc_SL1'}{'loginid'}       = 'TESTING123';
$vars{'beta_qdc_SL1'}{'fiid'}          = 'DI5533';
$vars{'beta_qdc_SL1'}{'accountId'}     = 'AykBHnUGgYPNsRpsOrl9giFC4iPQs8hjXjUHdFBJOTI';
$vars{'beta_qdc_SL1'}{'url'}           = 'http://cbs-sl1-bta-qydc.banking.intuit.net:80';
$vars{'beta_qdc_SL1'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define beta_qdc_300 Variables below
#################################################################
$vars{'beta_qdc_300'}{'guid'}          = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_qdc_300'}{'loginid'}       = 'TESTING123';
$vars{'beta_qdc_300'}{'fiid'}          = 'DI5533';
$vars{'beta_qdc_300'}{'accountId'}     = 'AykBHnUGgYPNsRpsOrl9giFC4iPQs8hjXjUHdFBJOTI';
$vars{'beta_qdc_300'}{'url'}           = 'http://pprdcbsas300.ie.intuit.net:8080';
$vars{'beta_qdc_300'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define beta_qdc_301 Variables below
#################################################################
$vars{'beta_qdc_301'}{'guid'}          = 'c0a8f2bc004601624fc6908623db7d00';
$vars{'beta_qdc_301'}{'loginid'}       = 'TESTING123';
$vars{'beta_qdc_301'}{'fiid'}          = 'DI5533';
$vars{'beta_qdc_301'}{'accountId'}     = 'AykBHnUGgYPNsRpsOrl9giFC4iPQs8hjXjUHdFBJOTI';
$vars{'beta_qdc_301'}{'url'}           = 'http://pprdcbsas301.ie.intuit.net:8080';
$vars{'beta_qdc_301'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define preprod_wlv Variables below
#################################################################
$vars{'preprod_wlv'}{'guid'}       = 'c2a8eBM8002060624r693yyy00924514';
$vars{'preprod_wlv'}{'loginid'}    = 'SMOKETEST001';
$vars{'preprod_wlv'}{'fiid'}       = 'DI0508';
$vars{'preprod_wlv'}{'accountId'}  = 'pKNiDRch5C_5LSRy2EbUsnH5oWVxCTNauvWFP6gANGc';
$vars{'preprod_wlv'}{'url'}        = 'http://phoenix88a.app.prod.diginsite.com:8380';
$vars{'preprod_wlv'}{'ap_auth'}    = 'cbs2testclient';

#################################################################
#Define prod_wlv_VIP Variables below
#################################################################
$vars{'prod_wlv_VIP'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_wlv_VIP'}{'loginid'}       = '19999991';
$vars{'prod_wlv_VIP'}{'fiid'}          = 'DI3399';
$vars{'prod_wlv_VIP'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_wlv_VIP'}{'url'}           = 'http://cbs2-vip.live.diginsite.com:8180';
$vars{'prod_wlv_VIP'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_wlv_1c Variables below
#################################################################
$vars{'prod_wlv_1c'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_wlv_1c'}{'loginid'}       = '19999991';
$vars{'prod_wlv_1c'}{'fiid'}          = 'DI3399';
$vars{'prod_wlv_1c'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_wlv_1c'}{'url'}           = 'http://Phoenix1c.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1c'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_wlv_1d Variables below
#################################################################
$vars{'prod_wlv_1d'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_wlv_1d'}{'loginid'}       = '19999991';
$vars{'prod_wlv_1d'}{'fiid'}          = 'DI3399';
$vars{'prod_wlv_1d'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_wlv_1d'}{'url'}           = 'http://Phoenix1d.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1d'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_wlv_1e Variables below
#################################################################
$vars{'prod_wlv_1e'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_wlv_1e'}{'loginid'}       = '19999991';
$vars{'prod_wlv_1e'}{'fiid'}          = 'DI3399';
$vars{'prod_wlv_1e'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_wlv_1e'}{'url'}           = 'http://Phoenix1e.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1e'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_wlv_1f Variables below
#################################################################
$vars{'prod_wlv_1f'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_wlv_1f'}{'loginid'}       = '19999991';
$vars{'prod_wlv_1f'}{'fiid'}          = 'DI3399';
$vars{'prod_wlv_1f'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_wlv_1f'}{'url'}           = 'http://Phoenix1f.app.prod.diginsite.com:8180';
$vars{'prod_wlv_1f'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_SL1 Variables below
#################################################################
$vars{'prod_qdc_SL1'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_SL1'}{'loginid'}       = '19999991';
$vars{'prod_qdc_SL1'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_SL1'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_SL1'}{'url'}           = 'http://cbs-sl1-prd-qydc.banking.intuit.net:80';
$vars{'prod_qdc_SL1'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_302 Variables below
#################################################################
$vars{'prod_qdc_302'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_302'}{'loginid'}       = '19999991';
$vars{'prod_qdc_302'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_302'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_302'}{'url'}           = 'http://pprdcbsas302.ie.intuit.net:8080';
$vars{'prod_qdc_302'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_303 Variables below
#################################################################
$vars{'prod_qdc_303'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_303'}{'loginid'}       = '19999991';
$vars{'prod_qdc_303'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_303'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_303'}{'url'}           = 'http://pprdcbsas303.ie.intuit.net:8080';
$vars{'prod_qdc_303'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_306 Variables below
#################################################################
$vars{'prod_qdc_306'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_306'}{'loginid'}       = '19999991';
$vars{'prod_qdc_306'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_306'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_306'}{'url'}           = 'http://pprdcbsas306.ie.intuit.net:8080';
$vars{'prod_qdc_306'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_SL2 Variables below
#################################################################
$vars{'prod_qdc_SL2'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_SL2'}{'loginid'}       = '19999991';
$vars{'prod_qdc_SL2'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_SL2'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_SL2'}{'url'}           = 'http://cbs-sl2-prd-qydc.banking.intuit.net:80';
$vars{'prod_qdc_SL2'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_304 Variables below
#################################################################
$vars{'prod_qdc_304'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_304'}{'loginid'}       = '19999991';
$vars{'prod_qdc_304'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_304'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_304'}{'url'}           = 'http://pprdcbsas304.ie.intuit.net:8080';
$vars{'prod_qdc_304'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_305 Variables below
#################################################################
$vars{'prod_qdc_305'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_305'}{'loginid'}       = '19999991';
$vars{'prod_qdc_305'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_305'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_305'}{'url'}           = 'http://pprdcbsas305.ie.intuit.net:8080';
$vars{'prod_qdc_305'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30b Variables below
#################################################################
$vars{'prod_qdc_30b'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30b'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30b'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30b'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30b'}{'url'}           = 'http://pprdcbsas30b.ie.intuit.net:8080';
$vars{'prod_qdc_30b'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_SL3 Variables below
#################################################################
$vars{'prod_qdc_SL3'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_SL3'}{'loginid'}       = '19999991';
$vars{'prod_qdc_SL3'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_SL3'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_SL3'}{'url'}           = 'http://cbs-sl3-prd-qydc.banking.intuit.net:80';
$vars{'prod_qdc_SL3'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30c Variables below
#################################################################
$vars{'prod_qdc_30c'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30c'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30c'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30c'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30c'}{'url'}           = 'http://pprdcbsas30c.ie.intuit.net:8080';
$vars{'prod_qdc_30c'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30d Variables below
#################################################################
$vars{'prod_qdc_30d'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30d'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30d'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30d'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30d'}{'url'}           = 'http://pprdcbsas30d.ie.intuit.net:8080';
$vars{'prod_qdc_30d'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30e Variables below
#################################################################
$vars{'prod_qdc_30e'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30e'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30e'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30e'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30e'}{'url'}           = 'http://pprdcbsas30e.ie.intuit.net:8080';
$vars{'prod_qdc_30e'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_SL4 Variables below
#################################################################
$vars{'prod_qdc_SL4'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_SL4'}{'loginid'}       = '19999991';
$vars{'prod_qdc_SL4'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_SL4'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_SL4'}{'url'}           = 'http://cbs-sl4-prd-qydc.banking.intuit.net:80';
$vars{'prod_qdc_SL4'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30s Variables below
#################################################################
$vars{'prod_qdc_30s'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30s'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30s'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30s'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30s'}{'url'}           = 'http://pprdcbsas30s.ie.intuit.net:8080';
$vars{'prod_qdc_30s'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30t Variables below
#################################################################
$vars{'prod_qdc_30t'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30t'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30t'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30t'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30t'}{'url'}           = 'http://pprdcbsas30t.ie.intuit.net:8080';
$vars{'prod_qdc_30t'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30u Variables below
#################################################################
$vars{'prod_qdc_30u'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30u'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30u'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30u'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30u'}{'url'}           = 'http://pprdcbsas30u.ie.intuit.net:8080';
$vars{'prod_qdc_30u'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_SL5 Variables below
#################################################################
$vars{'prod_qdc_SL5'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_SL5'}{'loginid'}       = '19999991';
$vars{'prod_qdc_SL5'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_SL5'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_SL5'}{'url'}           = 'http://cbs-sl5-prd-qydc.banking.intuit.net:80';
$vars{'prod_qdc_SL5'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30v Variables below
#################################################################
$vars{'prod_qdc_30v'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30v'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30v'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30v'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30v'}{'url'}           = 'http://pprdcbsas30v.ie.intuit.net:8080';
$vars{'prod_qdc_30v'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30w Variables below
#################################################################
$vars{'prod_qdc_30w'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30w'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30w'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30w'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30w'}{'url'}           = 'http://pprdcbsas30w.ie.intuit.net:8080';
$vars{'prod_qdc_30w'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_30z Variables below
#################################################################
$vars{'prod_qdc_30z'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_30z'}{'loginid'}       = '19999991';
$vars{'prod_qdc_30z'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_30z'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_30z'}{'url'}           = 'http://pprdcbsas30z.ie.intuit.net:8080';
$vars{'prod_qdc_30z'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_SL6 Variables below
#################################################################
$vars{'prod_qdc_SL6'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_SL6'}{'loginid'}       = '19999991';
$vars{'prod_qdc_SL6'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_SL6'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_SL6'}{'url'}           = 'http://cbs-sl6-prd-qydc.banking.intuit.net:80';
$vars{'prod_qdc_SL6'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_310 Variables below
#################################################################
$vars{'prod_qdc_310'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_310'}{'loginid'}       = '19999991';
$vars{'prod_qdc_310'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_310'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_310'}{'url'}           = 'http://pprdcbsas310.ie.intuit.net:8080';
$vars{'prod_qdc_310'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_qdc_311 Variables below
#################################################################
$vars{'prod_qdc_311'}{'guid'}          = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_qdc_311'}{'loginid'}       = '19999991';
$vars{'prod_qdc_311'}{'fiid'}          = 'DI3399';
$vars{'prod_qdc_311'}{'accountId'}     = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_qdc_311'}{'url'}           = 'http://pprdcbsas311.ie.intuit.net:8080';
$vars{'prod_qdc_311'}{'ap_auth'}       = 'cbs2testclient';

#################################################################
#Define prod_lvdc_SL1 Variables below
#################################################################
$vars{'prod_lvdc_SL1'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_SL1'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_SL1'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_SL1'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_SL1'}{'url'}          = 'http://cbs-sl1-prd-lvdc.banking.intuit.net:80';
$vars{'prod_lvdc_SL1'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40b Variables below
#################################################################
$vars{'prod_lvdc_40b'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40b'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40b'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40b'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40b'}{'url'}          = 'http://pprdcbsas40b.corp.intuit.net:8080';
$vars{'prod_lvdc_40b'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40c Variables below
#################################################################
$vars{'prod_lvdc_40c'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40c'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40c'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40c'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40c'}{'url'}          = 'http://pprdcbsas40c.corp.intuit.net:8080';
$vars{'prod_lvdc_40c'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40h Variables below
#################################################################
$vars{'prod_lvdc_40h'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40h'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40h'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40h'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40h'}{'url'}          = 'http://pprdcbsas40h.corp.intuit.net:8080';
$vars{'prod_lvdc_40h'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_SL2 Variables below
#################################################################
$vars{'prod_lvdc_SL2'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_SL2'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_SL2'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_SL2'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_SL2'}{'url'}          = 'http://cbs-sl2-prd-lvdc.banking.intuit.net:80';
$vars{'prod_lvdc_SL2'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40d Variables below
#################################################################
$vars{'prod_lvdc_40d'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40d'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40d'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40d'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40d'}{'url'}          = 'http://pprdcbsas40d.corp.intuit.net:8080';
$vars{'prod_lvdc_40d'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40e Variables below
#################################################################
$vars{'prod_lvdc_40e'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40e'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40e'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40e'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40e'}{'url'}          = 'http://pprdcbsas40e.corp.intuit.net:8080';
$vars{'prod_lvdc_40e'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40i Variables below
#################################################################
$vars{'prod_lvdc_40i'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40i'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40i'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40i'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40i'}{'url'}          = 'http://pprdcbsas40i.corp.intuit.net:8080';
$vars{'prod_lvdc_40i'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_SL3 Variables below
#################################################################
$vars{'prod_lvdc_SL3'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_SL3'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_SL3'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_SL3'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_SL3'}{'url'}          = 'http://cbs-sl3-prd-lvdc.banking.intuit.net:80';
$vars{'prod_lvdc_SL3'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40k Variables below
#################################################################
$vars{'prod_lvdc_40k'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40k'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40k'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40k'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40k'}{'url'}          = 'http://pprdcbsas40k.ie.intuit.net:8080';
$vars{'prod_lvdc_40k'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40l Variables below
#################################################################
$vars{'prod_lvdc_40l'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40l'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40l'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40l'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40l'}{'url'}          = 'http://pprdcbsas40l.ie.intuit.net:8080';
$vars{'prod_lvdc_40l'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40m Variables below
#################################################################
$vars{'prod_lvdc_40m'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40m'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40m'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40m'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40m'}{'url'}          = 'http://pprdcbsas40m.ie.intuit.net:8080';
$vars{'prod_lvdc_40m'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_SL4 Variables below
#################################################################
$vars{'prod_lvdc_SL4'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_SL4'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_SL4'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_SL4'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_SL4'}{'url'}          = 'http://cbs-sl4-prd-lvdc.banking.intuit.net:80';
$vars{'prod_lvdc_SL4'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40n Variables below
#################################################################
$vars{'prod_lvdc_40n'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40n'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40n'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40n'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40n'}{'url'}          = 'http://pprdcbsas40n.ie.intuit.net:8080';
$vars{'prod_lvdc_40n'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40o Variables below
#################################################################
$vars{'prod_lvdc_40o'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40o'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40o'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40o'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40o'}{'url'}          = 'http://pprdcbsas40o.ie.intuit.net:8080';
$vars{'prod_lvdc_40o'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40p Variables below
#################################################################
$vars{'prod_lvdc_40p'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40p'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40p'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40p'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40p'}{'url'}          = 'http://pprdcbsas40p.ie.intuit.net:8080';
$vars{'prod_lvdc_40p'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_SL5 Variables below
#################################################################
$vars{'prod_lvdc_SL5'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_SL5'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_SL5'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_SL5'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_SL5'}{'url'}          = 'http://cbs-sl5-prd-lvdc.banking.intuit.net:80';
$vars{'prod_lvdc_SL5'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40q Variables below
#################################################################
$vars{'prod_lvdc_40q'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40q'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40q'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40q'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40q'}{'url'}          = 'http://pprdcbsas40q.ie.intuit.net:8080';
$vars{'prod_lvdc_40q'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40r Variables below
#################################################################
$vars{'prod_lvdc_40r'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40r'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40r'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40r'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40r'}{'url'}          = 'http://pprdcbsas40r.ie.intuit.net:8080';
$vars{'prod_lvdc_40r'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40s Variables below
#################################################################
$vars{'prod_lvdc_40s'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40s'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40s'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40s'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40s'}{'url'}          = 'http://pprdcbsas40s.ie.intuit.net:8080';
$vars{'prod_lvdc_40s'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_SL6 Variables below
#################################################################
$vars{'prod_lvdc_SL6'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_SL6'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_SL6'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_SL6'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_SL6'}{'url'}          = 'http://cbs-sl6-prd-lvdc.banking.intuit.net:80';
$vars{'prod_lvdc_SL6'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40t Variables below
#################################################################
$vars{'prod_lvdc_40t'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40t'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40t'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40t'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40t'}{'url'}          = 'http://pprdcbsas40t.ie.intuit.net:8080';
$vars{'prod_lvdc_40t'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Define prod_lvdc_40u Variables below
#################################################################
$vars{'prod_lvdc_40u'}{'guid'}         = 'c0a8f2b600042af64b2ba1bf37312700';
$vars{'prod_lvdc_40u'}{'loginid'}      = '19999991';
$vars{'prod_lvdc_40u'}{'fiid'}         = 'DI3399';
$vars{'prod_lvdc_40u'}{'accountId'}    = 'owLaMpTvVWq5M8mwmn_ev3ynu1GGje4cwks13E5oz5c';
$vars{'prod_lvdc_40u'}{'url'}          = 'http://pprdcbsas40u.ie.intuit.net:8080';
$vars{'prod_lvdc_40u'}{'ap_auth'}      = 'cbs2testclient';

#################################################################
#Execute Tests Below
#################################################################

for (my $i=0; $i<$#servers+1 ; $i++) {
if ($servers[$i]->[1] eq 'y'){
$env = $servers[$i]->[0];

print "\nTesting on $env: $vars{$env}{'url'}\n\n";

#######################################################
#Test 1. Execute CBS2 getServiceStatusV2
#######################################################
$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" $vars{$env}{'url'}/cbs2/status 2>&1`;
    
#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
    print "CBS2 getServiceStatusV2: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
}
{
    print "CBS2 getServiceStatusV2 test result:          	     PASSED\n";
}
    
if ($debug eq 'true') { print "$response\n\n"; }


#######################################################
#Test 2. Execute CBS2 getFinancialInstitutionV2
#######################################################
$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'} 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
    print "CBS2 getFinancialInstitutionV2: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
}
{
    print "CBS2 getFinancialInstitutionV2 test result:          PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }

#######################################################
#Test 3. Execute CBS2 getFICustomerV2
#######################################################
$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}?fiCustomerIdType=GUID 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
    print "CBS2 getFICustomer: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
}
else
{
    print "CBS2 getFICustomer test result:                      PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }



#######################################################
#Test 4. Execute CBS2 getAccountsV2
#######################################################
$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" -H "getExportAcctNum: true" -H "getCrossAccts: true" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts?fiCustomerIdType=GUID 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
    print "CBS2 getAccountsV2: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
}
else
{
    print "CBS2 getAccountsV2 test result:                      PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }


#######################################################
#Test 5. Execute CBS2 getFinancialInfoV2
#######################################################
$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" -H "getExportAcctNum: true" -H "getCrossAccts: true" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/financialInfo?fiCustomerIdType=GUID 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
    print "CBS2 getFinancialInfoV2: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
}
else
{
    print "CBS2 getFinancialInfoV2 test result:                 PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }

#######################################################
#Test 6. Execute CBS2  getTransactionsV2
########################################################
$response = `curl -v -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" -H "intuit_session: sessionId00001" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts/$vars{$env}{'accountId'}/transactions?fiCustomerIdType=GUID 2>&1`;
#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
    print "CBS2 getTransactionsV2: FAILED\n";
    print 'Expected: < HTTP/1.1 200 OK' . "\n";
    print "Instead we got: $response\n\n";
}
else
{
    print "CBS2 getTransactionsV2 test result:                  PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }


#######################################################
#Test 7. Execute CBS2 invalidateUserCacheDel
#######################################################
$response = `curl -v -X DELETE -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/invalidateusercache 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 204 No Content/)
{
    print "CBS2 invalidateUserCacheDel: FAILED\n";
    print 'Expected: < HTTP/1.1 204 No Content' . "\n";
    print "Instead we got: $response\n\n";
}
else
{
    print "CBS2 invalidateUserCacheDel test result:             PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }

#######################################################
#Test 8. Execute CBS2 deleteAccountUSRSUM
#######################################################
$response = `curl -v -X DELETE -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: autoTest" -H "intuit_offeringId: autoTest" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: 1234abcd" $vars{$env}{'url'}/cbs2/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts/usrsum?fiCustomerIdType=GUID 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 204 No Content/)
{
    print "CBS2 deleteAccountUSRSUM: FAILED\n";
    print 'Expected: < HTTP/1.1 204 No Content' . "\n";
    print "Instead we got: $response\n\n";
}
else
{
    print "CBS2 deleteAccountUSRSUM test result:                PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }

} # end of if statement
} # end of for statement
