from fabric.api import task, run, put, sudo, cd, env
from fabric.contrib.files import exists


env.use_ssh_config = True
REPO_URL = "https://github.com/littleweaver/dancerfly.com.git"


@task
def bootstrap_salt():
    run("curl -L https://bootstrap.saltstack.com | sudo sh -s -- git develop")


@task
def bootstrap_env():
    conf = 'salt.conf'
    put(conf, '/etc/salt/minion', use_sudo=True)
    if not exists('/srv/salt/'):
        sudo('git clone {} /srv/'.format(REPO_URL))
    else:
        with cd('/srv/'):
            sudo('git fetch')
            sudo('git reset --hard origin/master')
    put('pillar', '/srv/', use_sudo=True)


@task
def salt_call():
    sudo("salt-call --local state.highstate")


@task
def full_deploy():
    bootstrap_salt()
    bootstrap_env()
    salt_call()
