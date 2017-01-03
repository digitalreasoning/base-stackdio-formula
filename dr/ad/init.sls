{%- set server_fqdn = pillar.dr.ad.server_fqdn -%}
{%- set base_dn = pillar.dr.ad.ldap_base_dn -%}
{%- set krb5_realm = pillar.dr.ad.krb5_realm -%}
#
# install Active Directory for authentication
#

{% set pam_ldap_pkg = salt['grains.filter_by']({
  '6': 'pam_ldap',
  '7': 'nss-pam-ldapd',
}, grain='osmajorrelease') %}

ad-packages:
  pkg:
    - installed
    - pkgs:
      - openldap
      - pam
      - {{ pam_ldap_pkg }}
      - pam_krb5
      - ntp
      - sssd
      - nscd
      - autofs
      - nfs-utils

authconfig:
  cmd:
    - run
    - name: authconfig --enablesssd --enablesssdauth --enableldap --enableshadow --enablekrb5 --enablekrb5kdcdns --disableldaptls --ldapserver={{ server_fqdn }} --ldapbasedn={{ base_dn }}  --krb5realm={{ krb5_realm }} --krb5adminserver={{ server_fqdn }} --updateall
    - user: root
    - require:
      - pkg: ad-packages

/etc/sssd/sssd.conf:
  file:
    - managed
    - source: salt://dr/etc/sssd/sssd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - cmd: authconfig

/etc/krb5.conf:
  file:
    - managed
    - source: salt://dr/etc/krb5.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: authconfig

/etc/nsswitch.conf:
  file:
    - replace
    - pattern: 'automount: .*'
    - repl: 'automount:  files ldap sss'
    - require:
      - cmd: authconfig
    - watch_in:
      - service: rpcbind
      - service: nfs
      - service: sssd
      - service: autofs

/etc/idmapd.conf:
  file:
    - managed
    - source: salt://dr/etc/idmapd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: authconfig

/etc/sysconfig/autofs:
  file:
    - managed
    - source: salt://dr/etc/sysconfig/autofs-ad
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: authconfig

/etc/autofs_ldap_auth.conf:
  file:
    - managed
    - source: salt://dr/etc/autofs_ldap_auth_ad.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0600'
    - require:
      - cmd: authconfig

/etc/sudoers:
  file:
    - append
    - text: '%linuxusers    ALL=(ALL)       NOPASSWD: ALL'
    - require:
      - cmd: authconfig

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
      - pkg: ad-packages
      - cmd: authconfig
    - watch:
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
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
      - file: /etc/idmapd.conf
      - file: /etc/sysconfig/autofs
      - file: /etc/autofs_ldap_auth.conf
      - file: /etc/sudoers
