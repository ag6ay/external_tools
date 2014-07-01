#!/usr/bin/perl
################################################################################
################################################################################
##                                                                            ##
##   testFSG.pl -   Basic set of FSG INTERNAL and EXTERNAL smoke tests used   ##
##                  for deployment verification as well as priming FSG.       ##
##                                                                            ##
##                  Created by: David Schwab                                  ##
##                  Last updated: DS - 12/24/2013 Ver. 1.2                    ##
##                                                                            ##
##                  FSG Version: 3.11                                         ##
##                                                                            ##
################################################################################
################################################################################
use strict;
use lib './tpm/linux/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi/';
use HTTP::Request;
use LWP::UserAgent;
use Sys::Hostname;
use Compress::Zlib;
use Time::HiRes;
use Crypt::OpenSSL::RSA;
use MIME::Base64;
use Digest::SHA;



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
my %tests              = ();
my $env                = ($ARGV[0] || '');
my $msg                = '';
my $response           = '';
my $version            = '1.2';
my $localHostName      = hostname;
my $fsgInternalUrl     = '';
my $fsgExternalUrl     = '';
my $baseUrlForOAuth    = '';
my $httpResCode        = '';
my $httpResponseHeader = '';
my $httpResponseBody   = '';
my $httpResponse       = '';
my %httpHeaderHash     = ();
my $httpContentType    = 'application/xml';
my $httpBody           = '';
my $outboundProxy      = '';
my $testResult         = '';
our $finalTestResult   = 'PASSED';
my $realm              = '';
my %envDef             = ();
my %oAuthBaseUrlDef    = ();
my $oAuthSigMethod     = '';
my $accessToken        = '';
my $accessTokenSecret  = '';
my $ficustomerId       = '';
my $accountId          = '';


#################################################################
#Configure Which Tests To Execute (true/false)
#################################################################
#Internal Tests
$tests{'int_fsg-status'}                         = 'true';
$tests{'int_cbs-getFICustomerV2'}                = 'true';
$tests{'int_cbs-getFinancialInfoV2'}             = 'true';
$tests{'int_cbs-getAccountsV2'}                  = 'true';
$tests{'int_cbs-getFinancialInstitutionV2'}      = 'true';
$tests{'int_spi-getFinanceInstitutionV1'}        = 'true';
$tests{'int_cas-getFinancialInstitutionV3'}      = 'false';
#External Tests
$tests{'ext_fsg-status'}                         = 'true';
$tests{'ext_cbs-unsecuredgetFIConfigurationV2'}  = 'true';
$tests{'ext_cas-createAuthTokenV4'}              = 'true';
$tests{'ext_fsg-createAccessTokenV2'}            = 'true';
$tests{'ext_cbs-getFinancialInstitutionV2'}      = 'true';
$tests{'ext_cbs-getFICustomerV2'}                = 'true';
$tests{'ext_cbs-getAccountsV2'}                  = 'true';
$tests{'ext_cbs-getTransactionsV2'}              = 'true';



#################################################################
#Test Definitions Set Below
#################################################################

#################################################################
#Define dev Variables Below
#################################################################
$vars{'dev'}{'guid'}           = 'c0a8e32600aba0664d409dc33b379600';
$vars{'dev'}{'loginid'}        = 'FSGCCBPFIS001';
$vars{'dev'}{'pass'}           = '11111';
$vars{'dev'}{'fiid'}           = 'DI0508';
$vars{'dev'}{'cons_key'}       = 'IFIDIFSFSGTEST1';
$vars{'dev'}{'app_token'}      = 'IFIDIFSFSGTEST1';
$vars{'dev'}{'ap_auth'}        = 'gateway2testclient';
$vars{'dev'}{'cc_auth'}        = 'gateway2testclient';
$vars{'dev'}{'pr_auth'}        = 'gateway2testclient';
$vars{'dev'}{'cas_auth'}       = 'gateway2testclient';
$vars{'dev'}{'usp_auth'}       = 'gateway2testclient';
$vars{'dev'}{'sdp_auth'}       = 'gateway2testclient';
$vars{'dev'}{'cas-catv4'}      = '501';

#################################################################
#Define qa Variables Below
#################################################################
$vars{'qa'}{'guid'}            = 'c0a8e32600aba0664d409dc33b379600';
$vars{'qa'}{'loginid'}         = 'FSGCCBPFIS001';
$vars{'qa'}{'pass'}            = '11111';
$vars{'qa'}{'fiid'}            = 'DI0508';
$vars{'qa'}{'cons_key'}        = 'IFIDIFSFSGTEST1';
$vars{'qa'}{'app_token'}       = 'IFIDIFSFSGTEST1';
$vars{'qa'}{'ap_auth'}         = 'c1ae7aed44054565800fb9356040867f';
$vars{'qa'}{'cc_auth'}         = 'a296817245ca4bb092ef90599bef7607';
$vars{'qa'}{'pr_auth'}         = '34d9ef105f5949938727628e2b999677';
$vars{'qa'}{'cas_auth'}        = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'qa'}{'usp_auth'}        = '5f6fab55077f4de1bec2670836667cec';
$vars{'qa'}{'sdp_auth'}        = '33737ecd8d64d24b226cc09a9ccfd33';
$vars{'qa'}{'cas-catv4'}       = '501';

