FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash observador \
    && mkdir -p /run/sshd /var/lib/sshkeys
COPY sshd_config /etc/ssh/sshd_config
COPY entrada.sh /usr/local/bin/entrada.sh
EXPOSE 22
ENTRYPOINT ["/bin/sh", "/usr/local/bin/entrada.sh"]
