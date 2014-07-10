FROM ubuntu

MAINTAINER Ukang'a Dickson

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq python python-dev python-setuptools python-pip python-virtualenv git-core libpq-dev libproj-dev gdal-bin memcached libmemcached-dev supervisor

RUN useradd -m -d /home/ubuntu ubuntu
RUN mkdir -p /home/ubuntu/src/.virtualenvs
RUN virtualenv /home/ubuntu/src/.virtualenvs/ona

ADD context /tmp

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq libxslt1-dev libjpeg-dev libfreetype6-dev zlib1g-dev default-jre
RUN ln -s /usr/include/freetype2 /usr/include/freetype
RUN ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/
RUN . home/ubuntu/src/.virtualenvs/ona/bin/activate && pip install uwsgi
RUN . /home/ubuntu/src/.virtualenvs/ona/bin/activate && pip install -r /tmp/requirements.pip --allow-all-external

RUN apt-get install -yqq nginx
RUN cp /tmp/etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/ona.conf
RUN rm -f /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN apt-get install -yqq rabbitmq-server

RUN git clone https://github.com/onaio/onadata.git /home/ubuntu/src/ona
RUN cp /tmp/onadata/preset/local_settings.py /home/ubuntu/src/ona/onadata/settings/local_settings.py
RUN chmod +x /home/ubuntu/src/ona/script/start
RUN chown -R ubuntu:ubuntu /home/ubuntu/src/ona
RUN ln -s /home/ubuntu/src/ona/context/etc/supervisor/conf.d/ona.conf /etc/supervisor/conf.d/
RUN mkdir -p /var/log/uwsgi
RUN mkdir -p /var/log/ona
RUN mkdir -p /var/log/celery
RUN echo "virtualenv=/home/ubuntu/src/.virtualenvs/ona" >> /home/ubuntu/src/ona/uwsgi.ini

RUN apt-get install -yqq tmux
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV DJANGO_SETTINGS_MODULE onadata.settings.common

EXPOSE 80

CMD ["/home/ubuntu/src/ona/script/start"]
