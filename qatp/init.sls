/home/{{pillar.qatp.username}}/.s3cfg:
  file:
    - managed
    - source: salt:///home/qatp/s3cfg
    - template: jinja

/home/{{pillar.qatp.username}}/.aws/config:
  file:
    - managed
    - source: salt:///home/qatp/aws_config
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
    - recurse
      - mode
