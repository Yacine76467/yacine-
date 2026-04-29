# Trojan-Go Cloud Server

Ready-to-deploy Trojan-Go server using Docker.

## Credentials:
- **Password:** `CloudPass_Trojan_2024`
- **Port:** `443`
- **WS Path:** `/v2ray-ws`

## Deployment:
1. Upload these files to your repository.
2. Provide your SSL certificates (`server.crt` and `server.key`).
3. Build and run:
   ```bash
   docker build -t trojan-server .
   docker run -d --name trojan -p 443:443 trojan-server
   ```

