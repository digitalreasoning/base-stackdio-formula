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
    - name: authconfig --enableshadow --enablemkhomedir --enableldap --ldapserver={{ pillar.dr.ad.ldap_server }} --ldapbasedn={{ pillar.dr.ad.ldap_base_dn }} --disableldaptls --enablekrb5 --enablekrb5kdcdns --enablesssd --enablesssdauth --krb5realm={{ pillar.dr.ad.krb5_realm }} --krb5adminserver={{ pillar.dr.ad.krb5_admin_server }} --updateall
    - user: root
    - require:
      - file: /etc/resolv.conf

/etc/sssd/sssd.conf:
  file:
    - managed
    - source: salt://dr/awsds/sssd.conf
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

/etc/ssh/sshd_config:
  file:
    - replace
    - pattern: '#AuthorizedKeysCommand .*'
    - repl: 'AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys'
    - require:
      - pkg: ad_packages

/etc/sudoers:
  file:
    - append
    - text: '%{{ pillar.dr.ad.allow_group }}    ALL=(ALL)       NOPASSWD: ALL'
    - require:
      - pkg: ad_packages

sshd:
  service:
    - running
    - watch:
      - file: /etc/ssh/sshd_config

sssd:
  service:
    - running
    - require:
      - cmd: authconfig
      - pkg: ad_packages
    - watch:
      - file: /etc/resolv.conf
      - file: /etc/sssd/sssd.conf
      - file: /etc/krb5.conf
      - file: /etc/sudoers
