# AHB Sub Page for PasarGuard

صفحه‌ی اطلاعات اشتراک (دایره‌ی مصرف، مخزن حجم، کپی و QR کانفیگ‌ها) به‌صورت قالب سفارشی پاسارگاد.

## نصب

```bash
AHB_REPO=OWNER/REPO bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh)
```

بعد از نصب، لینک ساب هر کاربر را در مرورگر باز کنید. کلاینت‌های VPN همچنان خروجی معمولی را می‌گیرند.

## حذف

```bash
AHB_REPO=OWNER/REPO bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh) uninstall
```

## نصب دستی

```bash
sudo mkdir -p /var/lib/pasarguard/templates/subscription
sudo wget -O /var/lib/pasarguard/templates/subscription/ahb.html https://raw.githubusercontent.com/OWNER/REPO/main/index.html
```

در `/opt/pasarguard/.env`:

```
CUSTOM_TEMPLATES_DIRECTORY="/var/lib/pasarguard/templates/"
SUBSCRIPTION_PAGE_TEMPLATE="subscription/ahb.html"
```

سپس `pasarguard restart`.

## نکته

فونت و کتابخانه‌ی QR از CDN لود می‌شوند؛ اگر CDN روی سرور/کاربر فیلتر باشد، صفحه با فونت پیش‌فرض و بدون QR کار می‌کند.
