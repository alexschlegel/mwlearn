"""
Django settings for mwlearn project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

import platform
import os

from django.conf.global_settings import TEMPLATE_CONTEXT_PROCESSORS, \
	STATICFILES_FINDERS

#set some stuff based on where we are
ME_DEV = 'grendel'
ME_TEST = 'fechner'
ME = platform.node()

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(__file__))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '*$v$xq7d)e!-&2589*f4y!^t!&ep$#-te+ans7h2n27yivp9(m'

# SECURITY WARNING: don't run with debug turned on in production!
if ME == ME_DEV:
	DEBUG = True
else:
	DEBUG = False

TEMPLATE_DEBUG = DEBUG

ALLOWED_HOSTS = [
	'fechner.dartmouth.edu',
	'localhost',
]

TEMPLATE_DIRS = [os.path.join(BASE_DIR, 'templates')]

# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
	'south',
	'compressor',
#	'djangobower',
    'mwlearnapp',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'mwlearn.urls'

WSGI_APPLICATION = 'mwlearn.wsgi.application'


TEMPLATE_CONTEXT_PROCESSORS += (
	'django.core.context_processors.request',
)


# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

if ME == ME_DEV:
	DB_USER = 'alex'
elif ME == ME_TEST:
	DB_USER = 'tselab'
else:
	raise Exception('Where am I?')

DATABASES = {
    'default': {
		'ENGINE': 'django.db.backends.postgresql_psycopg2',
		'NAME': 'mwlearn',
		'USER': DB_USER,
		'PASSWORD': '0ecky68ecky5',
		'HOST': '127.0.0.1',
		'PORT': '5432'
	}
}

# Auth

AUTH_USER_MODEL = 'auth.User'

LOGIN_URL = 'account-login'
LOGIN_REDIRECT_URL = 'experiment'
LOGOUT_URL = 'account-logout'

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_URL = '/static/'

STATICFILES_FINDERS += (
	'compressor.finders.CompressorFinder',
	#i'm just using bower to have the sources to look at 'djangobower.finders.BowerFinder',
)

# compressor

COMPRESS_PRECOMPILERS = (
	('text/x-sass', 'sass "{infile}" "{outfile}"'),
	('text/x-scss', 'sass --scss --compass "{infile}" "{outfile}"'),
	('text/coffeescript', 'coffee --compile --stdio'),
)

COMPRESS_CSS_FILTERS = (
	'compressor.filters.css_default.CssAbsoluteFilter',
	'compressor.filters.cssmin.CSSMinFilter',
)

COMPRESS_JS_FILTERS = (
	'compressor.filters.jsmin.JSMinFilter',
)

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True
