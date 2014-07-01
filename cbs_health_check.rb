################################################################################
################################################################################
##                                                                            ##
##   CBS2HealthCheck.rb - Verify CBS2 app tier Health check Status.           ##
##                                                                            ##
##                   Created by: Vaidy & Amzad                                ##
##                   Last updated: AH - 03/12/2013 Ver. 1.00                  ##
##                                                                            ##
##                                                                            ##
################################################################################
################################################################################


require 'rubygems'
require 'httparty'
response = HTTParty.get('http://pdevcbsas103.corp.intuit.net:8080/cbs2/status')
#puts response.body, response.code, response.message, response.headers.inspect

if response.code==200 and response.message=="OK"
  puts "Dev CBS2 is up"
else
  puts "Dev CBS2 may be down.  Recieved response code #{response.code} and response message #{response.message}"
end
