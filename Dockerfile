FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash heli && \
    echo "heli:heli100" | chpasswd

RUN mkdir /var/run/sshd

RUN echo 'import socket, threading\n\
def handle(client_sock):\n\
    remote_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
    remote_sock.connect(("127.0.0.1", 22))\n\
    def forward(src, dst):\n\
        try:\n\
            while True:\n\
                data = src.recv(4096)\n\
                if not data: break\n\
                dst.send(data)\n\
        except: pass\n\
    threading.Thread(target=forward, args=(client_sock, remote_sock), daemon=True).start()\n\
    threading.Thread(target=forward, args=(remote_sock, client_sock), daemon=True).start()\n\
\n\
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)\n\
server.bind(("0.0.0.0", 8080))\n\
server.listen(5)\n\
while True:\n\
    client, addr = server.accept()\n\
    try:\n\
        client.recv(1024)\n\
        handle(client)\n\
    except: pass' > /proxy.py

EXPOSE 22 8080

CMD /usr/sbin/sshd && python3 /proxy.py
