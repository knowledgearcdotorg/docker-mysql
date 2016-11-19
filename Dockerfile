FROM ubuntu:16.04
MAINTAINER development@knowledgearc.com

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update

RUN apt-get upgrade -y && \
    apt-get install -y mysql-server supervisor && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/mysqld
RUN chown mysql:mysql /var/run/mysqld

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /usr/local/bin/
RUN chmod 750 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

VOLUME /var/lib/mysql

EXPOSE 3306

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
