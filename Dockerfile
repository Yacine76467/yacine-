FROM debian:stable-slim

RUN apt-get update && apt-get install -y openssh-server curl ca-certificates && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/erebe/wstunnel/releases/download/v1.1.0/wstunnel_1.1.0_linux_amd64 -o /usr/local/bin/wstunnel && chmod +x /usr/local/bin/wstunnel

RUN mkdir /var/run/sshd && echo 'root:yacine123' | chpasswd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "Port 2222" >> /etc/ssh/sshd_config

EXPOSE 8080

# استخدام صيغة بسيطة جداً للتشغيل
CMD /usr/sbin/sshd && /usr/local/bin/wstunnel --server ws://0.0.0.0:8080 --proxyTo 127.0.0.1:2222