#################################################################
#Define pte Variables Below
#################################################################
$vars{'pte'}{'guid'}          = 'c0a8f2b30004401a471b8a1e02b82a00';
$vars{'pte'}{'loginid'}       = 'PRTEST1000';
$vars{'pte'}{'pass'}          = '11111';
$vars{'pte'}{'fiid'}          = 'DI0508';
$vars{'pte'}{'cons_key'}      = 'IFIDIFSFSGTEST1';
$vars{'pte'}{'app_token'}     = 'IFIDIFSFSGTEST1';
$vars{'pte'}{'ap_auth'}       = 'c1ae7aed44054565800fb9356040867f';
$vars{'pte'}{'cc_auth'}       = 'a296817245ca4bb092ef90599bef7607';
$vars{'pte'}{'pr_auth'}       = '34d9ef105f5949938727628e2b999677';
$vars{'pte'}{'cas_auth'}      = '6d4bcdc15d724bb0a476b12507f8278d';
$vars{'pte'}{'usp_auth'}      = '5f6fab55077f4de1bec2670836667cec';
$vars{'pte'}{'sdp_auth'}      = '33737ecd8d64d24b226cc09a9ccfd33';
$vars{'pte'}{'cas-catv4'}     = '200';

#################################################################
#Prod prodSL1 Variables Below
#################################################################
$vars{'prodSL1'}{'guid'}      = 'c0a8f2b5014f01204fe240110dfb2300';
$vars{'prodSL1'}{'loginid'}   = 'JoRd88';
$vars{'prodSL1'}{'pass'}      = 'kRup10!';
$vars{'prodSL1'}{'fiid'}      = 'DI3402';
$vars{'prodSL1'}{'cons_key'}  = 'IFIDIFSMMVMobileWebPROD';
$vars{'prodSL1'}{'app_token'} = 'IFIDIFSMMVMobileWebPROD';
$vars{'prodSL1'}{'ap_auth'}   = 'edd868fe08b244f4bb4dffd0a00a8fc0';
$vars{'prodSL1'}{'cc_auth'}   = '76a9a43ee40a4fe7a184f7a305ef862d';
$vars{'prodSL1'}{'pr_auth'}   = '48d34a562815445194981f402c62abeb';
$vars{'prodSL1'}{'cas_auth'}  = '8188261f3031465b98d3cae2bf9b57ae';
$vars{'prodSL1'}{'usp_auth'}  = 'ea501fb80f814a2ab516253b85408860';
$vars{'prodSL1'}{'sdp_auth'}  = 'bc1f2337a8864b61a6c37f2597c38e1c';
$vars{'prodSL1'}{'cas-catv4'} = '200';


#################################################################
# Check $env variable, print usage
#################################################################
if ( ($env eq '') || (! defined($vars{$env})) )
{
  $msg =  "****************************************************************************************************\n" .
           "                                testFSG Ver. $version\n" .
           "****************************************************************************************************\n\n\n" .
           "   USAGE:  \$ $0 <env_key>\n\n" .
           "     <env_key>    - Supported values are:\n\n" .
           "                    dev\n" .
           "                    qa\n" .
           "                    pte\n" .
           "                    prodSL1\n\n" .
           "****************************************************************************************************\n\n\n";

   print $msg;
   exit 0;
}




#################################################################
#Environment Definition
#################################################################
$envDef{'dev'}     = 1;
$envDef{'qa'}      = 3;
$envDef{'pte'}     = 4;
$envDef{'prodSL1'} = 7;
$envDef{'prodSL2'} = 7;
$envDef{'prodSL3'} = 7;
$envDef{'prodSL4'} = 7;
$envDef{'prodSL5'} = 7;
$envDef{'prodSL6'} = 7;




