#!/bin/bash

# this needs to be run twice
for f in `seq 0 1`; do
    ipa-client-install \
        --domain={{ pillar.ipa.client_domain }} \
        --server={{ pillar.ipa.server}} \
        --realm={{ pillar.ipa.realm }} \
        -p builduser \
        -w "{{ pillar.ipa.client_password }}" \
        -U
    cp /var/log/ipaclient-install.log /var/log/ipaclient-install.log.${ff}
done

service sshd restart

