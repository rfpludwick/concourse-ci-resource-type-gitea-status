FROM alpine:3.23.3

COPY --chown=root:root --chmod=755 src/check.sh /opt/resource/check
COPY --chown=root:root --chmod=755 src/in.sh /opt/resource/in
COPY --chown=root:root --chmod=755 src/out.sh /opt/resource/out

RUN \
	apk update ; \
	apk add --no-cache \
		bash=5.3.3-r1 \
		curl=8.17.0-r1 \
		git=2.52.0-r0 \
		jq=1.8.1-r0 ;

CMD [ "/bin/bash" ]
