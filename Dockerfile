# استخدام نسخة خفيفة ومستقرة من Xray
FROM teddysun/xray:latest

# ضبط مسار العمل
WORKDIR /etc/xray

# نسخ ملف الإعدادات من جهازك إلى داخل الحاوية
# ملاحظة: يجب أن يكون ملف الإعدادات باسم config.json في نفس المجلد
COPY config.json /etc/xray/config.json

# فتح المنفذ (يجب أن يطابق المنفذ الموجود في الـ Inbound في إعداداتك)
EXPOSE 1080

# أمر تشغيل الخدمة
CMD ["xray", "run", "-c", "/etc/xray/config.json"]
