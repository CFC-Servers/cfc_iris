#!/bin/bash

REPO="CFC-Servers/cfc_iris_frontend"
REPO_LINK="https://github.com/$REPO.git"
CONTENT_URL="https://github.com/$REPO/releases/latest/download/built-site.tar.bz2"

CURRENT_VERSION=`cat public/frontend/VERSION`
LATEST_VERSION=`git ls-remote --refs --sort='version:refname' --tags $REPO_LINK | cut -d/ -f3-|tail -n1`

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "Static site content is out of date ($CURRENT_VERSION vs. $LATEST_VERSION), downloading latest release..."

  CONTENT_DIR="public/frontend"
  SITE_PACKAGE="$CONTENT_DIR/site.tar.bz2"

  rm -rf "$CONTENT_DIR/*"

  curl --silent --show-error --location "$CONTENT_URL" --output "$SITE_PACKAGE"
  tar --directory "$CONTENT_DIR/" --extract --bunzip2 --file "$SITE_PACKAGE"
  rm "$SITE_PACKAGE"
fi
