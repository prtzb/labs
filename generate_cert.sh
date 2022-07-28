#!/bin/bash

# Usage:
# ./generate_cert.sh <fqdn> <ip> <number of days>
# Example:
# ./generate_cert.sh test.bla.com 192.168.8.10 365

export FQDN=$1
export IP=$2
export DAYS=$3

# Generate root cert
openssl req \
    -x509 \
    -sha256 \
    -days $DAYS \
    -nodes \
    -newkey rsa:2048 \
    -subj "/C=SE/L=Stockholm" \
    -keyout rootCA.key \
    -out rootCA.crt

# Generate key
openssl genrsa -out server.key 2048

# Generate config files
cat <<EOF | tee csr.conf
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = SE
O = Linnaeus
OU = Linnaeus Dev
CN = $FQDN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $FQDN
IP.1 = $IP

EOF

cat <<EOF | tee cert.conf
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $FQDN

EOF

# Generate csr
openssl req -new -key server.key -out server.csr -config csr.conf

# Generate cert
openssl x509 -req \
    -in server.csr \
    -CA rootCA.crt \
    -CAkey rootCA.key \
    -CAcreateserial \
    -out server.crt \
    -days $DAYS \
    -sha256 \
    -extfile cert.conf

# Cleanup
rm *.conf