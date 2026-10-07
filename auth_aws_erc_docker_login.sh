#!/usr/bin/env bash

AWS_PROFILE=""
AWS_REGION="us-east-2"
DOCKER_REGISTRY_USERNAME=""
DOCKER_REGISTRY_URL=""

# Loop through arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	  --profile=*)
	    AWS_PROFILE="${1#*=}"
	    shift
	    ;;
	  --docker-registry-username=*)
	  	DOCKER_REGISTRY_USERNAME="${1#*=}"
	  	shift
	  	;;
	  --docker-registry-url=*)
	  	DOCKER_REGISTRY_URL="${1#*=}"
	  	shift
	  	;;
	  --aws-region=*)
	  	AWS_REGION="${1#*=}"
	  	shift
	  	;;
	  *)
	    echo "Unknown option: $1"
	    exit 1
	    ;;
	esac
done

if [ "$AWS_PROFILE" = "" ]; then
	echo "AWS profile (--profile) must be set"
	exit 1
fi

if [ "$DOCKER_REGISTRY_URL" = "" ]; then
	echo "Docker registry URL (--docker-registry-url) must be set"
	exit 1
fi

if [ "$DOCKER_REGISTRY_USERNAME" = "" ]; then
	echo "Docker registry username (--docker-registry-username) must be set"
	exit 1
fi

if [ "$AWS_REGION" = "" ]; then
	echo "AWS region (--aws-region) must be set"
	exit 1
fi

update_docker_login() {
	aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username $DOCKER_REGISTRY_USERNAME --password-stdin $DOCKER_REGISTRY_URL
}

echo "Attempting to reauthenticate AWS ECR Docker registry for $DOCKER_REGISTRY_URL using profile '$AWS_PROFILE'"

output="$(update_docker_login)"

if grep -q "Token has expired and refresh failed" <<< "$output"; then
	echo "Token expired; attempting to reauthenticate with SSO"

	aws sso login --profile $AWS_PROFILE || { 
		echo "Failed to reauthenticate"
		exit 1
	}

	update_docker_login || { 
		echo "Failed to update Docker registry login"
		exit 1
	}
fi

echo "Successfully reauthenticated AWS ECR Docker registry for $DOCKER_REGISTRY_URL"
