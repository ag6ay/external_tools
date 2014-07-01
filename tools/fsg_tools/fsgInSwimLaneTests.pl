#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
## fsgInSwimLaneTests.pl - FSG INTERNAL swim lane smoke tests used to         ##
##                         validate FSG is functional in swim lane.           ##
##                                                                            ##
##                   Created by: David Schwab                                 ##
##                   Last updated: DS - 05/07/2014 Ver. 1.0                   ##
##                                                                            ##
##                   FSG Version: 4.10                                        ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use HTTP::Request;
use LWP::UserAgent;
system('clear');




#################################################################
#Configurable Variables
#################################################################
our $debug             = 'false';
my $offeringId         = 'FSGSmokeTest';
my $agent              = 'DI FSG TESTING';
my $originatingIp      = '1.1.1.1';
my $tid                = '40a51cd1-560c-4d4c-bb00-f7d4d15714e7';
my $readTimeOut        = 30;




#################################################################
#Declare Variables
#################################################################
my %vars               = ();
my $env                = ($ARGV[0] || '');
my $msg                = '';
my $response           = '';
my $version            = '1.0';
my $testName           = '';
my $outboundProxy      = '';
my $httpResCode        = '';
my $httpResponseHeader = '';
my $httpResponseBody   = '';
my $httpResponse       = '';
my %httpHeaderHash     = ();
my $httpContentType    = 'application/xml';
my $httpBody           = '';
my $testResult         = '';
our $finalTestResult   = 'PASSED';



#################################################################
#Test Definitions Set Below
#################################################################

