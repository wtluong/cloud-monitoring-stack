#!/bin/sh
echo "{\"ip\": \"$(curl -s ifconfig.me)/32\"}"
