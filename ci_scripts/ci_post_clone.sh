#!/bin/sh

# Get GoogleService-Info.plist and Info.plist file from the private repo
git clone --depth 1 $SINGFACT_PRIVATE_REPO $TMPDIR/SingFact

cp -r $TMPDIR/SingFact $CI_PRIMARY_REPOSITORY_PATH/
