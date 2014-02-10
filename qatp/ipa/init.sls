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
    - source: salt://qatp/etc/init.d/removefromipa
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

/etc/sudoers.d/ipa:
  file:
    - managed
    - template: jinja
    - source: salt://qatp/etc/sudoers
    - mode: 400

/root/.ssh/config:
  file:
    - managed 
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - source: salt://qatp/ipa/sshfs_config

/root/.ssh/sshfs_id_rsa:
  file:
    - managed
    - source: salt://qatp/ipa/sshfs_id_rsa
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/root/.ssh/sshfs_id_rsa.pub:
  file:
    - managed
    - source: salt://qatp/ipa/sshfs_id_rsa.pub
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
  service:
    - running
    - name: autofs
    - enable: true

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

/etc/nsswitch.conf:
  file:
    - replace
    - pattern: '^automount.*'
    - repl: 'automount: files ldap'

install_ipa:
  cmd:
    - script
    - template: jinja
    - user: root
    - source: salt://qatp/ipa/scripts/install_ipa.sh

