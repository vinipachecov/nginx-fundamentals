FROM ubuntu:latest

COPY ./updates.sh /home/updates.sh
COPY ./install-nginx.sh /home/install-nginx.sh
RUN chmod +x /home/updates.sh
RUN chmod +x /home/install-nginx.sh
ENV LANG en_US.utf8
RUN su
RUN ./home/updates.sh


#  docker run -d -t -p 80:80 myubuntu
