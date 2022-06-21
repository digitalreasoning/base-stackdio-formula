
bzip2:
  pkg:
    - installed

install-dir:
  file:
    - directory
    - name: {{ pillar.dr.yourkit.install_path }}
    - user: root
    - group: root

download-yourkit:
  cmd:
    - run
    - name: curl -O https://archive.yourkit.com/yjp/2015/yjp-2015-build-15088-linux.tar.bz2
    - cwd: {{ pillar.dr.yourkit.install_path }}
    - user: root
    - unless: test -f {{ pillar.dr.yourkit.install_path }}/yjp-2015-build-15088-linux.tar.bz2
    - require:
      - file: install-dir

unpack-yourkit:
  cmd:
    - run
    - name: tar -xf yjp-2015-build-15088-linux.tar.bz2
    - cwd: {{ pillar.dr.yourkit.install_path }}
    - user: root
    - unless: test -d {{ pillar.dr.yourkit.install_path }}/yjp-2015-build-15088-linux.tar.bz2
    - require:
      - pkg: bzip2
      - cmd: download-yourkit