#################################################################
#Define qa_wlv_web Variables below
#################################################################
$vars{'qa_wlv_web'}{'guid'}                      = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qa_wlv_web'}{'bps_guid'}                  = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qa_wlv_web'}{'ns_authid'}                 = '266380973';
$vars{'qa_wlv_web'}{'fiid'}                      = '00508';
$vars{'qa_wlv_web'}{'ns_fiid'}                   = '00519';
$vars{'qa_wlv_web'}{'bps_fiid'}                  = 'DI0516';
$vars{'qa_wlv_web'}{'url'}                       = 'http://fsgateway-vip.web.qa.diginsite.com:8681';
$vars{'qa_wlv_web'}{'ap_auth'}                   = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa_wlv_web'}{'ns_auth'}                   = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qa_wlv_web'}{'sdp_auth'}                  = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qa_wlv_app Variables below
#################################################################
$vars{'qa_wlv_app'}{'guid'}                      = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qa_wlv_app'}{'bps_guid'}                  = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qa_wlv_app'}{'ns_authid'}                 = '266380973';
$vars{'qa_wlv_app'}{'fiid'}                      = '00508';
$vars{'qa_wlv_app'}{'ns_fiid'}                   = '00519';
$vars{'qa_wlv_app'}{'bps_fiid'}                  = 'DI0516';
$vars{'qa_wlv_app'}{'url'}                       = 'http://fsgateway-vip.app.qa.diginsite.com:8681';
$vars{'qa_wlv_app'}{'ap_auth'}                   = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa_wlv_app'}{'ns_auth'}                   = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qa_wlv_app'}{'sdp_auth'}                  = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qa_qdc_sl1 Variables below
#################################################################
$vars{'qa_qdc_sl1'}{'guid'}                      = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qa_qdc_sl1'}{'bps_guid'}                  = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qa_qdc_sl1'}{'ns_authid'}                 = '266380973';
$vars{'qa_qdc_sl1'}{'fiid'}                      = '00508';
$vars{'qa_qdc_sl1'}{'ns_fiid'}                   = '00519';
$vars{'qa_qdc_sl1'}{'bps_fiid'}                  = 'DI0516';
$vars{'qa_qdc_sl1'}{'url'}                       = 'http://services-int-sl1-qal-qydc.banking.intuit.net';
$vars{'qa_qdc_sl1'}{'ap_auth'}                   = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa_qdc_sl1'}{'ns_auth'}                   = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qa_qdc_sl1'}{'sdp_auth'}                  = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qa_qdc_sl2 Variables below
#################################################################
$vars{'qa_qdc_sl2'}{'guid'}                      = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qa_qdc_sl2'}{'bps_guid'}                  = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qa_qdc_sl2'}{'ns_authid'}                 = '266380973';
$vars{'qa_qdc_sl2'}{'fiid'}                      = '00508';
$vars{'qa_qdc_sl2'}{'ns_fiid'}                   = '00519';
$vars{'qa_qdc_sl2'}{'bps_fiid'}                  = 'DI0516';
$vars{'qa_qdc_sl2'}{'url'}                       = 'http://services-int-sl2-qal-qydc.banking.intuit.net';
$vars{'qa_qdc_sl2'}{'ap_auth'}                   = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa_qdc_sl2'}{'ns_auth'}                   = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qa_qdc_sl2'}{'sdp_auth'}                  = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal1_dca_sl1 Variables below
#################################################################
$vars{'qal1_dca_sl1'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal1_dca_sl1'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal1_dca_sl1'}{'ns_authid'}               = '266380973';
$vars{'qal1_dca_sl1'}{'fiid'}                    = '00508';
$vars{'qal1_dca_sl1'}{'ns_fiid'}                 = '00519';
$vars{'qal1_dca_sl1'}{'bps_fiid'}                = 'DI0516';
$vars{'qal1_dca_sl1'}{'url'}                     = 'http://fsg-sl1.qal1.dca.diginsite.net';
$vars{'qal1_dca_sl1'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal1_dca_sl1'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal1_dca_sl1'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal1_dca_sl2 Variables below
#################################################################
$vars{'qal1_dca_sl2'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal1_dca_sl2'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal1_dca_sl2'}{'ns_authid'}               = '266380973';
$vars{'qal1_dca_sl2'}{'fiid'}                    = '00508';
$vars{'qal1_dca_sl2'}{'ns_fiid'}                 = '00519';
$vars{'qal1_dca_sl2'}{'bps_fiid'}                = 'DI0516';
$vars{'qal1_dca_sl2'}{'url'}                     = 'http://fsg-sl2.qal1.dca.diginsite.net';
$vars{'qal1_dca_sl2'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal1_dca_sl2'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal1_dca_sl2'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal1_dcb_sl1 Variables below
#################################################################
$vars{'qal1_dcb_sl1'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal1_dcb_sl1'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal1_dcb_sl1'}{'ns_authid'}               = '266380973';
$vars{'qal1_dcb_sl1'}{'fiid'}                    = '00508';
$vars{'qal1_dcb_sl1'}{'ns_fiid'}                 = '00519';
$vars{'qal1_dcb_sl1'}{'bps_fiid'}                = 'DI0516';
$vars{'qal1_dcb_sl1'}{'url'}                     = 'http://fsg-sl1.qal1.dcb.diginsite.net';
$vars{'qal1_dcb_sl1'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal1_dcb_sl1'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal1_dcb_sl1'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal1_dcb_sl2 Variables below
#################################################################
$vars{'qal1_dcb_sl2'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal1_dcb_sl2'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal1_dcb_sl2'}{'ns_authid'}               = '266380973';
$vars{'qal1_dcb_sl2'}{'fiid'}                    = '00508';
$vars{'qal1_dcb_sl2'}{'ns_fiid'}                 = '00519';
$vars{'qal1_dcb_sl2'}{'bps_fiid'}                = 'DI0516';
$vars{'qal1_dcb_sl2'}{'url'}                     = 'http://fsg-sl2.qal1.dcb.diginsite.net';
$vars{'qal1_dcb_sl2'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal1_dcb_sl2'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal1_dcb_sl2'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal2_dca_sl1 Variables below
#################################################################
$vars{'qal2_dca_sl1'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal2_dca_sl1'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal2_dca_sl1'}{'ns_authid'}               = '266380973';
$vars{'qal2_dca_sl1'}{'fiid'}                    = '00508';
$vars{'qal2_dca_sl1'}{'ns_fiid'}                 = '00519';
$vars{'qal2_dca_sl1'}{'bps_fiid'}                = 'DI0516';
$vars{'qal2_dca_sl1'}{'url'}                     = 'http://fsg-sl1.qal2.dca.diginsite.net';
$vars{'qal2_dca_sl1'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal2_dca_sl1'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal2_dca_sl1'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal2_dca_sl2 Variables below
#################################################################
$vars{'qal2_dca_sl2'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal2_dca_sl2'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal2_dca_sl2'}{'ns_authid'}               = '266380973';
$vars{'qal2_dca_sl2'}{'fiid'}                    = '00508';
$vars{'qal2_dca_sl2'}{'ns_fiid'}                 = '00519';
$vars{'qal2_dca_sl2'}{'bps_fiid'}                = 'DI0516';
$vars{'qal2_dca_sl2'}{'url'}                     = 'http://fsg-sl2.qal2.dca.diginsite.net';
$vars{'qal2_dca_sl2'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal2_dca_sl2'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal2_dca_sl2'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal2_dcb_sl1 Variables below
#################################################################
$vars{'qal2_dcb_sl1'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal2_dcb_sl1'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal2_dcb_sl1'}{'ns_authid'}               = '266380973';
$vars{'qal2_dcb_sl1'}{'fiid'}                    = '00508';
$vars{'qal2_dcb_sl1'}{'ns_fiid'}                 = '00519';
$vars{'qal2_dcb_sl1'}{'bps_fiid'}                = 'DI0516';
$vars{'qal2_dcb_sl1'}{'url'}                     = 'http://fsg-sl1.qal2.dcb.diginsite.net';
$vars{'qal2_dcb_sl1'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal2_dcb_sl1'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal2_dcb_sl1'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define qal2_dcb_sl2 Variables below
#################################################################
$vars{'qal2_dcb_sl2'}{'guid'}                    = 'c0a82a26000cc08c4bbe76f80146c500';
$vars{'qal2_dcb_sl2'}{'bps_guid'}                = 'c0a82a26019f002a4e8cea0b34f11a00';
$vars{'qal2_dcb_sl2'}{'ns_authid'}               = '266380973';
$vars{'qal2_dcb_sl2'}{'fiid'}                    = '00508';
$vars{'qal2_dcb_sl2'}{'ns_fiid'}                 = '00519';
$vars{'qal2_dcb_sl2'}{'bps_fiid'}                = 'DI0516';
$vars{'qal2_dcb_sl2'}{'url'}                     = 'http://fsg-sl2.qal2.dcb.diginsite.net';
$vars{'qal2_dcb_sl2'}{'ap_auth'}                 = 'c1ae7aed44054565800fb9356040867f';
$vars{'qal2_dcb_sl2'}{'ns_auth'}                 = 'f97c28bad90b48f28f378fa1e65ed828';
$vars{'qal2_dcb_sl2'}{'sdp_auth'}                = '33737ecd8d64d24b226cc09a9ccfd33';

#################################################################
#Define beta_qdc Variables below
#################################################################
$vars{'beta_qdc'}{'guid'}                        = 'c0a8f2bc0003f01e466f385a1ed1e100';
$vars{'beta_qdc'}{'bps_guid'}                    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'beta_qdc'}{'ns_authid'}                   = '820597795';
$vars{'beta_qdc'}{'fiid'}                        = '05150';
$vars{'beta_qdc'}{'ns_fiid'}                     = '04165';
$vars{'beta_qdc'}{'bps_fiid'}                    = 'DI3355';
$vars{'beta_qdc'}{'url'}                         = 'http://services-bta-qydc.banking.intuit.net';
$vars{'beta_qdc'}{'ap_auth'}                     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'beta_qdc'}{'ns_auth'}                     = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'beta_qdc'}{'sdp_auth'}                    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define stg1_dca Variables below
#################################################################
$vars{'stg1_dca'}{'guid'}                        = 'c0a8f2bc0003f01e466f385a1ed1e100';
$vars{'stg1_dca'}{'bps_guid'}                    = 'c0a82a2600d0000c4fc566c4215855';
$vars{'stg1_dca'}{'ns_authid'}                   = '820597795';
$vars{'stg1_dca'}{'fiid'}                        = '05150';
$vars{'stg1_dca'}{'ns_fiid'}                     = '04165';
$vars{'stg1_dca'}{'bps_fiid'}                    = 'DI3355';
$vars{'stg1_dca'}{'url'}                         = 'http://fsg-sl1.stg1.dca.diginsite.net';
$vars{'stg1_dca'}{'ap_auth'}                     = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'stg1_dca'}{'ns_auth'}                     = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'stg1_dca'}{'sdp_auth'}                    = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_wlv_web Variables below
#################################################################
$vars{'prod_wlv_web'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_wlv_web'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_wlv_web'}{'ns_authid'}               = '787121750';
$vars{'prod_wlv_web'}{'fiid'}                    = '03645';
$vars{'prod_wlv_web'}{'ns_fiid'}                 = '03402';
$vars{'prod_wlv_web'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_wlv_web'}{'url'}                     = 'http://fsgateway-vip.web.prod.diginsite.com:8681';
$vars{'prod_wlv_web'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_wlv_web'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_wlv_web'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_wlv_app Variables below
#################################################################
$vars{'prod_wlv_app'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_wlv_app'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_wlv_app'}{'ns_authid'}               = '787121750';
$vars{'prod_wlv_app'}{'fiid'}                    = '03645';
$vars{'prod_wlv_app'}{'ns_fiid'}                 = '03402';
$vars{'prod_wlv_app'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_wlv_app'}{'url'}                     = 'http://fsgateway-vip.app.prod.diginsite.com:8681';
$vars{'prod_wlv_app'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_wlv_app'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_wlv_app'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_qdc_sl1 Variables below
#################################################################
$vars{'prod_qdc_sl1'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl1'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl1'}{'ns_authid'}               = '787121750';
$vars{'prod_qdc_sl1'}{'fiid'}                    = '03645';
$vars{'prod_qdc_sl1'}{'ns_fiid'}                 = '03402';
$vars{'prod_qdc_sl1'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_qdc_sl1'}{'url'}                     = 'http://services-int-sl1-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl1'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl1'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_qdc_sl1'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_qdc_sl2 Variables below
#################################################################
$vars{'prod_qdc_sl2'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl2'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl2'}{'ns_authid'}               = '787121750';
$vars{'prod_qdc_sl2'}{'fiid'}                    = '03645';
$vars{'prod_qdc_sl2'}{'ns_fiid'}                 = '03402';
$vars{'prod_qdc_sl2'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_qdc_sl2'}{'url'}                     = 'http://services-int-sl2-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl2'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl2'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_qdc_sl2'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_qdc_sl3 Variables below
#################################################################
$vars{'prod_qdc_sl3'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl3'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl3'}{'ns_authid'}               = '787121750';
$vars{'prod_qdc_sl3'}{'fiid'}                    = '03645';
$vars{'prod_qdc_sl3'}{'ns_fiid'}                 = '03402';
$vars{'prod_qdc_sl3'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_qdc_sl3'}{'url'}                     = 'http://services-int-sl3-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl3'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl3'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_qdc_sl3'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_qdc_sl4 Variables below
#################################################################
$vars{'prod_qdc_sl4'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl4'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl4'}{'ns_authid'}               = '787121750';
$vars{'prod_qdc_sl4'}{'fiid'}                    = '03645';
$vars{'prod_qdc_sl4'}{'ns_fiid'}                 = '03402';
$vars{'prod_qdc_sl4'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_qdc_sl4'}{'url'}                     = 'http://services-int-sl4-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl4'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl4'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_qdc_sl4'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_qdc_sl5 Variables below
#################################################################
$vars{'prod_qdc_sl5'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl5'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl5'}{'ns_authid'}               = '787121750';
$vars{'prod_qdc_sl5'}{'fiid'}                    = '03645';
$vars{'prod_qdc_sl5'}{'ns_fiid'}                 = '03402';
$vars{'prod_qdc_sl5'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_qdc_sl5'}{'url'}                     = 'http://services-int-sl5-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl5'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl5'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_qdc_sl5'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_qdc_sl6 Variables below
#################################################################
$vars{'prod_qdc_sl6'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_qdc_sl6'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_qdc_sl6'}{'ns_authid'}               = '787121750';
$vars{'prod_qdc_sl6'}{'fiid'}                    = '03645';
$vars{'prod_qdc_sl6'}{'ns_fiid'}                 = '03402';
$vars{'prod_qdc_sl6'}{'bps_fiid'}                = 'DI3355';
$vars{'prod_qdc_sl6'}{'url'}                     = 'http://services-int-sl6-prd-qydc.banking.intuit.net';
$vars{'prod_qdc_sl6'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_qdc_sl6'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_qdc_sl6'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_lvdc_sl1 Variables below
#################################################################
$vars{'prod_lvdc_sl1'}{'guid'}                   = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl1'}{'bps_guid'}               = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl1'}{'ns_authid'}              = '787121750';
$vars{'prod_lvdc_sl1'}{'fiid'}                   = '03645';
$vars{'prod_lvdc_sl1'}{'ns_fiid'}                = '03402';
$vars{'prod_lvdc_sl1'}{'bps_fiid'}               = 'DI3355';
$vars{'prod_lvdc_sl1'}{'url'}                    = 'http://services-int-sl1-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl1'}{'ap_auth'}                = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl1'}{'ns_auth'}                = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_lvdc_sl1'}{'sdp_auth'}               = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_lvdc_sl2 Variables below
#################################################################
$vars{'prod_lvdc_sl2'}{'guid'}                   = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl2'}{'bps_guid'}               = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl2'}{'ns_authid'}              = '787121750';
$vars{'prod_lvdc_sl2'}{'fiid'}                   = '03645';
$vars{'prod_lvdc_sl2'}{'ns_fiid'}                = '03402';
$vars{'prod_lvdc_sl2'}{'bps_fiid'}               = 'DI3355';
$vars{'prod_lvdc_sl2'}{'url'}                    = 'http://services-int-sl2-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl2'}{'ap_auth'}                = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl2'}{'ns_auth'}                = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_lvdc_sl2'}{'sdp_auth'}               = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_lvdc_sl3 Variables below
#################################################################
$vars{'prod_lvdc_sl3'}{'guid'}                   = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl3'}{'bps_guid'}               = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl3'}{'ns_authid'}              = '787121750';
$vars{'prod_lvdc_sl3'}{'fiid'}                   = '03645';
$vars{'prod_lvdc_sl3'}{'ns_fiid'}                = '03402';
$vars{'prod_lvdc_sl3'}{'bps_fiid'}               = 'DI3355';
$vars{'prod_lvdc_sl3'}{'url'}                    = 'http://services-int-sl3-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl3'}{'ap_auth'}                = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl3'}{'ns_auth'}                = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_lvdc_sl3'}{'sdp_auth'}               = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_lvdc_sl4 Variables below
#################################################################
$vars{'prod_lvdc_sl4'}{'guid'}                   = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl4'}{'bps_guid'}               = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl4'}{'ns_authid'}              = '787121750';
$vars{'prod_lvdc_sl4'}{'fiid'}                   = '03645';
$vars{'prod_lvdc_sl4'}{'ns_fiid'}                = '03402';
$vars{'prod_lvdc_sl4'}{'bps_fiid'}               = 'DI3355';
$vars{'prod_lvdc_sl4'}{'url'}                    = 'http://services-int-sl4-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl4'}{'ap_auth'}                = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl4'}{'ns_auth'}                = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_lvdc_sl4'}{'sdp_auth'}               = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_lvdc_sl5 Variables below
#################################################################
$vars{'prod_lvdc_sl5'}{'guid'}                   = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl5'}{'bps_guid'}               = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl5'}{'ns_authid'}              = '787121750';
$vars{'prod_lvdc_sl5'}{'fiid'}                   = '03645';
$vars{'prod_lvdc_sl5'}{'ns_fiid'}                = '03402';
$vars{'prod_lvdc_sl5'}{'bps_fiid'}               = 'DI3355';
$vars{'prod_lvdc_sl5'}{'url'}                    = 'http://services-int-sl5-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl5'}{'ap_auth'}                = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl5'}{'ns_auth'}                = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_lvdc_sl5'}{'sdp_auth'}               = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prod_lvdc_sl6 Variables below
#################################################################
$vars{'prod_lvdc_sl6'}{'guid'}                   = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prod_lvdc_sl6'}{'bps_guid'}               = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prod_lvdc_sl6'}{'ns_authid'}              = '787121750';
$vars{'prod_lvdc_sl6'}{'fiid'}                   = '03645';
$vars{'prod_lvdc_sl6'}{'ns_fiid'}                = '03402';
$vars{'prod_lvdc_sl6'}{'bps_fiid'}               = 'DI3355';
$vars{'prod_lvdc_sl6'}{'url'}                    = 'http://services-int-sl6-prd-lvdc.banking.intuit.net';
$vars{'prod_lvdc_sl6'}{'ap_auth'}                = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prod_lvdc_sl6'}{'ns_auth'}                = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prod_lvdc_sl6'}{'sdp_auth'}               = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dca_sl1 Variables below
#################################################################
$vars{'prd1_dca_sl1'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dca_sl1'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dca_sl1'}{'ns_authid'}               = '787121750';
$vars{'prd1_dca_sl1'}{'fiid'}                    = '03645';
$vars{'prd1_dca_sl1'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dca_sl1'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dca_sl1'}{'url'}                     = 'http://fsg-sl1.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl1'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dca_sl1'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dca_sl1'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dca_sl2 Variables below
#################################################################
$vars{'prd1_dca_sl2'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dca_sl2'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dca_sl2'}{'ns_authid'}               = '787121750';
$vars{'prd1_dca_sl2'}{'fiid'}                    = '03645';
$vars{'prd1_dca_sl2'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dca_sl2'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dca_sl2'}{'url'}                     = 'http://fsg-sl2.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl2'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dca_sl2'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dca_sl2'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dca_sl3 Variables below
#################################################################
$vars{'prd1_dca_sl3'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dca_sl3'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dca_sl3'}{'ns_authid'}               = '787121750';
$vars{'prd1_dca_sl3'}{'fiid'}                    = '03645';
$vars{'prd1_dca_sl3'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dca_sl3'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dca_sl3'}{'url'}                     = 'http://fsg-sl3.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl3'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dca_sl3'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dca_sl3'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dca_sl4 Variables below
#################################################################
$vars{'prd1_dca_sl4'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dca_sl4'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dca_sl4'}{'ns_authid'}               = '787121750';
$vars{'prd1_dca_sl4'}{'fiid'}                    = '03645';
$vars{'prd1_dca_sl4'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dca_sl4'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dca_sl4'}{'url'}                     = 'http://fsg-sl4.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl4'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dca_sl4'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dca_sl4'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dca_sl5 Variables below
#################################################################
$vars{'prd1_dca_sl5'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dca_sl5'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dca_sl5'}{'ns_authid'}               = '787121750';
$vars{'prd1_dca_sl5'}{'fiid'}                    = '03645';
$vars{'prd1_dca_sl5'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dca_sl5'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dca_sl5'}{'url'}                     = 'http://fsg-sl5.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl5'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dca_sl5'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dca_sl5'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dca_sl6 Variables below
#################################################################
$vars{'prd1_dca_sl6'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dca_sl6'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dca_sl6'}{'ns_authid'}               = '787121750';
$vars{'prd1_dca_sl6'}{'fiid'}                    = '03645';
$vars{'prd1_dca_sl6'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dca_sl6'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dca_sl6'}{'url'}                     = 'http://fsg-sl6.prd1.dca.diginsite.net';
$vars{'prd1_dca_sl6'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dca_sl6'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dca_sl6'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dcb_sl1 Variables below
#################################################################
$vars{'prd1_dcb_sl1'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dcb_sl1'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dcb_sl1'}{'ns_authid'}               = '787121750';
$vars{'prd1_dcb_sl1'}{'fiid'}                    = '03645';
$vars{'prd1_dcb_sl1'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dcb_sl1'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dcb_sl1'}{'url'}                     = 'http://fsg-sl1.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl1'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dcb_sl1'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dcb_sl1'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dcb_sl2 Variables below
#################################################################
$vars{'prd1_dcb_sl2'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dcb_sl2'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dcb_sl2'}{'ns_authid'}               = '787121750';
$vars{'prd1_dcb_sl2'}{'fiid'}                    = '03645';
$vars{'prd1_dcb_sl2'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dcb_sl2'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dcb_sl2'}{'url'}                     = 'http://fsg-sl2.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl2'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dcb_sl2'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dcb_sl2'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dcb_sl3 Variables below
#################################################################
$vars{'prd1_dcb_sl3'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dcb_sl3'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dcb_sl3'}{'ns_authid'}               = '787121750';
$vars{'prd1_dcb_sl3'}{'fiid'}                    = '03645';
$vars{'prd1_dcb_sl3'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dcb_sl3'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dcb_sl3'}{'url'}                     = 'http://fsg-sl3.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl3'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dcb_sl3'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dcb_sl3'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dcb_sl4 Variables below
#################################################################
$vars{'prd1_dcb_sl4'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dcb_sl4'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dcb_sl4'}{'ns_authid'}               = '787121750';
$vars{'prd1_dcb_sl4'}{'fiid'}                    = '03645';
$vars{'prd1_dcb_sl4'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dcb_sl4'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dcb_sl4'}{'url'}                     = 'http://fsg-sl4.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl4'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dcb_sl4'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dcb_sl4'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dcb_sl5 Variables below
#################################################################
$vars{'prd1_dcb_sl5'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dcb_sl5'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dcb_sl5'}{'ns_authid'}               = '787121750';
$vars{'prd1_dcb_sl5'}{'fiid'}                    = '03645';
$vars{'prd1_dcb_sl5'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dcb_sl5'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dcb_sl5'}{'url'}                     = 'http://fsg-sl5.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl5'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dcb_sl5'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dcb_sl5'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';

#################################################################
#Define prd1_dcb_sl6 Variables below
#################################################################
$vars{'prd1_dcb_sl6'}{'guid'}                    = 'c0a8f2b7000110bc451339ef086de700';
$vars{'prd1_dcb_sl6'}{'bps_guid'}                = 'c0a82a2600d0000c4fc566c4215855';
$vars{'prd1_dcb_sl6'}{'ns_authid'}               = '787121750';
$vars{'prd1_dcb_sl6'}{'fiid'}                    = '03645';
$vars{'prd1_dcb_sl6'}{'ns_fiid'}                 = '03402';
$vars{'prd1_dcb_sl6'}{'bps_fiid'}                = 'DI3355';
$vars{'prd1_dcb_sl6'}{'url'}                     = 'http://fsg-sl6.prd1.dcb.diginsite.net';
$vars{'prd1_dcb_sl6'}{'ap_auth'}                 = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prd1_dcb_sl6'}{'ns_auth'}                 = '74448fa47c7a4dae94778a4dfe5956f7';
$vars{'prd1_dcb_sl6'}{'sdp_auth'}                = 'bc1f2337a8864b61a6c37f2597c38e1c';




#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
   $msg =  "****************************************************************************************************\n" .
           "                                      FSG Internal Swim Lane Tests Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <env_key>\n\n" .
           "     <env_key>    - Supported values are:\n\n" .
           "                    qa_wlv_web\n" .
           "                    qa_wlv_app\n\n" .
           "                    qa_qdc_sl1\n" .
           "                    qa_qdc_sl2\n\n" .
           "                    qal1_dca_sl1\n" .
           "                    qal1_dca_sl2\n" .
           "                    qal1_dcb_sl1\n" .
           "                    qal1_dcb_sl2\n\n" .
           "                    qal2_dca_sl1\n" .
           "                    qal2_dca_sl2\n" .
           "                    qal2_dcb_sl1\n" .
           "                    qal2_dcb_sl2\n\n" .
           "                    beta_qdc\n" .
           "                    stg1_dca\n\n" .
           "                    prod_wlv_web\n" .
           "                    prod_wlv_app\n\n" .
           "                    prod_qdc_sl1\n" .
           "                    prod_qdc_sl2\n" .
           "                    prod_qdc_sl3\n" .
           "                    prod_qdc_sl4\n" .
           "                    prod_qdc_sl5\n" .
           "                    prod_qdc_sl6\n\n" .
           "                    prod_lvdc_sl1\n" .
           "                    prod_lvdc_sl2\n" .
           "                    prod_lvdc_sl3\n" .
           "                    prod_lvdc_sl4\n" .
           "                    prod_lvdc_sl5\n" .
           "                    prod_lvdc_sl6\n\n" .
           "                    prd1_dca_sl1\n" .
           "                    prd1_dca_sl2\n" .
           "                    prd1_dca_sl3\n" .
           "                    prd1_dca_sl4\n" .
           "                    prd1_dca_sl5\n" .
           "                    prd1_dca_sl6\n\n" .
           "                    prd1_dcb_sl1\n" .
           "                    prd1_dcb_sl2\n" .
           "                    prd1_dcb_sl3\n" .
           "                    prd1_dcb_sl4\n" .
           "                    prd1_dcb_sl5\n" .
           "                    prd1_dcb_sl6\n\n" .
           "****************************************************************************************************\n\n\n";

   print $msg;
   exit 0;
}





