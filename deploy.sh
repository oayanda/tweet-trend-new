#!/bin/bash
kubectl apply -f deployment.yml
kubectl apply -f namespace.yml
kubectl apply -f service.yml
kubectl apply -f secret.yml
kubectl apply -f secret.yml