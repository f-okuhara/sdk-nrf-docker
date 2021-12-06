FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib g++-multilib libsdl2-dev curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


RUN mkdir /gnuarmemb
RUN wget -O - "https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2?revision=ca0cbf9c-9de2-491c-ac48-898b5bbc0443&la=en&hash=68760A8AE66026BCF99F05AC017A6A50C6FD832A" \
  | tar jxf - -C /gnuarmemb


ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/gnuarmemb/gcc-arm-none-eabi-10-2020-q4-major

RUN pip3 install west
RUN mkdir -p /opt/nordic/ncs/v1.7.1
WORKDIR /opt/nordic/ncs/v1.7.1
RUN west init -m https://github.com/nrfconnect/sdk-nrf --mr v1.7.1
RUN west update
RUN west zephyr-export
RUN echo "" > nrf/scripts/requirements-doc.txt
RUN pip3 install -r zephyr/scripts/requirements.txt
RUN pip3 install -r nrf/scripts/requirements.txt
RUN pip3 install -r bootloader/mcuboot/scripts/requirements.txt

ENV ZEPHYR_BASE=/opt/nordic/ncs/v1.7.1/zephyr
ENV PATH=$GNUARMEMB_TOOLCHAIN_PATH/bin:$PATH