################################################################################
#                          START TESTS                                         #
################################################################################

$msg =  "****************************************************************************************************\n" .
        "                               $0 (Ver. $version)\n" .
        "****************************************************************************************************\n";
print $msg;


#Print Which Environment Running Tests Against
print "Running tests for environment: $env\n";


#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'status';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/fsg/v2/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (fsg)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getSchedules-v1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v1/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/schedules", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (abs)", '204', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinancialInstitution-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (cbs)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getNotificationDestinationsForApp-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'ns_fiid'}/products/IB/notificationApps/MFA/fiCustomers/$vars{$env}{'ns_authid'}/destinations", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (nsmfa)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getNotificationAccounts-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/products/IB/notificationApps/MBL/fiCustomers/$vars{$env}{'guid'}/accounts", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (nsmbl)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFICustomer-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (cbs)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinancialInfo-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ns_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "NotificationService";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/financialInfo", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (cbs)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getAccounts-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (cbs)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinanceInstitution-v1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'intuit_payment_urid'}      = "$vars{$env}{'bps_guid'}";
   $httpHeaderHash{'intuit_payment_cid'}       = "1806478352";
   $httpHeaderHash{'intuit_payment_fiid'}      = "$vars{$env}{'bps_fiid'}";
   $httpHeaderHash{'intuit_payment_app_token'} = "$tid";
   $httpHeaderHash{'intuit_locale'}            = "en";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v1/realm/0/financeinstitution", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (bps)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test TODO - this is not needed for now.
