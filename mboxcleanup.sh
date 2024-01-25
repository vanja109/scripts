#!/bin/sh

DBUSER="postfix"
DBPASS="##########"
DBNAME="postfix"

mysql=`which mysql`
MYNAME=`basename $0`

#EXP_DAYS="86400"       # 24 hours
#EXP_DAYS="3600"        # 1 hour
EXP_DAYS="7779600"      # 3 months
CUR_DATE=`date +'%s'`
DEL=`expr $CUR_DATE - $EXP_DAYS`

LOG="/var/log/selfcreated_logs/mboxcleanup.log"
DOM="example.com"
MDIR="/home/mail/example.com"

sqlconnection ()
{
         /usr/bin/mysql -u $DBUSER  -p$DBPASS -D $DBNAME -s --disable-column-names -e "$@"
}

logwrite ()
{
        echo "`date '+%Y-%m-%d %H:%M:%S'` $1" >> $LOG
}


req=$(sqlconnection "SELECT userid FROM last_login WHERE last_access < $DEL")


if [ -n "$req" ]; then
        logwrite "  Found `echo $req | wc -w | tr -d ' '` expired mailbox(es):
$req "
        for k in $req
        do
                $(sqlconnection "DELETE FROM alias WHERE address = '$k'")
                $(sqlconnection "INSERT INTO log (timestamp, username, domain, action, data) VALUES (NOW(), '`whoami` ($MYNAME)', '$DOM', 'delete_alias', '$k')")
                dir=$(sqlconnection "SELECT local_part FROM mailbox WHERE username = '$k'")
                $(sqlconnection "DELETE FROM mailbox WHERE username = '$k'")
                $(sqlconnection "INSERT INTO log (timestamp, username, domain, action, data) VALUES (NOW(), '`whoami` ($MYNAME)', '$DOM', 'delete_mailbox', '$k')")
                $(sqlconnection "DELETE FROM quota2 WHERE username = '$k'")
                $(sqlconnection "INSERT INTO log (timestamp, username, domain, action, data) VALUES (NOW(), '`whoami` ($MYNAME)', '$DOM', 'delete_from_quota2', '$k')")
                $(sqlconnection "DELETE FROM last_login WHERE userid = '$k'")
                $(sqlconnection "INSERT INTO log (timestamp, username, domain, action, data) VALUES (NOW(), '`whoami` ($MYNAME)', '$DOM', 'delete_from_last_login', '$k')")

                #sudo tar -czf $MDIR/$k.tar.gz $MDIR/$k         # enable to do tar-archieve
                sudo rm -rf $MDIR/$k

                logwrite "    Mailbox $k removed"
        done
else
        logwrite "  Nothing to do"
fi

logwrite "Cleanup finished"
