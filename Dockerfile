FROM ubuntu:18.04

MAINTAINER Davide Bove

ENV SMALI_VERSION="2.2.7" \ 
    APKTOOL_VERSION="2.4.0" \ 
    JD_VERSION="1.6.3" \
    PROCYON_VERSION="0.5.36" \
    FRIDA_VERSION="12.6.11" \
    JDCMD_VERSION="0.9.2" \
    JADX_VERSION="1.0.0" \
    CLASSYSHARK_VERSION="8.2" \
    USER=root \
    PATH=$PATH:/opt/apktool:/opt/dex2jar-2.0:/opt/jadx/bin:/opt/

RUN dpkg --add-architecture i386 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
        default-jdk \
        software-properties-common \
        unzip \
        zip \
        wget \
        git \
        androguard \
        build-essential \
        iptables \
        iputils-ping \
        python-protobuf \
        python-pip \
        python-crypto \
        protobuf-compiler \
        libprotobuf-java \
        apt-transport-https \
        gdb-multiarch \
        eog \
        p7zip-full \
        curl \
        pkg-config \
        tree \
        python3 \
        bridge-utils \
        libc6:i386 \
        libncurses5:i386 \
        libstdc++6:i386 \
        lib32z1 \
        libbz2-1.0:i386 \
        xvfb \
        && rm -rf /var/lib/apt/lists/* \
        && pip install setuptools wheel && mkdir -p /opt

# Android Reverse Engineering tools -------------
# Install Smali / Baksmali
RUN wget -q -O "/opt/smali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/smali-$SMALI_VERSION.jar" \
        && echo -e '#!/usr/bin/java -jar\n' | cat - /opt/smali.jar > /opt/smali && chmod +x /opt/smali \
        && wget -q -O "/opt/baksmali.jar" "https://bitbucket.org/JesusFreke/smali/downloads/baksmali-$SMALI_VERSION.jar" \
        && echo -e '#!/usr/bin/java -jar\n' | cat - /opt/baksmali.jar > /opt/baksmali && chmod +x /opt/baksmali

# Apktool
RUN mkdir -p /opt/apktool \
        && wget -q -O "/opt/apktool/apktool" https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool \
        && wget -q -O "/opt/apktool/apktool.jar" https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$APKTOOL_VERSION.jar \
        && chmod u+x /opt/apktool/apktool /opt/apktool/apktool.jar

# Dex2Jar
RUN wget -q -O "/opt/dex2jar-2.0.zip" http://downloads.sourceforge.net/project/dex2jar/dex2jar-2.0.zip \
        && cd /opt \
        && unzip /opt/dex2jar-2.0.zip \
        && chmod u+x /opt/dex2jar-2.0/*.sh \
        && rm -f /opt/dex2jar-2.0.zip 

# JD-GUI
RUN wget -q -O "/opt/jd-gui.jar" "https://github.com/java-decompiler/jd-gui/releases/download/v$JD_VERSION/jd-gui-$JD_VERSION.jar" \
        && wget -q -O "/tmp/jd-cmd.zip" "https://github.com/kwart/jd-cmd/releases/download/jd-cmd-$JDCMD_VERSION.Final/jd-cli-$JDCMD_VERSION-dist.zip" \
        && unzip -qq "/tmp/jd-cmd.zip" -d "/opt/"

# JADX
RUN cd /opt && wget -q -O "/tmp/jadx.zip" "https://github.com/skylot/jadx/releases/download/v$JADX_VERSION/jadx-$JADX_VERSION.zip" \
        && unzip /tmp/jadx.zip -d /opt/jadx

# Procyon
RUN wget -q -O "/opt/procyon-decompiler.jar" "https://bitbucket.org/mstrobel/procyon/downloads/procyon-decompiler-$PROCYON_VERSION.jar" \
        && echo -e '#!/usr/bin/java -jar\n' | cat - /opt/procyon-decompiler.jar > /opt/procyon-decompiler && chmod +x /opt/procyon-decompiler

# AXMLPrinter
RUN git clone https://github.com/rednaga/axmlprinter /tmp/axmlprinter \
        && cd /tmp/axmlprinter && ./gradlew jar && mv /tmp/axmlprinter/build/libs/*.jar /opt/axmlprinter.jar \
        && echo -e '#!/usr/bin/java -jar\n' | cat - /opt/axmlprinter.jar > /opt/axmlprinter && chmod +x /opt/axmlprinter

# Frida
RUN pip install frida frida-tools \
        && cd /opt && wget -q -O "/opt/frida-server.xz" https://github.com/frida/frida/releases/download/${FRIDA_VERSION}/frida-server-${FRIDA_VERSION}-android-arm.xz && unxz /opt/frida-server.xz
RUN echo -e '#!/bin/bash\nadb push /opt/frida-server /data/local/tmp/\nadb shell "chmod 755 /data/local/tmp/frida-server"' >> /opt/install-frida-server.sh \
        && chmod u+x /opt/install-frida-server.sh

# Other tools with simple install
# ClassyShark requires X11
# RUN wget -q -O "/opt/ClassyShark.jar" https://github.com/google/android-classyshark/releases/download/$CLASSYSHARK_VERSION/ClassyShark.jar \
#         && echo -e '#!/usr/bin/java -jar\n' | cat - /opt/ClassyShark.jar > /opt/ClassyShark && chmod +x /opt/ClassyShark

RUN apt-get remove -yqq curl wget git && apt-get autoremove -yqq && apt-get clean && rm -rf /tmp/* \
        && echo "export PATH=$PATH" >> /etc/profile \
        && echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /etc/profile \
        && echo "export LC_ALL=C" >> /root/.bashrc \
        && mkdir -p /work

WORKDIR /work

ADD decompile.sh /root

# open ports
# Android adb daemon
EXPOSE 5037
