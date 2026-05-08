# 1. استخدام نسخة Debian مستقرة وخفيفة
FROM debian:stable-slim

# 2. تثبيت خادم SSH وأداة curl
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. تحميل أداة wstunnel
RUN curl -L https://github.com/erebe/wstunnel/releases/download/v1.1.0/wstunnel_1.1.0_linux_amd64 -o /usr/local/bin/wstunnel \
    && chmod +x /usr/local/bin/wstunnel

# 4. إعداد خادم SSH
RUN mkdir /var/run/sshd
RUN echo 'root:yacine123' | chpasswd
# السماح بدخول الـ Root وتغيير المنفذ
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config

# 5. فتح المنفذ 8080 (Cloud Run)
EXPOSE 8080

# 6. أمر التشغيل المحسن
# استخدمنا النقطة المنقوطة لتشغيل SSH ثم تشغيل wstunnel في الواجهة (Foreground)
CMD /usr/sbin/sshd && /usr/local/bin/wstunnel --server ws://0.0.0.0:8080 --proxyTo tcp://127.0.0.1:2222
