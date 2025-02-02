FROM reactnativecommunity/react-native-android:v15.0

#ARG VERSION_NAME

WORKDIR /android-app

#Copy dependency files and install
COPY package.json .
COPY package-lock.json .
RUN npm install

# Add code files
COPY . .

# On startup, execute the build
RUN chmod +x ./android/build-inside-docker.sh
ENTRYPOINT ["./android/build-inside-docker.sh"]



