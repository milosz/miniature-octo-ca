#!/bin/sh
# generate root certificate for Certificate Authority 

# location of the common configuration
config_file="./common-ca-settings.sh"

# include common configuration
. $config_file

# do not overwrite root ca
if [ -f "${cert_directory}/ca/root-cert.pem" ]; then
  echo "Root certificate already exists"
  exit
fi

# read password
stty -echo
read -p "Root certificate (private key) password: " cert_password
stty echo

# export password for openssl
export cert_password

# certificate data
subj="/C=${cert_country}/ST=${cert_state}/O=${cert_organization}/localityName=${cert_city}/commonName=${cert_name}/organizationalUnitName=${cert_unit}/emailAddress=${cert_email}/"

openssl req \
            -new   \
            -x509  \
            -batch \
            -days    $cert_validfor    \
            -config  openssl.cnf       \
            -passout env:cert_password \
            -subj    "${subj}"         \
            -out     ${cert_directory}/ca/root-cert.pem \
            -keyout  ${cert_directory}/ca/root-key.pem

# unset certificate password
unset cert_password



