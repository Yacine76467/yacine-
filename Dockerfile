FROM debian:stable-slim

# تثبيت خادم SSH وأداة wstunnel
RUN apt-get update && apt-get install -y openssh-server wget

# إعداد كلمة المرور للمستخدم root
# يمكنك تغيير yacine123 بأي كلمة سر تفضلها
RUN echo 'root:yacine123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd

# تحميل أداة الأنفان (wstunnel) لربط SSH بالويب
RUN wget https://github.com/erebe/wstunnel/releases/download/v9.2.1/wstunnel_9.2.1_linux_amd64.tar.gz && \
    tar -xvf wstunnel_9.2.1_linux_amd64.tar.gz && \
    mv wstunnel /usr/local/bin/

# تشغيل SSH وتحويل منفذ 8080 إلى 22
# هذا المنفذ 8080 هو ما يطلبه Google Cloud Run ليعمل الرابط
CMD service ssh start && wstunnel server ws://0.0.0.0:8080 --restrictTo=127.0.0.1:22
