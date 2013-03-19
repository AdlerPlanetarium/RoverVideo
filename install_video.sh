#!/bin/bash

# Clean Up Before Installing
rm -rf ~/ffmpeg ~/x264 ~/libvpx ~/yasm-1.2.0 ~/fdk-aac
rm /opt/planetxrobots/video.sh # Remove Rover video script.
rm /etc/ffserver.conf # Remove old ffserver configuration

# Copy new ffserver config and upstart scripts
cp ffserver.conf /etc/ffserver.conf
cp video-server.conf /etc/init/video-server.conf
cp video-cam.conf /etc/init/video-cam.conf

# Build FFMpeg from Source according to https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide
sudo apt-get remove -y ffmpeg x264 libav-tools libvpx-dev libx264-dev yasm   

apt-get update
sudo apt-get -y install autoconf automake build-essential checkinstall git libass-dev libfaac-dev \
  libgpac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev librtmp-dev libspeex-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texi2html zlib1g-dev

# Building FFMpeg Deps, and FFMpeg. Also builds debian package for each
# so remove is simply apt-get remove package-name

#Yasm
cd
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure
make
sudo checkinstall --pkgname=yasm --pkgversion="1.2.0" --backup=no \
  --deldoc=yes --fstrans=no --default

#x264. I hope the adler bought an h.264 license ;)
cd
git clone git://git.videolan.org/x264
cd x264
./configure --enable-static
make
checkinstall --pkgname=x264 --pkgversion="3:$(./version.sh | \
  awk -F'[" ]' '/POINT/{print $4"+git"$5}')" --backup=no --deldoc=yes \
  --fstrans=no --default

# fdk-aac
cd
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
autoreconf -fiv
./configure --disable-shared
make
sudo checkinstall --pkgname=fdk-aac --pkgversion="$(date +%Y%m%d%H%M)-git" --backup=no \
  --deldoc=yes --fstrans=no --default

# libvpx
cd
git clone --depth 1 http://git.chromium.org/webm/libvpx.git
cd libvpx
./configure --disable-examples --disable-unit-tests
make
sudo checkinstall --pkgname=libvpx --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no \
  --deldoc=yes --fstrans=no --default

# ffmpeg
cd
git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
./configure --enable-gpl --enable-libass --enable-libfaac --enable-libfdk-aac --enable-libmp3lame \
  --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libspeex --enable-librtmp --enable-libtheora \
  --enable-libvorbis --enable-libvpx --enable-x11grab --enable-libx264 --enable-nonfree --enable-version3
make
sudo checkinstall --pkgname=ffmpeg --pkgversion="7:$(date +%Y%m%d%H%M)-git" --backup=no \
  --deldoc=yes --fstrans=no --default

hash -r

rm -rf ~/ffmpeg ~/x264 ~/libvpx ~/yasm-1.2.0 ~/fdk-aac

