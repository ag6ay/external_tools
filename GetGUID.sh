################################################################################
################################################################################
##                                                                            ##
##   GetGUID.sh - This curl command will help anyone to retrieve user's GUID  ##
##                without login into informix DB.                             ##
##                   Created by: Amzad Hossain                                ##
##                   Last updated: AH - 06/07/2013                            ##
##                                                                            ##
##                                                                            ##
################################################################################
################################################################################

#How to retrieve GUID - 
# Replace the FIID  to the APP you are using.
# Replcae the UserId with your UserId.

# Once you execute this .sh, you will see XML response. Look for id which is the GUID. e.g.- 
# <ns5:id>c0a82a26030d0106515a257b00495a00</ns5:id> is the GUID for user 'ahossain'.

curl -v -X GET \
--header 'Accept: text/xml,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
--header 'Accept-Language: en-us,en;q=0.5' \
--header 'Accept-Encoding: gzip,deflate' \
--header 'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7' \
--header 'Content-Type: text/xml; charset=utf-8' \
--header 'Authorization: cbs2testclient' \
--header 'intuit_tid: 123' \
--header 'intuit_originatingIp: 123.1.1.4' \
--header 'intuit_IFS_userProduct: CustomerCentral' \
--header 'intuit_appId: CustomerCentral' \
--header 'intuit_offeringId: CustomerCentral' \
--url 'http://cbs-sl1-qal-qydc.banking.intuit.net:80/cbs2/v2/fis/DI9901/fiCustomers/ahossain?fiCustomerIdType=MEMNUMBER'
