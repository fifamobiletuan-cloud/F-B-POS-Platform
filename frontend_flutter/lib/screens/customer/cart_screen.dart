import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../customer_order_screen.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatelessWidget {
  final void Function(OrderModel order) onOrderPlaced;

  const CartScreen({super.key, required this.onOrderPlaced});

  static const kRed = Color(0xFFA81E22);
  static const kDarkBg = Color(0xFF080808);
  static const kDarkCard = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final cart = CartProvider.of(context);
        final bg = isDark ? kDarkBg : const Color(0xFFF8F8F8);
        final cardBg = isDark ? kDarkCard : Colors.white;
        final textColor = isDark ? Colors.white : kDarkBg;
        final subColor =
            isDark ? const Color(0xFF9E9E9E) : const Color(0xFF767676);
        final divColor =
            isDark ? const Color(0xFF2B2B2B) : const Color(0xFFEEEEEE);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: ListenableBuilder(
              listenable: cart,
              builder: (context, _) {
                return Column(
                  children: [
                    // ── Header ──
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 10, 20, 10),
                      color: isDark ? kDarkCard : Colors.white,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back_rounded,
                                color: textColor),
                          ),
                          Expanded(
                            child: Text(
                              'Đơn hàng của tôi',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cart.currentTable,
                              style: const TextStyle(
                                color: kRed,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: divColor),

                    // ── Cart Items or Empty State ──
                    Expanded(
                      child: cart.items.isEmpty
                          ? _buildEmptyState(isDark, textColor, subColor)
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: cart.items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, index) =>
                                  _buildCartItem(
                                      ctx,
                                      cart,
                                      index,
                                      isDark,
                                      cardBg,
                                      textColor,
                                      subColor,
                                      divColor),
                            ),
                    ),

                    // ── Order Summary + Checkout ──
                    if (cart.items.isNotEmpty)
                      _buildCheckoutSection(
                          context, cart, isDark, cardBg, textColor, subColor),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor, Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: kRed, size: 50),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có món nào',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy chọn món từ thực đơn\nrồi quay lại đây nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(color: subColor, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartState cart,
    int index,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
    Color divColor,
  ) {
    final item = cart.items[index];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.product.imageUrl.startsWith('assets/')
                ? Image.asset(
                    item.product.imageUrl,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 75,
                      height: 75,
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.red.shade50,
                      child: const Icon(Icons.ramen_dining, color: kRed, size: 30),
                    ),
                  )
                : Image.network(
                    item.product.imageUrl,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 75,
                      height: 75,
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.red.shade50,
                      child: const Icon(Icons.ramen_dining, color: kRed, size: 30),
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.size}${item.sugar != 'Normal' ? ' · ${item.sugar}' : ''}${item.ice != 'Normal' ? ' · ${item.ice}' : ''}',
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                if (item.selectedToppings.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+ ${item.selectedToppings.map((t) => t.name.split(' ').first).join(', ')}',
                    style: const TextStyle(
                        color: kRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ],
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '📝 ${item.note}',
                    style:
                        TextStyle(color: subColor, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${item.totalPrice.toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    color: kRed,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Column(
            children: [
              GestureDetector(
                onTap: () => cart.updateQty(index, item.quantity + 1),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.quantity}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => cart.updateQty(index, item.quantity - 1),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2B2B2B)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.quantity > 1
                        ? Icons.remove
                        : Icons.delete_outline,
                    color: item.quantity > 1 ? textColor : Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartState cart,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
  ) {
    final tax = cart.tax;
    final total = cart.total;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF262626)
                  : const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal',
                    '${cart.subtotal.toStringAsFixed(0)} đ', textColor, subColor),
                const SizedBox(height: 8),
                _summaryRow('Tax (10%)',
                    '${tax.toStringAsFixed(0)} đ', textColor, subColor),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        color: kRed,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Checkout button
          GestureDetector(
            onTap: () => _checkout(context, cart),
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kRed,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40A81E22),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Đặt hàng · ${total.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label, String value, Color textColor, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subColor, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _checkout(BuildContext context, CartState cart) async {
    // Tạo order
    final orderItems = cart.items.map((item) {
      return OrderItem(
        productName: item.product.name,
        size: item.size,
        sugar: item.sugar,
        ice: item.ice,
        toppings:
            item.selectedToppings.map((t) => t.name).toList(),
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      );
    }).toList();

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      tableNumber: cart.currentTable,
      items: orderItems,
      totalAmount: cart.total,
      paymentMethod: 'VietQR',
      status: 'PREPARING',
      createdAt: DateTime.now(),
    );

    await ApiService.createOrder(newOrder);

    if (!context.mounted) return;

    // Chuyển sang màn hình xác nhận
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, _) => CartProvider(
          cart: cart,
          child: OrderConfirmationScreen(
            order: newOrder,
            onDone: () {
              cart.clear();
              onOrderPlaced(newOrder);
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
          ),
        ),
        transitionsBuilder: (ctx, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
