
/home/{{pillar.__stackdio__.username}}/.hiverc:
  file:
    - managed
    - makedirs: true
    - template: jinja
    - source: salt://qatp/hive/hiverc

/etc/hive/conf/hive-site.xml:
  file:
    - patch
    - template: jinja
    - hash: md5=dcfa0a7cc91262c921776d614efd2100
    - source: salt://qatp/hive/hite-site.patch

/etc/hadoop/conf/hive-site.xml:
  file:
    - symlink
    - target: /etc/hive/conf/hive-site.xml

