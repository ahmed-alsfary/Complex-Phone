class UserInfo {
  UserInfo({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.role,
    this.roleName,
    this.complexId,
    this.authKind,
    this.residentId,
    this.customerId,
    this.unitNumber,
    this.complexName,
    this.isSuperAdmin = false,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? role;
  final String? roleName;
  final String? complexId;
  final String? authKind;
  final String? residentId;
  final String? customerId;
  final String? unitNumber;
  final String? complexName;
  final bool isSuperAdmin;

  String get displayName {
    final name = [firstName, lastName].where((e) => (e ?? '').trim().isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    if ((phone ?? '').trim().isNotEmpty) return phone!.trim();
    return email ?? 'ساكن';
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: '${json['id'] ?? ''}',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      roleName: json['roleName'] as String?,
      complexId: json['complexId']?.toString(),
      authKind: json['authKind'] as String?,
      residentId: json['residentId']?.toString(),
      customerId: json['customerId']?.toString(),
      unitNumber: json['unitNumber'] as String?,
      complexName: json['complexName'] as String?,
      isSuperAdmin: json['isSuperAdmin'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': role,
        'roleName': roleName,
        'complexId': complexId,
        'authKind': authKind,
        'residentId': residentId,
        'customerId': customerId,
        'unitNumber': unitNumber,
        'complexName': complexName,
        'isSuperAdmin': isSuperAdmin,
      };
}

class PagedResult<T> {
  PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  factory PagedResult.fromJson(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) mapItem,
  ) {
    final raw = json?['items'];
    final items = <T>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) items.add(mapItem(Map<String, dynamic>.from(e)));
      }
    }
    return PagedResult(
      items: items,
      page: (json?['page'] as num?)?.toInt() ?? 1,
      pageSize: (json?['pageSize'] as num?)?.toInt() ?? items.length,
      totalCount: (json?['totalCount'] as num?)?.toInt() ?? items.length,
    );
  }
}

class ResidentProfile {
  ResidentProfile({
    required this.id,
    required this.customerId,
    required this.unitId,
    required this.complexId,
    this.primaryResidentName,
    this.unitNumber,
    this.buildingName,
    this.occupancyType,
    this.status,
    this.moveInDate,
    this.occupancyDate,
    this.nationalId,
    this.phone,
    this.email,
    this.totalOccupants = 0,
    this.hasHandover = false,
    this.emergencyContactName,
    this.emergencyPhone,
  });

  final String id;
  final String customerId;
  final String unitId;
  final String complexId;
  final String? primaryResidentName;
  final String? unitNumber;
  final String? buildingName;
  final int? occupancyType;
  final int? status;
  final DateTime? moveInDate;
  final DateTime? occupancyDate;
  final String? nationalId;
  final String? phone;
  final String? email;
  final int totalOccupants;
  final bool hasHandover;
  final String? emergencyContactName;
  final String? emergencyPhone;

  factory ResidentProfile.fromJson(Map<String, dynamic> json) {
    return ResidentProfile(
      id: '${json['id']}',
      customerId: '${json['customerId'] ?? ''}',
      unitId: '${json['unitId'] ?? ''}',
      complexId: '${json['complexId'] ?? ''}',
      primaryResidentName: json['primaryResidentName'] as String?,
      unitNumber: json['unitNumber'] as String?,
      buildingName: json['buildingName'] as String?,
      occupancyType: (json['occupancyType'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      moveInDate: DateTime.tryParse('${json['moveInDate'] ?? ''}'),
      occupancyDate: DateTime.tryParse('${json['occupancyDate'] ?? ''}'),
      nationalId: json['nationalId'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      totalOccupants: (json['totalOccupants'] as num?)?.toInt() ?? 0,
      hasHandover: json['hasHandover'] == true,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
    );
  }
}

class UnitItem {
  UnitItem({
    required this.id,
    this.unitNumber,
    this.unitType,
    this.area = 0,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.status,
    this.statusName,
    this.price = 0,
    this.floorLevel = 0,
    this.notes,
  });

  final String id;
  final String? unitNumber;
  final int? unitType;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final int? status;
  final String? statusName;
  final double price;
  final int floorLevel;
  final String? notes;

  factory UnitItem.fromJson(Map<String, dynamic> json) {
    return UnitItem(
      id: '${json['id']}',
      unitNumber: json['unitNumber'] as String?,
      unitType: (json['unitType'] as num?)?.toInt(),
      area: (json['area'] as num?)?.toDouble() ?? 0,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt(),
      statusName: json['statusName'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      floorLevel: (json['floorLevel'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }
}

class InstallmentItem {
  InstallmentItem({
    required this.id,
    required this.dueDate,
    required this.amount,
    this.paidAmount = 0,
    this.status,
    this.paidDate,
    this.name,
  });

  final String id;
  final DateTime? dueDate;
  final double amount;
  final double paidAmount;
  final int? status;
  final DateTime? paidDate;
  final String? name;

  factory InstallmentItem.fromJson(Map<String, dynamic> json) {
    return InstallmentItem(
      id: '${json['id']}',
      dueDate: DateTime.tryParse('${json['dueDate'] ?? ''}'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as num?)?.toInt(),
      paidDate: DateTime.tryParse('${json['paidDate'] ?? ''}'),
      name: json['name'] as String?,
    );
  }
}

class SalesContractItem {
  SalesContractItem({
    required this.id,
    this.contractNumber,
    this.contractDate,
    this.sellingPrice = 0,
    this.remainingAmount = 0,
    this.downPayment = 0,
    this.contractStatus,
    this.customerId,
    this.unitId,
    this.installments = const [],
  });

  final String id;
  final String? contractNumber;
  final DateTime? contractDate;
  final double sellingPrice;
  final double remainingAmount;
  final double downPayment;
  final int? contractStatus;
  final String? customerId;
  final String? unitId;
  final List<InstallmentItem> installments;

  factory SalesContractItem.fromJson(Map<String, dynamic> json) {
    final rawInstallments = json['installments'];
    final list = <InstallmentItem>[];
    if (rawInstallments is List) {
      for (final e in rawInstallments) {
        if (e is Map) list.add(InstallmentItem.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return SalesContractItem(
      id: '${json['id']}',
      contractNumber: json['contractNumber'] as String?,
      contractDate: DateTime.tryParse('${json['contractDate'] ?? ''}'),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0,
      contractStatus: (json['contractStatus'] as num?)?.toInt(),
      customerId: json['customerId']?.toString(),
      unitId: json['unitId']?.toString(),
      installments: list,
    );
  }
}

class PaymentItem {
  PaymentItem({
    required this.id,
    required this.amount,
    this.paymentDate,
    this.referenceNumber,
    this.bankName,
    this.paymentMethod,
    this.notes,
  });

  final String id;
  final double amount;
  final DateTime? paymentDate;
  final String? referenceNumber;
  final String? bankName;
  final int? paymentMethod;
  final String? notes;

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: '${json['id']}',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentDate: DateTime.tryParse('${json['paymentDate'] ?? ''}'),
      referenceNumber: json['referenceNumber'] as String?,
      bankName: json['bankName'] as String?,
      paymentMethod: (json['paymentMethod'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );
  }
}
