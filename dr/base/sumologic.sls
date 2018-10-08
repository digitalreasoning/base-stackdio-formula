{% if pillar.sumologic.install %}

# Get roles of this host
{% set datanode = 'cdh5.hadoop.hdfs.datanode' in grains.roles %}
{% set yarn = 'cdh5.hadoop.yarn.nodemanager' in grains.roles %}
{% set esdata = 'elasticsearch.data' in grains.roles %}
{% set edgenode = 'cdh5.hadoop.client' in grains.roles %}
{% set oozie = 'cdh5.oozie' in grains.roles %}

{% set anyroles = datanode or yarn or esdata or edgenode or oozie %}

collector_sources:
  file.directory:
    - name: /opt/SumoCollector/sources
    - user: root
    - group: root
    - mode: 755
    - makedirs: true

# Install log sources for this host
{% if datanode %}
/opt/SumoCollector/sources/datanode.json:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://dr/base/sources/datanode.json
    - requires:
      - file: collector_sources
{% endif %}

{% if yarn %}
/opt/SumoCollector/sources/yarn.json:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://dr/base/sources/yarn.json
    - requires:
      - file: collector_sources
{% endif %}

{% if esdata %}
/opt/SumoCollector/sources/esdata.json:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://dr/base/sources/esdata.json
    - requires:
      - file: collector_sources
{% endif %}

{% if edgenode %}
/opt/SumoCollector/sources/edgenode.json:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://dr/base/sources/edgenode.json
    - requires:
      - file: collector_sources
{% endif %}

{% if oozie %}
/opt/SumoCollector/sources/oozie.json:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://dr/base/sources/oozie.json
    - requires:
      - file: collector_sources
{% endif %}

/opt/SumoCollector/sources/messages.json:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://dr/base/sources/messages.json
    - requires:
      - file: collector_sources

# Install the package
wget:
  pkg.installed

sumo_script:
  file.managed:
    - name: /tmp/installsumo.sh
    - source: salt://dr/base/scripts/installsumo.sh
    - user: root
    - group: root
    - mode: 777
    - template: jinja
    - requires:
      - pkg: wget
      - file: collector_sources
      - file: /opt/SumoCollector/sources/messages.json

sumo_install:
  cmd.run:
    - name: /tmp/installsumo.sh
    - requires:
      - file: sumo_script

# Start the collector
collector:
  service.running:
    - enable: True
    - watch:
      - cmd: sumo_install

{% endif %}
