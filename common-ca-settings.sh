#!/bin/sh
# common CA settings 

# simple protection - every script can be executed only from current directory
if [ "$(pwd)" != "$(dirname $(readlink -f  $0))" ]; then
  echo "Do not run CA scripts from outside of $(dirname $(readlink -f  $0)) directory"
  exit
fi

# ensure proper permissions by setting umask
umask 077

# kolab secret
# use 'openssl rand -hex 16' command to generate it
kolab_secret="d2d97d097eedb397edea79f52b56ea74"

# key length
key_length=4096

# certificates directory
cert_directory="root-ca"

# number of days to certify the certificate
cert_validfor=3650        # root   certificate
client_cert_validfor=365  # client certificate
server_cert_validfor=365  # server certificate

# default certificate settings
cert_country="PL"
cert_organization="example.org"
cert_state="state"
cert_city="city"
cert_name="example.org CA"
cert_unit="Certificate Authority"
cert_email=""

# certificate number
if [ -f "${cert_directory}/serial" ]; then
  serial=$(cat ${cert_directory}/serial)
fi
