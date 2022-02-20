SHELL := /bin/bash

run:
	go run main.go

# Building containers

# $(shell git rev-parse --short HEAD)
VERSION := 1.0

all: service

service:
	docker build \
		-f zarf/docker/dockerfile \
		-t service-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

KIND_CLUSTER := theseregrets-service-cluster

kind-up:
	kind create cluster \
		--image kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=service-system

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-load:
	kind load docker-image service-amd64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	cat build zarf/k8s/base/service-pod/base-service.yaml | kubectl apply -f -

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces


kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100

kind-restart:
	kubectl rollout restart deployment service-pod


kind-update: all kind-load kind-restart

kind-describe:
	kubectl describe nodes
	kubectl describe svc
	kubectl describe pod -l app=service