FROM teddysun/xray:latest

WORKDIR /etc/xray

COPY config.json /etc/xray/config.json

EXPOSE 1080

CMD ["xray", "run", "-c", "/etc/xray/config.json"]
