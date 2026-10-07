#!/usr/bin/env zsh

prefix=$1

echo "Removing containers starting with $prefix"
docker rm $(docker ps --all --filter name=^$prefix -q)
