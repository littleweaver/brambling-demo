include:
  - circus
  - database

app-pkgs:
  pkg.installed:
    - names:
      - git
      - python-virtualenv
      - python-dev
      - gcc
      - libjpeg8-dev
      - libpq-dev

webproject_user:
  user.present:
    - name: webproject
    - gid_from_name: True

webproject_dirs:
  file.directory:
    - user: webproject
    - group: webproject
    - makedirs: true
    - names:
      - {{ pillar['files']['root_dir'] }}
      - {{ pillar['files']['media_dir'] }}
      - {{ pillar['files']['static_dir'] }}
    - require:
      - user: webproject

webproject_env:
  virtualenv.managed:
    - name: {{ pillar['files']['env_dir'] }}
    - requirements: salt://webserver/requirements.txt
    - system_site_packages: false
    - no_deps: true
    - clear: false
    - user: webproject
    - require:
      - pkg: app-pkgs
      - user: webproject
      - file: webproject_dirs

django_log_dir:
  file.directory:
    - name: {{ pillar['files']['logs']['django_dir'] }}
    - user: webproject
    - group: webproject
    - mode: 755

webproject_project:
  file.recurse:
    - user: webproject
    - group: webproject
    - name: {{ pillar['files']['project_dir'] }}
    - source: salt://webserver/webproject/
    - template: jinja
    - require:
      - file: django_log_dir
      - virtualenv: {{ pillar['files']['env_dir'] }}
      - service: postgresql

postfix:
  pkg:
    - latest
  service:
    - running

nginx:
  user:
    - present
  pkg:
    - latest
  service:
    - running
    - watch:
      - file: nginx_site_conf
      - file: nginx_app_conf
      - file: ssl_crt
      - file: ssl_key
    - require:
        - pkg: nginx

nginx_app_conf:
  file.managed:
    - name: {{ pillar['files']['nginx_app_conf'] }}
    - source: salt://webserver/nginx.app.conf
    - template: jinja
    - makedirs: True
    - mode: 755
    - user: nginx
    - group: nginx
    - require:
      - pkg: nginx

nginx_site_conf:
  file.managed:
    - name: /etc/nginx/sites-available/default
    - source: salt://webserver/nginx.site.conf
    - template: jinja
    - makedirs: True
    - mode: 755
    - user: nginx
    - group: nginx
    - require:
      - pkg: nginx

crt_dir:
  file.directory:
    - name: {{ pillar['files']['crt_dir'] }}
    - makedirs: True
    - mode: 755
    - user: nginx
    - group: nginx
    - require:
      - pkg: nginx

ssl_crt:
  file.managed:
    - name: {{ pillar['files']['crt_dir'] }}dancerfly.crt
    - contents: |-
        {{ pillar['deploy']['ssl_crt']|indent(8) }}
    - mode: 400
    - user: nginx
    - group: nginx
    - require:
      - pkg: nginx
      - file: crt_dir

ssl_key:
  file.managed:
    - name: {{ pillar['files']['crt_dir'] }}dancerfly.key
    - contents: |-
        {{ pillar['deploy']['ssl_key']|indent(8) }}
    - mode: 400
    - user: nginx
    - group: nginx
    - require:
      - pkg: nginx
      - file: crt_dir

eventlet:
  pip.installed:
    - bin_env: {{ pillar['files']['env_dir'] }}
    - user: webproject
    - require:
      - virtualenv: webproject_env

gunicorn:
  pip.installed:
    - name: gunicorn==19.1.1
    - bin_env: {{ pillar['files']['env_dir'] }}
    - user: webproject
    - require:
      - virtualenv: webproject_env
      - pip: eventlet

gunicorn_log:
  file.managed:
    - name: {{ pillar['files']['logs']['gunicorn'] }}
    - user: webproject
    - group: webproject
    - mode: 644
    - require:
      - pip: gunicorn

gunicorn_circus:
  file.managed:
    - name: /etc/circus.d/gunicorn.ini
    - source: salt://webserver/gunicorn.ini
    - makedirs: True
    - template: jinja
    - require:
      - file: gunicorn_log
      - user: webproject_user
      - virtualenv: webproject_env
    - watch_in:
      - service: circusd
  cmd.wait:
    - name: circusctl restart gunicorn
    - watch:
      - file: webproject_project
      - file: gunicorn_circus
      - virtualenv: webproject_env
    - require:
      - service: circusd

gunicorn_circus_start:
  cmd.run:
    - name: circusctl start gunicorn
    - require:
      - file: webproject_project
      - file: gunicorn_circus
      - virtualenv: webproject_env
    - onlyif: "[ `circusctl status gunicorn` == 'stopped' ]"


collectstatic:
  cmd.wait:
    - name: {{ pillar['files']['env_dir'] }}bin/python {{ pillar['files']['project_dir'] }}manage.py collectstatic --noinput
    - user: webproject
    - watch:
      - file: webproject_project
      - virtualenv: webproject_env
    - require:
      - postgres_database: webproject_db
      - user: webproject_user

migrate:
  cmd.wait:
    - name: {{ pillar['files']['env_dir'] }}bin/python {{ pillar['files']['project_dir'] }}manage.py migrate --noinput
    - user: webproject
    - watch:
      - file: webproject_project
      - virtualenv: webproject_env
    - require:
      - postgres_database: webproject_db
      - user: webproject_user
