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
