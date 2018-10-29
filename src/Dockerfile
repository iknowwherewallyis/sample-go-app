FROM golang:latest
RUN mkdir /go/src/app
ADD . /go/src/app/
WORKDIR /go/src/app
RUN go build -o main .
CMD ["/go/src/app/main"]