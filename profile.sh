echo "executing profile" 
set -o vi
 
PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:/opt/quest/bin

PATH=/bin:/usr/bin:/usr/sbin:/usr/ucb:/usr/bin/X11:/sbin:/usr/local/bin:/usr/lpp/ssp/bin:/usr/lpp/ssp/kerberos/bin:/usr/lpp/ssp/kerberos/etc:/var/sysman:/usr/local/sbin:/usr/dt/bin:/usr/lib/instl:/usr/ibmcxx/bin:/var/ifor:/usr/opt/ifor/ls/conf:/hb/bin/util:/u/webs/WEBTOOLS/:/hb/bin/util/iqa/SCRIPTS:./:/opt/di/service/PageSlave/2.0.2:/home/daas3276/testing:/hb/bin/util/iqa/SCRIPTS:/home/isva3169/bin:.

 

export PATH

 

export LIBPATH=/opt/di/lib/qa/internal:/hb/bin/staging/lib/internal:/hb/bin/staging/lib/3rdparty:/hb/informix/lib:/hb/informix/lib/esql:/opt/di/lib/:

export INFORMIXSERVER=qa1
export INFORMIXSERVER=db_pte
export PERL5LIB=/home/tool/lib:/hb/etc/schema/tools
export LIBPATH=/usr/lpp/xlC/lib:/usr/lib:/lib:/informix/lib/esql:/informix/lib
export LIBPATH=$LIBPATH:/hb/bin/staging/lib/Logging:/hb/bin/staging/lib/OpenSource:/hb/bin/staging/lib/3rdparty:/hb/bin/staging/lib/internal
export LIBPATH=/hb/bin/datecenter.env
export LIBPATH=$LIBPATH:/opt/di/lib
export LIBPATH=$LIBPATH:/hb/bin/staging/lib/Logging:/hb/bin/staging/lib/OpenSource:/hb/bin/staging/lib/3rdparty:/hb/bin/staging/lib/internal:usr/lpp/xlC/lib:/usr/lib:/lib:/informix/lib/esql:/informix/lib:/hb/bin:/opt/di/lib 
export LIBPATH=/lib:/usr/lib:/opt/informix_115_32/lib:/opt/informix_115_32/lib/esql:/opt/di/apps/qa/software/Interfaces/RDBServer/V1.0.0:/opt/di/apps/qa/software/DILib/V1.0.7


if [ "`whoami`" = "root" ]
       then
      PS1="`hostname`:\$PWD\# "

else

        PS1="`hostname`:\$PWD\> "

fi

 

hname=`hostname`

export hname

export PREAMBLE="$(whoami)@$(hostname)"

##export ECH="$(echo \\\012 \\\015)"

export PS1='${PREAMBLE}:${PWD}\> '

 

 

set -o vi                   # Enables command line editing with many of the vi commands - Hit the ESC key on the command line

                            # to enter command mode.  Hit i, a, or r to return to editing mode

 

                            # set parameters for vi (all parameters set with one line) EXINIT='set parm1 parm2 ...'

EXINIT='set ts=4 smd'       # tab size=4 spaces - enable showmode

alias utcmmfa='cd /opt/di/job/utilityCMMFA'
alias disite='cat /opt/di/service/util/Getsite/1.5.1/disite.conf'
alias env='. /opt/di/service/util/datacenter.env'
#alias root = '/opt/quest/bin/pmrun su - root'
#alias sudb='su - dbwriter'
#alias suin='su - informix'

export EXINIT

alias bbfqa='cd /opt/di/service/BBFSlave_40092'
alias qs='qa_setup'
alias sc='cd /hb/bin/util/iqa/SCRIPTS/'
alias ll='ls -ltr'
alias l='. pcd'
alias acdp='. add_cdpath'
alias md='mkdir'
alias v='vim'
alias vi='vim'
alias home='cd; clear'
alias e='exit'
alias ts='. settabstop'
alias p='ps -aef | grep'
alias client='. setP4Client'
alias each='while read line;do'
alias sn='sitename'
alias loco='ls -l | grep -v "^l"'
alias b='cd ..'
alias bb='cd ../..'
alias h='cd /hb/'
alias a1='cd /hb/wlvbatchqa1'
alias a2='cd /hb/wlvbatchqa2'
alias a3='cd /hb/wlvbatchqa3'
alias a4='cd /hb/wlvbatchqa4'
alias a5='cd /hb/wlvbatchqa5'
alias a6='cd /hb/wlvbatchqa6'
alias a7='cd /hb/wlvbatchqa7'
alias a8='cd /hb/wlvbatchqa8'
alias i1='cd /hb/wlviqa1'
alias i2='cd /hb/wlviqa2'
alias i3='cd /hb/wlviqa3'
alias i4='cd /hb/wlviqa4'
alias i5='cd /hb/wlviqa5'
alias i6='cd /hb/wlviqa6'
alias i7='cd /hb/wlviqa7'
alias i8='cd /hb/wlviqa8'
alias s1='cd /hb/srtqasite1'
alias s2='cd /hb/srtqasite2'
alias s3='cd /hb/srtqasite3'
alias s4='cd /hb/srtqasite4'
alias s5='cd /hb/srtqasite5'
alias s6='cd /hb/srtqasite6'
alias s7='cd /hb/srtqasite7'
alias s8='cd /hb/srtqasite8'
alias s9='cd /hb/srtqasite9'
alias s10='cd /hb/srtqasite10'
alias s11='cd /hb/srtqasite11'
alias s12='cd /hb/srtqasite12'
alias c1='cd /hb/candidate1'
alias c2='cd /hb/candidate2'
alias c3='cd /hb/candidate3'
alias c4='cd /hb/candidate4'
alias c5='cd /hb/candidate5'
alias c6='cd /hb/candidate6'
alias c7='cd /hb/candidate7'
alias c8='cd /hb/candidate8'
alias c9='cd /hb/candidate9'
alias c10='cd /hb/candidate10'
alias c11='cd /hb/candidate11'
alias c12='cd /hb/candidate12'
alias c13='cd /hb/candidate13'
alias c14='cd /hb/candidate14'
alias c15='cd /hb/candidate15'
alias c16='cd /hb/candidate16'
alias c17='cd /hb/candidate17'
alias c18='cd /hb/candidate18'
alias c19='cd /hb/candidate19'
alias root='/opt/quest/bin/pmrun su - root'

umask 022

 

if [ -s "$MAIL" ]           # This is at Shell startup.  In normal

then echo "$MAILMSG"        # operation, the Shell checks

fi                          # periodically.


export ORACLE_HOME=/opt/oracle/10.1.0.2.0

PATH=$PATH:/$ORACLE_HOME/bin
export LIBPATH=$LIBPATH:$ORACLE_HOME/lib32:$ORACLE_HOME/jdk/jre/bin:$ORACLE_HOME/jdk/jre/bin/classic
export ORACCENV=xlc_r


# Perforce setup
export P4PORT=p4:1777
export P4USER=ahossain
export P4CLIENT=amho3827-helium2qa

