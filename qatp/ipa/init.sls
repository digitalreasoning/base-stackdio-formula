#
# install IPA for authentication
#

ipa_packages:
  pkg:
    - installed
    - pkgs: 
      - authconfig
      - fuse-sshfs
      - ipa-client
      - fprintd-pam
      - autofs

authconfig:
  cmd:
    - run
    - name: "authconfig --enablemkhomedir --updateall"
    - user: root

/etc/init.d/removefromipa:
  file:
    - managed
    - source: salt://qatp/etc/init.d/removefrompia
    - template: jinja
    - user: root
    - group: root
    - mode: 755

chkconfig:
  cmd:
    - run
    - name: "chkconfig --add removefromipa && chkconfig removefromipa --level 0 on"
    - user: root
    - require:
      - file: /etc/init.d/removefromipa

removefromipa:
  service:
    - running
    - require:
      - cmd: chkconfig

/etc/sudoers:
  file:
    - append 
    - template: jinja
    - sources: 
      - salt://qatp/etc/sudoers

/root/.ssh/config:
  file:
    - append
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - sources:
        - salt://qatp/home/sshfs_config

/root/.ssh/sshfs_id_rsa:
  file:
    - managed
    - source: salt://qatp/home/sshfs_id_rsa
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/root/.ssh/sshfs_id_rsa.pub:
  file:
    - managed
    - source: salt://qatp/home/sshfs_id_rsa.pub
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/etc/sysconfig/autofs:
  file:
    - managed
    - source: salt://qatp/etc/sysconfig/autofs
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/autofs_ldap_auth.conf:
  file:
    - managed
    - source: salt://qatp/etc/autofs_ldap_auth.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/usr/local/scripts/autofs.reload.sh:
  file:
    - managed
    - source: salt://qatp/ipa/scripts/autofs.reload.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 755
  cron.present:
    - user: root
    - minute: 1

install_ipa:
  cmd:
    - script
    - user: root
    - source: salt://qatp/ipa/scripts/install_ipa.sh

