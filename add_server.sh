#!/bin/sh
# generate server certificate
# to remove password use command:

# location of the common configuration
config_file="./common-ca-settings.sh"

# include common configuration
. $config_file

# read server name 
read -p "Server name (eg. mail.example.com): " cert_name

# read email address
read -p "Email: " cert_email

# certificate data
subj="/C=${cert_country}/ST=${cert_state}/O=${cert_organization}/localityName=${cert_city}/commonName=${cert_name}/organizationalUnitName=${cert_unit}/emailAddress=${cert_email}/"

# read password
stty -echo
read -p "Root certificate (private key) password: " cert_password
stty echo

echo

# read password
stty -echo
read -p "Server certificate (private key) password: " server_password
stty echo

# export passwords for openssl
export cert_password
export server_password

# generate key and certificate request
openssl req \
            -newkey rsa \
            -batch \
            -config openssl.cnf \
            -passout env:server_password \
            -subj "${subj}" \
            -keyout ${cert_directory}/private/${serial}.pem \
            -out    ${cert_directory}/requests/${serial}.pem

# generate certificate
openssl ca \
            -batch \
            -config openssl.cnf \
            -passin env:cert_password \
            -days ${client_cert_validfor} \
            -in   ${cert_directory}/requests/${serial}.pem

# copy certificate 
cp ${cert_directory}/newcerts/${serial}.pem ${cert_directory}/server_certs/${serial}.crt

# remove password from private key
openssl rsa \
            -in ${cert_directory}/private/${serial}.pem \
            -passin env:server_password \
            >> ${cert_directory}/server_certs/${serial}.pem

# unset exported passwords
unset cert_password
unset server_password


