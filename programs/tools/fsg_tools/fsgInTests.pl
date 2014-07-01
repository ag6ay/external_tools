#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   fsgInTests.pl - Very simple set of FSG Internal smoke tests.  Primary    ##
##                   use for Beta and Production deployment verification.     ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 05/09/2013 Ver. 1.8                   ##
##                                                                            ##
##                   FSG Version: 3.9                                         ##
##                                                                            ##
################################################################################
################################################################################
use strict;
system('clear');




#################################################################
#Declare Variables
#################################################################
my %vars               = ();
my $env                = (lc($ARGV[0]) || '');
my $msg                = '';
my $response           = '';
my $debug              = 'false';
my $version            = '1.8';
my $offeringId         = 'FSGSmokeTest';
my $tid                = '40a51cd1-560c-4d4c-bb00-f7d4d15714e7';



#################################################################
#Test Definitions Set Below
#################################################################

#################################################################
#Define qa_wlv Variables below
#################################################################
$vars{'qa_wlv'}{'guid'}           = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qa_wlv'}{'loginid'}        = 'SMOKETEST001';
$vars{'qa_wlv'}{'fiid'}           = 'DI0508';
$vars{'qa_wlv'}{'fiid3'}          = 'DI0513';
$vars{'qa_wlv'}{'url'}            = 'http://fsgateway-vip.app.qa.diginsite.com:8681';
$vars{'qa_wlv'}{'ap_auth'}        = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa_wlv'}{'cc_auth'}        = 'a296817245ca4bb092ef90599bef7607';
$vars{'qa_wlv'}{'pr_auth'}        = '34d9ef105f5949938727628e2b999677';
$vars{'qa_wlv'}{'cas_auth'}       = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'qa_wlv'}{'usp_auth'}       = '5f6fab55077f4de1bec2670836667cec';
$vars{'qa_wlv'}{'sdp_auth'}       = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qa_qdc Variables below
#################################################################
$vars{'qa_qdc'}{'guid'}           = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qa_qdc'}{'loginid'}        = 'SMOKETEST001';
$vars{'qa_qdc'}{'fiid'}           = 'DI0508';
$vars{'qa_qdc'}{'fiid2'}          = 'DI3004';
$vars{'qa_qdc'}{'fiid3'}          = 'DI0513';
$vars{'qa_qdc'}{'url'}            = 'http://services-qal-qydc.banking.intuit.net:80';
$vars{'qa_qdc'}{'ap_auth'}        = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa_qdc'}{'cc_auth'}        = 'a296817245ca4bb092ef90599bef7607';
$vars{'qa_qdc'}{'pr_auth'}        = '34d9ef105f5949938727628e2b999677';
$vars{'qa_qdc'}{'cas_auth'}       = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'qa_qdc'}{'usp_auth'}       = '5f6fab55077f4de1bec2670836667cec';
$vars{'qa_qdc'}{'sdp_auth'}       = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define pte_wlv Variables below
#################################################################
$vars{'pte_wlv'}{'guid'}          = 'c0a8f2b30004401a471b8a1e02b82a00';
$vars{'pte_wlv'}{'loginid'}       = 'PRTEST1000';
$vars{'pte_wlv'}{'fiid'}          = 'DI7033';
$vars{'pte_wlv'}{'url'}           = 'http://fsgateway-pte-vip.app.qa.diginsite.com:8681';
$vars{'pte_wlv'}{'ap_auth'}       = 'c1ae7aed44054565800fb9356040867f';
$vars{'pte_wlv'}{'cc_auth'}       = 'a296817245ca4bb092ef90599bef7607';
$vars{'pte_wlv'}{'pr_auth'}       = '34d9ef105f5949938727628e2b999677';
$vars{'pte_wlv'}{'cas_auth'}      = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'pte_wlv'}{'usp_auth'}      = '5f6fab55077f4de1bec2670836667cec';
$vars{'pte_wlv'}{'sdp_auth'}      = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define perf_qdc Variables below
#################################################################
$vars{'perf_qdc'}{'guid'}         = 'c0a8f2b30004401a471b8a1e02b82a00';
$vars{'perf_qdc'}{'loginid'}      = 'PRTEST1000';
$vars{'perf_qdc'}{'fiid'}         = 'DI7033';
$vars{'perf_qdc'}{'url'}          = 'http://services-int-sl1-prf-qydc.banking.intuit.net:80';
$vars{'perf_qdc'}{'ap_auth'}      = 'c1ae7aed44054565800fb9356040867f';
$vars{'perf_qdc'}{'cc_auth'}      = 'a296817245ca4bb092ef90599bef7607';
$vars{'perf_qdc'}{'pr_auth'}      = '34d9ef105f5949938727628e2b999677';
$vars{'perf_qdc'}{'cas_auth'}     = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'perf_qdc'}{'usp_auth'}     = '5f6fab55077f4de1bec2670836667cec';
$vars{'perf_qdc'}{'sdp_auth'}     = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define stag_lvdc Variables below
#################################################################
$vars{'stag_lvdc'}{'guid'}        = 'c0a8f2b30004401a471b8a1e02b82a00';
$vars{'stag_lvdc'}{'loginid'}     = 'PRTEST1000';
$vars{'stag_lvdc'}{'fiid'}        = 'DI7033';
$vars{'stag_lvdc'}{'url'}         = 'http://services-stg-lvdc.banking.intuit.net:80';
$vars{'stag_lvdc'}{'ap_auth'}     = 'c1ae7aed44054565800fb9356040867f';
$vars{'stag_lvdc'}{'cc_auth'}     = 'a296817245ca4bb092ef90599bef7607';
$vars{'stag_lvdc'}{'pr_auth'}     = '34d9ef105f5949938727628e2b999677';
$vars{'stag_lvdc'}{'cas_auth'}    = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'stag_lvdc'}{'usp_auth'}    = '5f6fab55077f4de1bec2670836667cec';
$vars{'stag_lvdc'}{'sdp_auth'}    = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define uat_qdc Variables below
#################################################################
$vars{'uat_qdc'}{'guid'}          = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'uat_qdc'}{'loginid'}       = 'SMOKETEST001';
$vars{'uat_qdc'}{'fiid'}          = 'DI0508';
$vars{'uat_qdc'}{'url'}           = 'http://services-uat-qydc.banking.intuit.net:80';
$vars{'uat_qdc'}{'ap_auth'}       = 'c1ae7aed44054565800fb9356040867f';
$vars{'uat_qdc'}{'cc_auth'}       = 'a296817245ca4bb092ef90599bef7607';
$vars{'uat_qdc'}{'pr_auth'}       = '34d9ef105f5949938727628e2b999677';
$vars{'uat_qdc'}{'cas_auth'}      = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'uat_qdc'}{'usp_auth'}      = '5f6fab55077f4de1bec2670836667cec';
$vars{'uat_qdc'}{'sdp_auth'}      = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define beta_wlv Variables below
#################################################################
$vars{'beta_wlv'}{'guid'}         = 'c0a8f2bc0003f01e466f385a1ed1e100';
$vars{'beta_wlv'}{'loginid'}      = '717138588';
$vars{'beta_wlv'}{'fiid'}         = 'DI5150';
$vars{'beta_wlv'}{'url'}          = 'http://fsgateway-beta-vip.app.prod.diginsite.com:8681';
$vars{'beta_wlv'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'beta_wlv'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'beta_wlv'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'beta_wlv'}{'cas_auth'}     = '8188261f3031465b98d3cae2bf9b57ae';
$vars{'beta_wlv'}{'usp_auth'}     = 'ea501fb80f814a2ab516253b85408860';
$vars{'beta_wlv'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define beta_qdc Variables below
#################################################################
$vars{'beta_qdc'}{'guid'}         = 'c0a8f2bc0003f01e466f385a1ed1e100';
$vars{'beta_qdc'}{'loginid'}      = '717138588';
$vars{'beta_qdc'}{'fiid'}         = 'DI5150';
$vars{'beta_qdc'}{'fiid2'}        = 'DI5529';
$vars{'beta_qdc'}{'url'}          = 'http://services-bta-qydc.banking.intuit.net:80';
$vars{'beta_qdc'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'beta_qdc'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'beta_qdc'}{'pr_auth'}      = 'f21c2e67-9634-4006-9d2d-79ab525357c6';
$vars{'beta_qdc'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'beta_qdc'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'beta_qdc'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_wlv_web Variables below
#################################################################
$vars{'prod_wlv_web'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_wlv_web'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_wlv_web'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_wlv_web'}{'loginid'}      = 'gloria02';
$vars{'prod_wlv_web'}{'fiid'}         = 'DI3645';
$vars{'prod_wlv_web'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_wlv_web'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_wlv_web'}{'url'}          = 'http://fsgateway-vip.web.prod.diginsite.com:8681';
$vars{'prod_wlv_web'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_wlv_web'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_wlv_web'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_wlv_web'}{'cas_auth'}     = '8188261f3031465b98d3cae2bf9b57ae';
$vars{'prod_wlv_web'}{'usp_auth'}     = 'ea501fb80f814a2ab516253b85408860';
$vars{'prod_wlv_web'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_wlv_app Variables below
#################################################################
$vars{'prod_wlv_app'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_wlv_app'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_wlv_app'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_wlv_app'}{'loginid'}      = 'gloria02';
$vars{'prod_wlv_app'}{'fiid'}         = 'DI3645';
$vars{'prod_wlv_app'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_wlv_app'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_wlv_app'}{'url'}          = 'http://fsgateway-vip.app.prod.diginsite.com:8681';
$vars{'prod_wlv_app'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_wlv_app'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_wlv_app'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_wlv_app'}{'cas_auth'}     = '8188261f3031465b98d3cae2bf9b57ae';
$vars{'prod_wlv_app'}{'usp_auth'}     = 'ea501fb80f814a2ab516253b85408860';
$vars{'prod_wlv_app'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_qdc_sl1 Variables below
#################################################################
$vars{'prod_qdc_sl1'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl1'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl1'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_qdc_sl1'}{'loginid'}      = 'gloria02';
$vars{'prod_qdc_sl1'}{'fiid'}         = 'DI3645';
$vars{'prod_qdc_sl1'}{'fiid2'}        = 'DI5526';
$vars{'prod_qdc_sl1'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_qdc_sl1'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_qdc_sl1'}{'fiid_cbsalt'}  = 'DI5533';
$vars{'prod_qdc_sl1'}{'url'}          = 'http://services-int-sl1-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl1'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl1'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_qdc_sl1'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_qdc_sl1'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_qdc_sl1'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_qdc_sl1'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_qdc_sl2 Variables below
#################################################################
$vars{'prod_qdc_sl2'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl2'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl2'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_qdc_sl2'}{'loginid'}      = 'gloria02';
$vars{'prod_qdc_sl2'}{'fiid'}         = 'DI3645';
$vars{'prod_qdc_sl2'}{'fiid2'}        = 'DI5529';
$vars{'prod_qdc_sl2'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_qdc_sl2'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_qdc_sl2'}{'fiid_cbsalt'}  = 'DI5533';
$vars{'prod_qdc_sl2'}{'url'}          = 'http://services-int-sl2-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl2'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl2'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_qdc_sl2'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_qdc_sl2'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_qdc_sl2'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_qdc_sl2'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_qdc_sl3 Variables below
#################################################################
$vars{'prod_qdc_sl3'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl3'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl3'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_qdc_sl3'}{'loginid'}      = 'gloria02';
$vars{'prod_qdc_sl3'}{'fiid'}         = 'DI3645';
$vars{'prod_qdc_sl3'}{'fiid2'}        = 'DI5530';
$vars{'prod_qdc_sl3'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_qdc_sl3'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_qdc_sl3'}{'fiid_cbsalt'}  = 'DI5533';
$vars{'prod_qdc_sl3'}{'url'}          = 'http://services-int-sl3-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl3'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl3'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_qdc_sl3'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_qdc_sl3'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_qdc_sl3'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_qdc_sl3'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_qdc_sl4 Variables below
#################################################################
$vars{'prod_qdc_sl4'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl4'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl4'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_qdc_sl4'}{'loginid'}      = 'gloria02';
$vars{'prod_qdc_sl4'}{'fiid'}         = 'DI3645';
$vars{'prod_qdc_sl4'}{'fiid2'}        = 'DI5530';
$vars{'prod_qdc_sl4'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_qdc_sl4'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_qdc_sl4'}{'fiid_cbsalt'}  = 'DI5533';
$vars{'prod_qdc_sl4'}{'url'}          = 'http://services-int-sl4-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl4'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl4'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_qdc_sl4'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_qdc_sl4'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_qdc_sl4'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_qdc_sl4'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_qdc_sl5 Variables below
#################################################################
$vars{'prod_qdc_sl5'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl5'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl5'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_qdc_sl5'}{'loginid'}      = 'gloria02';
$vars{'prod_qdc_sl5'}{'fiid'}         = 'DI3645';
$vars{'prod_qdc_sl5'}{'fiid2'}        = 'DI5532';
$vars{'prod_qdc_sl5'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_qdc_sl5'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_qdc_sl5'}{'fiid_cbsalt'}  = 'DI5533';
$vars{'prod_qdc_sl5'}{'url'}          = 'http://services-int-sl5-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl5'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl5'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_qdc_sl5'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_qdc_sl5'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_qdc_sl5'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_qdc_sl5'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_qdc_sl6 Variables below
#################################################################
$vars{'prod_qdc_sl6'}{'guid'}         = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl6'}{'guid_spi'}     = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl6'}{'guid_spialt'}  = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_qdc_sl6'}{'loginid'}      = 'gloria02';
$vars{'prod_qdc_sl6'}{'fiid'}         = 'DI3645';
$vars{'prod_qdc_sl6'}{'fiid2'}        = 'DI5533';
$vars{'prod_qdc_sl6'}{'fiid_spi'}     = 'DI3355';
$vars{'prod_qdc_sl6'}{'fiid_spialt'}  = 'DI1370';
$vars{'prod_qdc_sl6'}{'fiid_cbsalt'}  = 'DI5533';
$vars{'prod_qdc_sl6'}{'url'}          = 'http://services-int-sl6-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl6'}{'ap_auth'}      = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl6'}{'cc_auth'}      = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_qdc_sl6'}{'pr_auth'}      = '48d34a562815445194981f402c62abeb';
$vars{'prod_qdc_sl6'}{'cas_auth'}     = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_qdc_sl6'}{'usp_auth'}     = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_qdc_sl6'}{'sdp_auth'}     = 'bc1f2337a8864b61a6c37f2597c38e1c';






#################################################################
#Prod prod_lvdc_sl1 Variables below
#################################################################
$vars{'prod_lvdc_sl1'}{'guid'}        = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl1'}{'guid_spi'}    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl1'}{'guid_spialt'} = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_lvdc_sl1'}{'loginid'}     = 'gloria02';
$vars{'prod_lvdc_sl1'}{'fiid'}        = 'DI3645';
$vars{'prod_lvdc_sl1'}{'fiid2'}       = 'DI5526';
$vars{'prod_lvdc_sl1'}{'fiid_spi'}    = 'DI3355';
$vars{'prod_lvdc_sl1'}{'fiid_spialt'} = 'DI1370';
$vars{'prod_lvdc_sl1'}{'fiid_cbsalt'} = 'DI5533';
$vars{'prod_lvdc_sl1'}{'url'}         = 'http://services-int-sl1-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl1'}{'ap_auth'}     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl1'}{'cc_auth'}     = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_lvdc_sl1'}{'pr_auth'}     = '48d34a562815445194981f402c62abeb';
$vars{'prod_lvdc_sl1'}{'cas_auth'}    = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_lvdc_sl1'}{'usp_auth'}    = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_lvdc_sl1'}{'sdp_auth'}    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_lvdc_sl2 Variables below
#################################################################
$vars{'prod_lvdc_sl2'}{'guid'}        = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl2'}{'guid_spi'}    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl2'}{'guid_spialt'} = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_lvdc_sl2'}{'loginid'}     = 'gloria02';
$vars{'prod_lvdc_sl2'}{'fiid'}        = 'DI3645';
$vars{'prod_lvdc_sl2'}{'fiid2'}       = 'DI5529';
$vars{'prod_lvdc_sl2'}{'fiid_spi'}    = 'DI3355';
$vars{'prod_lvdc_sl2'}{'fiid_spialt'} = 'DI1370';
$vars{'prod_lvdc_sl2'}{'fiid_cbsalt'} = 'DI5533';
$vars{'prod_lvdc_sl2'}{'url'}         = 'http://services-int-sl2-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl2'}{'ap_auth'}     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl2'}{'cc_auth'}     = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_lvdc_sl2'}{'pr_auth'}     = '48d34a562815445194981f402c62abeb';
$vars{'prod_lvdc_sl2'}{'cas_auth'}    = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_lvdc_sl2'}{'usp_auth'}    = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_lvdc_sl2'}{'sdp_auth'}    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_lvdc_sl3 Variables below
#################################################################
$vars{'prod_lvdc_sl3'}{'guid'}        = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl3'}{'guid_spi'}    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl3'}{'guid_spialt'} = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_lvdc_sl3'}{'loginid'}     = 'gloria02';
$vars{'prod_lvdc_sl3'}{'fiid'}        = 'DI3645';
$vars{'prod_lvdc_sl3'}{'fiid2'}       = 'DI5530';
$vars{'prod_lvdc_sl3'}{'fiid_spi'}    = 'DI3355';
$vars{'prod_lvdc_sl3'}{'fiid_spialt'} = 'DI1370';
$vars{'prod_lvdc_sl3'}{'fiid_cbsalt'} = 'DI5533';
$vars{'prod_lvdc_sl3'}{'url'}         = 'http://services-int-sl3-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl3'}{'ap_auth'}     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl3'}{'cc_auth'}     = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_lvdc_sl3'}{'pr_auth'}     = '48d34a562815445194981f402c62abeb';
$vars{'prod_lvdc_sl3'}{'cas_auth'}    = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_lvdc_sl3'}{'usp_auth'}    = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_lvdc_sl3'}{'sdp_auth'}    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_lvdc_sl4 Variables below
#################################################################
$vars{'prod_lvdc_sl4'}{'guid'}        = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl4'}{'guid_spi'}    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl4'}{'guid_spialt'} = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_lvdc_sl4'}{'loginid'}     = 'gloria02';
$vars{'prod_lvdc_sl4'}{'fiid'}        = 'DI3645';
$vars{'prod_lvdc_sl4'}{'fiid2'}       = 'DI5530';
$vars{'prod_lvdc_sl4'}{'fiid_spi'}    = 'DI3355';
$vars{'prod_lvdc_sl4'}{'fiid_spialt'} = 'DI1370';
$vars{'prod_lvdc_sl4'}{'fiid_cbsalt'} = 'DI5533';
$vars{'prod_lvdc_sl4'}{'url'}         = 'http://services-int-sl4-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl4'}{'ap_auth'}     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl4'}{'cc_auth'}     = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_lvdc_sl4'}{'pr_auth'}     = '48d34a562815445194981f402c62abeb';
$vars{'prod_lvdc_sl4'}{'cas_auth'}    = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_lvdc_sl4'}{'usp_auth'}    = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_lvdc_sl4'}{'sdp_auth'}    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_lvdc_sl5 Variables below
#################################################################
$vars{'prod_lvdc_sl5'}{'guid'}        = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl5'}{'guid_spi'}    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl5'}{'guid_spialt'} = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_lvdc_sl5'}{'loginid'}     = 'gloria02';
$vars{'prod_lvdc_sl5'}{'fiid'}        = 'DI3645';
$vars{'prod_lvdc_sl5'}{'fiid2'}       = 'DI5533';
$vars{'prod_lvdc_sl5'}{'fiid_spi'}    = 'DI3355';
$vars{'prod_lvdc_sl5'}{'fiid_spialt'} = 'DI1370';
$vars{'prod_lvdc_sl5'}{'fiid_cbsalt'} = 'DI5533';
$vars{'prod_lvdc_sl5'}{'url'}         = 'http://services-int-sl5-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl5'}{'ap_auth'}     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl5'}{'cc_auth'}     = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_lvdc_sl5'}{'pr_auth'}     = '48d34a562815445194981f402c62abeb';
$vars{'prod_lvdc_sl5'}{'cas_auth'}    = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_lvdc_sl5'}{'usp_auth'}    = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_lvdc_sl5'}{'sdp_auth'}    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Prod prod_lvdc_sl6 Variables below
#################################################################
$vars{'prod_lvdc_sl6'}{'guid'}        = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl6'}{'guid_spi'}    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl6'}{'guid_spialt'} = 'c0a8f2bc017d00e8506dbfa208370900';
$vars{'prod_lvdc_sl6'}{'loginid'}     = 'gloria02';
$vars{'prod_lvdc_sl6'}{'fiid'}        = 'DI3645';
$vars{'prod_lvdc_sl6'}{'fiid2'}       = 'DI5533';
$vars{'prod_lvdc_sl6'}{'fiid_spi'}    = 'DI3355';
$vars{'prod_lvdc_sl6'}{'fiid_spialt'} = 'DI1370';
$vars{'prod_lvdc_sl6'}{'fiid_cbsalt'} = 'DI5533';
$vars{'prod_lvdc_sl6'}{'url'}         = 'http://services-int-sl6-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl6'}{'ap_auth'}     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl6'}{'cc_auth'}     = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prod_lvdc_sl6'}{'pr_auth'}     = '48d34a562815445194981f402c62abeb';
$vars{'prod_lvdc_sl6'}{'cas_auth'}    = '0df4130d5e444013aa98d3bf738da4df';
$vars{'prod_lvdc_sl6'}{'usp_auth'}    = '0e4d7ae3194f4ccb97dc989482f974de';
$vars{'prod_lvdc_sl6'}{'sdp_auth'}    = 'bc1f2337a8864b61a6c37f2597c38e1c';




