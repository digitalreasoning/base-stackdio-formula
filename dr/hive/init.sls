
{% for user in pillar.__stackdio__.users %}
/home/{{user.username}}/.hiverc:
  file:
    - managed
    - makedirs: true
    - template: jinja
    - source: salt://dr/hive/hiverc
{% endfor %}

/etc/hive/conf/hive-site.xml:
  file:
    - patch
    - template: jinja
    - hash: md5=dcfa0a7cc91262c921776d614efd2100
    - source: salt://dr/hive/hite-site.patch

/etc/hadoop/conf/hive-site.xml:
  file:
    - symlink
    - target: /etc/hive/conf/hive-site.xml

