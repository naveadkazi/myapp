# syntax=docker/dockerfile:1
FROM reactnativecommunity/react-native-android:v15.0

# set a working directory for andoid app
WORKDIR /android-app

#Copy dependency files and install, since that
# allows Docker to cache this step if package.json did not change
COPY package.json .
COPY package-lock.json .
RUN npm install

# Add code files (.dockerignore files will not be copied)
COPY . .


COPY <<-EOT /entrypoint.sh
#!/bin/bash
chmod +x ./android/build-inside-docker.sh
./android/build-inside-docker.sh "\$@"
if [ "\${DEBUG}" = "true" ]; then
    exec /bin/bash
else
    exit $?
fi
EOT

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bundleRelease"]

# Run and exit (CI/CD)
# docker run android-builder assembleRelease

# Run and keep container for debugging
# docker run -it -e DEBUG=true android-builder assembleRelease