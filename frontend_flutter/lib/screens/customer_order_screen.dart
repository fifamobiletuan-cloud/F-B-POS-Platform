import 'package:flutter/material.dart';
import '../main.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'customer/home_menu_screen.dart';

/// CartState — shared state cho toàn bộ customer flow
class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];
  String currentTable;

  CartState({this.currentTable = 'Bàn 01'});

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get tax => subtotal * 0.1;

  double get total => subtotal + tax;

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQty(int index, int qty) {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void setTable(String table) {
    currentTable = table;
    notifyListeners();
  }
}

/// CartProvider — InheritedNotifier để truyền CartState xuống widget tree
class CartProvider extends InheritedNotifier<CartState> {
  const CartProvider({
    super.key,
    required CartState cart,
    required super.child,
  }) : super(notifier: cart);

  static CartState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<CartProvider>();
    assert(provider != null, 'CartProvider not found in widget tree');
    return provider!.notifier!;
  }
}

/// CustomerOrderScreen — root widget, khởi tạo cart và load data
class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  late final CartState _cart;
  late List<Product> _products;
  List<ProductOption> _toppings = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final table = _resolveTable();
    _cart = CartState(currentTable: table);
    // Khởi tạo menu ngay lập tức 0 giây, không chờ đợi timeout
    _products = ApiService.getProductsByCategory('All');
    _loadData();
  }

  String _resolveTable() {
    // ?table=Bàn 01 (query param thường)
    if (Uri.base.queryParameters.containsKey('table') &&
        Uri.base.queryParameters['table']!.trim().isNotEmpty) {
      return Uri.base.queryParameters['table']!;
    }
    // #/?table=Bàn 01 (hash fragment)
    final fragment = Uri.base.fragment;
    if (fragment.contains('table=')) {
      try {
        final queryStr =
            fragment.contains('?') ? fragment.split('?').last : fragment;
        final params = Uri.splitQueryString(queryStr);
        if (params.containsKey('table') &&
            params['table']!.trim().isNotEmpty) {
          return params['table']!;
        }
      } catch (_) {}
    }
    return 'Bàn 01';
  }

  Future<void> _loadData() async {
    try {
      final toppings = await ApiService.getToppings();
      if (mounted) {
        setState(() {
          _toppings = toppings;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        if (_isLoading) {
          return Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF080808) : const Color(0xFFF8F8F8),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFFA81E22)),
            ),
          );
        }

        return CartProvider(
          cart: _cart,
          child: HomeMenuScreen(
            products: _products,
            toppings: _toppings,
          ),
        );
      },
    );
  }
}
