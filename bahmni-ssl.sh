#! /bin/bash

##########################################
##    Steps tnvolved in creating SSL    ##
## 1. Become a CA                       ##
## 2. Sign your certificate using your  ##
##    CA (Cert + Key)                   ##
## 3. Import the CA as a trusted        ##
##    authority inside your browser.    ##
## 4. Use domain.crt and domain.key     ##
##    files in your server config.      ##
##    (Eg. /etc/httpd/conf.d/ssl.conf)  ## 
##########################################



##########################################
##         Certificates Variables       ##
##########################################
SSL_DIR="/home/nepalehr/ssl"
SSL_DOMAIN="stidh.ehr"
SSL_CA="ehr_ca"
SSL_PASS="3hr@T3ku002"

SERVER_IP="192.168.1.221"
VALID_DAYS=3650

##########################################
##     Get Confirmation on runtime      ##
##########################################
get_confirmation() {
    read -p "$1" res

    while true
    do
        if [["$res" == [yY]] || ["$res" == [yY][eE][sS]]]; then
            return 0
        elif [["$res" == [nN]] || ["$res"] == [nN][oO]]; then
            return 1
        fi
    done
}

##########################################
## Visual Flair to allow user to cancel ##
##########################################
start_countdown() {
    sleep 1
    printf "3.."
    sleep 1
    printf "2.."
    sleep 1
    printf "1..\n"
}

##########################################
##        Biconditional Messages        ##
##########################################
condn_message() {
    if [ $1 -eq 0 ]; then
        echo "[SUCCESS] Successfully generated $2."
    else
        echo "[ERROR] Failed creating $2."
    fi
}

##########################################
##   Starting certificate generations   ##
##########################################
if [ -d "$SSL_DIR" ]
then
    valid="true"

    # Tesing if the ssl files exist the directory
    files=("$SSL_CA.key" "$SSL_CA.pem" "$SSL_CA.srl" "$SSL_DOMAIN.crt" "$SSL_DOMAIN.csr" "$SSL_DOMAIN.ext" "$SSL_DOMAIN.key")
    for file in "${files[@]}"; do
        if [ ! -f "$SSL_DIR/$file" ]; then
            valid="false"
            break
        fi
    done

    if [ "$valid" == "true" ]; then
        get_confirmation "SSL files exist in the directory. Wanna overrite? [Y/N]:: "
        resp=$?

        if [ $resp -eq 1 ]; then
            echo "[EXIT] Got it! Exiting..."
            exit 0
        else
            echo "[INFO] Proceeding with overwrite..."
            start_countdown
        fi
    else
        printf "[WARNING] Directory is either empty or incomplete. Proceeding with script, press [CTRL + C] to stop..."
        start_countdown
    fi

    # Deleting SSL Directory
    rm -rf "$SSL_DIR"
fi

# Creating SSL Directory
mkdir "$SSL_DIR"

# Moving to SSL Directory
cd "$SSL_DIR"


# Time to generate some certificates
echo "[INFO] Generating SSL certifictes inside $SSL_DIR."

##########################################
##         Generating Private Key       ##
##########################################
echo "[INFO] Generating private key for server:: $SSL_CA.key"
openssl genrsa -des3 -passout pass:"$SSL_PASS" -out "$SSL_CA.key" 2048
condn_message $?, "Private Key"

##########################################
##      Generating Root Certificate     ##
##########################################
openssl req -x509 -new -nodes -key "$SSL_CA.key" -passin pass:"$SSL_PASS"\
 -passout pass:"$SSL_PASS" -sha256 -days 825 -out "$SSL_CA.pem"

##########################################
## Generating Certificates signed by CA ##
##########################################
openssl genrsa -out "$SSL_DOMAIN.key" 2048

##########################################
##     Creating a signing request       ##
##########################################
openssl req -new -key "$SSL_DOMAIN.key" -out "$SSL_DOMAIN.csr"

##########################################
##    Creating config for extensions    ##
##########################################
>$SSL_DOMAIN.ext cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:false
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=@alt_names
[alt_names]
DNS.1=$SSL_DOMAIN
DNS.2=web.$SSL_DOMAIN
DNS.3=elis.$SSL_DOMAIN
DNS.4=odoo.$SSL_DOMAIN
IP.1=$SERVER_IP
EOF

##########################################
##     Generate Signed Certificate      ##
##########################################
openssl x509 -req -in "$SSL_DOMAIN.csr" -CA "$SSL_CA.pem" -CAkey "$SSL_CA.key"\
 -CAcreateserial -out "$SSL_DOMAIN.crt" -passin pass:"$SSL_PASS" -passout pass:"$SSL_PASS"\
 -days "$VALID_DAYS" -sha256 -extfile "$SSL_DOMAIN.ext"