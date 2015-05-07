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

/etc/resolv.conf:
  file:
    - managed
    - source: salt://dr/etc/resolv.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ad_packages

authconfig:
  cmd:
    - run
    - name: authconfig --enableshadow --enableldap --ldapserver={{ pillar.dr.ad.ldap_server }} --ldapbasedn={{ pillar.dr.ad.ldap_base_dn }} --disableldaptls --enablekrb5 --enablekrb5kdcdns --enablesssd --enablesssdauth --krb5realm={{ pillar.dr.ad.krb5_realm }} --krb5adminserver={{ pillar.dr.ad.krb5_admin_server }} --updateall
    - user: root
    - require:
      - file: /etc/resolv.conf

/etc/sssd/sssd.conf:
  file:
    - mananged
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
    - append
    - text: 'automount:  files ldap'
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
    - user: root
    - group: root
    - mode: 644
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

sssd:
  service:
    - running
    - require:
      - pkg: ad_packages
      - cmd: authconfig
    - watch:
      - file: /etc/resolv.conf
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
      - pkg: ad_packages
      - cmd: authconfig
    - watch:
      - file: /etc/resolv.conf
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
      - file: /etc/nsswitch.conf
      - file: /etc/idmapd.conf
      - file: /etc/sysconfig/autofs
      - file: /etc/autofs_ldap_auth.conf
      - file: /etc/sudoers
