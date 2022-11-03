#! /bin/bash

$(which redis-server) > log/bitacoraScript.log &
rails runner "eval(File.read 'tools/levantaServicios/levantaBlurrily.rb')" &

