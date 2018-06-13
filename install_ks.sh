#!/bin/bash

url="https://github.com/ksonnet/ksonnet/releases/download/v0.11.0/ks_0.11.0_linux_amd64.tar.gz"

get_ks_file()
{
	wget $url
}