##################################################
# SET OAUTH PRIVATE KEY INFO FOR EACH ENVIRONMENT
#
# Instructions for converting jks to RSA private key:
#
#   keytool -importkeystore -srckeystore intuitKeyStore.jks -destkeystore mystore.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass fsgateway -deststorepass fsgateway -srcalias "intuit.ifs.mmvmobileweb.preprod" -destalias "intuit.ifs.mmvmobileweb.preprod" -srckeypass fsgateway -destkeypass fsgateway -noprompt
#   openssl pkcs12 -nodes -in mystore.p12 -out mystore.pem -passin pass:fsgateway -passout pass:fsgateway
#
#
##################################################
our %oAuthPrivateKey = ();
#Null Environment
$oAuthPrivateKey{0} = '';
#Dev Environment
$oAuthPrivateKey{1} = '-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQC/49tn/h2VrSs1CTbm7U5Rd9zViDZ9i8dsSlSyNDWFaH/TbcYa
+XdBBUkWmxbkVJgh93TC40z3mphHUv0h8qX7KKefjxAy2LO9sPPwHs5Rf7eV6nR5
CtEevdThq3mBMa4IuG2LcB0uX5DyuAYlHVd0CBK+fzVacH+BXz+1cnbpIQIDAQAB
AoGARwYOUopi5uCGioXTlVumTk8gJMTa7lMLSBCnEqJyYOOR1G7gEWHeeul66OwU
aATLnl7aD7xT452L2XJlEOif+BcCtXmBhpaKrhwtoZFeDHqatKrakfz+3ZBQUHMu
F5LoxAi/X0K+5DP3MJc/Y/e851BD/BrMnkRzyvqD89g2RbECQQDpmsOG/YqvkFsX
zpD80TiQ+Eo5ziJktmwUhp6BEqVc0Cq9i9eCDaFISi6ytoN63wEU7f+g0JRztZtC
kCZMdSKFAkEA0klQ9rkAqbXnu+xKIYn1aaSB83ZiY5t1Bq+MZxx6qfvMQUfiHImV
Ze29YLzRNYwvDmvtEyzm0bKMtXNeLYJk7QJAF+y5ycF9yq1GJxII11u2J2LGd1Ud
QKNOPmvrH90BAphvSCpiT/eFZRnz3mnC3XqpabNWUuoJyi/3TsHkqj/04QJACIqd
1UeydTJEVWfFoxMdessJ1D/Mw0r/N+RNiaqoeNsXctdeodYc0WUUuicxQEGPb8CG
gq7iOUZNXNlwy9xuCQJBANz5/7ck8OFly6OA1NqH30Yq1cs7NfXCSFV4hEBr5Koz
Rzyi0EDNboo7FaGkhCxe3xch8XWUDOl+C8e+sIJznHU=
-----END RSA PRIVATE KEY-----';
#ITE Environment
$oAuthPrivateKey{2} = '';
#QA Environment
$oAuthPrivateKey{3} = '-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQC/49tn/h2VrSs1CTbm7U5Rd9zViDZ9i8dsSlSyNDWFaH/TbcYa
+XdBBUkWmxbkVJgh93TC40z3mphHUv0h8qX7KKefjxAy2LO9sPPwHs5Rf7eV6nR5
CtEevdThq3mBMa4IuG2LcB0uX5DyuAYlHVd0CBK+fzVacH+BXz+1cnbpIQIDAQAB
AoGARwYOUopi5uCGioXTlVumTk8gJMTa7lMLSBCnEqJyYOOR1G7gEWHeeul66OwU
aATLnl7aD7xT452L2XJlEOif+BcCtXmBhpaKrhwtoZFeDHqatKrakfz+3ZBQUHMu
F5LoxAi/X0K+5DP3MJc/Y/e851BD/BrMnkRzyvqD89g2RbECQQDpmsOG/YqvkFsX
zpD80TiQ+Eo5ziJktmwUhp6BEqVc0Cq9i9eCDaFISi6ytoN63wEU7f+g0JRztZtC
kCZMdSKFAkEA0klQ9rkAqbXnu+xKIYn1aaSB83ZiY5t1Bq+MZxx6qfvMQUfiHImV
Ze29YLzRNYwvDmvtEyzm0bKMtXNeLYJk7QJAF+y5ycF9yq1GJxII11u2J2LGd1Ud
QKNOPmvrH90BAphvSCpiT/eFZRnz3mnC3XqpabNWUuoJyi/3TsHkqj/04QJACIqd
1UeydTJEVWfFoxMdessJ1D/Mw0r/N+RNiaqoeNsXctdeodYc0WUUuicxQEGPb8CG
gq7iOUZNXNlwy9xuCQJBANz5/7ck8OFly6OA1NqH30Yq1cs7NfXCSFV4hEBr5Koz
Rzyi0EDNboo7FaGkhCxe3xch8XWUDOl+C8e+sIJznHU=
-----END RSA PRIVATE KEY-----';
#PTE Environment
$oAuthPrivateKey{4} = '-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQC/49tn/h2VrSs1CTbm7U5Rd9zViDZ9i8dsSlSyNDWFaH/TbcYa
+XdBBUkWmxbkVJgh93TC40z3mphHUv0h8qX7KKefjxAy2LO9sPPwHs5Rf7eV6nR5
CtEevdThq3mBMa4IuG2LcB0uX5DyuAYlHVd0CBK+fzVacH+BXz+1cnbpIQIDAQAB
AoGARwYOUopi5uCGioXTlVumTk8gJMTa7lMLSBCnEqJyYOOR1G7gEWHeeul66OwU
aATLnl7aD7xT452L2XJlEOif+BcCtXmBhpaKrhwtoZFeDHqatKrakfz+3ZBQUHMu
F5LoxAi/X0K+5DP3MJc/Y/e851BD/BrMnkRzyvqD89g2RbECQQDpmsOG/YqvkFsX
zpD80TiQ+Eo5ziJktmwUhp6BEqVc0Cq9i9eCDaFISi6ytoN63wEU7f+g0JRztZtC
kCZMdSKFAkEA0klQ9rkAqbXnu+xKIYn1aaSB83ZiY5t1Bq+MZxx6qfvMQUfiHImV
Ze29YLzRNYwvDmvtEyzm0bKMtXNeLYJk7QJAF+y5ycF9yq1GJxII11u2J2LGd1Ud
QKNOPmvrH90BAphvSCpiT/eFZRnz3mnC3XqpabNWUuoJyi/3TsHkqj/04QJACIqd
1UeydTJEVWfFoxMdessJ1D/Mw0r/N+RNiaqoeNsXctdeodYc0WUUuicxQEGPb8CG
gq7iOUZNXNlwy9xuCQJBANz5/7ck8OFly6OA1NqH30Yq1cs7NfXCSFV4hEBr5Koz
Rzyi0EDNboo7FaGkhCxe3xch8XWUDOl+C8e+sIJznHU=
-----END RSA PRIVATE KEY-----';
#Beta Environment
$oAuthPrivateKey{5} = '-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0WkNhIysP20FmsHq2Aqwzuaa0CmT/Pahc6s4MdtNbFL9aFLn
1dUtPoWBOFIOCd4HzzZ9TcgyAy6Vs+7FevYO0KKnm1BJA+dOOstGTooJ6fxgdZ0z
uMbkNY3NISwOx/rqAwYzpErYfhFxQG0fJvQrBRQuCY/LBNbnSjlURLr12YQ22RVA
aaYWfJKv/2ccGbruHNqbRdlp+N368v5er4JMNto6/j3A99URWa/NpBufFyOW7B9G
FAFCxrxYcjpgc2ekMOd6C0UP+/My/U7zLoto9kwkQQ5HSHkkCMg15orygMOatDxA
7q0WzNPfCnsM66uCevfYs5dAbWyDvAe6HDa/1QIDAQABAoIBAQDKLEpItid19KN8
jctVWLzqg+jjH8EocFPfgGZ4e+l7s4PDvIbnAzDzM6FV5qJ3FE0l2M2Q0r62I7uU
Q+mUlQook2CNqi1T/3SffrEaElsP9ACMjIDq29pneceZRxfeKnjTAqHI9BmfXOeh
87gnu4PtG1Z3FMREn9Yc6sxYrse8fxGMD4b78qglXN+pvWvrYuehgm00FSUxfJq5
Eh+7U0WzBNzl5kvV7IO8f02ZuDU3kcaN9YNaTeplCvF8aDs2DikZw7H/qQofXX7V
yTTL3KlWsJWlVtgArMq+aKZtXMs55ZMldVC4nNr0bZNN2/BzjT7Sn0f9yr5t/ZrV
XIBRWQHhAoGBAPJGAdl8AIC4V8CmmOi27aJeXdTCFAlOFdfO9bpFnGp6hOlAbWFq
KMQFXy3YbSZN0JTOeGnUAgGK0ebf46IiwZoVbgcpSPsKPzuIHpNc/zTHz1+6kxjg
ekiHdA20DDVSbVFpkaCatPzVN7cauaSL5ES5U9V5vDKZ27ydO0HeJVfDAoGBAN1G
ZCX70UP41zAvnND7vxLz0mT+00pvim0tHA9WC0uWKStfvTRK3RtItv8NEvq2lk8v
gKkb5sP1CkzFidJsMDkCVliu7YJIQc+yRH8x93NypaGTeZsiB0qtTanv3kmZePbv
SgwGfVCAn1REXncJ+sMES2C/4ZuQUguAlfBOBSiHAoGAXGwafoYQhwpL56FmSbin
FL7dGrHjBN219XrtQN8XWYNdusGqOHRQEt9dvNaIZQlgXbQaOXz4OvBjPKkCZLLP
mmE8dRzpy2LQVnyJ9XuPm+nxkTpSrTXNUGfj/OpHkfvc2ibkuBjsnFsWgxJ96Wi4
bwMoGRL0mXUaX2y301vUcRMCgYEAwIB3qg/ca6z10KbrX2hUP7G9DT4gJXbKT9bZ
vYHWy8h0QpbE7NRgbVciVNtT8qecNoGWBgkPBtWMQ2PrVhPnFAGziu2MFTa1gnKN
YrbelyJbdCjvt4WwIEiK81eJ5C/Pa8ybd8DBjqKHenEMWbVl4fk/dokYRhUVO4p/
ZxMJK8sCgYBBDCt5GLYt5F1bSUNzyeqPqCHK9tTFowQUM17tvAhdk2KauAjblyNd
mtbzlyq418pqjtOUx33J1OvcAFt8KyHKi6NepNndYU4hD3JACOfiXc+r7mIGVcGo
CehhoZJ2uSxBjSL/fHlZ6Wth2/MqCGNZWlrDUxBpHZeXimEhOyqhBQ==
-----END RSA PRIVATE KEY-----';
#PreProd Environment
$oAuthPrivateKey{6} = '';
#Production Environment
$oAuthPrivateKey{7} = '-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA1qKCoJlazjUHUN8uvZvR8XWhH369dk1puO6cTt19+R8rT4Dm
vyXX+/R3KCijkRAguNmTnu2qkn6LDZN+YnkgtfOraAv7AqXYx3T52bU+sLwV35jv
afAmNHq9zxiv5EY4Qt2mdys36Wsr+0SVg7miXtw6CD1AWBsG2HR3xBcBVmKDConr
Wuv60VddhoT4lgMLXllGios39xYcOSKiibzCWvnWhnD788uAkZIJK2dkNAiGk6Wc
G8YgMwi6FqA3zlO4OA6dE2Nl7zu2LD36RXhSeCJ5meo/JCgNBCWo5z/ERwOr516L
LOI0jl5NflVNLfN1KAmEz+t/5Otq1isOT1bShwIDAQABAoIBAQCp3zLdoqIQxD2H
DyyyGoodvciI4clXwUskd400ie6y5a1knhOCQ5ResAxCt29FV2tega1pQpcWnJq3
Yv3LOCzgdPs7PQgr/1DEA9vfJ6h3PlVdg3Aw+0VxkZd6OgKz+7N5kG24sXbuAcls
c8qV160fwNMZREkRskpHtF45zy9ayueovvZiNb1NS9rrPMr8d5SV0ORrpEZskgTo
/yo+AGyw2vLKF1cqim4HmRRMNi1RtR9A8M8N0/7ifgToqUJGaE3KncGzVzaYZFZt
7bo+Z0zWC9axBWNwIR6CqECcg8I9LL9l60MgnutRtWy5oRxeOysahZKMr9y3pQ01
zflZjGeZAoGBAPRNM2D0UcvHC8fRqPfYc3NPdRJ5Tspx6QB0EcKo++vH38iWwKop
vtOpF+JfAbBgTI2gTXCe6uO6GfgQvS4kQmT2sR4kUgIFwZMpUSZCcr44gdEonCyY
rYwowlWQj5/lutbFTx3NDkCbHIxvmsPpq/elob4vrl/tRNWGpjr22bQdAoGBAODp
otkRKb2MR/D6eedQ/d9tutZz7tYZeereYTk0dg/Qtqo1i5pbTbe7RvdEnTWi8xKc
J0OQn3QsEonS7AVMTMwRMSJHbwl3PrqZcU5pbQ+OPfL1qkP4rw72GF+hEwGsgHKv
odL6MhfZGFA9yiCjG4XpQhF3e/Y4Z9+UtXgdd1fzAoGAJKSnvjUnR691XuVduL8o
ofUbFEhJvyfS0RSXzWDXWIhEUqv5/gwA6XKFeJjTggcPtHaE5w2PIdU6K/EmzxL1
OnueGW1NN6xxWodp+pkg6NNE9YBn3HCSJ2G9tGPYhx1IJwq1UTz+lEYvxAjBZ/1W
o/CeEA7K0uyd1IE70cBQ6ykCgYEAoBMpKD0i7BlPip9667ulNMQwWjmhHxh6wUMN
B13jOVZe6724Yl/hbIcJ9ysKiQY04mXpPBlOo6xKdXV9Ljgj4InL4o3c5WvNZZmY
HyrByHSAes+GI2J3lbpploZZtLNFqFqAXlxcEsUcnN+dYKU2DZT6xNu5ioCSzXpV
veua6SkCgYEAhyBFeuYUMbhHlyHmDbEvRN2hw7zNyjCGUjS8Mavv4IxKLj8c6H3o
u6us4eWONcuuiZrZJborwbmPkyBI6tWd9AsTkhkMlUbkO+wInQylB4H0o9vsxzPX
p82LaZ5zdDoPdITG+zFdH9gaLgSfFz9l26co/iDPHKTjrjPmTxbKAQ4=
-----END RSA PRIVATE KEY-----';




