// Data Models cho Hệ sinh thái Trà sữa F&B

class ProductOption {
  final String id;
  final String name;
  final String type; // SIZE, SUGAR, ICE, TOPPING
  final double price;

  ProductOption({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'TOPPING',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String category; // TraSua, TraTraiCay, AnVat
  final double basePrice;
  final String imageUrl;
  final String description;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.imageUrl,
    required this.description,
    this.isAvailable = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'TraSua',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}

class CartItem {
  final Product product;
  String size; // M hoặc L
  String sugar; // 0%, 30%, 50%, 70%, 100%
  String ice; // Nóng, Không đá, 50% đá, 100% đá
  List<ProductOption> selectedToppings;
  int quantity;
  String note;

  CartItem({
    required this.product,
    this.size = 'M (Vừa)',
    this.sugar = '100% Ngọt',
    this.ice = '100% Đá',
    required this.selectedToppings,
    this.quantity = 1,
    this.note = '',
  });

  double get unitPrice {
    double total = product.basePrice;
    if (size.contains('L')) total += 6000;
    for (var topping in selectedToppings) {
      total += topping.price;
    }
    return total;
  }

  double get totalPrice => unitPrice * quantity;
}

class OrderItem {
  final String productName;
  final String size;
  final String sugar;
  final String ice;
  final List<String> toppings;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productName,
    required this.size,
    required this.sugar,
    required this.ice,
    required this.toppings,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'size': size,
        'sugar': sugar,
        'ice': ice,
        'toppings': toppings,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

class OrderModel {
  final String id;
  final String tableNumber;
  final List<OrderItem> items;
  final double totalAmount;
  final String paymentMethod; // VietQR, CASH
  String status; // PENDING, PREPARING, COMPLETED, CANCELLED
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.tableNumber,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });
}

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category; // NGUYEN_LIEU, VAT_TU, DIEN_NUOC, KHAC
  final DateTime createdAt;
  final String createdBy;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.createdAt,
    required this.createdBy,
  });
}

class ShiftModel {
  final String id;
  final String shiftName; // Ca Sáng, Ca Chiều, Ca Tối
  final String startTime;
  final String endTime;
  final double hourlyRate;

  ShiftModel({
    required this.id,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.hourlyRate,
  });
}
