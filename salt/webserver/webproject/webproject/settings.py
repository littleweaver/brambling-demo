"""
Django settings for webproject project.

For more information on this file, see
https://docs.djangoproject.com/en/dev/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/dev/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/dev/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '{{ pillar["deploy"]["secret_key"] }}'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

TEMPLATE_DEBUG = False

ALLOWED_HOSTS = ['*']


# Application definition

INSTALLED_APPS = (
    'brambling',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'zenaida',
    'floppyforms',
    'django_filters',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'webproject.urls'

WSGI_APPLICATION = 'webproject.wsgi.application'


# Database
# https://docs.djangoproject.com/en/dev/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '{{ pillar["connections"]["db"]["name"] }}',
        'USER': '{{ pillar["connections"]["db"]["user"] }}',
        'PASSWORD': '{{ pillar["connections"]["db"]["password"] }}',
        'HOST': '{{ pillar["connections"]["db"]["host"] }}',
        'PORT': '{{ pillar["connections"]["db"]["port"] }}',
    }
}

# Internationalization
# https://docs.djangoproject.com/en/dev/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Media files (Uploaded)
MEDIA_ROOT = '{{ pillar["files"]["media_dir"] }}'
MEDIA_URL = '/media/'


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/dev/howto/static-files/
STATIC_ROOT = '{{ pillar["files"]["static_dir"] }}'
STATIC_URL = '/static/'

from django.core.urlresolvers import reverse_lazy

LOGIN_REDIRECT_URL = '/'
LOGIN_URL = reverse_lazy('login')

AUTH_USER_MODEL = 'brambling.Person'

STRIPE_PUBLISHABLE_KEY = '{{ pillar["deploy"]["stripe_pk"] }}'
STRIPE_SECRET_KEY = '{{ pillar["deploy"]["stripe_sk"] }}'
