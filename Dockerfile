FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash yacine && \
    echo "yacine:yacine100" | chpasswd

RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN echo 'import socket, threading\n\
def handle(client_sock):\n\
    try:\n\
        data = client_sock.recv(1024)\n\
        if b"Upgrade: Websocket" in data or b"websocket" in data.lower():\n\
            client_sock.send(b"HTTP/1.1 101 Switching Protocols\\r\\nUpgrade: websocket\\nConnection: Upgrade\\r\\n\\r\\n")\n\
        \n\
        remote_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
        remote_sock.connect(("127.0.0.1", 22))\n\
        \n\
        def forward(src, dst):\n\
            try:\n\
                while True:\n\
                    data = src.recv(4096)\n\
                    if not data: break\n\
                    dst.send(data)\n\
            except: pass\n\
        \n\
        threading.Thread(target=forward, args=(client_sock, remote_sock), daemon=True).start()\n\
        threading.Thread(target=forward, args=(remote_sock, client_sock), daemon=True).start()\n\
    except: pass\n\
\n\
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)\n\
server.bind(("0.0.0.0", 8080))\n\
server.listen(100)\n\
while True:\n\
    client, addr = server.accept()\n\
    threading.Thread(target=handle, args=(client,), daemon=True).start()' > /proxy.py

EXPOSE 22 8080

CMD /usr/sbin/sshd && python3 /proxy.py
