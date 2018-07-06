#!/bin/bash

wget https://collectors.sumologic.com/rest/download/linux/64 -O /tmp/sumocollector.sh
chmod +x /tmp/sumocollector.sh
/tmp/sumocollector.sh -q -Vsumo.accessid={{ pillar.sumologic.accessid }} -Vsumo.accesskey={{ pillar.sumologic.accesskey }} -Vcollector.name={{ grains.id }} -VsyncSources=/opt/SumoCollector/sources -Vephemeral=true
