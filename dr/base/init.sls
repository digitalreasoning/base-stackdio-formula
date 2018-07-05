include:
  - dr.base.sumologic
  
# turn off iptables
{% for svc in [ "iptables", "ip6tables"] %}
disable-{{svc}}:
  service:
    - dead
    - name: {{svc}}
    - enable: false
{% endfor %}

{% set vim_pkg = salt['grains.filter_by']({
  'Debian': 'vim',
  'RedHat': 'vim-enhanced'
}) %}

{% set pip_pkg = salt['grains.filter_by']({
  'Debian': 'python-pip',
  'RedHat': salt['grains.filter_by']({
    '6': 'python-pip',
    '7': 'python2-pip'
  }, 'osmajorrelease')
}) %}

#
# Setup AWS credentials and tools
#
{% for user in pillar.__stackdio__.users %}
/home/{{user.username}}/.s3cfg:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/home/s3cfg
    - template: jinja
    - user: {{ user.username }}
    - group: {{ user.username }}
    - mode: 755

/home/{{user.username}}/.aws/config:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/home/aws_config
    - template: jinja
    - user: {{ user.username }}
    - group: {{ user.username }}
    - mode: 755
    - makedirs: true

#
# Some default files
#
/home/{{user.username}}/.vimrc:
  file:
    - managed
    - makedirs: true
    - source: salt://dr/home/vimrc
    - user: {{ user.username }}
    - group: {{ user.username }}
    - mode: 755

/home/{{user.username}}/.bashrc:
  file:
    - append
    - template: jinja
    - mode: 755
    - sources:
      - salt://dr/home/bashrc

{{user.username}}_authorized_keys:
  ssh_auth:
    - present
    - user: {{ user.username }}
    - names: {{ pillar.dr.authorized_keys }}

{% endfor %}

# listing packages alphabetically for some sanity
base_packages:
  pkg:
    - installed
    - pkgs:
      - createrepo
      - ntp
      - {{ pip_pkg }}
      - s3cmd
      - screen
      - sysstat
      - tmux
      - unzip
      - wget
      - {{ vim_pkg }}
      - zsh

{% for pippkg in ["awscli","pygtail"] %}
install-{{pippkg}}:
  pip.installed:
    - name: {{pippkg}}
    - require:
      - pkg: base_packages
{% endfor %}

#
# Set a variety of system configuration and permissions
#
/mnt:
  file:
    - directory
    - mode: 777

/mnt1:
  file:
    - directory
    - mode: 777

/mnt2:
  file:
    - directory
    - mode: 777

/mnt3:
  file:
    - directory
    - mode: 777

/mnt4:
  file:
    - directory
    - mode: 777

fix_tty:
  cmd:
    - run
    - name: "sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers"
    - user: root

/etc/sysctl.conf:
  file:
    - append
    - template: jinja
    - sources:
      - salt://dr/etc/sysctl.conf

set_swappiness:
  cmd:
    - run
    - name: sysctl -n vm.swappiness=0
    - user: root

/etc/pam.d/su:
  file:
    - append
    - template: jinja
    - sources:
      - salt://dr/etc/pam.d/su

/etc/security/limits.conf:
  file:
    - append
    - template: jinja
    - sources:
      - salt://dr/etc/security/limits.conf

{% set ntp_svc = salt['grains.filter_by']({
  'Debian': 'ntp',
  'RedHat': 'ntpd'
}) %}

# actually turn on ntp
ntpd-svc:
  service:
    - running
    - name: {{ ntp_svc }}
    - require:
      - pkg: base_packages

{% if pillar.dr.cloudhealth.install %}

# Cloud health things
install-script:
  cmd:
    - run
    - name: curl -o /tmp/cloudhealth.sh https://s3.amazonaws.com/remote-collector/agent/v14/install_cht_perfmon.sh
    - user: root

run-script:
  cmd:
    - run
    - name: sh cloudhealth.sh 14 {{ pillar.dr.cloudhealth.key }} aws
    - user: root
    - cwd: /tmp
    - require:
      - cmd: install-script
      - pkg: base_packages

{% endif %}
