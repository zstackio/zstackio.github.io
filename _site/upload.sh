#!/bin/sh

cd _site
scp -i ~/zstack.pem -r * ubuntu@54.67.112.6:/var/www/html/
