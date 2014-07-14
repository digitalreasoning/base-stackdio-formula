#!/bin/bash

# this needs to be run twice
for attempt in `seq 0 1`; do
    ipa-client-install \
        --domain={{ pillar.ipa.client_domain }} \
        --realm={{ pillar.ipa.realm }} \
        -p builduser \
        -w "{{ pillar.ipa.client_password }}" \
        -U
    cp /var/log/ipaclient-install.log /var/log/ipaclient-install.log.$(date +%s%N)
done

service sshd restart

