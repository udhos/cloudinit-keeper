#!/bin/bash

me=$(basename $0)

msg() {
	echo 2>&1 $me: $@
}

# get binary

cd /tmp
rm -rf gowebhello
git clone https://github.com/udhos/gowebhello
cd gowebhello
go install ./gowebhello

# start service

restart() {
	msg restarting
	pkill -9 gowebhello
	~/go/bin/gowebhello -quota=5 &
}

restart

# loop 

query() {
	status=$(curl -o /dev/null -s -w "%{http_code}\n" http://www.google.com)
	[ $status == 200 ]
}

url=http://localhost:8080/www/

while :; do
	sleep 5
	status=$(curl -o /dev/null -s -w "%{http_code}\n" $url)
	msg "status=$status"
	if [ "$status" != 200 ]; then
		restart
	fi
done


