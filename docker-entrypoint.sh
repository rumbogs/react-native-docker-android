#!/bin/sh

# Set Github creds for auth
echo "https://${GH_USER}:${GH_TOKEN}@github.com" > /root/.git-credentials

# Copy the mounted tmp volume into the correct file
cp yarn.lock.tmp yarn.lock

# Replace ssh with https so that auth works
# Setting up ssh inside the container is more difficult and less secure
sed -i 's|ssh://git@github.com|https://github.com|g' yarn.lock

# Remove dev dependencies from package.json since there's a bug in yarn where it installs everthing
awk '/},/ { p = 0 } { if (!p) { print $0 } } /"devDependencies":/ { p = 1 }' package.json.tmp > package.json

# Install packages and ignore scripts for now
yarn install --prod --frozen-lockfile --ignore-scripts

# Apply package patches
yarn patch-package

# Run jetify globally
npx jetify

cd android

# Build Android
./gradlew assembleDocker --no-watch-fs -Dorg.gradle.jvmargs="-Xmx2048m -XX:MaxMetaspaceSize=512m" --debug

