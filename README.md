Multi port&ip ipv6 proxy with user auth
============
Configuration edit container.cfg
============
- MAXCOUNT=2 - Count ipv6 addresses
- NETWORK=2a08:14c0:200:200 - ipv6 network
- EXTERNAL_IP=172.17.0.2 - External ip
- FIRSTPORT=30000 -Start port listen proxy
- USER=tetrag - username auth proxy
- PASSWORD=mysuperpass - password
Build Docker image
============
- docker build -t ipv6proxy .

Build configuration files
============
- ./build.sh
