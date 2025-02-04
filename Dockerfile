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

# On startup, execute the build
#Pass command to build the image
RUN chmod +x ./android/build-inside-docker.sh
ENTRYPOINT ["./android/build-inside-docker.sh"]



