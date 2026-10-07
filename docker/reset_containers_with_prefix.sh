#!/usr/bin/env bash

prefix=$1

./stop_containers_with_prefix.sh $prefix
./remove_containers_with_prefix.sh $prefix

echo "Removing volumes"
docker volume rm $(docker volume ls --filter name=^$prefix -q)
