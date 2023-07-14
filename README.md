# lightsail-proxy
## Start proxy
1. `aws lightsail start-instance --instance-name <name>`
2. Keep monitoring instance status and testing proxy connection
3. `gost -L http://:<port1> -L socks5://:<port2> -F 'wss://<name>:<password>@<domain>:<proxy port>'`

## Stop proxy
1. stop local gost service
2. stop container

## TODO


