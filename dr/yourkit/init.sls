
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
    - name: curl -O https://www.yourkit.com/download/{{ pillar.dr.yourkit.version }}-linux.tar.bz2
    - cwd: {{ pillar.dr.yourkit.install_path }}
    - user: root
    - require:
      - file: install-dir

unpack-yourkit:
  cmd:
    - run
    - name: tar xf {{ pillar.dr.yourkit.version }}-linux.tar.bz2
    - cwd: {{ pillar.dr.yourkit.install_path }}
    - user: root
    - unless: test -d {{ pillar.dr.yourkit.install_path }}/{{ pillar.dr.yourkit.version }}
    - require:
      - pkg: bzip2
      - cmd: download-yourkit
