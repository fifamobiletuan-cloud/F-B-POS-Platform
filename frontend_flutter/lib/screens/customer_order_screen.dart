import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CustomerOrderScreen extends StatefulWidget {
  final String? tableFromUrl;

  const CustomerOrderScreen({super.key, this.tableFromUrl});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> with SingleTickerProviderStateMixin {
  late String currentTable;
  late TabController _tabController;
  List<Product> _allProducts = [];
  List<ProductOption> _toppings = [];
  final List<CartItem> _cart = [];
  bool _isLoading = true;
  OrderModel? _activeOrder;

  @override
  void initState() {
    super.initState();
    // Đọc số bàn từ URL hoặc mặc định Bàn 05
    currentTable = widget.tableFromUrl ?? Uri.base.queryParameters['table'] ?? 'Bàn 05';
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final products = await ApiService.getProducts();
    final toppings = await ApiService.getToppings();
    if (mounted) {
      setState(() {
        _allProducts = products;
        _toppings = toppings;
        _isLoading = false;
      });
    }
  }

  double get _cartTotal {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _addToCart(CartItem item) {
    setState(() {
      _cart.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${item.product.name}" vào giỏ hàng!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.brown,
        action: SnackBarAction(
          label: 'Xem Giỏ',
          textColor: Colors.amber,
          onPressed: _showCartBottomSheet,
        ),
      ),
    );
  }

  // Dialog chọn Size, Đường, Đá, Topping cho ly trà sữa
  void _openProductCustomizationModal(Product product) {
    String selectedSize = 'M (Vừa)';
    String selectedSugar = '100% Ngọt';
    String selectedIce = '100% Đá';
    final List<ProductOption> selectedToppings = [];
    int quantity = 1;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double currentUnitPrice = product.basePrice;
            if (selectedSize.contains('L')) currentUnitPrice += 6000;
            for (var t in selectedToppings) {
              currentUnitPrice += t.price;
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.amber.shade100,
                              child: const Icon(Icons.coffee, color: Colors.brown),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.basePrice.toStringAsFixed(0)} đ',
                                style: const TextStyle(fontSize: 16, color: Colors.deepOrange, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // 1. Chọn Size
                    const Text('1. Chọn Size ly:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Size M (+0đ)'),
                          selected: selectedSize.contains('M'),
                          onSelected: (val) => setModalState(() => selectedSize = 'M (Vừa)'),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Size L (+6.000đ)'),
                          selected: selectedSize.contains('L'),
                          onSelected: (val) => setModalState(() => selectedSize = 'Size L'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2. Chọn Đường & Đá (chỉ dành cho món trà/nước)
                    if (product.category != 'AnVat') ...[
                      const Text('2. Tùy chỉnh Đường & Đá:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['0% Ngọt', '30% Ngọt', '50% Ngọt', '70% Ngọt', '100% Ngọt'].map((sugar) {
                          return ChoiceChip(
                            label: Text(sugar, style: const TextStyle(fontSize: 12)),
                            selected: selectedSugar == sugar,
                            onSelected: (val) => setModalState(() => selectedSugar = sugar),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Nóng', '0% Đá', '50% Đá', '100% Đá'].map((ice) {
                          return ChoiceChip(
                            label: Text(ice, style: const TextStyle(fontSize: 12)),
                            selected: selectedIce == ice,
                            onSelected: (val) => setModalState(() => selectedIce = ice),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 3. Chọn Topping
                      const Text('3. Thêm Topping trà sữa:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Column(
                        children: _toppings.map((topping) {
                          final isChecked = selectedToppings.contains(topping);
                          return CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('${topping.name} (+${topping.price.toStringAsFixed(0)}đ)'),
                            value: isChecked,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedToppings.add(topping);
                                } else {
                                  selectedToppings.remove(topping);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Ghi chú riêng
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú cho pha chế (Ví dụ: Ít ngọt nhiều đá)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Số lượng & Nút thêm giỏ hàng
                    Row(
                      children: [
                        IconButton(
                          onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setModalState(() => quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _addToCart(CartItem(
                              product: product,
                              size: selectedSize,
                              sugar: selectedSugar,
                              ice: selectedIce,
                              selectedToppings: List.from(selectedToppings),
                              quantity: quantity,
                              note: noteController.text,
                            ));
                          },
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text('Thêm - ${(currentUnitPrice * quantity).toStringAsFixed(0)}đ'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Xem giỏ hàng & Thanh toán
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setCartState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Giỏ Hàng ($currentTable)', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),

                  if (_cart.isEmpty)
                    const Expanded(
                      child: Center(child: Text('Giỏ hàng trống. Mời bạn chọn món!')),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _cart.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${item.size} • ${item.sugar} • ${item.ice}\n'
                              'Topping: ${item.selectedToppings.map((e) => e.name).join(', ')}'
                              '${item.note.isNotEmpty ? '\nGhi chú: ${item.note}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${item.totalPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setCartState(() {
                                          if (item.quantity > 1) {
                                            item.quantity--;
                                          } else {
                                            _cart.removeAt(index);
                                          }
                                        });
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.remove, size: 18),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text('${item.quantity}'),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setCartState(() {
                                          item.quantity++;
                                        });
                                        setState(() {});
                                      },
                                      child: const Icon(Icons.add, size: 18),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  if (_cart.isNotEmpty) ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng thanh toán:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${_cartTotal.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () => _processOrder('CASH'),
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Tiền Mặt'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _processOrder('VietQR'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Thanh Toán VietQR'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Xử lý gửi đơn đặt món
  void _processOrder(String paymentMethod) async {
    Navigator.pop(context); // Đóng cart modal

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      tableNumber: currentTable,
      items: _cart.map((item) {
        return OrderItem(
          productName: item.product.name,
          size: item.size,
          sugar: item.sugar,
          ice: item.ice,
          toppings: item.selectedToppings.map((t) => t.name).toList(),
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        );
      }).toList(),
      totalAmount: _cartTotal,
      paymentMethod: paymentMethod,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );

    await ApiService.createOrder(newOrder);

    setState(() {
      _activeOrder = newOrder;
      _cart.clear();
    });

    if (paymentMethod == 'VietQR') {
      if (mounted) _showVietQRDialog(newOrder);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi đơn đặt món thành công! Vui lòng chờ nhân viên pha chế.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Dialog hiển thị mã VietQR thanh toán tự động
  void _showVietQRDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thanh Toán Chuyển Khoản VietQR', textAlign: TextAlign.center, style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 160, color: Colors.brown),
                  const SizedBox(height: 8),
                  Text('MBBANK: 0987654321', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  Text('Số tiền: ${order.totalAmount.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16)),
                  Text('Nội dung: ${order.tableNumber} ${order.id}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Vui lòng mở App Ngân hàng quét mã QR trên để hoàn tất thanh toán.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã Chuyển Khoản xong'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.amber),
            const SizedBox(width: 8),
            Text(currentTable, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            const Text('Menu Gọi Món Tại Bàn', style: TextStyle(fontSize: 14)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.local_cafe), text: 'Trà Sữa'),
            Tab(icon: Icon(Icons.local_drink), text: 'Trà Trái Cây'),
            Tab(icon: Icon(Icons.fastfood), text: 'Đồ Ăn Vặt'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Thanh trạng thái đơn đang gọi
                if (_activeOrder != null)
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.sync, color: Colors.brown),
                        const SizedBox(width: 8),
                        Text(
                          'Đơn ${_activeOrder!.id}: Trạng thái [${_activeOrder!.status == 'PENDING' ? 'Đang chờ' : 'Đang pha chế'}]',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductGrid('TraSua'),
                      _buildProductGrid('TraTraiCay'),
                      _buildProductGrid('AnVat'),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              onPressed: _showCartBottomSheet,
              icon: const Icon(Icons.shopping_cart),
              label: Text('Giỏ hàng (${_cart.length}) • ${_cartTotal.toStringAsFixed(0)}đ'),
            )
          : null,
    );
  }

  Widget _buildProductGrid(String category) {
    final categoryProducts = _allProducts.where((p) => p.category == category).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categoryProducts.length,
      itemBuilder: (context, index) {
        final product = categoryProducts[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _openProductCustomizationModal(product),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.brown.shade100,
                        child: const Center(child: Icon(Icons.local_cafe, size: 40, color: Colors.brown)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product.basePrice.toStringAsFixed(0)}đ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