#################################################################
#FSG WLV and QDC/LVDC URLs and realm values are different
#################################################################
if ( (lc($localHostName) =~ 'mariner') || (lc($localHostName) =~ 'outback') )
{
   #FSG WLV URLs
   $fsgInternalUrl = "http://$localHostName:8681";
   $fsgExternalUrl = "http://$localHostName:8680";

   #WLV URL FOR OAUTH
   $oAuthBaseUrlDef{1} = "http://$localHostName:8680";
   $oAuthBaseUrlDef{3} = "https://services.qal.banking.intuit.com:443";
   $oAuthBaseUrlDef{4} = "https://services.prf.banking.intuit.com:443";
   $oAuthBaseUrlDef{7} = "https://services.prd.banking.intuit.com:443";

   #WLV Realm
   $realm = 'http://services.banking.intuit.com/';
}
else
{
   #FSG QDC/LVDC URLs
   $fsgInternalUrl = "http://$localHostName:8889";
   $fsgExternalUrl = "http://$localHostName:8888";

   #E-SGP URL FOR OAUTH
   $oAuthBaseUrlDef{1} = "http://$localHostName:8888";
   $oAuthBaseUrlDef{3} = "https://services-qal.banking.intuit.com:443";
   $oAuthBaseUrlDef{4} = "https://services-prf.banking.intuit.com:443";
   $oAuthBaseUrlDef{7} = "https://services.banking.intuit.com:443";

   #QDC/LVDC Realm
   $realm = 'https://services.banking.intuit.com';
}








