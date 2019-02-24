#############################################################
# Dockerfile to build Interactive Broker TWS container images
#############################################################
FROM quay.io/orgsync/java:1.8.0_66-b17

# File Author / Maintainer
MAINTAINER Euclid Capital Ltd.

# Install libs
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    gsettings-desktop-schemas \
    xvfb \
    libxrender1 \
    libxtst6 \
    x11vnc \
	libswt-gtk-3-java

# Download IB Connect and TWS
RUN cd /tmp && \
	wget https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip && \
    unzip IBController-3.4.0.zip -d /opt/IBController && \
    wget https://download2.interactivebrokers.com/installers/tws/stable-standalone/tws-stable-standalone-linux-x64.sh && \
    chmod +x tws-stable-standalone-linux-x64.sh && \
    echo "n" | ./tws-stable-standalone-linux-x64.sh && \
    rm -rf /tmp/* && \
    mv /root/Jts/972 /opt/IBJts

# Set up Virtual Framebuffer and VNC
ADD vnc_init /etc/init.d/vnc
ADD xvfb_init /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
ENV DISPLAY :0.0

# Set up IBConnect
RUN mkdir -p /opt/IBJts/jars/dhmyhmeut/
ADD jts.972.ini /opt/IBJts/jars/jts.ini
ADD tws.972.xml /opt/IBJts/jars/dhmyhmeut/tws.xml
ADD IBController.ini /opt/IBController/
ADD IBControllerStart.sh /opt/IBController/
RUN chmod +x /opt/IBController/IBControllerStart.sh

# Default credentials for TWS and VNC (remote desktop)
ARG TWS_USERID=fdemo
ARG TWS_PASSWORD=demouser
ARG VNC_PASSWORD=donkeyballs

# Override credentials for TWS and VNC by user supplied environment
ENV TWS_USERID $TWS_USERID
ENV TWS_PASSWORD $TWS_PASSWORD
ENV VNC_PASSWORD $VNC_PASSWORD

RUN echo "TWS_USERID:   $TWS_USERID"
RUN echo "TWS_PASSWORD: $TWS_PASSWORD"
RUN echo "VNC_PASSWORD: $VNC_PASSWORD"

# Start TWS
EXPOSE 4001 5900
CMD ["/bin/bash", "/opt/IBController/IBControllerStart.sh"]
