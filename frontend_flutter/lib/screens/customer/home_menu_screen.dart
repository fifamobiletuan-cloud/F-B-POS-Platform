import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../customer_order_screen.dart';
import 'food_detail_screen.dart';
import 'cart_screen.dart';
import '../../widgets/tiktok_lucky_wheel_dialog.dart';

// ─────────────────── Định nghĩa danh mục ───────────────────
class FoodCategory {
  final String key;
  final String emoji;
  final String label;
  final Color color;

  const FoodCategory({
    required this.key,
    required this.emoji,
    required this.label,
    required this.color,
  });
}

const List<FoodCategory> kCategories = [
  FoodCategory(key: 'All', emoji: '🍽️', label: 'Tất cả', color: Color(0xFF607D8B)),
  FoodCategory(key: 'AnVatMan', emoji: '🧂', label: 'Ăn vặt mặn', color: Color(0xFFE65100)),
  FoodCategory(key: 'DoAnCay', emoji: '🌶️', label: 'Đồ ăn cay', color: Color(0xFFD32F2F)),
  FoodCategory(key: 'NuocUong', emoji: '🥤', label: 'Nước uống', color: Color(0xFF0288D1)),
  FoodCategory(key: 'BanhNgot', emoji: '🍰', label: 'Bánh & đồ ngọt', color: Color(0xFFE91E8C)),
  FoodCategory(key: 'SnackKeo', emoji: '🍫', label: 'Snack & kẹo', color: Color(0xFF6D4C41)),
  FoodCategory(key: 'TraiCayChua', emoji: '🥭', label: 'Trái cây & chua', color: Color(0xFFF9A825)),
  FoodCategory(key: 'AnVatHanQuoc', emoji: '🧀', label: 'Ăn vặt Hàn Quốc', color: Color(0xFF7B1FA2)),
  FoodCategory(key: 'MonNoNhe', emoji: '🍜', label: 'Món no nhẹ', color: Color(0xFF388E3C)),
];

// Sub-danh mục đồ uống
const Map<String, String> kDrinkSubcats = {
  'traSua': '🧋 Trà sữa',
  'nuocEp': '🍊 Nước ép',
  'tra': '🍵 Trà',
  'cacao': '🍫 Cacao',
  'sinhTo': '🥤 Sinh tố',
  'cafe': '☕ Cà phê',
  'khac': '🧊 Khác',
};

// ─────────────────── HomeMenuScreen ───────────────────
class HomeMenuScreen extends StatefulWidget {
  final List<Product> products;
  final List<ProductOption> toppings;

  const HomeMenuScreen({
    super.key,
    required this.products,
    required this.toppings,
  });

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _selectedSubcategory = '';
  String _searchQuery = '';
  bool _showSearchSuggestions = false;
  List<Product> _searchSuggestions = [];
  bool _showFilterDropdown = false;
  OrderModel? _activeOrder;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late AnimationController _filterAnimCtrl;
  late Animation<double> _filterAnim;

  static const kRed = Color(0xFFE53935);
  static const kDarkBg = Color(0xFF0A0A0A);
  static const kDarkCard = Color(0xFF1C1C1E);
  static const kDarkCard2 = Color(0xFF2C2C2E);

  int _wonDiscountPercent = 0; // Mặc định 0 = chưa quay (hiển thị giá gốc)

  FoodCategory get _currentCategory =>
      kCategories.firstWhere((c) => c.key == _selectedCategory);

  Product _applyDiscountToProduct(Product p) {
    final orig = p.originalPrice ?? p.basePrice;
    if (_wonDiscountPercent <= 0) {
      // Khi chưa quay: Tất cả sản phẩm đều có GIÁ GỐC, không có badge khuyến mãi
      return Product(
        id: p.id,
        name: p.name,
        category: p.category,
        subcategory: p.subcategory,
        basePrice: orig,
        originalPrice: null,
        imageUrl: p.imageUrl,
        imageUrls: p.imageUrls,
        description: p.description,
        isAvailable: p.isAvailable,
        rating: p.rating,
        soldCount: p.soldCount,
      );
    }
    // Sau khi quay xong: Giảm giá theo % vừa quay được kèm giá gốc gạch ngang và badge đỏ
    final discounted = (orig * (100 - _wonDiscountPercent) / 100).roundToDouble();
    return Product(
      id: p.id,
      name: p.name,
      category: p.category,
      subcategory: p.subcategory,
      basePrice: discounted,
      originalPrice: orig,
      imageUrl: p.imageUrl,
      imageUrls: p.imageUrls,
      description: p.description,
      isAvailable: p.isAvailable,
      rating: p.rating,
      soldCount: p.soldCount,
    );
  }

