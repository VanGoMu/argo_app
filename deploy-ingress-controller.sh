#!/usr/bin/env bash

helm upgrade ingress-nginx ingress-nginx/ingress-nginx \         
  --namespace ingress-nginx \
  --create-namespace \
  --values ingress-controller/values.yaml