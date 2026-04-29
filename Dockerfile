FROM p4gefau1t/trojan-go:latest

WORKDIR /etc/trojan-go

COPY config.json /etc/trojan-go/config.json

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/trojan-go"]
CMD ["-config", "/etc/trojan-go/config.json"]
