# Indicates the log level the app will use when started.
# <4=INFO
#  4=DEBUG
#  5=TRACE
VERBOSE_MODE ?= 4

DOCKER_NAME ?= aljesusg/open-charade
DOCKER_VERSION ?= dev
DOCKER_TAG = ${DOCKER_NAME}:${DOCKER_VERSION}

# Declares the namespace where the objects are to be deployed.
# For OpenShift, this is the name of the project.
NAMESPACE ?= open-charade

docker-build:
	@echo Building docker image into local docker daemon...
	rm -rf _output
	mkdir -p _output/docker
	docker build -t ${DOCKER_TAG} .

.openshift-validate:
	@oc get project ${NAMESPACE} > /dev/null

openshift-deploy: openshift-undeploy
	@if ! which envsubst > /dev/null 2>&1; then echo "You are missing 'envsubst'. Please install it and retry. If on MacOS, you can get this by installing the gettext package"; exit 1; fi
	@echo Deploying to OpenShift project ${NAMESPACE}
	oc create -f deploy/openshift/open-charade-configmap.yaml -n ${NAMESPACE}
	cat deploy/openshift/open-charade.yaml | IMAGE_NAME=${DOCKER_NAME} IMAGE_VERSION=${DOCKER_VERSION} NAMESPACE=${NAMESPACE} VERBOSE_MODE=${VERBOSE_MODE} envsubst | oc create -n ${NAMESPACE} -f -

openshift-undeploy: .openshift-validate
	@echo Undeploying from OpenShift project ${NAMESPACE}
	oc delete all,secrets,sa,templates,configmaps,deployments,clusterroles,clusterrolebindings --selector=app=open-charade -n ${NAMESPACE}

openshift-reload-image: .openshift-validate
	@echo Refreshing image in OpenShift project ${NAMESPACE}
	oc delete pod --selector=app=open-charade -n ${NAMESPACE}

