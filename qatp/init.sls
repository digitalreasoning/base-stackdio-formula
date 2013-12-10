/home/{{pillar.qatp.username}}/.s3cfg:
  file:
    - managed
    - source: salt://qatp/home/s3cfg
    - template: jinja

/home/{{pillar.qatp.username}}/.aws/config:
  file:
    - managed
    - source: salt://qatp/home/aws_config
    - template: jinja

base_packages:
  pkg:
    - installed
    - pkgs: 
      - s3cmd
      - screen

aws-cli:
  pip.installed:
    - name: awscli==1.0.0

/mnt:
  file:
    - directory 
    - mode: 777

fix_tty:
  cmd:
    - run
    - name: "sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers"
    - user: root
