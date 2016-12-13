
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
