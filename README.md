# مجمع الزهراء — تطبيق الجوال

تطبيق Flutter مخصص لـ **مجمع الزهراء السكني** فقط، متصل بـ PMS API:

`http://10.10.9.71:5216`

## المجمع الثابت

| الحقل | القيمة |
| --- | --- |
| الاسم | مجمع الزهراء السكني |
| ComplexId | `08df1fb2-f274-4c28-85ea-eb38f9d1a1c4` |

كل طلبات الوحدات / العملاء / الأقساط / الحجوزات / العقود تُفلتر تلقائياً بهذا المجمع.

## المزايا (تطبيق ساكن)

- دخول الساكن: `POST /api/Auth/resident-login` ثم `GET /api/Auth/me`
- الملف: `GET /api/Residents/{id}/profile`
- الوحدة: `GET /api/Units/{unitId}`
- العقود: `GET /api/SalesContracts?CustomerId=...`
- الأقساط: من العقد أو `GET /api/Installments?ContractId=...`
- الدفعات: `GET /api/Payments?CustomerId=...`
- واجهة عربية RTL

## التشغيل

```bash
cd /Users/ahmedalsfaru/Documents/GitHub/Complex-Phone
flutter pub get
flutter run
```

## ضبط مجمع آخر لاحقاً

عدّل القيم في `lib/config/app_config.dart`.