  void _openLuckyWheel() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TikTokLuckyWheelDialog(
        onWonReward: (discount) {
          setState(() {
            _wonDiscountPercent = discount;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đã kích hoạt Voucher Giảm $discount% cho toàn bộ thực đơn!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFFE2C55),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  List<Product> get _filteredProducts {
    List<Product> src;
    if (_selectedCategory == 'All') {
      src = widget.products;
    } else if (_selectedCategory == 'NuocUong' && _selectedSubcategory.isNotEmpty) {
      src = widget.products
          .where((p) => p.category == 'NuocUong' && p.subcategory == _selectedSubcategory)
          .toList();
    } else {
      src = widget.products.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      src = src
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.description.toLowerCase().contains(q)))
          .toList();
    }

    return src.map(_applyDiscountToProduct).toList();
  }

  @override
  void initState() {
    super.initState();
    _filterAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _filterAnim = CurvedAnimation(parent: _filterAnimCtrl, curve: Curves.easeOutCubic);

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSearchSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _filterAnimCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
      _searchSuggestions = ApiService.searchSuggestions(val);
      _showSearchSuggestions = val.isNotEmpty;
    });
  }

  void _onSearchSubmit(String val) {
    setState(() {
      _searchQuery = val;
      _showSearchSuggestions = false;
      _selectedCategory = 'All';
    });
    _searchFocus.unfocus();
  }

  void _selectSuggestion(Product p) {
    setState(() {
      _searchController.text = p.name;
      _searchQuery = p.name;
      _showSearchSuggestions = false;
    });
    _searchFocus.unfocus();
    _navigateToDetail(p, CartProvider.of(context));
  }

  void _toggleFilter() {
    setState(() => _showFilterDropdown = !_showFilterDropdown);
    if (_showFilterDropdown) {
      _filterAnimCtrl.forward();
    } else {
      _filterAnimCtrl.reverse();
    }
  }

  void _selectCategory(String key) {
    setState(() {
      _selectedCategory = key;
      _selectedSubcategory = '';
      _showFilterDropdown = false;
    });
    _filterAnimCtrl.reverse();
  }

  void _navigateToDetail(Product product, CartState cart) {
    final discountedProduct = _applyDiscountToProduct(product);
    final allDiscountedProducts = widget.products.map(_applyDiscountToProduct).toList();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, _) => CartProvider(
          cart: cart,
          child: FoodDetailScreen(
            product: discountedProduct,
            toppings: widget.toppings,
            allProducts: allDiscountedProducts,
          ),
        ),
        transitionsBuilder: (ctx, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToCart(CartState cart) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, _) => CartProvider(
          cart: cart,
          child: CartScreen(
            onOrderPlaced: (order) => setState(() => _activeOrder = order),
          ),
        ),
        transitionsBuilder: (ctx, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (ctx, isDark, _) {
        final cart = CartProvider.of(ctx);
        final bg = isDark ? kDarkBg : const Color(0xFFF2F2F7);
        final cardBg = isDark ? kDarkCard : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final subColor = const Color(0xFF8E8E93);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: ListenableBuilder(
              listenable: cart,
              builder: (context, _) {
                return Stack(
                  children: [
                    // ── Main content ──
                    Column(
                      children: [
                        // Header
                        _buildHeader(cart, isDark, textColor, subColor, cardBg),

                        // Search + Filter row
                        _buildSearchRow(isDark, textColor, subColor, cardBg),

                        // Filter dropdown (animated)
                        _buildFilterDropdown(isDark, cardBg, textColor),

                        // Search suggestions overlay
                        if (_showSearchSuggestions && _searchSuggestions.isNotEmpty)
                          _buildSearchSuggestions(cart, isDark, cardBg, textColor, subColor),

                        // Scrollable content
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              // Active order banner
                              if (_activeOrder != null)
                                SliverToBoxAdapter(
                                  child: _buildActiveOrderBanner(isDark, subColor),
                                ),

                              // Promo banner
                              SliverToBoxAdapter(child: _buildPromoBanner()),

                              // Category chips (2 rows)
                              SliverToBoxAdapter(
                                child: _buildCategoryGrid(isDark, cardBg, textColor),
                              ),

                              // Sub-category for drinks
                              if (_selectedCategory == 'NuocUong')
                                SliverToBoxAdapter(
                                  child: _buildDrinkSubcategories(isDark, cardBg, textColor),
                                ),

                              const SliverToBoxAdapter(child: SizedBox(height: 6)),

                              // Section header
                              SliverToBoxAdapter(
                                child: _buildSectionHeader(isDark, textColor),
                              ),

                              // Popular (horizontal) only for All
                              if (_selectedCategory == 'All' && _searchQuery.isEmpty) ...[
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 230,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: widget.products.length > 8 ? 8 : widget.products.length,
                                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                                      itemBuilder: (ctx, i) => _buildPopularCard(
                                          _applyDiscountToProduct(widget.products[i]), cart, isDark, cardBg, textColor, subColor),
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('Tất cả sản phẩm',
                                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                              ],

                              // Product list
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                                sliver: _filteredProducts.isEmpty
                                    ? SliverToBoxAdapter(
                                        child: _buildEmptyState(isDark, textColor),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (ctx, i) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _buildProductCard(
                                              _filteredProducts[i], cart, isDark, cardBg, textColor, subColor),
                                          ),
                                          childCount: _filteredProducts.length,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Cart bar
                    if (cart.itemCount > 0)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: _buildCartBar(cart, isDark),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ─────────────────── HEADER ───────────────────
  Widget _buildHeader(CartState cart, bool isDark, Color textColor, Color subColor, Color cardBg) {
    return Container(
      color: cardBg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showChangeTableDialog(cart, isDark),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: kRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.table_restaurant, color: kRed, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bàn của bạn', style: TextStyle(color: subColor, fontSize: 11)),
                      Row(children: [
                        Text(cart.currentTable,
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 3),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: subColor),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => isDarkModeNotifier.value = !isDarkModeNotifier.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                  color: isDark ? kDarkCard2 : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: isDark ? Colors.amber : const Color(0xFF3C3C43),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _navigateToCart(cart),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Text('${cart.itemCount}',
                          style: const TextStyle(color: kRed, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── SEARCH + FILTER ROW ───────────────────
  Widget _buildSearchRow(bool isDark, Color textColor, Color subColor, Color cardBg) {
    final searchBg = isDark ? kDarkCard : Colors.white;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _searchFocus.hasFocus ? kRed : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
                    width: _searchFocus.hasFocus ? 2 : 1),
                boxShadow: _showSearchSuggestions ? [
                  BoxShadow(color: kRed.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                ] : null,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: TextStyle(color: textColor, fontSize: 14),
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmit,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  prefixIcon: Icon(Icons.search, color: _searchFocus.hasFocus ? kRed : subColor, size: 20),
                  hintText: 'Tìm kiếm món ăn, đồ uống...',
                  hintStyle: TextStyle(color: subColor, fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: subColor, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter button
          GestureDetector(
            onTap: _toggleFilter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _showFilterDropdown ? kRed : (isDark ? kDarkCard : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _showFilterDropdown ? kRed : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA))),
                boxShadow: _showFilterDropdown ? [
                  BoxShadow(color: kRed.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                ] : null,
              ),
              child: Icon(
                _showFilterDropdown ? Icons.close_rounded : Icons.filter_list_rounded,
                color: _showFilterDropdown ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF3C3C43)),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── FILTER DROPDOWN ───────────────────
  Widget _buildFilterDropdown(bool isDark, Color cardBg, Color textColor) {
    return SizeTransition(
      sizeFactor: _filterAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kRed.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_list_rounded, color: kRed, size: 18),
                  const SizedBox(width: 8),
                  Text('Chọn danh mục', style: TextStyle(
                      color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            ...kCategories.map((cat) {
              final isSelected = _selectedCategory == cat.key;
              return InkWell(
                onTap: () => _selectCategory(cat.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? cat.color.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            color: isSelected ? cat.color : textColor,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, color: cat.color, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─────────────────── SEARCH SUGGESTIONS ───────────────────
  Widget _buildSearchSuggestions(CartState cart, bool isDark, Color cardBg, Color textColor, Color subColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? kDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 6))],
        border: Border.all(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                Icon(Icons.search, color: kRed, size: 16),
                const SizedBox(width: 6),
                Text('Gợi ý tìm kiếm',
                    style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._searchSuggestions.map((rawP) {
            final p = _applyDiscountToProduct(rawP);
            return InkWell(
              onTap: () => _selectSuggestion(p),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildSmartImage(p.imageUrl, 40, 40),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${p.basePrice.toStringAsFixed(0)}đ · ${_getCategoryName(p.category)}',
                              style: TextStyle(color: subColor, fontSize: 11)),
                        ],
                      ),
                    ),
                  Icon(Icons.north_west_rounded, color: subColor, size: 16),
                ],
              ),
            ),
          );
        }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─────────────────── ACTIVE ORDER BANNER ───────────────────
  Widget _buildActiveOrderBanner(bool isDark, Color subColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2A12) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade400),
        ),
        child: Row(
          children: [
            const Text('✅', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đơn ${_activeOrder!.id} đang được chuẩn bị!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.greenAccent : Colors.green.shade800)),
                  Text('Nhân viên sẽ mang đến bàn bạn sớm...',
                      style: TextStyle(fontSize: 11, color: subColor)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
              child: const Text('Đang làm',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── PROMO BANNER ───────────────────
  Widget _buildPromoBanner() {
    final bool hasVoucher = _wonDiscountPercent > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GestureDetector(
        onTap: _openLuckyWheel,
        child: Container(
          height: 95,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasVoucher
                  ? [const Color(0xFF880E4F), const Color(0xFFC2185B), const Color(0xFFFE2C55)]
                  : [const Color(0xFFB71C1C), const Color(0xFFE53935), const Color(0xFFFF5722)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (hasVoucher ? const Color(0xFFFE2C55) : const Color(0xFFE53935))
                    .withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                top: -15,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(hasVoucher ? '🎁' : '🎡', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasVoucher
                                ? '🎉 Đang áp dụng Voucher -$_wonDiscountPercent%!'
                                : 'Ưu đãi giảm giá lên đến 50% quay ngayyyy',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hasVoucher
                                ? '⚡ Đã giảm giá toàn bộ món ăn'
                                : '⚡ Vòng quay may mắn nhận voucher khủng',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasVoucher ? 'Quay lại' : 'Quay ngay',
                            style: TextStyle(
                              color: hasVoucher ? const Color(0xFFC2185B) : const Color(0xFFE53935),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text('🎡', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────── CATEGORY GRID (2 rows) ───────────────────
  Widget _buildCategoryGrid(bool isDark, Color cardBg, Color textColor) {
    final cats = kCategories;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Danh mục', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cats.take(5).map((cat) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildCategoryChip(cat, isDark, cardBg, textColor),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cats.skip(5).map((cat) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildCategoryChip(cat, isDark, cardBg, textColor),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(FoodCategory cat, bool isDark, Color cardBg, Color textColor) {
    final isSelected = _selectedCategory == cat.key;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategory = cat.key;
        _selectedSubcategory = '';
        _showFilterDropdown = false;
        _filterAnimCtrl.reverse();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? cat.color : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? cat.color : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
              width: isSelected ? 0 : 1),
          boxShadow: isSelected ? [
            BoxShadow(color: cat.color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(cat.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF3C3C43)),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  // ─────────────────── DRINK SUB-CATEGORIES ───────────────────
  Widget _buildDrinkSubcategories(bool isDark, Color cardBg, Color textColor) {
    final subMap = ApiService.getDrinkSubcategories();
    final keys = subMap.keys.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loại đồ uống', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "Tất cả" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSubcategory = ''),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedSubcategory.isEmpty ? const Color(0xFF0288D1) : (isDark ? kDarkCard2 : const Color(0xFFF2F2F7)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('🥤 Tất cả',
                          style: TextStyle(
                            color: _selectedSubcategory.isEmpty ? Colors.white : textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
                ...keys.map((key) {
                  final isSelected = _selectedSubcategory == key;
                  final label = kDrinkSubcats[key] ?? key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSubcategory = key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0288D1) : (isDark ? kDarkCard2 : const Color(0xFFF2F2F7)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textColor,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            )),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── SECTION HEADER ───────────────────
  Widget _buildSectionHeader(bool isDark, Color textColor) {
    final cat = _currentCategory;
    final count = _filteredProducts.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          if (_searchQuery.isNotEmpty)
            const Text('🔍', style: TextStyle(fontSize: 20))
          else
            Text(cat.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Kết quả: "$_searchQuery"'
                  : (_selectedCategory == 'All' ? '🔥 Phổ biến nhất' : cat.label),
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text('$count sản phẩm',
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
        ],
      ),
    );
  }

  // ─────────────────── EMPTY STATE ───────────────────
  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('Không tìm thấy sản phẩm',
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Thử từ khóa khác hoặc chọn danh mục khác',
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
        ],
      ),
    );
  }

  // ─────────────────── POPULAR CARD ───────────────────
  Widget _buildPopularCard(Product item, CartState cart, bool isDark, Color cardBg, Color textColor, Color subColor) {
    return GestureDetector(
      onTap: () => _navigateToDetail(item, cart),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildSmartImage(item.imageUrl, double.infinity, 115),
                ),
                if (item.discountPercent > 0)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(6)),
                      child: Text('-${item.discountPercent}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 12),
                      const SizedBox(width: 2),
                      Text('${item.rating}', style: TextStyle(color: subColor, fontSize: 10)),
                      const SizedBox(width: 3),
                      Text('· ${_formatSold(item.soldCount)}', style: TextStyle(color: subColor, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.basePrice.toStringAsFixed(0)}đ',
                          style: const TextStyle(color: kRed, fontSize: 13, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => _navigateToDetail(item, cart),
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── PRODUCT CARD ───────────────────
  Widget _buildProductCard(Product item, CartState cart, bool isDark, Color cardBg, Color textColor, Color subColor) {
    return GestureDetector(
      onTap: () => _navigateToDetail(item, cart),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: _buildSmartImage(item.imageUrl, 110, 110),
                ),
                if (item.discountPercent > 0)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(6)),
                      child: Text('-${item.discountPercent}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: subColor, fontSize: 11, height: 1.4)),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 13),
                        const SizedBox(width: 2),
                        Text('${item.rating}', style: TextStyle(color: subColor, fontSize: 11)),
                        const SizedBox(width: 6),
                        Text('Đã bán ${_formatSold(item.soldCount)}',
                            style: TextStyle(color: subColor, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.basePrice.toStringAsFixed(0)}đ',
                                style: const TextStyle(color: kRed, fontSize: 15, fontWeight: FontWeight.bold)),
                            if (item.originalPrice != null)
                              Text('${item.originalPrice!.toStringAsFixed(0)}đ',
                                  style: TextStyle(color: subColor, fontSize: 11, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _navigateToDetail(item, cart),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 15),
                                SizedBox(width: 4),
                                Text('Thêm', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────── CART BAR ───────────────────
  Widget _buildCartBar(CartState cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? kDarkCard : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text('${cart.itemCount} món',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: () => _navigateToCart(cart),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Text('Xem đơn · ${cart.subtotal.toStringAsFixed(0)}đ',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── SMART IMAGE (asset hoặc network) ───────────────────
  Widget _buildSmartImage(String url, double width, double height) {
    final isAsset = url.startsWith('assets/');
    if (isAsset) {
      return Image.asset(
        url,
        width: width == double.infinity ? null : width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(width, height),
      );
    } else {
      return Image.network(
        url,
        width: width == double.infinity ? null : width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(width, height),
      );
    }
  }

  Widget _imagePlaceholder(double width, double height) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      color: isDarkModeNotifier.value ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
      child: const Icon(Icons.fastfood, color: kRed, size: 36),
    );
  }

  // ─────────────────── CHANGE TABLE DIALOG ───────────────────
  void _showChangeTableDialog(CartState cart, bool isDark) {
    final ctrl = TextEditingController(text: cart.currentTable);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? kDarkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Đổi bàn',
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Ví dụ: Bàn 05',
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            prefixIcon: const Icon(Icons.table_restaurant, color: kRed),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kRed, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Huỷ', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) cart.setTable(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatSold(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  String _getCategoryName(String key) {
    return kCategories.firstWhere((c) => c.key == key, orElse: () => kCategories[0]).label;
  }
}
