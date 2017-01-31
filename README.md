Multi port&ip ipv6 proxy with user auth
============
Edit container.cfg
============
- MAXCOUNT=2 - Count ipv6 addresses
- NETWORK=2a08:14c0:200:200 - ipv6 network
- EXTERNAL_IP=172.17.0.2 - External ip
- FIRSTPORT=30000 -Start port listen proxy
- USER=tetrag - username auth proxy
- PASSWORD=mysuperpass - password

Build Docker image
============
- docker build -t tetrag/ipv6-proxy .

Build configuration files
============
- ./build.sh

Edit path volumes docker-compose.yml
============
  volumes:
   - /vmsssd/3proxy/3proxy.cfg:/root/3proxy/3proxy.cfg
   - /vmsssd/3proxy/ndppd.conf:/root/ndppd/ndppd.conf
   - /vmsssd/3proxy/init.sh:/init.sh


Start with docker-compose
============
docker-compose up -d
