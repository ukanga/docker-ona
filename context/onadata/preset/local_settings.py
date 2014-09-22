from onadata.settings.common import *  # noqa

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ALLOWED_HOSTS = [
    'localhost',
    'ukw530',
    'app_servers',
]

SITE_READ_ONLY = False
DB_READ_ONLY_MIDDLEWARE_MESSAGE = True

DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': 'onadata',
        'USER': 'onadata',
        'PASSWORD': 'onadata',
        'HOST': '127.0.0.1',
        'OPTIONS': {
            'autocommit': True,
        }
    }
}

SECRET_KEY = 'y>7Tn;e&:s6tHJ6D5`*?8*NMg.Tkbv'

MONGO_DATABASE = {
    'HOST': '127.0.0.1',
    'PORT': 27017,
    'NAME': 'onadata',
}

# celery
BROKER_BACKEND = "rabbitmq"
BROKER_URL = 'amqp://guest:guest@127.0.0.1:5672/'
CELERY_RESULT_BACKEND = "amqp"  # telling Celery to report results to RabbitMQ
CELERY_ALWAYS_EAGER = True

EMAIL_BACKEND = 'django_ses.SESBackend'
DEFAULT_FROM_EMAIL = 'noreply@ona.io'
SERVER_EMAIL = DEFAULT_FROM_EMAIL

AWS_STORAGE_BUCKET_NAME = ''
AWS_DEFAULT_ACL = 'private'

TESTING_MODE = False
if len(sys.argv) >= 2 and (sys.argv[1] == "test" or sys.argv[1] == "test_all"):
    # This trick works only when we run tests from the command line.
    TESTING_MODE = True
else:
    TESTING_MODE = False

if TESTING_MODE:
    MEDIA_ROOT = os.path.join(PROJECT_ROOT, 'test_media/')
    subprocess.call(["rm", "-r", MEDIA_ROOT])
    MONGO_DATABASE['NAME'] = "formhub_test"
    # need to have CELERY_ALWAYS_EAGER True and BROKER_BACKEND as memory
    # to run tasks immediately while testing
    CELERY_ALWAYS_EAGER = True
    BROKER_BACKEND = 'memory'
    ENKETO_API_TOKEN = 'abc'
    # TEST_RUNNER = 'djcelery.contrib.test_runner.CeleryTestSuiteRunner'
else:
    MEDIA_ROOT = os.path.join(PROJECT_ROOT, 'media/')
    ENKETO_URL = 'https://enketo.org/'
    ENKETO_PREVIEW_URL = ENKETO_URL + 'webform/preview'
    ENKETO_API_INSTANCE_IFRAME_URL = ENKETO_URL + 'api_v1/instance/iframe'
    ENKETO_API_TOKEN = ''

if PRINT_EXCEPTION and DEBUG:
    MIDDLEWARE_CLASSES += ('utils.middleware.ExceptionLoggingMiddleware',)


# MongoDB
if MONGO_DATABASE.get('USER') and MONGO_DATABASE.get('PASSWORD'):
    MONGO_CONNECTION_URL = (
        "mongodb://%(USER)s:%(PASSWORD)s@%(HOST)s:%(PORT)s") % MONGO_DATABASE
else:
    MONGO_CONNECTION_URL = "mongodb://%(HOST)s:%(PORT)s" % MONGO_DATABASE

MONGO_CONNECTION = MongoClient(
    MONGO_CONNECTION_URL, safe=True, j=True, tz_aware=True)
MONGO_DB = MONGO_CONNECTION[MONGO_DATABASE['NAME']]

# Clear out the test database
if TESTING_MODE:
    MONGO_DB.instances.drop()

import logging
south_logger = logging.getLogger('south')
south_logger.setLevel(logging.INFO)
SOUTH_TESTS_MIGRATE = False
