#!/bin/bash

# Grab a random value between 0-3600.
value=$RANDOM
while [ $value -gt 3600 ] ; do
    value=$RANDOM
done
sleep $value

/etc/init.d/autofs reload

