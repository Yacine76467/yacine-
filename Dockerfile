FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server python3 tini && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash yacine && echo "yacine:yacine100" | chpasswd

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN echo 'import socket, threading, os, sys\n\
def handle(client_sock):\n\
    try:\n\
        data = client_sock.recv(1024)\n\
        if b"Upgrade: Websocket" in data or b"websocket" in data.lower():\n\
            client_sock.send(b"HTTP/1.1 101 Switching Protocols\\r\\nUpgrade: websocket\\nConnection: Upgrade\\r\\n\\r\\n")\n\
        remote_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
        remote_sock.connect(("127.0.0.1", 22))\n\
        def forward(src, dst):\n\
            try:\n\
                while True:\n\
                    d = src.recv(4096)\n\
                    if not d: break\n\
                    dst.send(d)\n\
            except: pass\n\
        threading.Thread(target=forward, args=(client_sock, remote_sock), daemon=True).start()\n\
        threading.Thread(target=forward, args=(remote_sock, client_sock), daemon=True).start()\n\
    except: pass\n\
\n\
port = int(os.environ.get("PORT", 8080))\n\
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)\n\
server.bind(("0.0.0.0", port))\n\
server.listen(128)\n\
print(f"Server started on port {port}")\n\
while True:\n\
    client, addr = server.accept()\n\
    threading.Thread(target=handle, args=(client,), daemon=True).start()' > /proxy.py

EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sh", "-c", "/usr/sbin/sshd && python3 /proxy.py"]
