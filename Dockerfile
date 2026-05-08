# 1. استخدام نسخة مستقرة
FROM debian:stable-slim

# 2. تحديث وتثبيت المتطلبات (إضافة ca-certificates ضروري جداً للتحميل)
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. تحميل wstunnel مع التأكد من الرابط (استخدام -f للفشل السريع إذا الرابط خطأ)
RUN curl -fL https://github.com/erebe/wstunnel/releases/download/v1.1.0/wstunnel_1.1.0_linux_amd64 -o /usr/local/bin/wstunnel \
    && chmod +x /usr/local/bin/wstunnel

# 4. إعداد SSH وتغيير المنفذ لـ 2222
RUN mkdir /var/run/sshd && \
    echo 'root:yacine123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# 5. المنفذ المطلوب
EXPOSE 8080

# 6. تشغيل SSH و wstunnel مع التأكد من المسارات الكاملة
# استخدمنا شل (sh) لضمان تشغيل الأمرين معاً وبقاء الحاوية حية
CMD ["/bin/sh", "-c", "/usr/sbin/sshd && /usr/local/bin/wstunnel --server ws://0.0.0.0:8080 --proxyTo tcp://127.0.0.1:2222"]
