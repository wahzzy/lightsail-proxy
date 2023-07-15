#!/bin/bash

# Check if the container exists
if [ "$(sudo docker ps -a -q -f name=gost-warp)" ]; then
  echo "Container exists: gost-warp"
  sudo docker start gost-warp
else
  echo "Container does not exist: gost-warp"
  bash ./start_server.sh
fi