#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                        FSG Internal Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <env_key>\n\n" .
           "     <env_key>    - Supported values are:\n\n" .
           "                    qa_wlv\n" .
           "                    qa_qdc\n\n" .
           "                    pte_wlv\n" .
           "                    perf_qdc\n\n" .
           "                    stag_lvdc\n\n" .
           "                    uat_qdc\n\n" .
           "                    beta_wlv\n" .
           "                    beta_qdc\n\n" .
           "                    prod_wlv_web\n" .
           "                    prod_wlv_app\n" .
           "                    prod_qdc_sl1\n" .
           "                    prod_qdc_sl2\n" .
           "                    prod_qdc_sl3\n" .
           "                    prod_qdc_sl4\n" .
           "                    prod_qdc_sl5\n" .
           "                    prod_qdc_sl6\n" .
           "                    prod_lvdc_sl1\n" .
           "                    prod_lvdc_sl2\n" .
           "                    prod_lvdc_sl3\n" .
           "                    prod_lvdc_sl4\n" .
           "                    prod_lvdc_sl5\n" .
           "                    prod_lvdc_sl6\n\n" .
           "****************************************************************************************************\n\n\n";

   print $msg;
   exit 0;
}





#################################################################
#Execute Tests Below
#################################################################

#Print Which Environment Running Tests Against
print "Running FSG internal smoke test (Ver. $version) for environment: $env\n";

