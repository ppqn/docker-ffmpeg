FROM ubuntu:16.04 as common

FROM common as builder

RUN apt-get update -qq
RUN apt-get -y install \
      autoconf \
      automake \
      build-essential \
      cmake \
      git \
      libass-dev \
      libfdk-aac-dev \
      libfreetype6-dev \
      libmp3lame-dev \
      libopus-dev \
      libsdl2-dev \
      libtheora-dev \
      libtool \
      libva-dev \
      libvdpau-dev \
      libvorbis-dev \
      libvpx-dev \
      libx264-dev \
      libx265-dev \
      libxcb1-dev \
      libxcb-shm0-dev \
      libxcb-xfixes0-dev \
      mercurial \
      pkg-config \
      texinfo \
      wget \
      yasm \
      zlib1g-dev

RUN wget -O ffmpeg-snapshot.tar.bz2 http://ffmpeg.org/releases/ffmpeg-3.3.6.tar.bz2
RUN tar xjvf ffmpeg-snapshot.tar.bz2
WORKDIR /ffmpeg-3.3.6
RUN PATH="/ffmpeg_build/bin:$PATH" PKG_CONFIG_PATH="/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I/ffmpeg_build/include" \
  --extra-ldflags="-L/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="/ffmpeg_build/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
#  --enable-libx265 \
  --enable-nonfree
RUN PATH="/bin:$PATH" make
RUN make install
RUN hash -r
RUN ls -l /bin/

FROM common as production

RUN apt-get update \
 && apt-get -y install \
      libass5 \
      libfdk-aac0 \
      libSDL2-2.0 \
      libsndio6.1 \
      libxcb-shape0 \
      libxcb-shm0 \
      libva1 \
      libva-drm1 \
      libva-x11-1 \
      libvdpau1 \
      libxv1 \
      x264

COPY --from=builder /ffmpeg_build /opt/ffmpeg

#ENV LD_LIBRARY_PATH /opt/ffmpeg/lib

WORKDIR /root/ffmpeg

ENTRYPOINT [ "/opt/ffmpeg/bin/ffmpeg" ]