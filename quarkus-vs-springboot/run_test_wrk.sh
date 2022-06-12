#!/bin/bash

$wrk_home/wrk -t2 -c25 -d1m -s ./post_zipcode.lua --timeout 2m -H 'Host: localhost' http://localhost:8080 & sleep 60

$wrk_home/wrk -t2 -c14 -d5m -s ./get_by_city.lua --timeout 2m -H 'Host: localhost' http://localhost:8080 \ &
$wrk_home/wrk -t2 -c14 -d5m -s ./get_zipcode.lua --timeout 2m -H 'Host: localhost' http://localhost:8080 \ & sleep 120

$wrk_home/wrk -t1 -c14 -d3m -s ./get_by_city.lua --timeout 2m -H 'Host: localhost' http://localhost:8080 \ &
$wrk_home/wrk -t1 -c14 -d3m -s ./get_zipcode.lua --timeout 2m -H 'Host: localhost' http://localhost:8080 \ &

wait
