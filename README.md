# lightsail-proxy
## Start proxy
1. `aws lightsail start-instance --instance-name <name>`
2. Keep monitoring instance status and testing proxy connection
3. `gost -L http://:<port1> -L socks5://:<port2> -F 'wss://<name>:<password>@<domain>:<proxy port>'`

## Stop proxy
1. stop local gost service
2. stop container

## Deploy Startup 
1. cp config files
`cp config/proxy.service /etc/systemd/system/proxy.service`
`cp config/startup_script.sh /usr/local/bin/proxy/startup_script.sh`
`cp config/start_server.sh /usr/local/bin/proxy/start_server.sh`
2. reload & start proxy service
`sudo systemctl daemon-reload`
`sudo systemctl start proxy`
`sudo systemctl enable proxy`
`sudo systemctl status proxy` to view service status
## TODO


