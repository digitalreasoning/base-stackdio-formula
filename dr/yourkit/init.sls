

{#download-yourkit:#}
{#  cmd:#}
{#    - run#}
{#    - name: curl -o {{ pillar.dr.yourkit.install_path }} https://www.yourkit.com/download/{{ pillar.dr.yourkit.version }}-linux.tar.bz2#}
{#    - user: root#}
{##}
{#unpack-yourkit:#}
{#  cmd:#}
{#    - run#}
{#    - name: tar xf#}


yourkit-binaries:
  archive:
    - extracted
    - name: {{ pillar.dr.yourkit.install_path }}
    - source: https://www.yourkit.com/download/{{ pillar.dr.yourkit.version }}-linux.tar.bz2
    - archive_format: tar
    - user: root
    - group: root
    - if_missing: {{ pillar.dr.yourkit.install_path }}/{{ pillar.dr.yourkit.version }}
