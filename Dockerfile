#FROM thewicklowwolf/channeltube:latest as builder
FROM pknw1/channeltube as builder

FROM tailscale/tailscale:latest
RUN apk add --update py3-pip nodejs npm python3 ffmpeg aria2 coreutils shadow su-exec curl tini && \
    apk add --update --virtual .build-deps gcc g++ musl-dev 
RUN apk del .build-deps && \
    rm -rf /var/cache/apk/* && \
    mkdir /.cache && chmod 777 /.cache
RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables
COPY --from=builder /channeltube/requirements.txt /requirements.txt
RUN pip install -r requirements.txt

COPY --from=builder /channeltube /channeltube
RUN sed -i 's/video_title = video["title"]/video_title = video["title"] + " - [" + video["id"] + "]"' /channeltube/src/ChannelTube.py
RUN mkdir /tailscale 
RUN mv /usr/local/bin/containerboot /usr/local/bin/tailscaleboot
ADD channeltube.sh /usr/local/bin/containerboot
RUN chmod +x /usr/local/bin/containerboot
