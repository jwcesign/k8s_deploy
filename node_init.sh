#!/bin/bash

master_id=""
node_name="node"

get_ip()
{
	host_ip=`ip addr | grep "global eth0" | awk '{print $2}' | awk -F '/' '{print $1}'`
}