import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// Helper: tạo đường dẫn asset cho Flutter Web
String _img(String path) => 'assets/images/$path';

class ApiService {
  static const String baseUrl = 'http://localhost:8085/api/v1';

  // ─────────────────────────────────────────────────────────
  //  DANH MỤC ĂN VẶT VIỆT NAM — TikTok Shop Style
  //  Dùng ảnh thật từ assets/images/ + Unsplash
  // ─────────────────────────────────────────────────────────
  static final List<Product> _mockProducts = [

    // ══════════════════════════════════════════
    //  🧂 Ăn vặt mặn
    // ══════════════════════════════════════════
    Product(
      id: '1', name: 'Cá viên chiên', category: 'AnVatMan',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.9, soldCount: 3200,
      imageUrl: _img('anvatman/cavienchien/cavien1.jpg'),
      imageUrls: [
        _img('anvatman/cavienchien/cavien1.jpg'),
        _img('anvatman/cavienchien/cavien2.jpg'),
        _img('anvatman/cavienchien/cavien3.jpg'),
        _img('anvatman/cavienchien/cavien4.jpg'),
        _img('anvatman/cavienchien/cavien5.jpg'),
        _img('anvatman/cavienchien/cavien7.jpg'),
        _img('anvatman/cavienchien/cavien1.jpg'),
      ],
      description:
          '🐟 Cá viên chiên giòn rụm, nhân cá thật béo ngậy, sốt tương ớt đặc biệt. Được làm từ cá biển tươi, không chất bảo quản. Ăn nóng ngon hơn — mỗi xiên 5 viên cá viên vàng ươm giòn tan!',
    ),
    Product(
      id: '2', name: 'Xúc xích nướng', category: 'AnVatMan',
      basePrice: 12000, originalPrice: 20000,
      rating: 4.7, soldCount: 2800,
      imageUrl: _img('anvatman/xucxich/xucxich1.jpg'),
      imageUrls: [
        _img('anvatman/xucxich/xucxich1.jpg'),
        _img('anvatman/xucxich/xucxich2.jpg'),
        _img('anvatman/xucxich/xucxich3.jpg'),
        _img('anvatman/xucxich/xucxich4.jpg'),
        _img('anvatman/xucxich/xucxich5.jpg'),
        _img('anvatman/xucxich/xucxich6.jpg'),
        _img('anvatman/xucxich/xucxich7.jpg'),
      ],
      description:
          '🌭 Xúc xích heo nướng than hoa thơm lừng, da giòn bên ngoài, bên trong mọng nước. Ăn kèm tương ớt & tương cà. Đặc biệt không phẩm màu, không chất bảo quản — an toàn tuyệt đối!',
    ),
    Product(
      id: '3', name: 'Khoai tây chiên', category: 'AnVatMan',
      basePrice: 18000, originalPrice: 30000,
      rating: 4.8, soldCount: 4100,
      imageUrl: _img('anvatman/khoaitaychien/khoaitay1.jpg'),
      imageUrls: [
        _img('anvatman/khoaitaychien/khoaitay1.jpg'),
        _img('anvatman/khoaitaychien/khoaitay2.jpg'),
        _img('anvatman/khoaitaychien/khoaitay3.jpg'),
        _img('anvatman/khoaitaychien/khoaitay4.jpg'),
        _img('anvatman/khoaitaychien/khoaitay5.jpg'),
        _img('anvatman/khoaitaychien/khoaitay6.jpg'),
        _img('anvatman/khoaitaychien/khoaitay7.jpg'),
      ],
      description:
          '🍟 Khoai tây chiên vàng giòn kiểu Mỹ, được cắt lát đều tay, chiên ngập dầu ở nhiệt độ cao. Rắc muối tiêu phô mai, ăn kèm sốt mayonnaise Nhật Bản. Giòn từ đầu đến cuối!',
    ),
    Product(
      id: '4', name: 'Phô mai que', category: 'AnVatMan',
      basePrice: 20000, originalPrice: 35000,
      rating: 4.9, soldCount: 2100,
      imageUrl: _img('anvatman/phomaique/phomai1.jpg'),
      imageUrls: [
        _img('anvatman/phomaique/phomai1.jpg'),
        _img('anvatman/phomaique/phomai2.jpg'),
        _img('anvatman/phomaique/phomai3.jpg'),
        _img('anvatman/phomaique/phomai4.jpg'),
        _img('anvatman/phomaique/phomai5.jpg'),
        _img('anvatman/phomaique/phomai6.jpg'),
        _img('anvatman/phomaique/phomai1.jpg'),
      ],
      description:
          '🧀 Phô mai que mozzarella kéo sợi cực đã, lớp bột chiên giòn vàng ươm bên ngoài, phô mai chảy dẻo bên trong. Ăn với sốt marinara cà chua hoặc tương ớt ngọt Thái Lan. Kéo sợi siêu đã!',
    ),
    Product(
      id: '5', name: 'Nem chua rán', category: 'AnVatMan',
      basePrice: 10000, originalPrice: 18000,
      rating: 4.6, soldCount: 5600,
      imageUrl: _img('anvatman/nemchuaran/images (1).jpg'),
      imageUrls: [
        _img('anvatman/nemchuaran/images (1).jpg'),
        _img('anvatman/nemchuaran/images (2).jpg'),
        _img('anvatman/nemchuaran/images (3).jpg'),
        _img('anvatman/nemchuaran/images (4).jpg'),
        _img('anvatman/nemchuaran/images (5).jpg'),
        _img('anvatman/nemchuaran/images (6).jpg'),
        _img('anvatman/nemchuaran/images.jpg'),
      ],
      description:
          '🥟 Nem chua rán đặc sản truyền thống — lớp vỏ giòn, nhân nem chua thơm đậm đà. Chua cay ngọt hài hòa, ăn kèm tỏi ớt. Mỗi phần 3 chiếc, ăn vặt cực đã buổi chiều!',
    ),
    // --- NEW AnVatMan products ---
    Product(
      id: '101', name: 'Bắp xào bơ', category: 'AnVatMan',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.7, soldCount: 2900,
      imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
      ],
      description:
          '🌽 Bắp xào bơ tươi thơm lừng — bắp ngọt lựa chọn từ vùng Đà Lạt, xào với bơ Anchor béo ngậy, muối tiêu và đường. Ngọt giòn từng hạt, ăn là ghiền. Món ăn vặt lành mạnh số 1!',
    ),
    Product(
      id: '102', name: 'Trứng cút chiên', category: 'AnVatMan',
      basePrice: 8000, originalPrice: 14000,
      rating: 4.5, soldCount: 4200,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🥚 Trứng cút chiên giòn vàng — trứng cút tươi luộc vừa chín, chiên ngập dầu vàng giòn bên ngoài. Chấm muối tiêu chanh hoặc tương ớt cay. Xiên 5 trứng, ăn vặt vỉa hè kinh điển!',
    ),
    Product(
      id: '103', name: 'Đậu hũ chiên mắm', category: 'AnVatMan',
      basePrice: 15000, originalPrice: 22000,
      rating: 4.6, soldCount: 3100,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
      ],
      description:
          '🍢 Đậu hũ chiên mắm tỏi ớt — đậu hũ non chiên giòn vàng ươm, sốt mắm tỏi ớt đặc biệt thấm đều. Ngoài giòn, trong mềm mịn. Ăn kèm rau sống, đậm đà không ngán. Món chay ngon đỉnh!',
    ),
    Product(
      id: '104', name: 'Bánh gạo chiên', category: 'AnVatMan',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 2700,
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🍘 Bánh gạo chiên giòn kiểu Hàn — bánh gạo hình trụ dài chiên phồng giòn rụm, rắc muối mè thơm. Ngoài giòn trong dai, vị nhạt dịu ăn kèm tương ớt ngọt. Snack lành mạnh đang hot!',
    ),
    Product(
      id: '105', name: 'Hành tây chiên xù', category: 'AnVatMan',
      basePrice: 12000, originalPrice: 20000,
      rating: 4.5, soldCount: 3500,
      imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=700&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=800&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🧅 Hành tây chiên xù giòn rụm — hành tây thái vòng to, tẩm bột chiên xù vàng giòn kiểu Bloomin Onion. Thơm ngọt tự nhiên, giòn tan đỉnh cao. Chấm mayonnaise hoặc sốt BBQ cực đã!',
    ),
    Product(
      id: '106', name: 'Bò viên nướng', category: 'AnVatMan',
      basePrice: 20000, originalPrice: 30000,
      rating: 4.8, soldCount: 3800,
      imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🔥 Bò viên nướng than hoa đặc biệt — bò viên thật 100% thịt bò Úc xay nhuyễn, nướng trên than hoa thơm phức. Chấm sốt mắm tỏi ớt đặc trưng. Mỗi xiên 4 viên — đã miệng cực kỳ!',
    ),

    // ══════════════════════════════════════════
    //  🌶️ Đồ ăn cay
    // ══════════════════════════════════════════
    Product(
      id: '6', name: 'Bánh tráng cuộn', category: 'DoAnCay',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.8, soldCount: 5400,
      imageUrl: _img('doancay/banhtrangcuon/cuon1.jpg'),
      imageUrls: [
        _img('doancay/banhtrangcuon/cuon1.jpg'),
        _img('doancay/banhtrangcuon/cuon2.jpg'),
        _img('doancay/banhtrangcuon/cuon3.jpg'),
        _img('doancay/banhtrangcuon/cuon4.jpg'),
        _img('doancay/banhtrangcuon/cuon5.jpg'),
        _img('doancay/banhtrangcuon/cuon6.jpg'),
        _img('doancay/banhtrangcuon/cuon7.jpg'),
      ],
      description:
          '🌯 Bánh tráng cuộn cay đặc biệt — bánh tráng mỏng cuộn các loại rau, thịt, tôm và sốt mắm tỏi ớt chua ngọt. Ăn vặt tuổi thơ, ngon mà không ngấy. Cuộn to tay, ăn thật đã miệng!',
    ),
    Product(
      id: '7', name: 'Bánh tráng trộn', category: 'DoAnCay',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.9, soldCount: 8200,
      imageUrl: _img('doancay/banhtrangtron/tron1.jpg'),
      imageUrls: [
        _img('doancay/banhtrangtron/tron1.jpg'),
        _img('doancay/banhtrangtron/tron2.jpg'),
        _img('doancay/banhtrangtron/tron3.jpg'),
        _img('doancay/banhtrangtron/tron4.jpg'),
        _img('doancay/banhtrangtron/tron5.jpg'),
        _img('doancay/banhtrangtron/tron6.jpg'),
        _img('doancay/banhtrangtron/tron7.jpg'),
      ],
      description:
          '🥗 Bánh tráng trộn cay ngọt — bánh tráng bóc trộn cùng bơ khô, trứng cút, khô bò, sa tế mắm ruốc. Đặc sản vỉa hè Sài Gòn, hương vị cay ngọt mặn đậm đà không thể quên!',
    ),
    Product(
      id: '8', name: 'Chân gà cay', category: 'DoAnCay',
      basePrice: 25000, originalPrice: 40000,
      rating: 4.7, soldCount: 3900,
      imageUrl: _img('doancay/changacay/changa1.jpg'),
      imageUrls: [
        _img('doancay/changacay/changa.jpg'),
        _img('doancay/changacay/changa1.jpg'),
        _img('doancay/changacay/changa2.jpg'),
        _img('doancay/changacay/changa3.jpg'),
        _img('doancay/changacay/changa1.jpg'),
        _img('doancay/changacay/changa2.jpg'),
        _img('doancay/changacay/changa3.jpg'),
      ],
      description:
          '🍗 Chân gà ngâm sả ớt cay nồng — chân gà tươi luộc chín, ngâm nước mắm sả ớt đặc biệt 24 giờ. Thấm đẫm gia vị, vừa chua vừa cay vừa thơm. Ăn vặt ghiền nhất mùa mưa!',
    ),
    // --- NEW DoAnCay products ---
    Product(
      id: '107', name: 'Mì cay Hàn cấp 5', category: 'DoAnCay',
      basePrice: 35000, originalPrice: 55000,
      rating: 4.8, soldCount: 5100,
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🔥 Mì cay Hàn Quốc cấp độ 5 — thách thức vị giác! Mì dai đậm đà, sốt gochujang đặc quánh cay nồng, thêm kimchi và trứng lòng đào. Cấp độ cay cao nhất — chỉ dành cho người gan dạ!',
    ),
    Product(
      id: '108', name: 'Tokbokki cay ngọt', category: 'DoAnCay',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.9, soldCount: 4700,
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🌶️ Tokbokki cay ngọt đường phố — bánh gạo mềm dai sốt gochujang truyền thống pha thêm đường nâu ngọt dịu. Kèm chả cá và trứng luộc. Ăn nóng, húp nước sốt — mê không lối thoát!',
    ),
    Product(
      id: '109', name: 'Bò khô sa tế', category: 'DoAnCay',
      basePrice: 30000, originalPrice: 48000,
      rating: 4.7, soldCount: 3200,
      imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🥩 Bò khô sa tế đặc biệt — thịt bò Úc loại ngon, tẩm sa tế ớt đỏ thơm nồng, sấy khô đều. Dai mềm vừa phải, cay thơm đậm đà. Túi 100g — ăn vặt đồng hành cùng phim, trà đá!',
    ),
    Product(
      id: '110', name: 'Lẩu mini cay', category: 'DoAnCay',
      basePrice: 55000, originalPrice: 85000,
      rating: 4.8, soldCount: 2100,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
      ],
      description:
          '🍲 Lẩu mini cay Tứ Xuyên — nồi lẩu nhỏ xinh cho 1-2 người, nước lèo sichuan cay tê nồng đặc trưng. Đủ rau, bò, tôm, nấm, đậu hũ. Ăn một mình cũng sang — cay mà cứ muốn thêm!',
    ),
    Product(
      id: '111', name: 'Gà cay chiên giòn', category: 'DoAnCay',
      basePrice: 38000, originalPrice: 58000,
      rating: 4.8, soldCount: 3900,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=700&q=80',
      ],
      description:
          '🍗 Gà cay chiên giòn kiểu Hàn — gà ta ướp gochujang, phủ bột crispy chiên vàng giòn rụm. Cay nồng đậm đà, bên trong mọng nước. Chấm sốt mayo cay — combo hoàn hảo không thể cưỡng!',
    ),
    Product(
      id: '112', name: 'Mực rim sa tế', category: 'DoAnCay',
      basePrice: 32000, originalPrice: 50000,
      rating: 4.6, soldCount: 2400,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=700&q=80',
      ],
      description:
          '🦑 Mực rim sa tế cay đặc biệt — mực ống tươi cắt khoanh, rim cùng sa tế tôm ớt thơm lừng đến cạn nước. Mực ngọt, cay thơm, đậm đà. Ăn kèm cơm trắng hoặc nhậu đều tuyệt hảo!',
    ),
    Product(
      id: '113', name: 'Trứng vịt lộn sốt cay', category: 'DoAnCay',
      basePrice: 20000, originalPrice: 30000,
      rating: 4.7, soldCount: 4500,
      imageUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=800&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🥚 Trứng vịt lộn sốt cay đặc biệt — trứng hột vịt lộn cổ điển phủ sốt cay sa tế ớt, thêm rau răm thơm và muối tiêu. Vừa bổ vừa ngon, đường phố Sài Gòn huyền thoại. 2 trứng/phần!',
    ),

    // ══════════════════════════════════════════
    //  🥤 Nước uống
    // ══════════════════════════════════════════
    Product(
      id: '9', name: 'Trà sữa đường đen', category: 'NuocUong',
      subcategory: 'traSua',
      basePrice: 35000, originalPrice: 50000,
      rating: 4.9, soldCount: 9800,
      imageUrl: _img('nuocuong/trasua/truyenthong/tt1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/truyenthong/tt1.jpg'),
        _img('nuocuong/trasua/truyenthong/tt2.jpg'),
        _img('nuocuong/trasua/truyenthong/tt3.jpg'),
        _img('nuocuong/trasua/truyenthong/tt4.jpg'),
        _img('nuocuong/trasua/truyenthong/tt5.jpg'),
        _img('nuocuong/trasua/truyenthong/tt6.jpg'),
        _img('nuocuong/trasua/truyenthong/tt7.jpg'),
      ],
      description:
          '🧋 Trà sữa đường đen đặc biệt — siro đường đen thủ công ngọt thơm, trà ô long béo sữa mịn, trân châu đen dai ngon. Kéo sợi đường cực đẹp, TikTok viral khắp nơi. Phải thử ngay!',
    ),
    Product(
      id: '10', name: 'Trà sữa matcha', category: 'NuocUong',
      subcategory: 'traSua',
      basePrice: 38000, originalPrice: 55000,
      rating: 4.8, soldCount: 6700,
      imageUrl: _img('nuocuong/trasua/matcha/matcha1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/matcha/matcha1.jpg'),
        _img('nuocuong/trasua/matcha/matcha2.jpg'),
        _img('nuocuong/trasua/matcha/matcha3.jpg'),
        _img('nuocuong/trasua/matcha/matcha4.jpg'),
        _img('nuocuong/trasua/matcha/matcha5.jpg'),
        _img('nuocuong/trasua/matcha/matcha6.jpg'),
        _img('nuocuong/trasua/matcha/matcha7.jpg'),
      ],
      description:
          '🍵 Trà sữa matcha Uji Nhật Bản — matcha xay mịn pha cùng sữa tươi béo ngậy, ngọt dịu. Màu xanh tự nhiên đẹp mắt, không phẩm màu. Thêm trân châu hoặc thạch thưởng thức cực phẩm!',
    ),
    Product(
      id: '11', name: 'Trà sữa truyền thống', category: 'NuocUong',
      subcategory: 'traSua',
      basePrice: 28000, originalPrice: 40000,
      rating: 4.7, soldCount: 7200,
      imageUrl: _img('nuocuong/trasua/truyenthong/tt1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/truyenthong/tt1.jpg'),
        _img('nuocuong/trasua/truyenthong/tt2.jpg'),
        _img('nuocuong/trasua/truyenthong/tt3.jpg'),
        _img('nuocuong/trasua/truyenthong/tt4.jpg'),
        _img('nuocuong/trasua/truyenthong/tt5.jpg'),
        _img('nuocuong/trasua/truyenthong/tt6.jpg'),
        _img('nuocuong/trasua/truyenthong/tt7.jpg'),
      ],
      description:
          '🥛 Trà sữa truyền thống Đài Loan — trà đen pha sữa đặc ngọt béo, trân châu đen dai mềm thủ công. Công thức gốc từ Đài Bắc, chuẩn vị boba kinh điển. Uống là yêu ngay lần đầu!',
    ),
    Product(
      id: '12', name: 'Nước ép cam tươi', category: 'NuocUong',
      subcategory: 'nuocEp',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.8, soldCount: 4300,
      imageUrl: _img('nuocuong/nuocep/cam/cam1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/cam/cam1.jpg'),
        _img('nuocuong/nuocep/cam/cam2.jpg'),
        _img('nuocuong/nuocep/cam/cam3.jpg'),
        _img('nuocuong/nuocep/cam/cam4.jpg'),
        _img('nuocuong/nuocep/cam/cam5.jpg'),
        _img('nuocuong/nuocep/cam/cam7.jpg'),
        _img('nuocuong/nuocep/cam/cam8.jpg'),
      ],
      description:
          '🍊 Nước ép cam vắt tươi 100% — không pha nước, không thêm đường, không chất bảo quản. Mỗi ly 4-5 quả cam đường Nghệ An. Ngọt tự nhiên, bổ vitamin C. Uống ngay khi vắt!',
    ),
    Product(
      id: '13', name: 'Trà đào sữa đá', category: 'NuocUong',
      subcategory: 'tra',
      basePrice: 30000, originalPrice: 45000,
      rating: 4.9, soldCount: 5800,
      imageUrl: _img('nuocuong/tradao/dao1.jpg'),
      imageUrls: [
        _img('nuocuong/tradao/dao1.jpg'),
        _img('nuocuong/tradao/dao2.jpg'),
        _img('nuocuong/tradao/dao3.jpg'),
        _img('nuocuong/tradao/dao4.jpg'),
        _img('nuocuong/tradao/dao5.jpg'),
        _img('nuocuong/tradao/dao6.jpg'),
        _img('nuocuong/tradao/dao7.jpg'),
      ],
      description:
          '🍑 Trà đào sữa đá thơm ngọt — trà xanh tươi pha cùng đào ngâm, thêm sữa tươi béo mát. Vị chua nhẹ, ngọt dịu, thơm mùi đào tự nhiên. Đá bào mịn, uống một ngụm là mê ngay!',
    ),
    // --- NEW NuocUong products ---
    Product(
      id: '114', name: 'Trà sữa ô long', category: 'NuocUong',
      subcategory: 'traSua',
      basePrice: 32000, originalPrice: 48000,
      rating: 4.8, soldCount: 5300,
      imageUrl: _img('nuocuong/trasua/olong/olong1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/olong/olong1.jpg'),
        _img('nuocuong/trasua/olong/olong2.jpg'),
        _img('nuocuong/trasua/olong/olong3.jpg'),
        _img('nuocuong/trasua/olong/olong4.jpg'),
        _img('nuocuong/trasua/olong/olong5.jpg'),
        _img('nuocuong/trasua/olong/olong6.jpg'),
        _img('nuocuong/trasua/olong/olong7.jpg'),
      ],
      description:
          '🍵 Trà sữa ô long cao cấp — trà ô long Đài Loan hảo hạng pha sữa tươi béo mịn, hương thơm hoa nhài dịu nhẹ. Màu nâu vàng đặc trưng, ngọt thanh. Thêm trân châu nâu hoặc thạch trà xanh!',
    ),
    Product(
      id: '115', name: 'Trà sữa Thái', category: 'NuocUong',
      subcategory: 'traSua',
      basePrice: 35000, originalPrice: 52000,
      rating: 4.7, soldCount: 4800,
      imageUrl: _img('nuocuong/trasua/thai/thai1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/thai/thai1.jpg'),
        _img('nuocuong/trasua/thai/thai2.jpg'),
        _img('nuocuong/trasua/thai/thai3.jpg'),
        _img('nuocuong/trasua/thai/thai4.jpg'),
        _img('nuocuong/trasua/thai/thai5.jpg'),
        _img('nuocuong/trasua/thai/thai6.jpg'),
        _img('nuocuong/trasua/thai/thai7.jpg'),
      ],
      description:
          '🧡 Trà sữa Thái truyền thống — pha từ trà ChaTraMue Thái Lan với nước cốt dừa và sữa đặc, màu cam đặc trưng đẹp mắt. Ngọt béo thơm lừng, uống đá mát lạnh tuyệt vời ngày hè!',
    ),
    Product(
      id: '116', name: 'Nước ép dừa tươi', category: 'NuocUong',
      subcategory: 'nuocEp',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.7, soldCount: 3600,
      imageUrl: _img('nuocuong/nuocep/dua/dua1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/dua/dua1.jpg'),
        _img('nuocuong/nuocep/dua/dua2.jpg'),
        _img('nuocuong/nuocep/dua/dua3.jpg'),
        _img('nuocuong/nuocep/dua/dua4.jpg'),
        _img('nuocuong/nuocep/dua/dua5.jpg'),
        _img('nuocuong/nuocep/dua/dua6.jpg'),
        _img('nuocuong/nuocep/dua/dua7.jpg'),
      ],
      description:
          '🥥 Nước ép dừa tươi nguyên chất — dừa xiêm Bến Tre trẻ, ép lấy nước trong vắt, thêm sữa dừa cốt béo. Ngọt thanh tự nhiên, giải nhiệt cực tốt. Không đường, không phụ gia — sạch 100%!',
    ),
    Product(
      id: '117', name: 'Trà tắc mật ong', category: 'NuocUong',
      subcategory: 'tra',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.6, soldCount: 4100,
      imageUrl: _img('nuocuong/tratac/tac1.jpg'),
      imageUrls: [
        _img('nuocuong/tratac/tac1.jpg'),
        _img('nuocuong/tratac/tac2.jpg'),
        _img('nuocuong/tratac/tac3.jpg'),
        _img('nuocuong/tratac/tac4.jpg'),
        _img('nuocuong/tratac/tac5.jpg'),
        _img('nuocuong/tratac/tac6.jpg'),
        _img('nuocuong/tratac/tac7.jpg'),
      ],
      description:
          '🍋 Trà tắc mật ong đặc biệt — tắc (quất) tươi cắt lát pha cùng trà xanh, mật ong nguyên chất và đá bào. Chua ngọt thanh mát, hương tắc thơm dịu. Giải khát mùa hè số 1 Việt Nam!',
    ),
    Product(
      id: '118', name: 'Cacao nóng đá', category: 'NuocUong',
      subcategory: 'cacao',
      basePrice: 30000, originalPrice: 45000,
      rating: 4.7, soldCount: 3200,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
      ],
      description:
          '☕ Cacao nóng đá đặc biệt — bột cacao nguyên chất pha cùng sữa tươi nguyên kem, thêm đá viên lạnh hoặc thưởng thức nóng. Đắng nhẹ thơm đậm đà, béo ngậy. Năng lượng cho ngày dài!',
    ),
    Product(
      id: '119', name: 'Sinh tố bơ', category: 'NuocUong',
      subcategory: 'sinhTo',
      basePrice: 35000, originalPrice: 52000,
      rating: 4.9, soldCount: 5600,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=700&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=700&q=80',
      ],
      description:
          '🥑 Sinh tố bơ mịn sữa đặc — bơ sáp chín mềm xay cùng sữa tươi, sữa đặc ngọt và đá bào. Sánh mịn như kem, béo ngậy thơm đặc trưng. Giàu vitamin, siêu bổ dưỡng. Ly to 500ml!',
    ),
    Product(
      id: '120', name: 'Nước ép dưa hấu', category: 'NuocUong',
      subcategory: 'nuocEp',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.6, soldCount: 3900,
      imageUrl: _img('nuocuong/nuocep/duahau/hau1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/duahau/hau1.jpg'),
        _img('nuocuong/nuocep/duahau/hau2.jpg'),
        _img('nuocuong/nuocep/duahau/hau3.jpg'),
        _img('nuocuong/nuocep/duahau/hau4.jpg'),
        _img('nuocuong/nuocep/duahau/hau5.jpg'),
        _img('nuocuong/nuocep/duahau/hau6.jpg'),
        _img('nuocuong/nuocep/duahau/hau7.jpg'),
      ],
      description:
          '🍉 Nước ép dưa hấu tươi nguyên chất — dưa hấu đỏ ruột ngọt lịm ép lấy nước, uống đá mát lạnh. Không đường, không pha, ngọt tự nhiên 100%. Giải nhiệt cực tốt, bổ khoáng chất!',
    ),
    Product(
      id: '121', name: 'Cà phê sữa đá', category: 'NuocUong',
      subcategory: 'cafe',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.8, soldCount: 6800,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
      ],
      description:
          '☕ Cà phê sữa đá truyền thống — cà phê Robusta Tây Nguyên phin chậm, pha sữa đặc ngọt béo, đá viên lạnh giòn. Đắng thơm đặc trưng, ngọt béo vừa phải. Tỉnh ngủ ngay từ ngụm đầu!',
    ),

    // ══════════════════════════════════════════
    //  🍰 Bánh & đồ ngọt
    // ══════════════════════════════════════════
    Product(
      id: '14', name: 'Bánh su kem', category: 'BanhNgot',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.8, soldCount: 4600,
      imageUrl: _img('banh&dongot/banhsukem/sukem1.jpg'),
      imageUrls: [
        _img('banh&dongot/banhsukem/sukem1.jpg'),
        _img('banh&dongot/banhsukem/sukem2.jpg'),
        _img('banh&dongot/banhsukem/sukem3.jpg'),
        _img('banh&dongot/banhsukem/sukem4.jpg'),
        _img('banh&dongot/banhsukem/sukem5.jpg'),
        _img('banh&dongot/banhsukem/sukem6.jpg'),
        _img('banh&dongot/banhsukem/sukem7.jpg'),
      ],
      description:
          '🍮 Bánh su kem Nhật Bản — vỏ choux phồng giòn, bên trong kem custard vani mịn màng thơm phức. Rắc đường bột trắng tinh. Mỗi phần 2 chiếc to — thơm ngon chuẩn tiệm bánh Nhật!',
    ),
    Product(
      id: '15', name: 'Tiramisu matcha', category: 'BanhNgot',
      basePrice: 45000, originalPrice: 65000,
      rating: 4.9, soldCount: 2100,
      imageUrl: _img('banh&dongot/tiramisu/misu1.jpg'),
      imageUrls: [
        _img('banh&dongot/tiramisu/misu1.jpg'),
        _img('banh&dongot/tiramisu/misu2.jpg'),
        _img('banh&dongot/tiramisu/misu3.jpg'),
        _img('banh&dongot/tiramisu/misu4.jpg'),
        _img('banh&dongot/tiramisu/misu5.jpg'),
        _img('banh&dongot/tiramisu/misu6.jpg'),
        _img('banh&dongot/tiramisu/misu7.jpg'),
      ],
      description:
          '🍵 Tiramisu trà xanh matcha Uji cao cấp — kem mascarpone béo nhẹ, bánh ladyfinger thấm cà phê, rắc matcha Nhật đặc. Vị đắng nhẹ, ngọt thanh. Hộp 4 phần cá nhân, sang trọng!',
    ),
    Product(
      id: '16', name: 'Cupcake nhiều vị', category: 'BanhNgot',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 3200,
      imageUrl: _img('banh&dongot/cupcake/cake1.jpg'),
      imageUrls: [
        _img('banh&dongot/cupcake/cake1.jpg'),
        _img('banh&dongot/cupcake/cake2.jpg'),
        _img('banh&dongot/cupcake/cake3.jpg'),
        _img('banh&dongot/cupcake/cake4.jpg'),
        _img('banh&dongot/cupcake/cake5.jpg'),
        _img('banh&dongot/cupcake/cake6.jpg'),
        _img('banh&dongot/cupcake/cake7.jpg'),
      ],
      description:
          '🧁 Cupcake kem bơ nhiều màu — bánh cupcake mềm ẩm, phủ kem bơ trang trí rực rỡ. 6 vị: vani, socola, dâu, chanh, matcha, caramel. Mỗi chiếc là một tác phẩm nghệ thuật ngọt ngào!',
    ),
    Product(
      id: '17', name: 'Bánh bông lan', category: 'BanhNgot',
      basePrice: 15000, originalPrice: 22000,
      rating: 4.6, soldCount: 5800,
      imageUrl: _img('banh&dongot/banhbonglan/bonglan1.jpg'),
      imageUrls: [
        _img('banh&dongot/banhbonglan/bonglan1.jpg'),
        _img('banh&dongot/banhbonglan/bonglan2.jpg'),
        _img('banh&dongot/banhbonglan/bonglan3.jpg'),
        _img('banh&dongot/banhbonglan/bonglan4.jpg'),
        _img('banh&dongot/banhbonglan/bonglan5.jpg'),
        _img('banh&dongot/banhbonglan/bonglan6.jpg'),
        _img('banh&dongot/banhbonglan/bonglan8.jpg'),
      ],
      description:
          '🍰 Bánh bông lan trứng muối — bánh mềm xốp vị vani nhẹ nhàng, lòng trứng muối chảy vàng ươm bên trong. Nướng tươi mỗi ngày, ăn còn ấm là đỉnh nhất. Bánh tuổi thơ cực yêu!',
    ),
    // --- NEW BanhNgot products ---
    Product(
      id: '122', name: 'Bánh donut phủ đường', category: 'BanhNgot',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.7, soldCount: 3400,
      imageUrl: 'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=700&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=800&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🍩 Bánh donut phủ đường nhiều vị — vòng donut xốp mềm chiên vàng, phủ chocolate, dâu, matcha, caramel. Rắc thêm sprinkle màu sắc bắt mắt. Mỗi chiếc là một niềm vui ngọt ngào!',
    ),
    Product(
      id: '123', name: 'Bánh mochi nhân đậu đỏ', category: 'BanhNgot',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.8, soldCount: 2700,
      imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=700&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🍡 Bánh mochi nhân đậu đỏ Nhật Bản — vỏ mochi dẻo thơm nếp trắng tinh, nhân đậu đỏ azuki ngọt bùi. Mềm mịn tan chảy trong miệng. Hộp 4 chiếc — quà tặng ngọt ngào tinh tế!',
    ),
    Product(
      id: '124', name: 'Bánh crepe matcha', category: 'BanhNgot',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.7, soldCount: 2900,
      imageUrl: 'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=700&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=800&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🍵 Bánh crepe matcha Nhật — lớp crepe mỏng xanh matcha Uji, cuộn kem tươi đánh bông mịn và trái cây tươi. Thanh mát, ngọt dịu, đẹp mắt cực chụp hình. Tráng miệng sang chảnh!',
    ),
    Product(
      id: '125', name: 'Bánh waffle', category: 'BanhNgot',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.8, soldCount: 3100,
      imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=700&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🧇 Bánh waffle giòn vàng — bánh waffle Bỉ nướng vàng giòn bên ngoài, mềm xốp bên trong. Phủ kem tươi, mứt dâu, siro maple. Nhiều topping lựa chọn — bữa sáng hoặc tráng miệng đều ngon!',
    ),
    Product(
      id: '126', name: 'Pudding caramel', category: 'BanhNgot',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 2500,
      imageUrl: 'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=700&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=800&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🍮 Pudding caramel kinh điển — trứng sữa hấp mịn mượt như lụa, phủ caramel vàng đắng ngọt hoàn hảo. Rung rinh nhẹ, tan chảy tức thì. Tráng miệng Pháp thanh lịch, đơn giản mà đẳng cấp!',
    ),
    Product(
      id: '127', name: 'Bánh tart sữa dừa', category: 'BanhNgot',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.6, soldCount: 2300,
      imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=700&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80',
        'https://images.unsplash.com/photo-1488477304112-4944851de03d?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🥥 Bánh tart sữa dừa nhân chảy — vỏ tart giòn bơ thơm, nhân sữa dừa béo ngậy chảy nhẹ khi cắn. Thêm dừa tươi nạo mỏng phía trên. Hương dừa đặc trưng miền Nam — ngọt dịu tinh tế!',
    ),

    // ══════════════════════════════════════════
    //  🍫 Snack & kẹo
    // ══════════════════════════════════════════
    Product(
      id: '18', name: 'Snack Oishi phô mai', category: 'SnackKeo',
      basePrice: 12000, originalPrice: 18000,
      rating: 4.7, soldCount: 9100,
      imageUrl: _img('snack&keo/oishi/oshi1.jpg'),
      imageUrls: [
        _img('snack&keo/oishi/oshi1.jpg'),
        _img('snack&keo/oishi/oshi2.jpg'),
        _img('snack&keo/oishi/oshi3.jpg'),
        _img('snack&keo/oishi/oshi4.jpg'),
        _img('snack&keo/oishi/oshi5.jpg'),
        _img('snack&keo/oishi/oshi6.jpg'),
        _img('snack&keo/oishi/oshi7.jpg'),
      ],
      description:
          '🍿 Snack Oishi phô mai Cheddar — giòn tan, béo bùi, vị phô mai đậm đà quen thuộc. Snack khoái khẩu quốc dân số 1 Việt Nam, ăn mãi không chán. Gói lớn chia sẻ cùng bạn bè!',
    ),
    Product(
      id: '19', name: 'Poca khoai tây', category: 'SnackKeo',
      basePrice: 15000, originalPrice: 22000,
      rating: 4.6, soldCount: 7800,
      imageUrl: _img('snack&keo/poca/poca1.jpg'),
      imageUrls: [
        _img('snack&keo/poca/poca1.jpg'),
        _img('snack&keo/poca/poca2.jpg'),
        _img('snack&keo/poca/poca3.jpg'),
        _img('snack&keo/poca/poca4.jpg'),
        _img('snack&keo/poca/poca5.jpg'),
        _img('snack&keo/poca/poca6.jpg'),
        _img('snack&keo/poca/poca7.jpg'),
      ],
      description:
          '🥔 Poca khoai tây lát mỏng — khoai tây thái lát siêu mỏng, chiên giòn rụm vàng đều. Vị phô mai & kem chua, mặn ngọt hài hòa. Bỏ vào miệng tan ngay — giòn đỉnh của giòn!',
    ),
    Product(
      id: '20', name: 'Kẹo dẻo các vị', category: 'SnackKeo',
      basePrice: 20000, originalPrice: 30000,
      rating: 4.6, soldCount: 4500,
      imageUrl: _img('snack&keo/keodeo/deo1.jpg'),
      imageUrls: [
        _img('snack&keo/keodeo/deo1.jpg'),
        _img('snack&keo/keodeo/deo2.jpg'),
        _img('snack&keo/keodeo/deo3.jpg'),
        _img('snack&keo/keodeo/deo4.jpg'),
        _img('snack&keo/keodeo/deo5.jpg'),
        _img('snack&keo/keodeo/deo6.jpg'),
        _img('snack&keo/keodeo/deo7.jpg'),
      ],
      description:
          '🐻 Kẹo dẻo gấu nhiều vị — 5 vị trái cây phủ đường, dai mềm, màu sắc bắt mắt cực cute. Ngọt thơm, bên trong có nhân trái cây thật. Gói 200g — kẹo dẻo tuổi thơ ai cũng nhớ!',
    ),
    Product(
      id: '21', name: 'Socola các vị', category: 'SnackKeo',
      basePrice: 35000, originalPrice: 55000,
      rating: 4.8, soldCount: 2800,
      imageUrl: _img('snack&keo/chocolate/socola1.jpg'),
      imageUrls: [
        _img('snack&keo/chocolate/socola1.jpg'),
        _img('snack&keo/chocolate/socola2.jpg'),
        _img('snack&keo/chocolate/socola3.jpg'),
        _img('snack&keo/chocolate/socola4.jpg'),
        _img('snack&keo/chocolate/socola5.jpg'),
        _img('snack&keo/chocolate/socola6.jpg'),
        _img('snack&keo/chocolate/socola7.jpg'),
      ],
      description:
          '🍫 Socola premium nhiều vị — đắng nhẹ, hương thơm tinh tế, tan chảy mượt trên đầu lưỡi. Nhiều vị: đen 70%, sữa, dâu, hạnh nhân, caramel. Không chất bảo quản, sang trọng!',
    ),
    Product(
      id: '22', name: 'Snack rong biển', category: 'SnackKeo',
      basePrice: 8000, originalPrice: 12000,
      rating: 4.5, soldCount: 6200,
      imageUrl: _img('snack&keo/rongbien/rongbien1.jpg'),
      imageUrls: [
        _img('snack&keo/rongbien/rongbien1.jpg'),
        _img('snack&keo/rongbien/rongbien2.jpg'),
        _img('snack&keo/rongbien/rongbien3.jpg'),
        _img('snack&keo/rongbien/rongbien4.jpg'),
        _img('snack&keo/rongbien/rongbien5.jpg'),
        _img('snack&keo/rongbien/rongbien6.jpg'),
        _img('snack&keo/rongbien/rongbien7.jpg'),
      ],
      description:
          '🌿 Snack rong biển nướng mè vàng — rong biển Hàn Quốc mỏng giòn, nướng dầu mè thơm ngậy, rắc mè trắng béo. Ăn không ngán, tốt cho sức khỏe, ít calo. Snack sạch cực trending!',
    ),
    // --- NEW SnackKeo products ---
    Product(
      id: '128', name: 'Snack mực Thái', category: 'SnackKeo',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 4100,
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=700&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
      ],
      description:
          '🦑 Snack mực sấy Thái Lan — mực ống tươi tẩm gia vị Thái đặc trưng, sấy giòn dai thơm phức. Ngọt tự nhiên từ mực, cay nhẹ hậu vị. Túi 80g — ăn vặt cùng trà đá siêu đỉnh!',
    ),
    Product(
      id: '129', name: 'Kẹo caramel mềm', category: 'SnackKeo',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.6, soldCount: 3200,
      imageUrl: 'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=800&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=700&q=80',
      ],
      description:
          '🍬 Kẹo caramel bơ mềm Pháp — caramel sữa tan chảy mượt, bơ Normandy thơm béo ngậy, mặn ngọt hài hòa tuyệt vời. Mỗi viên gói giấy bạc tinh tế. Hộp 200g — quà tặng sang trọng!',
    ),
    Product(
      id: '130', name: 'Bánh quy bơ', category: 'SnackKeo',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 3800,
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=700&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
      ],
      description:
          '🍪 Bánh quy bơ Đan Mạch giòn tan — làm từ bơ Lurpak chính hãng, giòn nhẹ thơm béo không ngấy. Nhiều hình dáng dễ thương, vị vani và phô mai. Hộp thiếc 400g — bánh nhà làm chuẩn vị!',
    ),
    Product(
      id: '131', name: 'Snack khoai lang', category: 'SnackKeo',
      basePrice: 12000, originalPrice: 20000,
      rating: 4.5, soldCount: 4500,
      imageUrl: 'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=800&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=700&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=700&q=80',
      ],
      description:
          '🍠 Snack khoai lang sấy giòn — khoai lang Nhật tím và vàng thái lát mỏng, sấy giòn tự nhiên không dầu chiên. Ngọt bùi tự nhiên, lành mạnh ít calo. Snack ăn kiêng mà vẫn ngon!',
    ),
    Product(
      id: '132', name: 'Kẹo lollipop', category: 'SnackKeo',
      basePrice: 8000, originalPrice: 15000,
      rating: 4.4, soldCount: 2900,
      imageUrl: 'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=800&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=700&q=80',
      ],
      description:
          '🍭 Kẹo lollipop màu sắc cực cute — kẹo que xoắn ốc nhiều màu rực rỡ, vị dâu, cam, nho, táo. Ngọt thơm, màu tự nhiên. Cute cực chụp ảnh, làm quà sinh nhật hay trang trí đều tuyệt!',
    ),

    // ══════════════════════════════════════════
    //  🥭 Trái cây & đồ chua
    // ══════════════════════════════════════════
    Product(
      id: '23', name: 'Xoài lắc muối ớt', category: 'TraiCayChua',
      basePrice: 20000, originalPrice: 30000,
      rating: 4.9, soldCount: 7800,
      imageUrl: _img('traicay&dochua/xoailac/xoai1.jpg'),
      imageUrls: [
        _img('traicay&dochua/xoailac/xoai1.jpg'),
        _img('traicay&dochua/xoailac/xoai2.jpg'),
        _img('traicay&dochua/xoailac/xoai3.jpg'),
        _img('traicay&dochua/xoailac/xoai4.jpg'),
        _img('traicay&dochua/xoailac/xoai5.jpg'),
        _img('traicay&dochua/xoailac/xoai6.jpg'),
        _img('traicay&dochua/xoailac/xoai7.jpg'),
      ],
      description:
          '🥭 Xoài cát Hòa Lộc xanh chua lắc muối ớt — xoài non cứng chắc thái hạt lựu, lắc cùng muối ớt xanh Tây Ninh đặc biệt. Chua cay mặn ngọt đủ vị — đồ ăn vặt huyền thoại tuổi học trò!',
    ),
    Product(
      id: '24', name: 'Ổi lắc muối ớt', category: 'TraiCayChua',
      basePrice: 15000, originalPrice: 22000,
      rating: 4.7, soldCount: 5100,
      imageUrl: _img('traicay&dochua/oilac/oi1.jpg'),
      imageUrls: [
        _img('traicay&dochua/oilac/oi1.jpg'),
        _img('traicay&dochua/oilac/oi2.jpg'),
        _img('traicay&dochua/oilac/oi3.jpg'),
        _img('traicay&dochua/oilac/oi4.jpg'),
        _img('traicay&dochua/oilac/oi5.jpg'),
        _img('traicay&dochua/oilac/oi6.jpg'),
        _img('traicay&dochua/oilac/oi7.jpg'),
      ],
      description:
          '🍈 Ổi đào giòn lắc muối ớt — ổi non cứng chắc, lắc muối ớt cay nồng. Ăn vào giòn sần sật, chua ngọt dịu dàng, cực kích thích vị giác. Phần 300g — ăn vặt sạch healthy!',
    ),
    Product(
      id: '25', name: 'Me chua ngâm', category: 'TraiCayChua',
      basePrice: 12000, originalPrice: 18000,
      rating: 4.6, soldCount: 4900,
      imageUrl: _img('traicay&dochua/me/me1.jpg'),
      imageUrls: [
        _img('traicay&dochua/me/me1.jpg'),
        _img('traicay&dochua/me/me2.jpg'),
        _img('traicay&dochua/me/me3.jpg'),
        _img('traicay&dochua/me/me4.jpg'),
        _img('traicay&dochua/me/me5.jpg'),
        _img('traicay&dochua/me/me6.jpg'),
        _img('traicay&dochua/me/me7.jpg'),
      ],
      description:
          '🟤 Me chua ngâm muối ớt đặc biệt — me Bình Phước chín tới, vừa chua vừa ngọt, ngâm muối ớt đỏ cay nồng. Chua kích thích vị giác tức thì. Hộp 200g — ăn vặt kinh điển Nam Bộ!',
    ),
    Product(
      id: '26', name: 'Mận ngâm cay', category: 'TraiCayChua',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 4100,
      imageUrl: _img('traicay&dochua/man/man1.jpg'),
      imageUrls: [
        _img('traicay&dochua/man/man1.jpg'),
        _img('traicay&dochua/man/man2.jpg'),
        _img('traicay&dochua/man/man3.jpg'),
        _img('traicay&dochua/man/man4.jpg'),
        _img('traicay&dochua/man/man5.jpg'),
        _img('traicay&dochua/man/man6.jpg'),
        _img('traicay&dochua/man/man7.jpg'),
      ],
      description:
          '🍑 Mận ngâm nước muối ớt thơm — mận tươi Bắc ngâm đường gừng muối ớt, chua ngọt cay đặc trưng. Ăn lạnh ngon tuyệt, giải nhiệt mùa hè. Hộp nhỏ tiện lợi, ăn vặt đường phố!',
    ),
    Product(
      id: '27', name: 'Cóc lắc muối', category: 'TraiCayChua',
      basePrice: 15000, originalPrice: 22000,
      rating: 4.6, soldCount: 3800,
      imageUrl: _img('traicay&dochua/coclac/coclac1.jpg'),
      imageUrls: [
        _img('traicay&dochua/coclac/coclac1.jpg'),
        _img('traicay&dochua/coclac/coclac2.jpg'),
        _img('traicay&dochua/coclac/coclac3.jpg'),
        _img('traicay&dochua/coclac/coclac4.jpg'),
        _img('traicay&dochua/coclac/coclac5.jpg'),
        _img('traicay&dochua/coclac/coclac6.jpg'),
        _img('traicay&dochua/coclac/coclac7.jpg'),
      ],
      description:
          '🌿 Cóc non lắc muối ớt sấy — cóc xanh giòn sần sật, lắc muối ớt sấy đặc biệt vị cay nồng mặn ngọt. Đặc sản vỉa hè Nam Bộ, ai ăn một lần là nhớ mãi. Túi lớn 300g đã tay!',
    ),
    // --- NEW TraiCayChua products ---
    Product(
      id: '133', name: 'Khế chua muối ớt', category: 'TraiCayChua',
      basePrice: 12000, originalPrice: 20000,
      rating: 4.5, soldCount: 2900,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=700&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=700&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=900&q=80',
      ],
      description:
          '⭐ Khế chua chấm muối ớt đặc biệt — khế vàng chua giòn thái lát, chấm muối ớt xanh tây ninh. Vị chua gắt kích thích vị giác ngay lập tức. Đặc sản vỉa hè Nam Bộ khó quên!',
    ),
    Product(
      id: '134', name: 'Sấu ngâm đường', category: 'TraiCayChua',
      basePrice: 15000, originalPrice: 24000,
      rating: 4.6, soldCount: 2300,
      imageUrl: 'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=700&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=700&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=900&q=80',
      ],
      description:
          '🟢 Sấu ngâm đường chua ngọt — sấu Hà Nội chua gắt ngâm đường phèn qua đêm, vị chua dịu lại, ngọt thanh. Đặc sản mùa hè miền Bắc, giải nhiệt tuyệt vời. Hũ thủy tinh đẹp, tặng quà cũng hay!',
    ),
    Product(
      id: '135', name: 'Dứa lắc muối', category: 'TraiCayChua',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 3600,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=700&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=700&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=900&q=80',
      ],
      description:
          '🍍 Dứa (thơm) lắc muối ớt chua ngọt — dứa tươi thái miếng, lắc muối ớt đỏ cay nồng. Ngọt chua tự nhiên, cay thơm đặc trưng. Ăn vặt đường phố huyền thoại. Hộp 200g đủ no bụng!',
    ),
    Product(
      id: '136', name: 'Chuối sấy', category: 'TraiCayChua',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.6, soldCount: 3200,
      imageUrl: 'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=700&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=700&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=900&q=80',
      ],
      description:
          '🍌 Chuối sấy dẻo thơm ngọt — chuối già Nam Bộ chín vàng, sấy dẻo ở nhiệt độ thấp giữ nguyên dinh dưỡng. Ngọt tự nhiên, dai dẻo, thơm thơm. Snack lành mạnh không đường không dầu!',
    ),
    Product(
      id: '137', name: 'Chôm chôm tươi', category: 'TraiCayChua',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.5, soldCount: 2100,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=700&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=600&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=700&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=800&q=80',
        'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=900&q=80',
      ],
      description:
          '🔴 Chôm chôm Java ngọt lịm — chôm chôm đỏ tươi trồng vùng Đông Nam Bộ, thịt dày ngọt mát, hạt nhỏ. Bóc vỏ ăn ngay, mọng nước tự nhiên. Phần 400g — trái cây tươi ngon mùa hè!',
    ),

    // ══════════════════════════════════════════
    //  🧀 Ăn vặt Hàn Quốc
    // ══════════════════════════════════════════
    Product(
      id: '28', name: 'Kimbap cuộn', category: 'AnVatHanQuoc',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.8, soldCount: 4800,
      imageUrl: _img('anvathanquoc/kimbap/kb1.jpg'),
      imageUrls: [
        _img('anvathanquoc/kimbap/kb1.jpg'),
        _img('anvathanquoc/kimbap/kb2.jpg'),
        _img('anvathanquoc/kimbap/kb3.jpg'),
        _img('anvathanquoc/kimbap/kb4.jpg'),
        _img('anvathanquoc/kimbap/kb5.jpg'),
        _img('anvathanquoc/kimbap/kb6.jpg'),
        _img('anvathanquoc/kimbap/kb7.jpg'),
      ],
      description:
          '🇰🇷 Kimbap cuộn nhân gà nướng — cơm dẻo trộn dầu mè thơm, cuộn rong biển nori, nhân gà nướng teriyaki, dưa muối, trứng chiên. 8 miếng/phần — bữa ăn nhẹ chuẩn Hàn!',
    ),
    Product(
      id: '29', name: 'Tokbokki cay ngọt', category: 'AnVatHanQuoc',
      basePrice: 28000, originalPrice: 45000,
      rating: 4.9, soldCount: 6200,
      imageUrl: _img('anvathanquoc/tokbokki/tobokki1.jpg'),
      imageUrls: [
        _img('anvathanquoc/tokbokki/tobokki1.jpg'),
        _img('anvathanquoc/tokbokki/tobokki2.jpg'),
        _img('anvathanquoc/tokbokki/tobokki3.jpg'),
        _img('anvathanquoc/tokbokki/tobokki4.jpg'),
        _img('anvathanquoc/tokbokki/tobokki5.jpg'),
        _img('anvathanquoc/tokbokki/tobokki6.jpg'),
        _img('anvathanquoc/tokbokki/tobokki7.jpg'),
      ],
      description:
          '🔴 Tokbokki bánh gạo Hàn Quốc — bánh gạo dai mềm nấu sốt gochujang cay ngọt đặc quánh. Thêm trứng cút và chả cá. Ăn nóng trong bát sứ đúng kiểu Hàn — chuẩn vị Seoul!',
    ),
    Product(
      id: '30', name: 'Mandu bánh bao chiên', category: 'AnVatHanQuoc',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 3500,
      imageUrl: _img('anvathanquoc/mandu/mandu1.jpg'),
      imageUrls: [
        _img('anvathanquoc/mandu/mandu1.jpg'),
        _img('anvathanquoc/mandu/mandu2.jpg'),
        _img('anvathanquoc/mandu/mandu3.jpg'),
        _img('anvathanquoc/mandu/mandu4.jpg'),
        _img('anvathanquoc/mandu/mandu5.jpg'),
        _img('anvathanquoc/mandu/mandu6.jpg'),
        _img('anvathanquoc/mandu/mandu7.jpg'),
      ],
      description:
          '🥟 Mandu chiên giòn — bánh bao nhân thịt heo & kimchi kiểu Hàn, chiên áp chảo giòn vàng đáy. Vỏ giòn sần sật, nhân đậm đà thơm. Chấm sốt gochujang pha — đỉnh!',
    ),
    Product(
      id: '31', name: 'Chả cá Hàn Quốc', category: 'AnVatHanQuoc',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.6, soldCount: 2900,
      imageUrl: _img('anvathanquoc/chaca/chaca1.jpg'),
      imageUrls: [
        _img('anvathanquoc/chaca/chaca1.jpg'),
        _img('anvathanquoc/chaca/chaca2.jpg'),
        _img('anvathanquoc/chaca/chaca3.jpg'),
        _img('anvathanquoc/chaca/chaca4.jpg'),
        _img('anvathanquoc/chaca/chaca5.jpg'),
        _img('anvathanquoc/chaca/chaca6.jpg'),
        _img('anvathanquoc/chaca/chaca7.jpg'),
      ],
      description:
          '🐟 Chả cá Hàn Quốc (Eomuk) — chả cá dẹt xiên que hầm trong nước dùng cá thơm ngọt. Dai mềm, không tanh, ăn kèm nước dùng nóng hổi. Kinh điển đường phố Seoul đúng điệu!',
    ),
    // --- NEW AnVatHanQuoc products ---
    Product(
      id: '138', name: 'Hotteok bánh nóng', category: 'AnVatHanQuoc',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.8, soldCount: 2700,
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🥞 Hotteok bánh nóng Hàn Quốc — bánh dẹp nhân đường đen hạt dẻ, chiên áp chảo vàng giòn. Cắn vào chảy ngọt ấm bên trong, vỏ giòn thơm mùi bơ. Đặc sản mùa đông Seoul cực hút!',
    ),
    Product(
      id: '139', name: 'Dalgona kẹo bong', category: 'AnVatHanQuoc',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.7, soldCount: 3400,
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=600&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&q=80',
        'https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?w=700&q=80',
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=700&q=80',
      ],
      description:
          '🍬 Dalgona kẹo đường bong bóng — đường caramel đun chảy đổ khuôn hình thú độc đáo (squid game). Mỏng giòn, ngọt caramel thơm. Thử thách tách khuôn cực vui! Đặc sản viral TikTok!',
    ),
    Product(
      id: '140', name: 'Tteok bánh gạo nướng', category: 'AnVatHanQuoc',
      basePrice: 25000, originalPrice: 40000,
      rating: 4.7, soldCount: 2800,
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&q=80',
      ],
      description:
          '🍢 Tteok bánh gạo nướng than — bánh gạo dẹt xiên que nướng trên than hoa, phết gochujang ngọt cay. Ngoài cháy xém thơm, trong dẻo dai. Đường phố Hàn Quốc hương vị không đâu có!',
    ),
    Product(
      id: '141', name: 'Japchae miến xào', category: 'AnVatHanQuoc',
      basePrice: 32000, originalPrice: 50000,
      rating: 4.7, soldCount: 2400,
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🍜 Japchae miến xào Hàn Quốc — miến khoai lang dai trong xào cùng thịt bò, rau củ ngũ sắc, sốt ganjang mè thơm. Ăn nóng hoặc nguội đều ngon, vị ngọt mặn đặc trưng xứ Hàn!',
    ),
    Product(
      id: '142', name: 'Gimbap cơm cuộn đặc biệt', category: 'AnVatHanQuoc',
      basePrice: 30000, originalPrice: 48000,
      rating: 4.8, soldCount: 3100,
      imageUrl: 'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
      ],
      description:
          '🍱 Gimbap cơm cuộn đặc biệt — cơm dẻo trộn mè dầu mè, cuộn nori với bò bulgogi, trứng chiên, cà rốt, rau bina. Thơm ngon đậm vị Hàn. Hộp 10 miếng — bữa trưa hoàn hảo!',
    ),
    Product(
      id: '143', name: 'Bingsoo đá bào', category: 'AnVatHanQuoc',
      basePrice: 45000, originalPrice: 70000,
      rating: 4.9, soldCount: 2900,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=600&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=700&q=80',
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=700&q=80',
      ],
      description:
          '❄️ Bingsoo đá bào sữa truyền thống — đá bào mịn như tuyết tưới siro đậu đỏ, thêm trân châu, mochi, condensed milk. Mát lạnh, ngọt ngào, đẹp mắt hết nấc. Dessert Hàn số 1 mùa hè!',
    ),

    // ══════════════════════════════════════════
    //  🍜 Món no nhẹ
    // ══════════════════════════════════════════
    Product(
      id: '32', name: 'Mì trộn cay', category: 'MonNoNhe',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.8, soldCount: 7200,
      imageUrl: _img('monnonhe/mitron/tron1.jpg'),
      imageUrls: [
        _img('monnonhe/mitron/tron1.jpg'),
        _img('monnonhe/mitron/tron2.jpg'),
        _img('monnonhe/mitron/tron3.jpg'),
        _img('monnonhe/mitron/tron4.jpg'),
        _img('monnonhe/mitron/tron5.jpg'),
        _img('monnonhe/mitron/tron6.jpg'),
        _img('monnonhe/mitron/tron7.jpg'),
      ],
      description:
          '🍜 Mì trộn cay đặc biệt — mì dai mềm trộn sốt cay mắm tỏi ớt, thêm trứng lòng đào, thịt heo băm, hành phi giòn. No nhẹ mà đầy đủ dưỡng chất. Ăn một tô là no cả buổi chiều!',
    ),
    Product(
      id: '33', name: 'Nui xào hải sản', category: 'MonNoNhe',
      basePrice: 30000, originalPrice: 45000,
      rating: 4.7, soldCount: 4100,
      imageUrl: _img('monnonhe/nuixao/nui1.jpg'),
      imageUrls: [
        _img('monnonhe/nuixao/nui1.jpg'),
        _img('monnonhe/nuixao/nui2.jpg'),
        _img('monnonhe/nuixao/nui3.jpg'),
        _img('monnonhe/nuixao/nui4.jpg'),
        _img('monnonhe/nuixao/nui5.jpg'),
        _img('monnonhe/nuixao/nui6.jpg'),
        _img('monnonhe/nuixao/nui7.jpg'),
      ],
      description:
          '🦐 Nui xào hải sản — nui ống dai ngon xào cùng tôm, mực, nghêu tươi, sốt cà chua đặc. Ngọt tự nhiên từ hải sản, không bột ngọt. No nhẹ mà đủ chất, ăn buổi tối ngon miệng!',
    ),
    // --- NEW MonNoNhe products ---
    Product(
      id: '144', name: 'Bánh mì ốp la', category: 'MonNoNhe',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.7, soldCount: 4800,
      imageUrl: 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600&q=80',
        'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=700&q=80',
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=800&q=80',
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🍳 Bánh mì ốp la đặc biệt — bánh mì nóng giòn kẹp trứng ốp la lòng đào, chả lụa, pate, dưa chua, rau thơm. Sốt mayo và tương ớt đặc biệt. Bữa sáng đường phố Sài Gòn cực đỉnh!',
    ),
    Product(
      id: '145', name: 'Cơm chiên Dương Châu', category: 'MonNoNhe',
      basePrice: 35000, originalPrice: 55000,
      rating: 4.8, soldCount: 5200,
      imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🍚 Cơm chiên Dương Châu kinh điển — cơm nguội xào với tôm, lạp xưởng, trứng, đậu Hà Lan và hành. Thơm lừng, hạt cơm tơi rời. Nấu đúng lửa to, đúng điệu nhà hàng Trung Hoa!',
    ),
    Product(
      id: '146', name: 'Phở cuộn rau', category: 'MonNoNhe',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.6, soldCount: 2900,
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
      ],
      description:
          '🌯 Phở cuộn rau thanh mát — bánh phở mỏng cuộn rau xà lách, dưa leo, cà rốt và tôm thịt, chấm tương đậu phộng đặc sệt. Lành mạnh, ít calo, ngon miệng. Bữa ăn nhẹ healthy cực yêu!',
    ),
    Product(
      id: '147', name: 'Sandwich cá ngừ', category: 'MonNoNhe',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.7, soldCount: 3100,
      imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&q=80',
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=700&q=80',
        'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&q=80',
        'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🥪 Sandwich cá ngừ kem phô mai — bánh mì sandwich mềm kẹp cá ngừ trộn mayo phô mai, rau diếp tươi, cà chua. Protein cao, béo ngon vừa phải. Bữa trưa nhanh gọn mà no bụng!',
    ),
    Product(
      id: '148', name: 'Bánh ướt cuộn thịt', category: 'MonNoNhe',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.6, soldCount: 3500,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
      ],
      description:
          '🌮 Bánh ướt cuộn thịt đặc biệt — bánh ướt mỏng mềm mịn cuộn thịt heo luộc, chả lụa, hành phi giòn. Chan nước mắm chua ngọt đặc trưng. Ăn nóng vừa thổi vừa ăn — ngon xuất sắc!',
    ),
    Product(
      id: '149', name: 'Cháo yến mạch', category: 'MonNoNhe',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.5, soldCount: 2200,
      imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🥣 Cháo yến mạch dinh dưỡng — yến mạch nguyên hạt nấu sữa tươi, thêm chuối, mật ong và hạt chia. Mịn sánh, ngọt dịu tự nhiên. Bữa sáng lành mạnh, giàu chất xơ — no lâu cực kỳ!',
    ),
    Product(
      id: '150', name: 'Xôi bắp', category: 'MonNoNhe',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 4200,
      imageUrl: 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=800&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
      ],
      description:
          '🌽 Xôi bắp dừa nước cốt dừa — nếp dẻo nấu cùng bắp ngọt Đà Lạt, chan nước cốt dừa béo và muối mè thơm. Ngọt bùi đặc trưng, ăn nóng mới đúng vị. Bữa sáng quốc dân cực ngon!',
    ),
    Product(
      id: '151', name: 'Bánh giò', category: 'MonNoNhe',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.6, soldCount: 3800,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
        'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=700&q=80',
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=700&q=80',
      ],
      description:
          '🌿 Bánh giò nhân thịt đặc biệt — bột gạo tẻ trắng hấp mịn bọc lá chuối, nhân thịt heo mộc nhĩ nấm hương đậm đà. Mềm mịn, thơm mùi lá chuối. Ăn kèm giò chả — chuẩn vị Bắc Bộ!',
    ),
  ];

  static final List<ProductOption> _mockToppings = [
    ProductOption(id: 't1', name: 'Thêm ớt', type: 'TOPPING', price: 2000),
    ProductOption(id: 't2', name: 'Thêm sốt đặc biệt', type: 'TOPPING', price: 3000),
    ProductOption(id: 't3', name: 'Phần lớn hơn', type: 'TOPPING', price: 5000),
    ProductOption(id: 't4', name: 'Đóng gói hộp riêng', type: 'TOPPING', price: 2000),
  ];

  static final List<OrderModel> _mockOrders = [];
  static final List<ExpenseModel> _mockExpenses = [];

  // API: Lấy thực đơn
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/customer/menu'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (_) {}
    return _mockProducts;
  }

  static Future<List<ProductOption>> getToppings() async => _mockToppings;

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
      return true;
    }
  }

  static Future<List<OrderModel>> getOrders() async => _mockOrders;

  static Future<void> updateOrderStatus(String id, String newStatus) async {
    try {
      final order = _mockOrders.firstWhere((o) => o.id == id);
      order.status = newStatus;
    } catch (_) {}
  }

  static Future<List<ExpenseModel>> getExpenses() async => _mockExpenses;
  static Future<void> addExpense(ExpenseModel expense) async {
    _mockExpenses.insert(0, expense);
  }

  static List<Product> getProductsByCategory(String categoryKey) {
    if (categoryKey == 'All') return _mockProducts;
    return _mockProducts.where((p) => p.category == categoryKey).toList();
  }

  static List<Product> getSuggestedProducts(String excludeId, {int count = 6}) {
    final others = _mockProducts.where((p) => p.id != excludeId).toList();
    others.shuffle();
    return others.take(count).toList();
  }

  /// Get sub-categories for NuocUong
  static Map<String, List<Product>> getDrinkSubcategories() {
    final drinks = _mockProducts.where((p) => p.category == 'NuocUong').toList();
    final Map<String, List<Product>> result = {};
    for (final p in drinks) {
      final sub = p.subcategory ?? 'khac';
      result.putIfAbsent(sub, () => []).add(p);
    }
    return result;
  }

  /// Search suggestions
  static List<Product> searchSuggestions(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _mockProducts
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .take(8)
        .toList();
  }
}
