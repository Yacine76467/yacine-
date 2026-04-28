FROM teddysun/xray:latest
ENV PORT=8080
EXPOSE 8080
COPY config.json /etc/xray/config.json
CMD ["xray", "run", "-config", "/etc/xray/config.json"]
