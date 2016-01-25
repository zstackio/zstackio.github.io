#!/bin/bash

which gem > /dev/null

if [ $? -ne 0 ]; then
    echo "please install gem. For CentOS/Redhat, run 'yum -y install gem'"
    exit 1
fi

set -e
gem install jekyll -v 2.5.3
gem install rdiscount -v 2.1.8
gem install jekyll-multiple-language -v 1.0.8
gem install jekyll-multiple-languages-plugin -v 1.2.9
gem install jekyll-paginate -v 1.1.0


#jekyll (2.5.3)
#jekyll-coffeescript (1.0.1)
#jekyll-gist (1.3.4)
#jekyll-multiple-languages (1.0.8)
#jekyll-multiple-languages-plugin (1.2.9)
#jekyll-paginate (1.1.0)
#jekyll-sass-converter (1.3.0)
#jekyll-watch (1.2.1)
