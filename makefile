SHELL := /bin/bash

run:
	go run main.go

build:
	go build main.go -ldflags "-X main.build=${BUILD_REF}"