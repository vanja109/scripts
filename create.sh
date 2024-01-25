#!/bin/sh
OFS=$IFS
IFS=","

while read number domain ; do
 /var/www/html/postfixadmin/scripts/postfixadmin-cli mailbox add "test$number@domain" \
        --name "Test $number" \
        --password "test"$number"&01" --password2 "test"$number"&01" \
        --quota 100 --welcome-mail 1  --active 1
done < test.csv

IFS=$OFS