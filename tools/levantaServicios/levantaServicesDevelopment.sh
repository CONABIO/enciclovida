#! /bin/bash

redis-server > log/bitacoraScript.log &
sleep 10
soulmate-web --foreground --no-launch --redis=redis://172.16.3.213:6379/0 >> log/bitacoraScript.log &
rails runner "eval(File.read 'tools/levantaServicios/levantaBlurrily.rb')" &