################################################################################
#                          START TESTS                                         #
################################################################################

$msg =  "****************************************************************************************************\n" .
        "                                testFSG Ver. $version\n" .
        "****************************************************************************************************\n";
print $msg;


################################################################################
#Internal Tests
################################################################################
if ($tests{'int_fsg-status'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/fsg/v2/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal status (FSG)', '503', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'int_cbs-getFICustomerV2'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}?fiCustomerIdType=GUID", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal getFICustomerV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'int_cbs-getFinancialInfoV2'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'cc_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "CustomerCentral";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/financialInfo?fiCustomerIdType=GUID", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal getFinancialInfoV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'int_cbs-getAccountsV2'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'pr_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "PRService";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$vars{$env}{'guid'}/accounts", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal getAccountsV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'int_cbs-getFinancialInstitutionV2'} eq 'true')
{
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
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/v2/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal getFinancialInstitutionV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'int_spi-getFinanceInstitutionV1'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'sdp_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "SDP";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'intuit_payment_app_token'} = "$tid";
   $httpHeaderHash{'intuit_payment_fiid'}      = "$vars{$env}{'fiid'}";
   $httpHeaderHash{'intuit_payment_cid'}       = "180541645";
   $httpHeaderHash{'intuit_payment_urid'}      = "$vars{$env}{'guid'}";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/v1/realm/0/financeinstitution", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal getFinanceInstitutionV1 (BPS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'int_cas-getFinancialInstitutionV3'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "$vars{$env}{'ap_auth'}";
   $httpHeaderHash{'intuit_appId'}             = "AdminPlatform";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgInternalUrl/v3/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('Internal getFinancialInstitutionV3 (CAS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}


################################################################################
#External Tests
################################################################################
if ($tests{'ext_fsg-status'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/fsg/v2/status", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External status (FSG)', '503', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'ext_cbs-unsecuredgetFIConfigurationV2'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "OAuth";
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/v2/fis/$vars{$env}{'fiid'}/ficonfig?method=unsecuredConfig", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External unsecuredgetFIConfigurationV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'ext_cas-createAuthTokenV4'} eq 'true')
{
   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = "OAuth";
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><tns:AuthToken xmlns:tns=\"http://schema.intuit.com/platform/integration/identity/authToken/v2\" xmlns:cm=\"http://schema.intuit.com/fs/common/v2\" xmlns:tns3=\"http://schema.intuit.com/domain/banking/fiCustomer/v2\"><tns:requestChannel>MOBILE_APP</tns:requestChannel><tns:credential><cm:loginId>$vars{$env}{'loginid'}</cm:loginId><cm:password>$vars{$env}{'pass'}</cm:password></tns:credential></tns:AuthToken>";

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/v4/fis/$vars{$env}{'fiid'}/identity/authToken", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'POST', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External createAuthTokenV4 (CAS)', $vars{$env}{'cas-catv4'}, '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'ext_fsg-createAccessTokenV2'} eq 'true')
{
   #Set OAuth values
   $baseUrlForOAuth = $oAuthBaseUrlDef{$envDef{$env}};
   $oAuthSigMethod = 'RSA-SHA1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = generateOAuth('initial', \%vars, $realm, $env, $envDef{$env}, "$baseUrlForOAuth/platform/integration/identity/oauth/accessToken", 'POST', $oAuthSigMethod, '', '', '');
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/platform/integration/identity/oauth/accessToken", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'POST', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External createAccessTokenV2 (FSG)', '201', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);

   #Parse OAuth Response
   ($accessToken, $accessTokenSecret, $ficustomerId) = parseOAuthResponse($httpResponseBody);
}

if ($tests{'ext_cbs-getFinancialInstitutionV2'} eq 'true')
{
   #Set OAuth values
   $baseUrlForOAuth = $oAuthBaseUrlDef{$envDef{$env}};
   $oAuthSigMethod = 'RSA-SHA1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = generateOAuth('renew', \%vars, $realm, $env, $envDef{$env}, "$baseUrlForOAuth/v2/fis/$vars{$env}{'fiid'}", 'GET', $oAuthSigMethod, $accessToken, '', $accessTokenSecret);
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/v2/fis/$vars{$env}{'fiid'}", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External getFinancialInstitutionV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'ext_cbs-getFICustomerV2'} eq 'true')
{
   #Set OAuth values
   $baseUrlForOAuth = $oAuthBaseUrlDef{$envDef{$env}};
   $oAuthSigMethod = 'RSA-SHA1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = generateOAuth('renew', \%vars, $realm, $env, $envDef{$env}, "$baseUrlForOAuth/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$ficustomerId", 'GET', $oAuthSigMethod, $accessToken, '', $accessTokenSecret);
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$ficustomerId", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External getFICustomerV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
}

if ($tests{'ext_cbs-getAccountsV2'} eq 'true')
{
   #Set OAuth values
   $baseUrlForOAuth = $oAuthBaseUrlDef{$envDef{$env}};
   $oAuthSigMethod = 'RSA-SHA1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = generateOAuth('renew', \%vars, $realm, $env, $envDef{$env}, "$baseUrlForOAuth/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$ficustomerId/accounts", 'GET', $oAuthSigMethod, $accessToken, '', $accessTokenSecret);
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$ficustomerId/accounts", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External getAccountsV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);

   #Parse account id
   ($accountId) = getXmlValue($httpResponseBody, ':id');
}

if ($tests{'ext_cbs-getTransactionsV2'} eq 'true')
{
   #Set OAuth values
   $baseUrlForOAuth = $oAuthBaseUrlDef{$envDef{$env}};
   $oAuthSigMethod = 'RSA-SHA1';

   #Set %httpHeaderHash values
   %httpHeaderHash = ();
   $httpHeaderHash{'Authorization'}            = generateOAuth('renew', \%vars, $realm, $env, $envDef{$env}, "$baseUrlForOAuth/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$ficustomerId/accounts/$accountId/transactions", 'GET', $oAuthSigMethod, $accessToken, '', $accessTokenSecret);
   $httpHeaderHash{'intuit_appId'}             = "iPhoneBankingApp";
   $httpHeaderHash{'intuit_offeringId'}        = "$offeringId";
   $httpHeaderHash{'intuit_originatingIp'}     = "$originatingIp";
   $httpHeaderHash{'intuit_tid'}               = "$tid";
   $httpHeaderHash{'Content-Type'}             = "application/xml";

   #Set $httpBody
   $httpBody = '';

   #Send Request
   ($httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse) = httpRequest("$fsgExternalUrl/v2/fis/$vars{$env}{'fiid'}/fiCustomers/$ficustomerId/accounts/$accountId/transactions", \%httpHeaderHash, $agent, $readTimeOut, $httpContentType, 'GET', $httpBody, $outboundProxy);

   #Validate Response
   $testResult = validateResponse('External getTransactionsV2 (CBS)', '200', '', '', $httpResCode, $httpResponseHeader, $httpResponseBody, $httpResponse);
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
# generateOAuth -
################################################################################
sub generateOAuth($$$$$$$$$$$)
{
   my $authType           = $_[0];
   my $hashRef            = $_[1];
   my $realm              = $_[2];
   my $env                = $_[3];
   my $envDef             = $_[4];
   my $url                = $_[5];
   my $httpMethod         = $_[6];
   my $oAuthSigMethod     = $_[7];
   my $accessToken        = $_[8];
   my $consumerSecret     = $_[9];
   my $accessTokenSecret  = $_[10];

   my $oAuth              = '';
   my %oAuthParamHash     = ();
   my $hashKey            = '';
   my $hashValue          = '';

   my $rsaPrivateKey      = '';
   my $oAuthMessage       = '';
   my $signature          = '';
   my $oAuthSignature     = '';


   #Set %oAuthParamHash
   $oAuthParamHash{'xoauth_username'}        = $hashRef->{$env}->{'loginid'};
   $oAuthParamHash{'xoauth_password'}        = $hashRef->{$env}->{'pass'};
   $oAuthParamHash{'xoauth_fid'}             = $hashRef->{$env}->{'fiid'};
   $oAuthParamHash{'oauth_signature_method'} = $oAuthSigMethod;
   $oAuthParamHash{'oauth_consumer_key'}     = $hashRef->{$env}->{'cons_key'};
   $oAuthParamHash{'xoauth_app_token'}       = $hashRef->{$env}->{'app_token'};
   $oAuthParamHash{'oauth_token'}            = $accessToken;
   $oAuthParamHash{'realm'}                  = $realm;
   $oAuthParamHash{'oauth_nonce'}            = generateNonce();
   $oAuthParamHash{'oauth_timestamp'}        = currentTimeSeconds();
   $oAuthParamHash{'oauth_version'}          = '1.0';


   #Strip port from $url -
   #   The port MUST be included if it is not the default port for the
   #   scheme, and MUST be excluded if it is the default. Specifically,
   #   the port MUST be excluded when making an HTTP request [RFC2616]
   #   to port 80 or when making an HTTPS request [RFC2818] to port 443.
   #   All other non-default port numbers MUST be included.
   if (substr($url, 0, 6) eq 'https:')
   {
      #Strip port ':443' from $url
      $url =~ s/\:443//;
   }
   elsif (substr($url, 0, 5) eq 'http:')
   {
      #Strip port ':80' from $url
      $url =~ s/\:80//;
   }


   #Cleanup based on $authType
   if (lc($authType) eq 'initial')
   {
      delete $oAuthParamHash{'oauth_token'};

      $accessTokenSecret = '';
   }
   elsif (lc($authType) eq 'renew')
   {
      delete $oAuthParamHash{'xoauth_username'};
      delete $oAuthParamHash{'xoauth_password'};
      delete $oAuthParamHash{'xoauth_fid'};
   }


   #URL Encode Values in %oAuthParamHash
   for $hashKey (sort keys %oAuthParamHash)
   {
      $hashValue = $oAuthParamHash{$hashKey};
      $hashValue = urlEncodeString($hashValue);
      $oAuthParamHash{$hashKey} = $hashValue;
   }


   if (uc($oAuthSigMethod) eq 'PLAINTEXT')
   {
      #Simply set $oAuthSignature to &
      $oAuthSignature = '&';

      #Delete unneeded $oAuthParamHash{'oauth_consumer_key'} for this type of request
      delete $oAuthParamHash{'oauth_consumer_key'};
   }
   elsif (uc($oAuthSigMethod) eq 'RSA-SHA1')
   {
      #Get Base OAuth String
      $oAuthMessage = generateBaseOAuthString(\%oAuthParamHash, $url, $httpMethod);

      #Set correct $rsaPrivateKey for signing $oAuthMessage
      $rsaPrivateKey = Crypt::OpenSSL::RSA->new_private_key($oAuthPrivateKey{$envDef});

      #Sign the $oAuthMessage
      $signature = $rsaPrivateKey->sign($oAuthMessage);

      #Base64 Encode $signature
      $oAuthSignature = MIME::Base64::encode($signature);

      #Strip newlines from $oAuthSignature
      $oAuthSignature =~ s/\n//g;
   }
   elsif (uc($oAuthSigMethod) eq 'HMAC-SHA1')
   {
      #Get Base OAuth String
      $oAuthMessage = generateBaseOAuthString(\%oAuthParamHash, $url, $httpMethod);

      #HMAC encode $oAuthMessage
      $oAuthSignature = Digest::SHA::hmac_sha1_base64($oAuthMessage, $consumerSecret . '&' . $accessTokenSecret);

      #Pad Base64 Digest
      while (length($oAuthSignature) % 4)
      {
         $oAuthSignature .= '=';
      }
   }


   #URL Encode $oAuthSignature
   $oAuthSignature = urlEncodeString($oAuthSignature);

   #Construct OAuth Header String
   $oAuth = 'OAuth ' . 'realm="' . $oAuthParamHash{'realm'} . '", ';

   #Delete 'realm' key from $oAuthParamHash
   delete $oAuthParamHash{'realm'};

   for $hashKey (sort keys %oAuthParamHash)
   {
      #Only set for non-null values
      if (defined($oAuthParamHash{$hashKey}) && $oAuthParamHash{$hashKey} ne '')
      {
         $oAuth .= $hashKey . '="' . $oAuthParamHash{$hashKey} . '", ';
      }
   }

   #Add final $oAuthSignature to $oAuth
   $oAuth .= 'oauth_signature="' . $oAuthSignature . '"';


   return ($oAuth);
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




################################################################################
# urlEncodeString -
################################################################################
sub urlEncodeString($)
{
   my $inputString = $_[0];

   my $outputString = $inputString;

   $outputString =~ s/\%/%25/g;
   $outputString =~ s/\!/%21/g;
   $outputString =~ s/\"/%22/g;
   $outputString =~ s/\#/%23/g;
   $outputString =~ s/\$/%24/g;
   $outputString =~ s/\&/%26/g;
   $outputString =~ s/\'/%27/g;
   $outputString =~ s/\(/%28/g;
   $outputString =~ s/\)/%29/g;
   $outputString =~ s/\*/%2A/g;
   $outputString =~ s/\+/%2B/g;
   $outputString =~ s/\,/%2C/g;
#   $outputString =~ s/\-/%2D/g;
   $outputString =~ s/\//%2F/g;
   $outputString =~ s/\:/%3A/g;
   $outputString =~ s/\;/%3B/g;
   $outputString =~ s/\</%3C/g;
   $outputString =~ s/\=/%3D/g;
   $outputString =~ s/\>/%3E/g;
   $outputString =~ s/\?/%3F/g;
   $outputString =~ s/\@/%40/g;
   $outputString =~ s/\[/%5B/g;
   $outputString =~ s/\\/%5C/g;
   $outputString =~ s/\]/%5D/g;
   $outputString =~ s/\^/%5E/g;
   $outputString =~ s/\`/%60/g;
   $outputString =~ s/\{/%7B/g;
   $outputString =~ s/\|/%7C/g;
   $outputString =~ s/\}/%7D/g;
   $outputString =~ s/\~/%7E/g;

   return ($outputString);
}




################################################################################
# generateBaseOAuthString -
################################################################################
sub generateBaseOAuthString($$$)
{
   my $hashRef            = $_[0];
   my $url                = $_[1];
   my $httpMethod         = $_[2];


   my $oAuthMessage       = '';
   my $urlBase            = '';
   my $urlQueryParameters = '';
   my %tempHash           = ();
   my $key                = '';
   my @qArray             = ();
   my $qKey               = '';
   my $qValue             = '';
   my $realm              = '';


   #Populate %tempHash with specific values from $hashRef
   if ( defined($hashRef->{'oauth_consumer_key'}) ) { $tempHash{'oauth_consumer_key'} = $hashRef->{'oauth_consumer_key'}; }
   if ( defined($hashRef->{'oauth_nonce'}) ) { $tempHash{'oauth_nonce'} = $hashRef->{'oauth_nonce'}; }
   if ( defined($hashRef->{'oauth_signature_method'}) ) { $tempHash{'oauth_signature_method'} = $hashRef->{'oauth_signature_method'}; }
   if ( defined($hashRef->{'oauth_timestamp'}) ) { $tempHash{'oauth_timestamp'} = $hashRef->{'oauth_timestamp'}; }
   if ( defined($hashRef->{'oauth_token'}) ) { $tempHash{'oauth_token'} = $hashRef->{'oauth_token'}; }
   if ( defined($hashRef->{'oauth_version'}) ) { $tempHash{'oauth_version'} = $hashRef->{'oauth_version'}; }



   #Use legacy method for constructing base oauth string
   if ( ($hashRef->{'realm'} eq 'http%3A%2F%2Fintuit.ifs.com%2F') || ($hashRef->{'realm'} eq 'http%3A%2F%2Fintuit.ifs.com') || ($hashRef->{'realm'} eq 'https%3A%2F%2Fservices.prd.banking.intuit.com') )
   {
      #OAuth libs expect a trailing slash (%2F) at the end of the URL
      #Add a trailing slash if not already there
      if ( substr($hashRef->{'realm'}, -3) ne '%2F')
      {
         $realm = $hashRef->{'realm'} . '%2F';
      }
      else
      {
         $realm = $hashRef->{'realm'};
      }


      #Begin Base Message
      $oAuthMessage = 'POST&' . $realm . '&';
   }
   #Use new method for constructing base oauth string
   else
   {
      #Split $url into $urlBase and $urlQueryParameters
      ($urlBase, $urlQueryParameters) = split(/\?/, $url);

      #Add urlQueryParameters to %tempHash
      if (defined($urlQueryParameters))
      {
         #Split all query parameters into @qArray
         @qArray = split(/\&/, $urlQueryParameters);

         #Iterate over @qArray and add to %tempHash
         foreach (@qArray)
         {
            ($qKey, $qValue) = split(/\=/, $_);

            $tempHash{$qKey} = urlEncodeString($qValue);
         }
      }

      #Begin Base Message
      $oAuthMessage = $httpMethod . '&' . urlEncodeString($urlBase) . '&';
   }


   #Add remaining parameters to $oAuthMessage
   for $key (sort keys %tempHash)
   {
      $oAuthMessage .= $key . '%3D' . $tempHash{$key} . '%26';
   }
   #Strip Trailing %26
   $oAuthMessage = substr($oAuthMessage, 0, length($oAuthMessage) - 3);


   return ($oAuthMessage);
}




################################################################################
# generateNonce subroutine -
################################################################################
sub generateNonce()
{
   my @a = (0..9);
   my $nonce = '';

   for(0..17)
   {
      $nonce .= $a[rand(scalar(@a))];
   }

   return($nonce);
}




################################################################################
# currentTimeSeconds subroutine -
################################################################################
sub currentTimeSeconds()
{
   my $secondsSinceEpoch = 0;

   $secondsSinceEpoch =  int(Time::HiRes::gettimeofday());


   return($secondsSinceEpoch);
}




################################################################################
# parseOAuthResponse subroutine -
################################################################################
sub parseOAuthResponse($)
{
   my $oAuthResponseBody     = $_[0];

   my $accessToken           = 'undef';
   my $accessTokenSecret     = 'undef';
   my $ficustomerId          = 'undef';
   my $strPos1               = 0;
   my $strPos2               = 0;

   #Parse $accessToken
   $strPos1 = index($oAuthResponseBody, 'oauth_token="');
   if ($strPos1 >= 0)
   {
      $strPos2 = index($oAuthResponseBody, '"', $strPos1 + length('oauth_token="') + 1);
      if ($strPos2 >= 0)
      {
         $accessToken = substr($oAuthResponseBody, $strPos1 + length('oauth_token="'), $strPos2 - $strPos1 - length('oauth_token="'));
      }
   }


   #Parse $accessTokenSecret
   $strPos1 = index($oAuthResponseBody, 'oauth_token_secret="');
   if ($strPos1 >= 0)
   {
      $strPos2 = index($oAuthResponseBody, '"', $strPos1 + length('oauth_token_secret="') + 1);
      if ($strPos2 >= 0)
      {
         $accessTokenSecret = substr($oAuthResponseBody, $strPos1 + length('oauth_token_secret="'), $strPos2 - $strPos1 - length('oauth_token_secret="'));
      }
   }


   #Parse $ficustomerId
   $strPos1 = index($oAuthResponseBody, "ficustomerId='");
   if ($strPos1 >= 0)
   {
      $strPos2 = index($oAuthResponseBody, "'", $strPos1 + length("ficustomerId='") + 1);
      if ($strPos2 >= 0)
      {
         $ficustomerId = substr($oAuthResponseBody, $strPos1 + length("ficustomerId='"), $strPos2 - $strPos1 - length("ficustomerId='"));
      }
   }



   return($accessToken, $accessTokenSecret, $ficustomerId);
}




################################################################################
# getXmlValue subroutine -
################################################################################
sub getXmlValue($$)
{
   my $xmlString        = $_[0];
   my $xmlKey           = $_[1];

   my $value            = '';
   my $strPos1          = 0;
   my $strPos2          = 0;


   #Search for $xmlKey in $xmlString and extract $value
   $strPos1 = index($xmlString, "$xmlKey>");
   if ($strPos1 >= 0)
   {
      $strPos2 = index($xmlString, '</', $strPos1 + length("$xmlKey>") + 1);
      if ($strPos2 >= 0)
      {
         $value = substr($xmlString, $strPos1 + length("$xmlKey>"), $strPos2 - $strPos1 - length("$xmlKey>"));
      }
      else
      {
         $value = 'NOT_FOUND';
      }
   }
   else
   {
      $value = 'NOT_FOUND';
   }


   return ($value);
}
