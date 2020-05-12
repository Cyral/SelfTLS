#!/bin/bash
mkdir certs || true && cd certs || exit
echo "Input organization: (ex: Example, Inc)"
read org
echo "Input state: (ex: FL)"
read state
echo "Input host (ex: example, which will make a *.example.localhost key)"
read domain
echo "Generating Root Certifcate Authority..."
openssl genrsa -out "$domain-ca.key" 2048
openssl req -new -x509 -days 3650 -key "$domain-ca.key" -subj "/C=US/ST=$state/O=$org/CN=$org CA" -out "$domain-ca.crt"

echo "Generating certificate..."
openssl req -newkey rsa:2048 -nodes -keyout "$domain.localhost.key" -subj "/C=US/ST=$state/O=$org./CN=*.$domain.localhost" -out "$domain.localhost.csr"
openssl x509 -req -extfile <(printf "subjectAltName=DNS:*.$domain.localhost,DNS:$domain.localhost") -days 3650 -in "$domain.localhost.csr" -CA "$domain-ca.crt" -CAkey  "$domain-ca.key" -CAcreateserial -out  "$domain.localhost.crt"
cat "$domain-ca.crt" "$domain.localhost.key" > "$domain.localhost.pem"
echo "Done!"
echo "For nginx, use the .pem with ssl_certificate and the .key with ssl_certificate_key"
