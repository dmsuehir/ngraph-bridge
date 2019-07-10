#!  /bin/bash

# ==============================================================================
#  Copyright 2018-2019 Intel Corporation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# ==============================================================================

# Script environment variables:
#
# BASE_DOCKERFILE      Dockerfile to use to build the base env container
# BASE_IMAGE_NAME      Image name for the base env container
# BASE_IMAGE_TAG       Image tag for the base env container
# NGTF_DOCKERFILE      Dockerfile to use to build/install NGTF container
# NGTF_IMAGE_NAME      Image name for the NGTF container
# NGTF_IMAGE_TAG       Image tag for the NGTF container
# DIR_DOCKERFILES      Directory where the dockerfiles are located

# Set vars for the base image
BASE_DOCKERFILE='Dockerfile.ngraph_tf.build_ngtf_ubuntu1604_gcc48_py35'
BASE_IMAGE_NAME='ngraph-bridge'
BASE_IMAGE_TAG='base-ubuntu1604-gcc48-py35'

# Set vars for the ngtf image
NGTF_DOCKERFILE='Dockerfile.ngraph_tf.install_ngtf'
NGTF_IMAGE_NAME='ngraph-bridge'
NGTF_IMAGE_TAG='ngtf'

DIR_DOCKERFILES='dockerfiles'

echo "docker-build-base-and-install-ngtf is building the following:"
echo "    Base Dockerfile:             ${BASE_DOCKERFILE}"
echo "    Base Image name/tag:         ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
echo "    nGraph TF Dockerfile:        ${NGTF_DOCKERFILE}"
echo "    nGraph TF Image name/tag:    ${NGTF_IMAGE_NAME}:${NGTF_IMAGE_TAG}"

# If proxy settings are detected in the environment, make sure they are
# included on the docker-build command-line.  This mirrors a similar system
# in the Makefile.

if [ ! -z "${http_proxy}" ] ; then
    DOCKER_HTTP_PROXY="--build-arg http_proxy=${http_proxy}"
else
    DOCKER_HTTP_PROXY=' '
fi

if [ ! -z "${https_proxy}" ] ; then
    DOCKER_HTTPS_PROXY="--build-arg https_proxy=${https_proxy}"
else
    DOCKER_HTTPS_PROXY=' '
fi

# Build base docker image to get the build environment for ngraph and TF
dbuild_cmd="docker build --rm=true \
${DOCKER_HTTP_PROXY} ${DOCKER_HTTPS_PROXY} \
-f=${DIR_DOCKERFILES}/${BASE_DOCKERFILE} -t=${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} ."

echo "Docker build command for base image: ${dbuild_cmd}"
$dbuild_cmd
dbuild_result=$?

if [ $dbuild_result = 0 ] ; then
    echo ' '
    echo "Successfully created base docker image ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
else
    echo ' '
    echo "Base docker image build reported an error (exit code ${dbuild_result})"
    exit 1
fi

# Use the base docker image to then run the build_ngtf.py script and install ngraph and TF
dbuild_cmd="docker build --rm=true \
${DOCKER_HTTP_PROXY} ${DOCKER_HTTPS_PROXY} \
--build-arg base_image=${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} \
-f=${DIR_DOCKERFILES}/${NGTF_DOCKERFILE} -t=${NGTF_IMAGE_NAME}:${NGTF_IMAGE_TAG} ."

echo "Docker build command for base image: ${dbuild_cmd}"
$dbuild_cmd
dbuild_result=$?

if [ $dbuild_result = 0 ] ; then
    echo ' '
    echo "Successfully created docker image with ngtf installed: ${NGTF_IMAGE_NAME}:${NGTF_IMAGE_TAG}"
else
    echo ' '
    echo "Docker image with ngtf build reported an error (exit code ${dbuild_result})"
    exit 1
fi
