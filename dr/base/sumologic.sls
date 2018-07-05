{% if sumologic.install %}

# Get roles of this host
{% set datanode = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.hdfs.datanode', 'grains.items', 'compound') %}
{% set yarn = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.yarn.nodemanager', 'grains.items', 'compound') %}
{% set esdata = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:elasticsearch.data', 'grains.items', 'compound') %}
{% set edgenode = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:dh5.hadoop.client', 'grains.items', 'compound') %}
{% set oozie = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.oozie', 'grains.items', 'compound') %}

{% set anyroles = datanode or yarn or esdata or edgenode or oozie %}
{% if anyroles %}
collector_sources:
  file.directory:
    - name: /opt/SumoCollector/sources
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
{% endif %}

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


{% if anyroles %}
# Install the package
wget:
  pkg.installed

script:
  file.managed:
    - name: /tmp/installsumo.sh
    - source: salt://dr/base/scripts/installsumo.sh
    - user: root
    - group: root
    - mode: 777
    - template: jinja
    - requires:
      - pkg: wget

install:
  cmd.run:
    - name: /tmp/installsumo.sh
    - requires:
      - file: script

# Start the collector
collector:
  service.running:
    - enable: True
    - watch:
      - cmd: install
{% endif %}

{% endif %}
