#! /bin/bash

redis-server > log/bitacoraScript.log &
sleep 10
rails runner "eval(File.read 'tools/levantaServicios/levantaBlurrily.rb')" &
rails s -p 4000
