import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../customer_order_screen.dart';

Widget _smartImg(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  Widget err = Container(
    width: width,
    height: height,
    color: const Color(0xFF2C2C2E),
    child: const Icon(Icons.fastfood, color: Color(0xFFE53935), size: 40),
  );
  if (url.startsWith('assets/')) {
    return Image.asset(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => err,
    );
  }
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => err,
  );
}

class FoodDetailScreen extends StatefulWidget {
  final Product product;
  final List<ProductOption> toppings;
  final List<Product> allProducts;

  const FoodDetailScreen({
    super.key,
    required this.product,
    required this.toppings,
    required this.allProducts,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  String _size = 'M';
  String _sugar = '100%';
  String _ice = '100% đá';
  final Set<ProductOption> _selectedToppings = {};
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  static const kRed = Color(0xFFE53935);

  List<String> get _sizes => ['S', 'M', 'L', 'XL'];
  List<String> get _sugars => ['0%', '30%', '50%', '70%', '100%'];
  List<String> get _ices => ['Nóng', 'Không đá', '30% đá', '70% đá', '100% đá'];

  double get _totalPrice {
    double t = widget.product.basePrice * _quantity;
    for (final tp in _selectedToppings) {
      t += tp.price * _quantity;
    }
    return t;
  }

  String _formatSold(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  bool _isDrink() {
    return widget.product.category == 'NuocUong';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (ctx, isDark, _) {
        final cart = CartProvider.of(ctx);
        final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF2F2F7);
        final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final subColor = const Color(0xFF8E8E93);

        final images = widget.product.imageUrls.isNotEmpty
            ? widget.product.imageUrls
            : [widget.product.imageUrl];
        final suggested = ApiService.getSuggestedProducts(widget.product.id, count: 8);

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ── Image Carousel Header ──
                  SliverToBoxAdapter(
                    child: _buildCarousel(images, isDark, textColor, subColor),
                  ),

                  // ── Product Info ──
                  SliverToBoxAdapter(
                    child: Container(
                      color: cardBg,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.discountPercent > 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: kRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🔥 Flash Sale -${widget.product.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                if (i < widget.product.rating.floor()) {
                                  return const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16);
                                } else if (i < widget.product.rating) {
                                  return const Icon(Icons.star_half_rounded, color: Color(0xFFFFC107), size: 16);
                                }
                                return const Icon(Icons.star_outline_rounded, color: Color(0xFFFFC107), size: 16);
                              }),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.product.rating}',
                                style: const TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '|  Đã bán ${_formatSold(widget.product.soldCount)}',
                                style: TextStyle(color: subColor, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '${widget.product.basePrice.toStringAsFixed(0)}đ',
                                style: const TextStyle(
                                  color: kRed,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.product.originalPrice != null) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '${widget.product.originalPrice!.toStringAsFixed(0)}đ',
                                  style: TextStyle(
                                    color: subColor,
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Mô tả sản phẩm',
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.product.description,
                            style: TextStyle(color: subColor, fontSize: 13, height: 1.6),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // ── Gallery scroll ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hình ảnh sản phẩm',
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 90,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (ctx, i) => GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    i,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  setState(() => _currentImageIndex = i);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _currentImageIndex == i ? kRed : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: _smartImg(images[i], width: 90, height: 90),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Customization ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOptionSection(
                            title: '📏 Kích cỡ',
                            options: _sizes,
                            selected: _size,
                            onSelect: (v) => setState(() => _size = v),
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 16),
                          if (_isDrink()) ...[
                            _buildOptionSection(
                              title: '🍬 Độ ngọt',
                              options: _sugars,
                              selected: _sugar,
                              onSelect: (v) => setState(() => _sugar = v),
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 16),
                            _buildOptionSection(
                              title: '🧊 Lượng đá',
                              options: _ices,
                              selected: _ice,
                              onSelect: (v) => setState(() => _ice = v),
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (widget.toppings.isNotEmpty) ...[
                            Text(
                              '✨ Topping thêm',
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ...widget.toppings.map((t) => _buildToppingRow(t, isDark, textColor, subColor)),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            '📝 Ghi chú',
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noteController,
                            style: TextStyle(color: textColor, fontSize: 13),
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: không hành, ít cay...',
                              hintStyle: TextStyle(color: subColor),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Gợi ý sản phẩm ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Text(
                        '🎲 Có thể bạn thích',
                        style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildSuggestedCard(suggested[i], cart, isDark, cardBg, textColor, subColor),
                        childCount: suggested.length,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Bottom Bar ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(cart, isDark, textColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarousel(List<String> images, bool isDark, Color textColor, Color subColor) {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemCount: images.length,
            itemBuilder: (ctx, i) => _smartImg(images[i], width: double.infinity, height: 340),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 90,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImageIndex == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == i ? kRed : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSection({
    required String title,
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kRed : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kRed : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToppingRow(ProductOption t, bool isDark, Color textColor, Color subColor) {
    final isSelected = _selectedToppings.contains(t);
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedToppings.remove(t);
        } else {
          _selectedToppings.add(t);
        }
      }),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? kRed : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isSelected ? kRed : subColor, width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(t.name, style: TextStyle(color: textColor, fontSize: 14))),
            Text(
              '+${t.price.toStringAsFixed(0)}đ',
              style: const TextStyle(color: kRed, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedCard(
    Product item,
    CartState cart,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subColor,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, animation, _) => CartProvider(
            cart: cart,
            child: FoodDetailScreen(
              product: item,
              toppings: widget.toppings,
              allProducts: widget.allProducts,
            ),
          ),
          transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: _smartImg(item.imageUrl, height: 130, width: double.infinity),
                ),
                if (item.discountPercent > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '-${item.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 12),
                      const SizedBox(width: 2),
                      Text('${item.rating}', style: TextStyle(color: subColor, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.basePrice.toStringAsFixed(0)}đ',
                    style: const TextStyle(color: kRed, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(CartState cart, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  if (_quantity > 1) _quantity--;
                }),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.remove, color: textColor, size: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_quantity',
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _quantity++),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                final item = CartItem(
                  product: widget.product,
                  size: _size,
                  sugar: _sugar,
                  ice: _ice,
                  selectedToppings: _selectedToppings.toList(),
                  quantity: _quantity,
                  note: _noteController.text,
                );
                cart.addItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Đã thêm ${widget.product.name} vào giỏ!')),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: kRed,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: kRed.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Thêm · ${_totalPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
