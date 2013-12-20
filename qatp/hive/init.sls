
/home/{{pillar.__stackdio__.username}}/.hiverc:
  file:
    - template: jinja
    - source: salt://qatp/hive/hiverc

/etc/hive/conf/hive-site.xml:
  file:
    - patch
    - template: jinja
    - source: salt://qatp/hive/hite-site.patch

/etc/hadoop/conf/hive-site.xml:
  file:
    - symlink
    - target: /etc/hive/conf/hive-site.xml
    - require: /etc/hive/conf/hive-site.xml

