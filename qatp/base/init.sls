#
# Setup AWS credentials and tools
# 
/home/{{pillar.qatp.username}}/.s3cfg:
  file:
    - managed
    - makedirs: true
    - source: salt://qatp/home/s3cfg
    - template: jinja
    - user: {{pillar.qatp.username}}
    - group: {{pillar.qatp.username}}
    - mode: 755

/home/{{pillar.qatp.username}}/.aws/config:
  file:
    - managed
    - makedirs: true
    - source: salt://qatp/home/aws_config
    - template: jinja
    - user: {{pillar.qatp.username}}
    - group: {{pillar.qatp.username}}
    - mode: 755
    - makedirs: true

base_packages:
  pkg:
    - installed
    - pkgs: 
      - s3cmd
      - screen
      - createrepo
      - ntp
      - zsh
      - sysstat

aws-cli:
  pip.installed:
    - name: awscli==1.0.0

#
# Some default files
#
/home/{{pillar.qatp.username}}/.vimrc:
  file:
    - managed
    - makedirs: true
    - source: salt://qatp/home/vimrc
    - user: {{pillar.qatp.username}}
    - group: {{pillar.qatp.username}}
    - mode: 755

/home/{{pillar.qatp.username}}/.bashrc:
  file:
    - append
    - template: jinja
    - mode: 755
    - sources: 
      - salt://qatp/home/bashrc

/home/{{pillar.qatp.username}}/.ssh/authorized_keys:
  file:
    - append 
    - template: jinja
    - mode: 755
    - makedirs: true
    - sources: 
      - salt://qatp/home/authorized_keys

# 
# Set a variety of system configuration and permissions
#
/mnt:
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
      - salt://qatp/etc/sysctl.conf

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
      - salt://qatp/etc/pam.d/su

/etc/security/limits.conf:
  file:
    - append
    - template: jinja
    - sources:
      - salt://qatp/etc/security/limits.conf