#######################################################
if (0)
{
   #Set Test Name
   $testName = 'getFinanceInstitution-v1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'intuit_payment_urid'}      = "$vars{$env}{'bpsalt_guid'}";
   $httpHeaderHash{'intuit_payment_cid'}       = "1802422399";
   $httpHeaderHash{'intuit_payment_fiid'}      = "$vars{$env}{'bpsalt_fiid'}";
   $httpHeaderHash{'intuit_payment_app_token'} = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v1/realm/0/financeinstitution", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (bps-alt)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'payments-getFinancialInstitution-v1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v1/paymentfis/DI9999", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (payments)", '404', '', 'PAYMENTS-ENT009', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getSampleAccountFile-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/sampleAccountFile", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (prs)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test TODO - not live in prod yet
#######################################################
if (0)
{
   #Set Test Name
   $testName = 'getSAMLConfigsForFI-v1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v1/fis/$vars{$env}{'fiid'}/samlconfigs", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (fmis)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getFinancialInstitution-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v3/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (cas)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test TODO - not live in prod yet
#######################################################
if (0)
{
   #Set Test Name
   $testName = 'getCrossSellRules-v2';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v2/fis/$vars{$env}{'fiid'}/crosssellrules", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (fw)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test
#######################################################
if (1)
{
   #Set Test Name
   $testName = 'getMessages-v3';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v3/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/messages?location=LOGOUT_PROMPT", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (mais)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

#######################################################
#Execute test TODO - not live in prod yet
#######################################################
if (0)
{
   #Set Test Name
   $testName = 'getPfmUser-v1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "AdminPlatform";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";


   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$vars{$env}{'url'}/v1/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/pfmUser", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse("$testName (ofx)", '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

################################################################################
#                           END TESTS                                          #
################################################################################


################################################################################
#FINAL TEST RESULT
################################################################################
print "****************************************************************************************************\n";
print "FINAL TEST RESULT:   $finalTestResult\n";
print "****************************************************************************************************\n";












################################################################################
#                     ALL SUBROUTINES BELOW                                    #
################################################################################


################################################################################
# httpRequest
################################################################################
sub httpRequest($$$$$$$$)
{
   my $url           = $_[0];
   my $headerData    = $_[1];
   my $agent         = $_[2];
   my $timeoutVal    = $_[3];
   my $contentType   = $_[4];
   my $requestType   = $_[5];
   my $requestData   = $_[6];
   my $proxy         = $_[7];

   my $userAgent;
   my $uaRequestAsString;
   my $uaRequest;
   my $uaResponse;
   my $uaResponseAsString;
   my $httpResCode;
   my $httpResponseHeader;
   my $httpResponseBody;
   my $rawRequestResponse;

   #Below is needed to prevent _ values from changing to - values in HTTP Header names
   $HTTP::Headers::TRANSLATE_UNDERSCORE = 0;


   if ( ($proxy ne '') && (lc($proxy) ne 'false') )
   {
      $ENV{HTTPS_PROXY} = "$proxy";
      $ENV{HTTP_PROXY}  = "$proxy";
   }
   else
   {
      $ENV{HTTPS_PROXY} = "";
      $ENV{HTTP_PROXY}  = "";
   }

   $userAgent = LWP::UserAgent->new;
   $userAgent->timeout($timeoutVal);
   $userAgent->agent($agent);

   $uaRequest = new HTTP::Request($requestType => $url);
   #Send Custom HTTP Headers
   if ( keys(%{$headerData}) > 0 )
   {
      $uaRequest->header(%{$headerData});
   }
   $uaRequest->content($requestData);
   $uaRequest->content_type($contentType);
   $uaRequest->content_length(length($requestData));
   $uaRequestAsString = $uaRequest->as_string();

   $uaResponse = $userAgent->request($uaRequest);
   $httpResCode = $uaResponse->{'_rc'};
   $httpResponseBody = $uaResponse->{'_content'};
   $httpResponseHeader = $uaResponse->headers_as_string;
   $uaResponseAsString = $uaResponse->as_string();

   if ( $httpResponseHeader =~ m/Content-Encoding: gzip/i )
   {
      $httpResponseBody = Compress::Zlib::memGunzip(my $buf = $httpResponseBody);
   }

   $rawRequestResponse = "HTTP REQUEST:\n$uaRequestAsString\nHTTP RESPONSE:\n$uaResponseAsString\n";


   return ($httpResCode, $httpResponseHeader, $httpResponseBody, $rawRequestResponse);
}



################################################################################
# validateResponse -
################################################################################
sub validateResponse($$$$$$$$)
{
   my $testName           = $_[0];
   my $expectedResCode    = $_[1];
   my $expectedResHeader  = $_[2];
   my $expectedResBody    = $_[3];
   my $actualResCode      = $_[4];
   my $actualResHeader    = $_[5];
   my $actualResBody      = $_[6];
   my $httpResponse       = $_[7];

   my $testResult         = '';
   my $printLength        = 60;


   #Validate HTTP Response Code
   if ($expectedResCode ne '')
   {
      if ($actualResCode !~ $expectedResCode)
      {
         $testResult      = 'FAILED';
         $finalTestResult = 'FAILED';

         print "$testName:" . ' ' x ($printLength - length($testName)) . "FAILED\n";
         print "     EXPECTED RESPONSE CODE: $expectedResCode\n";
         print "     ACTUAL RESPONSE CODE: $actualResCode\n";
         print "     FULL RESPONSE:\n";
         print "$httpResponse\n";
         return ($testResult);
      }
   }


   #Validate HTTP Response Header
   if ($expectedResHeader ne '')
   {
      if ($actualResHeader !~ $expectedResHeader)
      {
         $testResult      = 'FAILED';
         $finalTestResult = 'FAILED';

         print "$testName:" . ' ' x ($printLength - length($testName)) . "FAILED\n";
         print "     EXPECTED RESPONSE HEADER: $expectedResHeader\n";
         print "     ACTUAL RESPONSE HEADER: $actualResHeader\n";
         print "     FULL RESPONSE:\n";
         print "$httpResponse\n";
         return ($testResult);
      }
   }


   #Validate HTTP Response Body
   if ($expectedResBody ne '')
   {
      if ($actualResBody !~ $expectedResBody)
      {
         $testResult      = 'FAILED';
         $finalTestResult = 'FAILED';

         print "$testName:" . ' ' x ($printLength - length($testName)) . "FAILED\n";
         print "     EXPECTED RESPONSE BODY: $expectedResBody\n";
         print "     ACTUAL RESPONSE BODY: $actualResBody\n";
         print "     FULL RESPONSE:\n";
         print "$httpResponse\n";
         return ($testResult);
      }
   }


   #Test Passed
   if ($testResult ne 'FAILED')
   {
      $testResult = 'PASSED';

      print "$testName:" . ' ' x ($printLength - length($testName)) . "PASSED\n";
   }

   return ($testResult);
}
