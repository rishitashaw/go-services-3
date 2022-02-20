package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
)

var build = "Develop"

func main() {
	log.Println("starting service rishita shaw", build)
	defer log.Println("stopping service")

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown

	log.Println("stopping service")
}

// look for lib