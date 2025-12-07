FROM alpine:3.23.0

COPY --chown=root:root --chmod=755 src/check.sh /opt/resource/check
COPY --chown=root:root --chmod=755 src/in.sh /opt/resource/in
COPY --chown=root:root --chmod=755 src/out.sh /opt/resource/out

RUN \
	apk update && \
	apk add --no-cache \
		bash=5.2.37-r0 \
		curl=8.14.1-r2 \
		git=2.49.1-r0 \
		jq=1.8.0-r0;

CMD [ "/bin/bash" ]
