#!/usr/bin/env bash

prefix=$1

echo "Stopping containers with prefix '$prefix'"
docker stop $(docker ps --all --filter name=^$prefix -q)
