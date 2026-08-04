FROM alpine:3.24.1

COPY --chown=root:root --chmod=755 src/check.sh /opt/resource/check
COPY --chown=root:root --chmod=755 src/in.sh /opt/resource/in
COPY --chown=root:root --chmod=755 src/out.sh /opt/resource/out

RUN \
	apk update ; \
	apk add --no-cache \
		bash=5.3.9-r1 \
		curl=8.21.0-r0 \
		git=2.54.0-r0 \
		jq=1.8.1-r0 ;

CMD [ "/bin/bash" ]
