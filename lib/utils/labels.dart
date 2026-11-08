import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0', 'en_US');
final _date = DateFormat('yyyy-MM-dd');

String formatMoney(num? value) {
  if (value == null) return '—';
  return '${_money.format(value)} د.ع';
}

String formatDate(DateTime? value) {
  if (value == null) return '—';
  return _date.format(value.toLocal());
}

String unitStatusLabel(int? status) {
  switch (status) {
    case 1:
      return 'متاح';
    case 2:
      return 'محجوز';
    case 3:
      return 'مباع';
    case 4:
      return 'مؤجر';
    case 5:
      return 'صيانة';
    default:
      return '—';
  }
}

String unitTypeLabel(int? type) {
  switch (type) {
    case 1:
      return 'شقة';
    case 2:
      return 'فيلا';
    case 3:
      return 'مكتب';
    case 4:
      return 'محل';
    case 5:
      return 'مخزن';
    default:
      return 'وحدة';
  }
}

String vehicleTypeLabel(int? type) {
  switch (type) {
    case 1:
      return 'سيارة صالون';
    case 2:
      return 'سيارة عائلية';
    case 3:
      return 'سيارة نقل / شحن';
    case 4:
      return 'سيارة حافلة صغيرة';
    case 5:
      return 'دراجة نارية';
    case 6:
      return 'أخرى';
    default:
      return 'أخرى';
  }
}

const vehicleTypeOptions = <({int value, String label})>[
  (value: 1, label: 'سيارة صالون'),
  (value: 2, label: 'سيارة عائلية'),
  (value: 3, label: 'سيارة نقل / شحن'),
  (value: 4, label: 'سيارة حافلة صغيرة'),
  (value: 5, label: 'دراجة نارية'),
  (value: 6, label: 'أخرى'),
];

String familyRelationLabel(int? relation) {
  switch (relation) {
    case 1:
      return 'زوج / زوجة';
    case 2:
      return 'أب / أم';
    case 3:
      return 'أخ / أخت';
    case 4:
      return 'ابن / ابنة';
    case 5:
      return 'أخرى';
    default:
      return 'أخرى';
  }
}

const familyRelationOptions = <({int value, String label})>[
  (value: 1, label: 'زوج / زوجة'),
  (value: 2, label: 'أب / أم'),
  (value: 3, label: 'أخ / أخت'),
  (value: 4, label: 'ابن / ابنة'),
  (value: 5, label: 'أخرى'),
];

String installmentStatusLabel(int? status) {
  switch (status) {
    case 1:
      return 'غير مدفوع';
    case 2:
      return 'مدفوع';
    case 3:
      return 'جزئي';
    case 4:
      return 'متأخر';
    case 5:
      return 'ملغى';
    default:
      return '—';
  }
}

String contractStatusLabel(int? status) {
  switch (status) {
    case 1:
      return 'مسودة';
    case 2:
      return 'ساري';
    case 3:
      return 'مكتمل';
    case 4:
      return 'ملغى';
    case 5:
      return 'موقوف';
    default:
      return '—';
  }
}

String occupancyTypeLabel(int? type) {
  switch (type) {
    case 1:
      return 'مالك';
    case 2:
      return 'مستأجر';
    default:
      return '—';
  }
}

String residentStatusLabel(int? status) {
  switch (status) {
    case 1:
      return 'مقيم';
    case 2:
      return 'مغادر';
    case 3:
      return 'إخلاء';
    default:
      return '—';
  }
}

String paymentMethodLabel(int? method) {
  switch (method) {
    case 1:
      return 'نقداً';
    case 2:
      return 'تحويل';
    case 3:
      return 'شيك';
    case 4:
      return 'بطاقة';
    case 5:
      return 'إلكتروني';
    default:
      return '—';
  }
}
