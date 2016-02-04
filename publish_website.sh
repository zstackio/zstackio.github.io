#!/bin/bash
#build zstack multiple languages website from source to web pages
# Before run this script, you need to checkout source branch to edit web site 
# and push all changes.

function exe_cmd() {
    echo $1
    eval $1
}

if [ $# -lt 1 ]; then
    echo "Usage: sh $0 [ master ]"
    exit
fi

branch=$1
if [ -z "$branch" ] || [ "$branch" != "master" ]; then
    branch='master'
fi

git checkout $branch
if [ $? -ne 0 ]; then
    echo "checkout $branch failed. Maybe you forget to commit local changes in source branch."
    exit 1
fi
git pull
git checkout source

exe_cmd "jekyll build"
if [ ! -d '_site' ];then
    echo "not content to be published"
    exit
fi

exe_cmd "git checkout $branch"
error_code=$?
if [ $error_code != 0 ];then
    echo "Switch $branch fail. You need to commit your new codes firstly to source branch."
    exit
else
    ls | grep -v _site|xargs rm -rf
    exe_cmd "/bin/cp -fr _site/* ."
    exe_cmd "rm -rf _site/"
    exe_cmd "touch .nojekyll"
fi

echo "Successfully generate website static web pages for master"
echo "----------"
echo "Next Step:"
echo " 1.'git add -A'
 2. 'git commit -a' 
 3. 'git push --all origin'
 3. 'git checkout source' for next round edit

 or do it all in one line (don't forget use right comment):

 git add -A; git commit -a -m \"THE COMMENTS NEED TO BE REPLACED\"; git push --all origin; git checkout source

"
echo "----------"
