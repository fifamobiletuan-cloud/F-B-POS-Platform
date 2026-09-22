import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Đường dẫn REST API Backend Spring Boot
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Danh sách dữ liệu mẫu khi chưa bật server Backend (Offline Mock Data)
  static final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Trà Sữa Ô Long Nướng',
      category: 'TraSua',
      basePrice: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=300',
      description: 'Vị ô long đậm đà hòa quyện với lớp kem béo ngậy nướng thơm lừng.',
    ),
    Product(
      id: '2',
      name: 'Trà Sữa Trân Châu Hoàng Gia',
      category: 'TraSua',
      basePrice: 39000,
      imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=300',
      description: 'Trà đen đậm đà kèm trân châu đen dai dẻo chuẩn vị truyền thống.',
    ),
    Product(
      id: '3',
      name: 'Trà Đào Cam Sả',
      category: 'TraTraiCay',
      basePrice: 38000,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300',
      description: 'Trà đào thanh mát kết hợp vị cam tươi và hương sả nồng nàn.',
    ),
    Product(
      id: '4',
      name: 'Trà Dâu Tây Kem Cheese',
      category: 'TraTraiCay',
      basePrice: 42000,
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=300',
      description: 'Trà dâu tây tươi mọng nước phủ lớp màng kem cheese mặn béo.',
    ),
    Product(
      id: '5',
      name: 'Bánh Tráng Trộn Sài Gòn',
      category: 'AnVat',
      basePrice: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300',
      description: 'Bánh tráng trộn bò khô, trứng cút, xoài bào đậm đà chua cay.',
    ),
    Product(
      id: '6',
      name: 'Cá Viên Chiên Mắm Tỏi',
      category: 'AnVat',
      basePrice: 30000,
      imageUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=300',
      description: 'Cá viên chiên giòn rụm đảo xốt mắm tỏi ớt thơm lừng.',
    ),
  ];

  static final List<ProductOption> _mockToppings = [
    ProductOption(id: 't1', name: 'Trân Châu Đen', type: 'TOPPING', price: 5000),
    ProductOption(id: 't2', name: 'Thạch Phô Mai Tươi', type: 'TOPPING', price: 7000),
    ProductOption(id: 't3', name: 'Pudding Trứng Dẻo', type: 'TOPPING', price: 6000),
    ProductOption(id: 't4', name: 'Thạch Củ Năng Giòn', type: 'TOPPING', price: 5000),
  ];

  static final List<OrderModel> _mockOrders = [
    OrderModel(
      id: 'ORD-101',
      tableNumber: 'Bàn 05',
      items: [
        OrderItem(
          productName: 'Trà Sữa Ô Long Nướng',
          size: 'Size L (+6k)',
          sugar: '70% Ngọt',
          ice: '100% Đá',
          toppings: ['Trân Châu Đen', 'Pudding Trứng Dẻo'],
          quantity: 2,
          unitPrice: 52000,
        ),
        OrderItem(
          productName: 'Bánh Tráng Trộn Sài Gòn',
          size: 'Mặc định',
          sugar: 'Bình thường',
          ice: 'Không',
          toppings: [],
          quantity: 1,
          unitPrice: 25000,
        )
      ],
      totalAmount: 129000,
      paymentMethod: 'VietQR',
      status: 'PREPARING',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  static final List<ExpenseModel> _mockExpenses = [
    ExpenseModel(
      id: 'EXP-01',
      title: 'Nhập Trà Ô Long & Sữa đặc',
      amount: 450000,
      category: 'NGUYEN_LIEU',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdBy: 'Nguyễn Huỳnh Anh Tuấn',
    ),
    ExpenseModel(
      id: 'EXP-02',
      title: 'Mua ly nhựa & ống hút dập màng',
      amount: 180000,
      category: 'VAT_TU',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdBy: 'Thu Ngân Ca Sáng',
    ),
  ];

  // API 1: Lấy thực đơn món ăn
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customer/menu')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (_) {
      // Tự động dùng Offline Mock khi Backend chưa khởi động
    }
    return _mockProducts;
  }

  // API 2: Lấy danh sách Topping
  static Future<List<ProductOption>> getToppings() async {
    return _mockToppings;
  }

  // API 3: Gửi đơn đặt món từ bàn
  static Future<bool> createOrder(OrderModel order) async {
    _mockOrders.insert(0, order);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customer/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tableNumber': order.tableNumber,
          'totalAmount': order.totalAmount,
          'paymentMethod': order.paymentMethod,
          'items': order.items.map((e) => e.toJson()).toList(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Mock lưu thành công offline
    }
  }

  // API 4: Lấy danh sách đơn hàng cho Cửa hàng
  static Future<List<OrderModel>> getOrders() async {
    return _mockOrders;
  }

  // API 5: Đổi trạng thái đơn hàng
  static Future<void> updateOrderStatus(String id, String newStatus) async {
    final order = _mockOrders.firstWhere((o) => o.id == id);
    order.status = newStatus;
  }

  // API 6: Quản lý chi tiêu
  static Future<List<ExpenseModel>> getExpenses() async {
    return _mockExpenses;
  }

  static Future<void> addExpense(ExpenseModel expense) async {
    _mockExpenses.insert(0, expense);
  }
}
