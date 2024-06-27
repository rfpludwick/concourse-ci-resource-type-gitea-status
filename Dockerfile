FROM alpine:3.20.1

COPY --chown=root:root --chmod=755 src/check.sh /opt/resource/check
COPY --chown=root:root --chmod=755 src/in.sh /opt/resource/in
COPY --chown=root:root --chmod=755 src/out.sh /opt/resource/out

RUN \
	apk update && \
	apk add --no-cache \
		bash=5.2.26-r0 \
		curl=8.8.0-r0 \
		git=2.45.2-r0 \
		jq=1.7.1-r0;

CMD [ "/bin/bash" ]
