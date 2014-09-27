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

messagebus:
  service:
    - running
    - require:
      - pkg: ipa_packages

authconfig:
  cmd:
    - run
    - name: "authconfig --enablemkhomedir --updateall"
    - user: root
    - unless: "service sssd status"
    - require:
      - service: messagebus

/etc/init.d/removefromipa:
  file:
    - managed
    - source: salt://dr/etc/init.d/removefromipa
    - template: jinja
    - user: root
    - group: root
    - mode: 755

# removefromipa  	0:on	1:off	2:off	3:on	4:off	5:on	6:off
removefromipa_chkconfig:
  cmd:
    - run
    - name: "chkconfig --add removefromipa && chkconfig removefromipa --level 0 on && chkconfig removefromipa --level 0 off"
    - user: root
    - unless: "chkconfig --list removefromipa"
    - require:
      - file: /etc/init.d/removefromipa

removefromipa:
  service:
    - running
    - require:
      - cmd: removefromipa_chkconfig

/etc/sudoers.d/ipa:
  file:
    - managed
    - template: jinja
    - source: salt://dr/etc/sudoers
    - mode: 400

/root/.ssh/config:
  file:
    - managed 
    - makedirs: true
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - source: salt://dr/ipa/sshfs_config

/root/.ssh/sshfs_id_rsa:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/ipa/sshfs_id_rsa
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/root/.ssh/sshfs_id_rsa.pub:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/ipa/sshfs_id_rsa.pub
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/etc/sysconfig/autofs:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/etc/sysconfig/autofs
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
    - source: salt://dr/etc/autofs_ldap_auth.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 600

/usr/local/scripts/autofs.reload.sh:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/ipa/scripts/autofs.reload.sh
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
    - template: jinja
    - user: root
    - source: salt://dr/ipa/scripts/install_ipa.sh
    - unless: "klist -k /etc/krb5.keytab"

sssd:
  service:
    - running
    - require:
      - cmd: install_ipa

/etc/nsswitch.conf:
  file:
    - replace
    - pattern: '^automount.*'
    - repl: 'automount: files ldap'
    - require:
      - cmd: install_ipa

restart_autofs:
  cmd:
    - wait
    - name: "service autofs restart"
    - user: root
    - watch: 
      - file: /etc/nsswitch.conf
    - require:
      - file: /etc/nsswitch.conf

