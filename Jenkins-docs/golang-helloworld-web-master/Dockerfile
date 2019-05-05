FROM docker.oa.com:8080/public/golang:latest

ADD . $GOPATH/src

ADD run.sh /run.sh

RUN chmod +x /run.sh

EXPOSE 80

WORKDIR $GOPATH/src

CMD ["/run.sh"]
