
#ubuntu
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV GIT_SSL_NO_VERIFY=1
ENV FORCE_UNSAFE_CONFIGURE=1

#RUN sed -i s:/archive.ubuntu.com:/mirrors.tuna.tsinghua.edu.cn/ubuntu:g /etc/apt/sources.list
#RUN apt-get clean

RUN apt-get -y update --fix-missing && \
    apt-get install -y \
    ecj \
    git \
    vim \
    npm \
    g++ \
    gcc \
    file \
    swig \
    wget \
    time \
    make \
    curl \
    cmake \
    gawk \
    unzip \
    rsync \
    ccache \
    fastjar \
    gettext \
    xsltproc \
    apt-utils \
    libssl-dev \
    libelf-dev \
    zlib1g-dev \
    subversion \
    build-essential \
    libncurses5-dev \
    libncursesw5-dev \
    python \
    python3 \
    python3-dev \
    python2.7-dev \
    python3-setuptools \
    python-distutils-extra \
    java-propose-classpath \
    && apt-get clean

RUN npm cache clean -f && \
    npm install -g n && \
    n stable && \
    /bin/bash && \
    node -v

RUN npm install -g npm@8.19.2 &&\
    /bin/bash && \
    npm -v

WORKDIR /home

RUN git clone --recursive https://github.com/coolsnowwolf/openwrt-gl-ax1800.git openwrt

WORKDIR /home/openwrt

RUN ./scripts/feeds update -a \
    && ./scripts/feeds install -a

RUN rm -f .config* && touch .config && \
    echo "CONFIG_HOST_OS_LINUX=y" >> .config && \
    echo "CONFIG_TARGET_ipq60xx=y" >> .config && \
    echo "CONFIG_TARGET_ipq60xx_generic=y" >> .config && \
    echo "CONFIG_TARGET_ipq60xx_generic_DEVICE_glinet_gl-ax1800=y" >> .config && \
    echo "CONFIG_TARGET_ROOTFS_INITRAMFS=y" >> .config && \
    echo "CONFIG_SDK=y" >> .config && \
    echo "CONFIG_MAKE_TOOLCHAIN=y" >> .config && \
    echo "CONFIG_IB=y" >> .config && \
    echo "CONFIG_PACKAGE_vim=y" >> .config && \
    echo "CONFIG_PACKAGE_bash=y" >> .config && \
    echo "CONFIG_PACKAGE_wget=y" >> .config && \
    echo "CONFIG_PACKAGE_ethtool=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-rpc-core=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-ui-core=y" >> .config && \
    echo "CONFIG_OUI_USE_HOST_NODE=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-eem=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-subset=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-rndis=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-ipw=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-garmin=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-option=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-wwan=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-ohci=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-uhci=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb2=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-wdm=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-mii=y" >> .config && \
    echo "CONFIG_PACKAGE_wwan=y" >> .config && \
    echo "CONFIG_PACKAGE_chat=y" >> .config && \
    echo "CONFIG_PACKAGE_ppp=y" >> .config && \
    echo "CONFIG_PACKAGE_uqmi=y" >> .config && \
    echo "CONFIG_PACKAGE_umbim=y" >> .config && \
    echo "CONFIG_PACKAGE_comgt=y" >> .config && \
    echo "CONFIG_PACKAGE_comgt-ncm=y" >> .config && \
    echo "CONFIG_PACKAGE_usb-modeswitch=y" >> .config && \
    echo "CONFIG_PACKAGE_qmi-utils=y" >> .config && \
    echo "CONFIG_PACKAGE_usbutils=y" >> .config && \
    sed -i 's/^[ \t]*//g' .config && \
    make defconfig

RUN make download -j8 \
    && make -j1 V=w \
    && tar -jxvf ./bin/targets/ipq60xx/generic/openwrt-toolchain-ipq60xx-generic_gcc-7.5.0_musl.Linux-x86_64.tar.bz2 -C /opt/ \
    && tar -Jxvf ./bin/targets/ipq60xx/generic/openwrt-imagebuilder-ipq60xx-generic.Linux-x86_64.tar.xz -C /home/ \
    && mkdir -p /opt/Kernel-ipq60xx \
    && mv ./build_dir/target-aarch64_cortex-a53_musl/linux-ipq60xx_generic/linux-4.4.60/ /opt/Kernel-ipq60xx \
    && cd /home && rm -rf ./openwrt

ENV ARCH=arm64
ENV CROSS_COMPILE=/opt/openwrt-toolchain-ipq60xx-generic_gcc-7.5.0_musl.Linux-x86_64/toolchain-aarch64_cortex-a53_gcc-7.5.0_musl/bin/aarch64-openwrt-linux-
ENV STAGING_DIR=/opt/openwrt-toolchain-ipq60xx-generic_gcc-7.5.0_musl.Linux-x86_64/toolchain-aarch64_cortex-a53_gcc-7.5.0_musl/bin

WORKDIR /home/openwrt-imagebuilder-ipq60xx-generic.Linux-x86_64

RUN make image PROFILE="glinet_gl-ax1800" PACKAGES="wget vim bash"

WORKDIR /home

CMD [ "/bin/bash" ]
