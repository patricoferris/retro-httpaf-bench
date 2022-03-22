#!/bin/bash
set -xe

run_duration="${RUN_DURATION:-45}"

export GOMAXPROCS=1
export COHTTP_DOMAINS=1
export HTTPAF_EIO_DOMAINS=1

rm -rf output/*
mkdir -p output

for cmd in "cohttp_eio.exe" "httpaf_eio.exe" "rust_hyper.exe" "cohttp_lwt_unix.exe" "httpaf_lwt.exe" "httpaf_effects.exe" "nethttp_go.exe" "httpaf_shuttle_async.exe"; do
  for rps in 1000 50000 75000 150000 300000 400000 ; do
      ./build/$cmd &
      running_pid=$!
      sleep 2;
      ./build/wrk2 -t 24 -d${run_duration}s -L -s ./build/json.lua -R $rps -c 1000 http://localhost:8080 > output/run-$cmd-$rps-1000.txt;
      kill ${running_pid};
      sleep 1;
  done
done

source build/pyenv/bin/activate
mv build/parse_output.ipynb .
jupyter nbconvert --to html --execute parse_output.ipynb
mv parse_output* output/
