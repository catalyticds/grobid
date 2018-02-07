#!/usr/bin/env bash

# Env vars you may want to set:
# GROBID_LOG_LEVEL (self-explanatory, default=ERROR)
# GROBID_LOG_DIR (ditto, default=/var/log/grobid)
# GROBID_BASE_DIR (where all grobid code, models, etc.
#    will be installed, default=/home/ubuntu/grobid).
# GROBID_VERSION (which zipped version to pull down 
#    from the repository, default=0.5.1).
# GROBID_PORT (port for PDF processing requests, default=8070)
# GROBID_ADMIN_PORT (port for admin functions, default=8071)

if [[ -z "${GROBID_LOG_LEVEL}" ]]
then
    GROBID_LOG_LEVEL=ERROR
fi

# No spaces here, please.
if [[ -z "${GROBID_LOG_DIR}" ]]
then
    GROBID_LOG_DIR=/var/log/grobid
fi

if [[ ! -d "${GROBID_LOG_DIR}" ]]
then
    mkdir -p "${GROBID_LOG_DIR}"
fi

# No spaces here, please.
if [[ -z "${GROBID_BASE_DIR}" ]]
then
    GROBID_BASE_DIR=/home/ubuntu/grobid
fi

if [[ ! -d "${GROBID_BASE_DIR}" ]]
then
    mkdir -p "${GROBID_BASE_DIR}"
fi

if [[ -z "${GROBID_VERSION}" ]]
then
    GROBID_VERSION="0.5.1"
fi

if [[ -z "${GROBID_PORT}" ]]
then
    GROBID_PORT=8070
fi

if [[ -z "${GROBID_ADMIN_PORT}" ]]
then
    GROBID_ADMIN_PORT=8071
fi

CONFIG_FILE="${GROBID_BASE_DIR}/grobid-service-config.yaml"

# Create a custom config file (with full paths)
# using these env vars.  (There has to be a better way...)
echo "
grobid:
  # NOTE: change these values to absolute paths when running on production
  grobidHome: \"${GROBID_BASE_DIR}/grobid-${GROBID_VERSION}/grobid-home\"
  grobidServiceProperties: \"${GROBID_BASE_DIR}/grobid-${GROBID_VERSION}/grobid-service/src/main/conf/grobid_service.properties\"

server:
    type: custom
    applicationConnectors:
    - type: http
      port: 8070
    adminConnectors:
    - type: http
      port: 8071
    registerDefaultExceptionMappers: false


logging:
  level: ${GROBID_LOG_LEVEL}
  loggers:
    org.apache.pdfbox.pdmodel.font.PDSimpleFont: \"OFF\"
  appenders:
    - type: console
      threshold: ALL
      timeZone: UTC
    - type: file
      currentLogFilename: ${GROBID_LOG_DIR}/grobid-service.log
      threshold: ALL
      archive: true
      archivedLogFilenamePattern: ${GROBID_LOG_DIR}/grobid-service-%d.log
      archivedFileCount: 5
      timeZone: UTC
" > $CONFIG_FILE

# Get and set up the grobid service.
cd ${GROBID_BASE_DIR}

if [[ ! -d grobid-${GROBID_VERSION} ]]
then  
    wget https://github.com/catalyticds/grobid/archive/${GROBID_VERSION}.zip
    unzip ${GROBID_VERSION}
fi

cd grobid-${GROBID_VERSION}
cp $CONFIG_FILE ./grobid-service/config/config.yaml
