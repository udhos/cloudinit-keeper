#!/bin/bash

me=$(basename $0)

msg() {
	echo 2>&1 $me: $@
}

[ -z "$USER" ] && export USER=root
[ -z "$HOME" ] && export HOME=/root

msg USER=$USER HOME=$HOME

# get code

tmpdir=/tmp/$USER
mkdir $tmpdir
cd $tmpdir
rm -rf gowebhello
git clone https://github.com/udhos/gowebhello
cd gowebhello

# compile

app_home=$HOME/app
app=$app_home/gowebhello
rm -rf $app_home
mkdir $app_home
/usr/local/go/bin/go build -v -o $app ./gowebhello

# start service

restart() {
	msg restarting
	pkill -9 gowebhello
	$app -quota=5 &
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
	msg "status: $status"
	if [ "$status" != 200 ]; then
		restart
	fi
done


