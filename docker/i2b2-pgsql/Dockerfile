FROM  image_tag

RUN apt-get install && \
    apt-get install -y supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["supervisord"]