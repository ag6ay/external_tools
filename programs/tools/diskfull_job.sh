#!/bin/bash
################################################################################
################################################################################
##                                                                            ##
##   diskfull_job.sh - This script determines the percentage of disk usage    ##
##                    If that percentage is greater than 80% a user is emailed##
##                     a report notifying them of the usage.                  ##
##                                                                            ##
##                                                                            ##
##               Created by: Amzad Hossain                                    ##
##               Last Updated: AH - 01/26/2013 Ver. 1.01                      ##
##                                                                            ##
################################################################################
################################################################################


#emailUser="amzad_hossain@intuit.com"
emailUser="amzad_hossain@intuit.com -c david_schwab@intuit.com -c Jose_Fuente@intuit.com -c matthew_greenberg@intuit.com -c bradford_parry@intuit.com -c mohit_richhariya@intuit.com -c Mark_Barrinuevo@intuit.com -c Poshan_Sharma@intuit.com -c Marilyn_Cole@intuit.com -c Sirisha_Chigurupati@intuit.com -c bharathi_kunigiri@intuit.com -c alex_bryan@intuit.com -c Bernardo_Martinez@intuit.com -c chester_reyes@intuit.com -c leif_gaebler@intuit.com -c misael_davila@intuit.com -c Bhoomikai_Annaiah@intuit.com -c james_variot@intuit.com"

typeset -i error="80"
if [ -e temp.txt ]; then
rm temp.txt
fi
for disc in `mount| egrep '^/dev' | egrep -iv 'cdrom|proc|sys|pts' |awk '{print $3}'`
do
typeset -i discUsage=`df -h $disc|cut -c40-42|grep -i [^a-z]`
if [ "$discUsage" -ge "$error" ]; then

USAGE_REPORT=`du -sk /home/* | sort -nr -k 1`

echo "Hi All,">> temp.txt
echo "" >> temp.txt
echo "Disc usage for Primary IATF Automation Machine: $HOSTNAME is at $discUsage% FULL.">> temp.txt
echo "" >> temp.txt
echo "PLEASE CLEAN UP YOUR LOG DIRECTORY AND REMOVE ALL OLD ARCHIEVE LOGS.">> temp.txt
echo "" >> temp.txt
echo "You must use a symbolic link for your logs that points outside of the home directory to the /app/network storage folder.">> temp.txt
echo "" >> temp.txt
echo "An Example:-">> temp.txt
echo "" >> temp.txt
echo "cd /home/amho3827/work/testing-software">> temp.txt
echo "" >> temp.txt
echo "[amho3827@pdevdv1os15s testing-software]$ ls -l logs">> temp.txt
echo "" >> temp.txt
echo "lrwxrwxrwx  1 amho3827 amho3827   18 Jul  5 15:22 logs -> /app/amho3827/logs">> temp.txt
echo "" >> temp.txt
echo "Delete old test results in //depot/QA/test-plan_test-results/.">> temp.tx
echo "" >> temp.txt
echo "COMPLETE DISK USAGE REPORT BY USERS-">>temp.txt
echo "" >> temp.txt
echo "$USAGE_REPORT">>temp.txt
echo "" >> temp.txt
echo "Thanks,">> temp.txt
echo "Amzad" >> temp.txt

fi
done
if [ -e temp.txt ]; then
message=`cat temp.txt`
fi
if [ ${#message} -gt 0 ]; then
cat temp.txt | mail  -s "Disc Usage >80% Report for Primary IATF Automation Machine: $HOSTNAME" $emailUser
fi