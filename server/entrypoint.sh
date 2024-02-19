#!/bin/bash
rm -rf /judger/*
mkdir -p /judger/run /judger/spj

chown compiler:code /judger/run
chmod 711 /judger/run

chown compiler:spj /judger/spj
chmod 710 /judger/spj

core=$(grep --count ^processor /proc/cpuinfo)
n=$(($core*2))
while /bin/true; do
    python3 /code/service.py
    sleep 5
done &
exec gunicorn --workers 4 --threads 4 --error-logfile /log/gunicorn.log --time 600 --bind 0.0.0.0:8080 server:app