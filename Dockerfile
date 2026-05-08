# 1. استخدام نسخة خفيفة ومستقرة
FROM debian:stable-slim

# 2. تثبيت الأدوات الأساسية وتحديث النظام
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. تحميل أداة wstunnel (الإصدار المستقر)
RUN curl -L https://github.com/erebe/wstunnel/releases/download/v1.1.0/wstunnel_1.1.0_linux_amd64 -o /usr/local/bin/wstunnel \
    && chmod +x /usr/local/bin/wstunnel

# 4. إعداد SSH وتحديد كلمة المرور
RUN mkdir /var/run/sshd && \
    echo 'root:yacine123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# 5. فتح منفذ Google Cloud Run الإلزامي
EXPOSE 8080

# 6. أمر التشغيل: ربط الـ WebSocket بالـ SSH الداخلي
# ملاحظة: استخدمنا سارقة (Prefix) فارغة لتناسب الـ Payload الافتراضي
CMD /usr/sbin/sshd && /usr/local/bin/wstunnel --server ws://0.0.0.0:8080 --proxyTo tcp://127.0.0.1:2222
