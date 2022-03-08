echo "Autoconfiguring dockerized VPN server by nett00n's fork of kylemanna/docker-openvpn"
echo "https://github.com/nett00n/dockerized_ovpn"
docker-compose build 2>&1
test "$?" -ne "0" && echo "docker build stage is failed"
test -f ./data/pki/private/ca.key && echo "server is already configured. If you want to reinitialise, delete data directory." && exit 0
test -s .env && . .env
test -z "${VPNServerName}" && VPNServerName="$(wget -qO - api.ipify.org)"
echo "Public name of server is $VPNServerName"
docker-compose run server ovpn_genconfig -u udp://${VPNServerName}
docker-compose run server ovpn_initpki nopass
docker-compose up -d
