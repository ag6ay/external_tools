#!/bin/ksh

program=${0##*(*/|-)}

# Define 'usage' text for error messages:
usage="Usage: ${program} [ SITE ] [ PATH ]
\n\tparameter 1 = SITE (e.g. srtqasite4)
\n\tparameter 2 = PATH (e.g. /home/user/process.txt)
\n\tparameter 3 = INTERVAL (e.g. 60 = 1 Minuet, default if omitted = 15 Minuets)
\ne.g:\n\t$program srtqasite4 /home/user/process.txt 60
\n\t$program srtqasite4 /home/user/process.txt"

# Check to see if at least two arguments were passed
if [[ $# < 2 ]]
then
        echo
        echo ${usage}
        echo
        exit 1;
fi

# Check for interval being passed from command line
interval=$3

# If interval is less than 1 or was not passed set to 900 or 15 Minuets
if [[ ${interval} < 1 ]]
then
	interval=900
fi


# Use arguments to build command:
while /bin/true; do ps -aeNo "PID:%p PPID:%P VSZ:%z ETIME:%t ARGS:%a" | grep $1 | grep -v "memMonitor.sh" | grep -v "grep" >> $2; sleep ${interval}; done
