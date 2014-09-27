{% if grains['os_family'] == 'Debian' %}

# Add the appropriate fish-shell repository. See http://fishshell.com/
# for which distributions and versions are supported.

# TODO this should be migrated to a pkgrepo as well
fish_shell_repo:
  cmd:
    - run
    - name: "sudo apt-add-repository ppa:fish-shell/release-2"
    - user: root

{% elif grains['os_family'] == 'RedHat' %}

fish_shell_repo:
  pkgrepo:
    - managed
    - humanname: "Fish shell - 2.x release series (RedHat_RHEL-6)"
    - baseurl: http://download.opensuse.org/repositories/shells:/fish:/release:/2/RedHat_RHEL-6/
    - gpgkey: http://download.opensuse.org/repositories/shells:/fish:/release:/2/RedHat_RHEL-6/repodata/repomd.xml.key
    - gpgcheck: 1

{% endif %}
