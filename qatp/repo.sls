{% if grains['os_family'] == 'Debian' %}

# Add the appropriate FISH repository. See http://fishshell.com/
# for which distributions and versions are supported.


add_fish_repo:
  cmd:
    - run
    - name: "sudo apt-add-repository ppa:fish-shell/release-2"
    - user: root


{% elif grains['os_family'] == 'RedHat' %}

add_fish_repo:
  cmd:
    - run
    - name: "yum-config-manager --add-repo http://fishshell.com/files/linux/RedHat_RHEL-6/fish.release:2.repo"
    - user: root

{% endif %}
