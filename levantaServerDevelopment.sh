#! /bin/bash

redis-server > bitacoraScript &
sleep 10
soulmate-web --foreground --no-launch --redis=redis://localhoscd CONABIO/buscador/ >> bitacoraScript &
rails s -p 4000
