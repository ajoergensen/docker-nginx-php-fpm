#!/bin/bash
set -eo pipefail

for i in 5.6 7.0 7.1 7.2 7.3 7.4
 do
	C=nginx-php$i-fpm
	I=nginx-php-fpm:$i
	
	docker build -t $I -f Dockerfile.php$i .
	docker run --rm -d --name $C $I
	docker ps
	sleep 4
	docker logs $C
	docker exec $C pgrep nginx
	docker exec $C pgrep php-fpm
	IP=`docker inspect -f '{{ .NetworkSettings.IPAddress }}' $C`
	#curl -s --connect-timeout 2 http://$IP/index.php | grep -q "phpinfo()"
	curl -v --connect-timeout 2 http://$IP/index.php | grep "phpinfo()"
	docker rm -f $C
	docker rmi -f $I
done
