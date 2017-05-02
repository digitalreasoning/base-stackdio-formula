
{% if grains.os_family == 'RedHat' %}
dev-tools:
  pkg.group_installed:
    - name: Development Tools
{% endif %}

blas:
  pkg.installed:
    - pkgs:
      - blas-devel
      - openblas-devel

ius-release:
  pkg.installed:
    - sources:
      - ius-release: https://{{ grains['os'] }}{{ grains['osmajorrelease'] }}.iuscommunity.org/ius-release.rpm

git:
  pkg.removed: []

git2u-all:
  pkg.installed:
    - require:
      - pkg: ius-release
      - pkg: git