#######################################################
#Test 1. Execute FSG Status Service
#######################################################
$response = `curl -vN  $vars{$env}{'url'}/fsg/v2/status 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
   print "FSG 'Status' service test result: FAILED\n";
   print 'Expected: < HTTP/1.1 200 OK' . "\n";
   print "Instead we got: $response\n\n";
}
else
{
   print "FSG 'Status' service test result:                          PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }



#######################################################
#Test 2. Execute FSG CBS2-getFICustomerV2 Request:
#######################################################
$response = `curl -vN -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: AdminPlatform" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}?fiCustomerIdType=GUID 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
   print "FSG 'CBS2-getFICustomerV2' test result: FAILED\n";
   print 'Expected: < HTTP/1.1 200 OK' . "\n";
   print "Instead we got: $response\n\n";
}
else
{
   print "FSG 'CBS2-getFICustomerV2' test result:                    PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }


#######################################################
#Test 3. Execute FSG CBS2-getFinancialInfoV2 Request:
#######################################################
$response = `curl -vN -H "Authorization: $vars{$env}{'cc_auth'}" -H "intuit_appId: CustomerCentral" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/financialInfo?fiCustomerIdType=GUID 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
   print "FSG 'CBS2-getFinancialInfoV2' test result: FAILED\n";
   print 'Expected: < HTTP/1.1 200 OK' . "\n";
   print "Instead we got: $response\n\n";
}
else
{
   print "FSG 'CBS2-getFinancialInfoV2' test result:                 PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }


#######################################################
#Test 4. Execute FSG CBS2-getAccountsV2 Request:
#######################################################
$response = `curl -vN -H "Authorization: $vars{$env}{'pr_auth'}" -H "intuit_appId: PRService" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts 2>&1`;

#Validate Response
if ($response !~ /\< HTTP\/1\.1 200 OK/)
{
   print "FSG 'CBS2-getAccountsV2' test result: FAILED\n";
   print 'Expected: < HTTP/1.1 200 OK' . "\n";
   print "Instead we got: $response\n\n";
}
else
{
   print "FSG 'CBS2-getAccountsV2' test result:                      PASSED\n";
}

if ($debug eq 'true') { print "$response\n\n"; }



if ( (defined $vars{$env}{'guid_spi'}) && ($vars{$env}{'guid_spi'} ne '') && (defined $vars{$env}{'fiid_spi'}) && ($vars{$env}{'fiid_spi'} ne '') )
{
   #######################################################
   #Test 5. Execute FSG SPI-getFinanceInstitution-v1
   #######################################################
   $response = `curl -vN -H "intuit_locale: en" -H "intuit_payment_urid: $vars{$env}{'guid_spi'}" -H "intuit_payment_cid: 180541645" -H "intuit_payment_fiid: $vars{$env}{'fiid_spi'}" -H "intuit_payment_app_token: $tid" -H "Authorization: $vars{$env}{'sdp_auth'}" -H "intuit_appId: SDP" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v1/realm/0/financeinstitution 2>&1`;

   #Validate Response
   if ($response !~ /\< HTTP\/1\.1 200 OK/)
   {
      print "FSG 'SPI-getFinanceInstitution-v1' test result: FAILED\n";
      print 'Expected: < HTTP/1.1 200 OK' . "\n";
      print "Instead we got: $response\n\n";
   }
   else
   {
      print "FSG 'SPI-getFinanceInstitution-v1' test result:            PASSED\n";
   }

   if ($debug eq 'true') { print "$response\n\n"; }
}



if ( (defined $vars{$env}{'guid_spialt'}) && ($vars{$env}{'guid_spialt'} ne '') && (defined $vars{$env}{'fiid_spialt'}) && ($vars{$env}{'fiid_spialt'} ne '') )
{
   #######################################################
   #Test 6. Execute FSG SPI-ALT-getFinanceInstitution-v1
   #######################################################
   $response = `curl -vN -H "intuit_locale: en" -H "intuit_payment_urid: $vars{$env}{'guid_spialt'}" -H "intuit_payment_cid: 180541645" -H "intuit_payment_fiid: $vars{$env}{'fiid_spialt'}" -H "intuit_payment_app_token: $tid" -H "Authorization: $vars{$env}{'sdp_auth'}" -H "intuit_appId: SDP" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v1/realm/0/financeinstitution 2>&1`;

   #Validate Response
   if ($response !~ /\< HTTP\/1\.1 200 OK/)
   {
      print "FSG 'SPI-ALT-getFinanceInstitution-v1' test result: FAILED\n";
      print 'Expected: < HTTP/1.1 200 OK' . "\n";
      print "Instead we got: $response\n\n";
   }
   else
   {
      print "FSG 'SPI-ALT-getFinanceInstitution-v1' test result:        PASSED\n";
   }

   if ($debug eq 'true') { print "$response\n\n"; }
}


#######################################################
#######################################################
##The below tests are specific to qdc and lvdc
#######################################################
#######################################################
if ( ($env =~ /qdc/) || ($env =~ /lvdc/) )
{
   #######################################################
   #Test 7. Execute FSG CAS-getFinancialInstitution-v3 Request:
   #######################################################
   $response = `curl -vN -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: AdminPlatform" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v3/fis/$vars{$env}{'fiid2'} 2>&1`;

   #Validate Response
   if ($response !~ /\< HTTP\/1\.1 200 OK/)
   {
      print "FSG 'CAS-getFinancialInstitution-v3' test result: FAILED\n";
      print 'Expected: < HTTP/1.1 200 OK' . "\n";
      print "Instead we got: $response\n\n";
   }
   else
   {
      print "FSG 'CAS-getFinancialInstitution-v3' test result:          PASSED\n";
   }

   if ($debug eq 'true') { print "$response\n\n"; }


   #######################################################
   #Test 8. Execute FSG CBS2-primary-getFIV2 Request using FI ID 1:
   #######################################################
   $response = `curl -vN -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: AdminPlatform" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'} 2>&1`;

   #Validate Response
   if ($response !~ /\< HTTP\/1\.1 200 OK/)
   {
      print "FSG 'CBS2-primary-getFIV2' test result: FAILED\n";
      print 'Expected: < HTTP/1.1 200 OK' . "\n";
      print "Instead we got: $response\n\n";
   }
   else
   {
      print "FSG 'CBS2-primary-getFIV2' test result:                    PASSED\n";
   }

   if ($debug eq 'true') { print "$response\n\n"; }


   if ( (defined $vars{$env}{'fiid_cbsalt'}) && ($vars{$env}{'fiid_cbsalt'} ne '') )
   {
      #######################################################
      #Test 9. Execute FSG CBS2-alternate-getFIV2 Request using FI ID CBS ALT:
      #######################################################
      $response = `curl -vN -H "Authorization: $vars{$env}{'ap_auth'}" -H "intuit_appId: AdminPlatform" -H "intuit_offeringId: $offeringId" -H "intuit_originatingIp: 1.1.1.1" -H "intuit_tid: $tid" $vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid_cbsalt'} 2>&1`;

      #Validate Response
      if ($response !~ /\< HTTP\/1\.1 200 OK/)
      {
         print "FSG 'CBS2-alternate-getFIV2' test result: FAILED\n";
         print 'Expected: < HTTP/1.1 200 OK' . "\n";
         print "Instead we got: $response\n\n";
      }
      else
      {
         print "FSG 'CBS2-alternate-getFIV2' test result:                  PASSED\n";
      }

      if ($debug eq 'true') { print "$response\n\n"; }
   }
}
