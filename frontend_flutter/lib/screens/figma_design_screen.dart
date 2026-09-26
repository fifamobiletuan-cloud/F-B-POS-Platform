import 'package:flutter/material.dart';

// Giao diện Figma Chuẩn 100% Pixel-Perfect xuất từ Figma Plugin
class FigmaDesignScreen extends StatelessWidget {
  const FigmaDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12202F),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            Center(child: ScanQrCodeFigmaWidget()),
            const SizedBox(height: 30),
            Center(child: FoodMenuFigmaWidget()),
            const SizedBox(height: 30),
            Center(child: BirthdayPromoFigmaWidget()),
          ],
        ),
      ),
    );
  }
}

// 1. Màn Hình Quét QR Figma Chuẩn
class ScanQrCodeFigmaWidget extends StatelessWidget {
  const ScanQrCodeFigmaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 844,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF080808),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Content Center
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 390,
              height: 844,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Camera Box
                  Container(
                    width: double.infinity,
                    height: 500,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(0.50, 0.00),
                        end: const Alignment(0.50, 1.00),
                        colors: [
                          Colors.black.withValues(alpha: 0.60),
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.60)
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top Left Corner
                        Positioned(
                          left: 63,
                          top: 138,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 2.61,
                                  color: Color(0xFFA81E22),
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                        // Top Right Corner
                        Positioned(
                          left: 254.99,
                          top: 138,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 2.61,
                                  color: Color(0xFFA81E22),
                                ),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                        // Bottom Left Corner
                        Positioned(
                          left: 63,
                          top: 329.99,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 2.61,
                                  color: Color(0xFFA81E22),
                                ),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                        // Bottom Right Corner
                        Positioned(
                          left: 254.99,
                          top: 329.99,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 2.61,
                                  color: Color(0xFFA81E22),
                                ),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                        // Scanning Line
                        Positioned(
                          left: 67,
                          top: 249,
                          child: Container(
                            width: 215.99,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(0.00, 0.50),
                                end: const Alignment(1.00, 0.50),
                                colors: [
                                  Colors.black.withValues(alpha: 0),
                                  const Color(0xFFA81E22),
                                  Colors.black.withValues(alpha: 0)
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFA81D22),
                                  blurRadius: 8,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title Text
                  const SizedBox(
                    width: 350,
                    child: Text(
                      'Point camera at the QR code on your table',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(
                    width: 350,
                    child: Text(
                      'Make sure the QR code is within the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF767676),
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w400,
                        height: 1.29,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Button Manual
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Enter table number manually',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF080808),
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                        height: 1.29,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Status Bar 9:41
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 390,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, color: Colors.white, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Top Bar Title
          Positioned(
            left: 0,
            top: 41,
            child: Container(
              width: 390,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
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
}

// 2. Màn Hình Menu Thực Đơn Figma Chuẩn
class FoodMenuFigmaWidget extends StatelessWidget {
  const FoodMenuFigmaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 844,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Content
          Positioned.fill(
            top: 90,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    color: Colors.black.withValues(alpha: 0.04),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF5F5F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search,
                                    color: Color(0xFF767676), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Search ramen, gyoza, drinks...',
                                  style: TextStyle(
                                    color: Color(0xFF767676),
                                    fontSize: 14,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFA81E22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Pills Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildCategoryPill('All', isSelected: true),
                        const SizedBox(width: 8),
                        _buildCategoryPill('Ramen'),
                        const SizedBox(width: 8),
                        _buildCategoryPill('Sides'),
                        const SizedBox(width: 8),
                        _buildCategoryPill('Drinks'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 Popular Now Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '🔥 Popular Now',
                      style: TextStyle(
                        color: Color(0xFF080808),
                        fontSize: 18,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Popular Now Cards Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildPopularCard(
                          'Shoyu Ramen',
                          '650 kcal',
                          '\$13.99',
                          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
                        ),
                        const SizedBox(width: 14),
                        _buildPopularCard(
                          'Iced Green Tea',
                          '700 kcal',
                          '\$12.99',
                          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // All Items Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'All Items',
                      style: TextStyle(
                        color: Color(0xFF080808),
                        fontSize: 18,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // All Items Vertical List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildAllItemCard(
                          'Shoyu Ramen',
                          'Soy sauce-based chicken broth with ramen noodles, sliced chashu pork, soft-boiled egg',
                          '650 kcal',
                          '\$13.99',
                          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
                        ),
                        const SizedBox(height: 12),
                        _buildAllItemCard(
                          'Tonkotsu Ramen',
                          'Creamy pork bone broth simmered for hours, served with chashu pork, soft egg, and black garlic oil',
                          '580 cal',
                          '\$15.99',
                          'https://images.unsplash.com/photo-1591814468924-caf88d1232e1?w=400',
                        ),
                        const SizedBox(height: 12),
                        _buildAllItemCard(
                          'Miso Ramen',
                          'Rich miso broth with ground pork, corn, butter, bean sprouts, and scallions',
                          '580 cal',
                          '\$14.99',
                          'https://images.unsplash.com/photo-1623341214825-9f4f963727da?w=400',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Header Seating Bar
          Positioned(
            left: 0,
            top: 42,
            child: Container(
              width: 390,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You\'re seated at',
                        style: TextStyle(
                          color: Color(0xFF767676),
                          fontSize: 10,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      Text(
                        'Table A8',
                        style: TextStyle(
                          color: Color(0xFF080808),
                          fontSize: 14,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFA81E22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'My Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Color(0xFFA81E22),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Bottom Bar
          Positioned(
            left: 20,
            top: 747,
            child: Container(
              width: 350,
              decoration: ShapeDecoration(
                color: const Color(0xFF080808),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x230A0C12),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      '3 dishes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFA81E22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Confirm Order · \$45.97',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                      ],
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

  Widget _buildCategoryPill(String title, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color:
            isSelected ? const Color(0xFFA81E22) : const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF080808),
          fontSize: 12,
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPopularCard(
      String title, String kcal, String price, String imgUrl) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C0A0C12),
            blurRadius: 4,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imgUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF080808),
              fontSize: 14,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            kcal,
            style: const TextStyle(
              color: Color(0xFF767676),
              fontSize: 10,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFFA81E22),
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFA81E22),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemCard(
      String title, String desc, String kcal, String price, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C0A0C12),
            blurRadius: 4,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imgUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF080808),
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF767676),
                    fontSize: 11,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFFA81E22),
                        fontSize: 14,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFA81E22),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Banner Sinh Nhật Figma Chuẩn
class BirthdayPromoFigmaWidget extends StatelessWidget {
  const BirthdayPromoFigmaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF7D1F22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free ramen on your birthday! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Claim your treat within your birthday week',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: ShapeDecoration(
                color: const Color(0xFFF5F5F5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Claim Now',
                style: TextStyle(
                  color: Color(0xFF080808),
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
