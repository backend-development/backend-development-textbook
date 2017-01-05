#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
    echo "Skipping deploy"
    exit 0
fi

# Save some useful information
REPO=git@github.com:backend-development/backend-development.github.io.git
SHA=`git log -1 --pretty=%h`
MESSAGE=`git log -1 --pretty=%B`
AUTHOR=`git log -1 --pretty=%an`
EMAIL=`git log -1 --pretty=%ae`
echo "will commit ${AUTHOR} <${EMAIL}>: commit ${SHA} ${MESSAGE}"
echo "to repo ${SSH_REPO}"

ENCRYPTED_KEY=$encrypted_bcc9cafb15dd_key
ENCRYPTED_IV=$encrypted_bcc9cafb15dd_iv

echo `file deploy.key.enc`
echo "openssl aes-256-cbc -K encrypted_bcc9cafb15dd_key -iv encrypted_bcc9cafb15dd_iv -in deploy.key.enc -out deploy.key -d"
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy.key.enc -out deploy.key -d

echo `file deploy.key`
chmod 600 deploy.key

echo "adding to ssh-agent"
eval `ssh-agent -s`
ssh-add deploy.key

# Clone the existing github pages into out/
echo "git clone $REPO out"
git clone $REPO out

echo "Clean out existing contents"
rm -rf out/* || exit 0

echo "Copy over results of build"
cp -a output/* out/

# Now let's go have some fun with the cloned repo
cd out
git config user.name "$AUTHOR via Travis CI"
git config user.email "$EMAIL"

echo 'Commit the "changes", i.e. the new version.'
# The delta will show diffs between new and old versions.
git add .
git commit -m "${MESSAGE} (originally ${SHA})"

# Now that we're all set up, we can push.
echo "git push origin master"
git push origin master
