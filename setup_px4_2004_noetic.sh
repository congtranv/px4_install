#!/bin/bash

BUILD_PX4="true"

echo -e "\e[1;33m NOTE: must run this script in the px4 setup directory \e[0m"
sleep 1
echo -e "\e[1;33m Input PATH to install PX4 firmware: \e[0m"
read -p "(e.g., /home/USERNAME/ros/px4/.): " -r PATHNAME
PX4_SRC=$(dirname "$PATHNAME")
echo
echo -e "\e[1;33m Your path: \e[0m" ${PX4_SRC}
read -p "Sure? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

sleep 0.5
echo -e "\e[1;33m NOTE: If have issues related to python tool, let install recommended packages or use virtual python3 environment (conda base environment) \e[0m"
####################################### Setup PX4 v1.10.1 #######################################
if [ "$BUILD_PX4" != "false" ]; then

    echo -e "\e[1;33m Setting up Px4 v1.10.1 \e[0m"
    # Installing initial dependencies
    sudo apt --quiet -y install \
        ca-certificates \
        gnupg \
        lsb-core \
        wget \
        ;
    
	DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    # check requirements.txt exists (script not run in source tree)
    REQUIREMENTS_FILE="px4_requirements.txt"
    if [ ! -f "${DIR}/${REQUIREMENTS_FILE}" ]; then
        echo "FAILED: ${REQUIREMENTS_FILE} needed in same directory as setup.sh (${DIR})."
        return 1
    fi

	echo -e "\e[1;33m Installing PX4 general dependencies \e[0m"

    sudo apt-get update -y --quiet
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
        astyle \
        build-essential \
        ccache \
        clang \
        clang-tidy \
        cmake \
        cppcheck \
        doxygen \
        file \
        g++ \
        gcc \
        gdb \
        git \
        lcov \
        make \
        ninja-build \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        rsync \
        shellcheck \
        unzip \
        xsltproc \
        zip \
        ;

    # Python3 dependencies
    echo
	echo -e "\e[1;33m Installing PX4 Python3 dependencies \e[0m"
    pip3 install --user -r ${DIR}/px4_requirements.txt

    echo "arrow" | sudo -S DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-ugly \
            libeigen3-dev \
            libgazebo11-dev \
            libgstreamer-plugins-base1.0-dev \
            libimage-exiftool-perl \
            libopencv-dev \
            libxml2-utils \
            pkg-config \
            protobuf-compiler \
            ;


    #Setting up PX4 Firmware
    if [ ! -d "${PX4_SRC}/Firmware" ]; then
        cd ${PX4_SRC}
        git clone https://github.com/PX4/Firmware
    else
        echo -e "\e[1;33m Firmware already exists. Just pulling latest upstream.... \e[0m"
        cd ${PX4_SRC}/Firmware
        git pull
    fi
    cd ${PX4_SRC}/Firmware
    make clean && make distclean
    git checkout v1.11.3 && git submodule init && git submodule update --recursive
    cd ${PX4_SRC}/Firmware/Tools/sitl_gazebo/external/OpticalFlow
    git submodule init && git submodule update --recursive
    cd ${PX4_SRC}/Firmware/Tools/sitl_gazebo/external/OpticalFlow/external/klt_feature_tracker
    git submodule init && git submodule update --recursive
    # NOTE: in PX4 v1.10.1, there is a bug in Firmware/Tools/sitl_gazebo/include/gazebo_opticalflow_plugin.h:43:18
    # #define HAS_GYRO TRUE needs to be replaced by #define HAS_GYRO true
    sed -i 's/#define HAS_GYRO.*/#define HAS_GYRO true/' ${PX4_SRC}/Firmware/Tools/sitl_gazebo/include/gazebo_opticalflow_plugin.h
    cd ${PX4_SRC}/Firmware
    DONT_RUN=1 make px4_sitl_default gazebo

    #Copying this to  .bashrc file
    grep -xF 'source ${PX4_SRC}/Firmware/Tools/setup_gazebo.bash ${PX4_SRC}/Firmware ${PX4_SRC}/Firmware/build/px4_sitl_default' ${HOME}/.bashrc || echo "source ${PX4_SRC}/Firmware/Tools/setup_gazebo.bash ${PX4_SRC}/Firmware ${PX4_SRC}/Firmware/build/px4_sitl_default" >> ${HOME}/.bashrc
    grep -xF 'export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:${PX4_SRC}/Firmware' ${HOME}/.bashrc || echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:${PX4_SRC}/Firmware" >> ${HOME}/.bashrc
    grep -xF 'export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:${PX4_SRC}/Firmware/Tools/sitl_gazebo' ${HOME}/.bashrc || echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:${PX4_SRC}/Firmware/Tools/sitl_gazebo" >> ${HOME}/.bashrc
    grep -xF 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins' ${HOME}/.bashrc || echo "export GAZEBO_PLUGIN_PATH=\$GAZEBO_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/gazebo-9/plugins" >> ${HOME}/.bashrc

    source ${HOME}/.bashrc
fi

echo -e "\e[1;33m DONE \e[0m"
