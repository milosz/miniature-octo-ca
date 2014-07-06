#!/bin/sh
# generate client certificate

# location of the common configuration
config_file="./common-ca-settings.sh"

# include common configuration
. $config_file

# read user name 
echo -n "User name (eg. John Doe): "
read cert_name

# read email address
echo -n "Email: "
read cert_email

# read export password
echo -n "Export password: "
stty -echo
read export_password
stty echo

echo

# read and encrypt kolab password
echo -n "Kolab password: "
stty -echo
read kolab_password
stty echo

echo

# read root ca (private key) password
stty -echo
read -p "Root certificate (private key) password: " cert_password
stty echo

echo

# read client certificate (private key) password
stty -echo
read -p "Client certificate (private key) password: " client_password
stty echo

# define IV (initialization vector)
kolab_iv=$(openssl rand -hex 16)

# encrypt kolab password
kolab_password=$(echo "$kolab_password" | openssl enc -aes-128-cbc -a -e -K "${kolab_secret}" -iv "${kolab_iv}")

# certificate subject
subj="/C=${cert_country}/ST=${cert_state}/O=${cert_organization}/localityName=${cert_city}/commonName=${cert_name}/organizationalUnitName=${cert_unit}/emailAddress=${cert_email}/kolabPasswordEnc=${kolab_password}/kolabPasswordIV=${kolab_iv}/"

# export passwords for openssl
export cert_password
export client_password
export export_password

# generate key and certificate request
openssl req \
            -newkey rsa                  \
            -batch                       \
            -config openssl.cnf          \
            -passout env:client_password \
            -subj "${subj}"              \
            -keyout ${cert_directory}/private/${serial}.pem \
            -out    ${cert_directory}/requests/${serial}.pem

# generate certificate
openssl ca \
            -batch                        \
            -config openssl.cnf           \
            -passin env:cert_password     \
            -days ${client_cert_validfor} \
            -in   ${cert_directory}/requests/${serial}.pem

# export certificate
openssl pkcs12 -export                      \
               -clcerts                     \
               -passin  env:client_password \
               -passout env:export_password \
               -in    ${cert_directory}/newcerts/${serial}.pem \
               -inkey ${cert_directory}/private/${serial}.pem  \
               -out   ${cert_directory}/client_certs/${serial}.p12

# unset exported passwords
unset cert_password
unset client_password
unset export_password
