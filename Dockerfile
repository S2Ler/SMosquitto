FROM swift:5.0
USER root
LABEL "com.github.actions.name"="SMosquitto-Actions"
LABEL "com.github.actions.description"=""
LABEL "com.github.actions.icon"="airplay"
LABEL "com.github.actions.color"="orange"
LABEL "repository"="https://github.com/S2Ler/SMosquitto.git"
LABEL "homepage"="http://github.com/actions"
LABEL "maintainer"="diejmon@gmail.com"
RUN apt-get update && apt-get install -y git libmosquitto-dev
RUN mkdir /SMosquitto
WORKDIR /SMosquitto
COPY . /SMosquitto
