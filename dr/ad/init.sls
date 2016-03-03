#
# install Active Directory for authentication
#

ad_packages:
  pkg:
    - installed
    - pkgs:
      - openldap
      - pam
      - pam_ldap
      - pam_krb5
      - ntp
      - sssd
      - nscd
      - autofs
      - nfs-utils

authconfig:
  cmd:
    - run
    - name: authconfig --enableshadow --enableldap --ldapserver={{ pillar.dr.ad.ldap_server }} --ldapbasedn={{ pillar.dr.ad.ldap_base_dn }} --disableldaptls --enablekrb5 --enablekrb5kdcdns --enablesssd --enablesssdauth --krb5realm={{ pillar.dr.ad.krb5_realm }} --krb5adminserver={{ pillar.dr.ad.krb5_admin_server }} --updateall
    - user: root
    - require:
      - pkg: ad_packages

/etc/sssd/sssd.conf:
  file:
    - managed
    - source: salt://dr/etc/sssd/sssd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - pkg: ad_packages

/etc/krb5.conf:
  file:
    - managed
    - source: salt://dr/etc/krb5.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ad_packages

/etc/nsswitch.conf:
  file:
    - replace
    - pattern: 'automount: .*'
    - repl: 'automount:  files ldap'
    - require:
      - pkg: ad_packages

/etc/idmapd.conf:
  file:
    - managed
    - source: salt://dr/etc/idmapd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ad_packages

/etc/sysconfig/autofs:
  file:
    - managed
    - source: salt://dr/etc/sysconfig/autofs-ad
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ad_packages

/etc/autofs_ldap_auth.conf:
  file:
    - managed
    - source: salt://dr/etc/autofs_ldap_auth_ad.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - pkg: ad_packages

/etc/sudoers:
  file:
    - append
    - text: '%linuxusers    ALL=(ALL)       NOPASSWD: ALL'
    - require:
      - pkg: ad_packages

/vhome:
  file:
    - directory
    - user: root
    - group: root
    - mode: 755

rpcbind:
  service:
    - running
    - require:
      - pkg: ad_packages
      - cmd: authconfig
    - watch:
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
      - file: /etc/nsswitch.conf
      - file: /etc/idmapd.conf
      - file: /etc/sysconfig/autofs
      - file: /etc/autofs_ldap_auth.conf
      - file: /etc/sudoers

nfs:
  service:
    - running
    - require:
      - service: rpcbind
    - watch:
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
      - file: /etc/nsswitch.conf
      - file: /etc/idmapd.conf
      - file: /etc/sysconfig/autofs
      - file: /etc/autofs_ldap_auth.conf
      - file: /etc/sudoers

sssd:
  service:
    - running
    - require:
      - service: nfs
    - watch:
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
      - file: /etc/nsswitch.conf
      - file: /etc/idmapd.conf
      - file: /etc/sysconfig/autofs
      - file: /etc/autofs_ldap_auth.conf
      - file: /etc/sudoers

autofs:
  service:
    - running
    - require:
      - service: sssd
    - watch:
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
      - file: /etc/nsswitch.conf
      - file: /etc/idmapd.conf
      - file: /etc/sysconfig/autofs
      - file: /etc/autofs_ldap_auth.conf
      - file: /etc/sudoers
