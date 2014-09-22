FROM ubuntu:14.04

MAINTAINER Ukang'a Dickson

ENV CODENAME trusty
RUN echo "deb http://archive.ubuntu.com/ubuntu $CODENAME main universe" > /etc/apt/sources.list.d/universe.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $CODENAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list
ADD apt.postgresql.org.gpg /apt.postgresql.org.gpg
ENV KEYRING /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg
RUN test -e $KEYRING || touch $KEYRING
RUN apt-key --keyring $KEYRING add /apt.postgresql.org.gpg
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq python python-dev python-setuptools python-pip python-virtualenv git-core libpq-dev libproj-dev gdal-bin memcached libmemcached-dev supervisor mongodb

RUN useradd -m -d /home/ubuntu ubuntu
RUN mkdir -p /home/ubuntu/src/.virtualenvs
RUN virtualenv /home/ubuntu/src/.virtualenvs/ona

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq libxslt1-dev libjpeg-dev libfreetype6-dev zlib1g-dev default-jre nginx rabbitmq-server
RUN ln -s /usr/include/freetype2 /usr/include/freetype
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/

RUN git clone https://github.com/onaio/onadata.git /home/ubuntu/src/ona
RUN . /home/ubuntu/src/.virtualenvs/ona/bin/activate && pip install -r /home/ubuntu/src/ona/requirements/common.pip --allow-all-external
RUN . home/ubuntu/src/.virtualenvs/ona/bin/activate && pip install uwsgi

RUN apt-get install -yqq tmux
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-9.3-postgis-2.1 postgresql-9.3-postgis-script postgis
ADD context /tmp

RUN cp /tmp/etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/ona.conf
RUN rm -f /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf


RUN cp /tmp/onadata/preset/local_settings.py /home/ubuntu/src/ona/onadata/settings/local_settings.py
RUN cp /tmp/start /home/ubuntu/start
RUN chmod +x /home/ubuntu/start
RUN chown -R ubuntu:ubuntu /home/ubuntu/src/ona
RUN cp /tmp/etc/supervisor/conf.d/ona.conf /etc/supervisor/conf.d/
RUN mkdir -p /var/log/uwsgi
RUN mkdir -p /var/log/ona
RUN mkdir -p /var/log/celery
RUN echo "virtualenv=/home/ubuntu/src/.virtualenvs/ona" >> /home/ubuntu/src/ona/uwsgi.ini
RUN mkdir -p /data/postgresql/9.3/main && mkdir -p /data/db

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV DJANGO_SETTINGS_MODULE onadata.settings.common

EXPOSE 80

CMD ["/home/ubuntu/start"]
