echo '===== Create intermediate pair ======='  
mypass=123456
cd ./intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > ./crlnumber
# curl https://jamielinux.com/docs/openssl-certificate-authority/_downloads/intermediate-config.txt > openssl.cnf

cd ..

openssl genrsa -aes256 \
      -passout pass:$mypass \
      -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

openssl req -config intermediate/openssl.cnf -new -sha256 \
	-passin pass:$mypass \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem \
	-subj '/C=TH/postalCode=10110/ST=Bangkok/L=Klongtoey/O=BEC World PCL/OU=Certificate Department/CN=BEC World PCL intermediate CA/emailAddress=phanuphong@thaitv3.com'


openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
	-passin pass:$mypass \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

openssl x509 -noout -text \
      -in intermediate/certs/intermediate.cert.pem

openssl verify -CAfile certs/ca.cert.pem \
      intermediate/certs/intermediate.cert.pem

# create certificate chain
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem
