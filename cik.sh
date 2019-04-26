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
[ -d "$tmpdir" ] || mkdir "$tmpdir"
cd $tmpdir
rm -rf gowebhello
git clone https://github.com/udhos/gowebhello
cd gowebhello

# compile

app_home=$HOME/app
app=$app_home/gowebhello
rm -rf $app_home
[ -d "$app_home" ] || mkdir "$app_home"
/usr/local/go/bin/go build -v -o $app ./gowebhello

# start service

restart() {
	msg restarting: $app
	pkill -9 gowebhello
	$app -quota=5 &
}

restart

# loop 

url=http://localhost:8080/www/

while :; do
	sleep 5
	http_code=$(curl -o /dev/null -s -I -X GET -w "%{http_code}" $url)
	exit_status=$?
	msg "exit_status=$exit_status http_code=$http_code"
	if [ "$exit_status" -ne 0 ] || [ "$http_code" != 200 ]; then
		restart
	fi
done


