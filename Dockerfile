FROM knowledgearcdotorg/supervisor
MAINTAINER development@knowledgearc.com

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update

RUN apt-get upgrade -y && \
    apt-get install -y mysql-server && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN rm -Rf /var/lib/mysql

RUN mkdir /var/run/mysqld
RUN chown mysql:mysql /var/run/mysqld

COPY supervisord/mysql.conf /etc/supervisor/conf.d/mysql.conf

COPY entrypoint.sh /usr/local/bin/
RUN chmod 750 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN sed \
    -i.orig \
    -e s/bind-address/#\ bind-address/g \
    /etc/mysql/mysql.conf.d/mysqld.cnf

EXPOSE 3306

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
