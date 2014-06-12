g++:
  pkg.installed

pyzmq:
  pip.installed:
    - name: pyzmq==13.1.0

circus:
  pip.installed:
    - name: circus
    - require:
      - pip: pyzmq
      - pkg: g++

circus_upstart:
  file.managed:
    - name: /etc/init/circusd.conf
    - source: salt://circus/circusd.conf

circus_conf:
  file.managed:
    - name: /etc/circus.ini
    - source: salt://circus/circus.ini

circus_dir:
  file.directory:
    - name: /etc/circus.d

circusd:
  service:
    - running
    - require:
      - file: circus_upstart
      - file: circus_dir
      - pip: circus
