FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get clean

RUN mkdir /var/run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
