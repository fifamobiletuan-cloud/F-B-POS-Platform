import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// Helper: tạo đường dẫn asset cho Flutter Web
String _img(String path) => 'assets/images/$path';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api/v1';

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
      imageUrl: _img('anvatman/bapxaobo/bap1.jpg'),
      imageUrls: [
        _img('anvatman/bapxaobo/bap1.jpg'),
        _img('anvatman/bapxaobo/bap2.jpg'),
        _img('anvatman/bapxaobo/bap3.jpg'),
        _img('anvatman/bapxaobo/bap4.jpg'),
        _img('anvatman/bapxaobo/bap5.jpg'),
        _img('anvatman/bapxaobo/bap6.jpg'),
        _img('anvatman/bapxaobo/bap7.jpg'),
      ],
      description:
          '🌽 Bắp xào bơ tươi thơm lừng — bắp ngọt lựa chọn từ vùng Đà Lạt, xào với bơ Anchor béo ngậy, muối tiêu và đường. Ngọt giòn từng hạt, ăn là ghiền. Món ăn vặt lành mạnh số 1!',
    ),
    Product(
      id: '102', name: 'Trứng cút chiên', category: 'AnVatMan',
      basePrice: 8000, originalPrice: 14000,
      rating: 4.5, soldCount: 4200,
      imageUrl: _img('anvatman/trungcutchien/cut1.jpg'),
      imageUrls: [
        _img('anvatman/trungcutchien/cut1.jpg'),
        _img('anvatman/trungcutchien/cut10.jpg'),
        _img('anvatman/trungcutchien/cut2.jpg'),
        _img('anvatman/trungcutchien/cut3.jpg'),
        _img('anvatman/trungcutchien/cut4.jpg'),
        _img('anvatman/trungcutchien/cut5.jpg'),
        _img('anvatman/trungcutchien/cut6.jpg'),
      ],
      description:
          '🥚 Trứng cút chiên giòn vàng — trứng cút tươi luộc vừa chín, chiên ngập dầu vàng giòn bên ngoài. Chấm muối tiêu chanh hoặc tương ớt cay. Xiên 5 trứng, ăn vặt vỉa hè kinh điển!',
    ),
    Product(
      id: '103', name: 'Đậu hũ chiên mắm', category: 'AnVatMan',
      basePrice: 15000, originalPrice: 22000,
      rating: 4.6, soldCount: 3100,
      imageUrl: _img('anvatman/dauhuchienmam/dauhu1.jpg'),
      imageUrls: [
        _img('anvatman/dauhuchienmam/dauhu1.jpg'),
        _img('anvatman/dauhuchienmam/dauhu2.jpg'),
        _img('anvatman/dauhuchienmam/dauhu3.jpg'),
        _img('anvatman/dauhuchienmam/dauhu4.jpg'),
        _img('anvatman/dauhuchienmam/dauhu5.jpg'),
        _img('anvatman/dauhuchienmam/dauhu6.jpg'),
        _img('anvatman/dauhuchienmam/dauhu7.jpg'),
      ],
      description:
          '🍢 Đậu hũ chiên mắm tỏi ớt — đậu hũ non chiên giòn vàng ươm, sốt mắm tỏi ớt đặc biệt thấm đều. Ngoài giòn, trong mềm mịn. Ăn kèm rau sống, đậm đà không ngán. Món chay ngon đỉnh!',
    ),
    Product(
      id: '104', name: 'Bánh gạo chiên', category: 'AnVatMan',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 2700,
      imageUrl: _img('anvatman/banhgaochien/bgao1.jpg'),
      imageUrls: [
        _img('anvatman/banhgaochien/bgao1.jpg'),
        _img('anvatman/banhgaochien/bgao2.jpg'),
        _img('anvatman/banhgaochien/bgao3.jpg'),
        _img('anvatman/banhgaochien/bgao4.jpg'),
        _img('anvatman/banhgaochien/bgao5.jpg'),
        _img('anvatman/banhgaochien/bgao6.jpg'),
        _img('anvatman/banhgaochien/bgao7.jpg'),
      ],
      description:
          '🍘 Bánh gạo chiên giòn kiểu Hàn — bánh gạo hình trụ dài chiên phồng giòn rụm, rắc muối mè thơm. Ngoài giòn trong dai, vị nhạt dịu ăn kèm tương ớt ngọt. Snack lành mạnh đang hot!',
    ),
    
    Product(
      id: '106', name: 'Bò viên nướng', category: 'AnVatMan',
      basePrice: 20000, originalPrice: 30000,
      rating: 4.8, soldCount: 3800,
      imageUrl: _img('anvatman/boviennuong/bo1.jpg'),
      imageUrls: [
        _img('anvatman/boviennuong/bo1.jpg'),
        _img('anvatman/boviennuong/bo2.jpg'),
        _img('anvatman/boviennuong/bo3.jpg'),
        _img('anvatman/boviennuong/bo4.jpg'),
        _img('anvatman/boviennuong/bo5.jpg'),
        _img('anvatman/boviennuong/bo6.jpg'),
        _img('anvatman/boviennuong/bo7.jpg'),
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
      imageUrl: _img('doancay/micayHancap5/micay1.jpg'),
      imageUrls: [
        _img('doancay/micayHancap5/micay1.jpg'),
        _img('doancay/micayHancap5/micay2.jpg'),
        _img('doancay/micayHancap5/micay3.jpg'),
        _img('doancay/micayHancap5/micay4.jpg'),
        _img('doancay/micayHancap5/micay5.jpg'),
        _img('doancay/micayHancap5/micay6.jpg'),
        _img('doancay/micayHancap5/micay7.jpg'),
      ],
      description:
          '🔥 Mì cay Hàn Quốc cấp độ 5 — thách thức vị giác! Mì dai đậm đà, sốt gochujang đặc quánh cay nồng, thêm kimchi và trứng lòng đào. Cấp độ cay cao nhất — chỉ dành cho người gan dạ!',
    ),
    Product(
      id: '108', name: 'Tokbokki cay ngọt', category: 'DoAnCay',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.9, soldCount: 4700,
      imageUrl: _img('doancay/tokbokkicayngot/to1.jpg'),
      imageUrls: [
        _img('doancay/tokbokkicayngot/to1.jpg'),
        _img('doancay/tokbokkicayngot/to2.jpg'),
        _img('doancay/tokbokkicayngot/to3.jpg'),
        _img('doancay/tokbokkicayngot/to4.jpg'),
        _img('doancay/tokbokkicayngot/to5.jpg'),
        _img('doancay/tokbokkicayngot/to6.jpg'),
        _img('doancay/tokbokkicayngot/to7.jpg'),
      ],
      description:
          '🌶️ Tokbokki cay ngọt đường phố — bánh gạo mềm dai sốt gochujang truyền thống pha thêm đường nâu ngọt dịu. Kèm chả cá và trứng luộc. Ăn nóng, húp nước sốt — mê không lối thoát!',
    ),
    Product(
      id: '109', name: 'Bò khô sa tế', category: 'DoAnCay',
      basePrice: 30000, originalPrice: 48000,
      rating: 4.7, soldCount: 3200,
      imageUrl: _img('doancay/bokhosate/bo1.jpg'),
      imageUrls: [
        _img('doancay/bokhosate/bo1.jpg'),
        _img('doancay/bokhosate/bo2.jpg'),
        _img('doancay/bokhosate/bo3.jpg'),
        _img('doancay/bokhosate/bo4.jpg'),
        _img('doancay/bokhosate/bo5.jpg'),
        _img('doancay/bokhosate/bo6.jpg'),
        _img('doancay/bokhosate/bo7.jpg'),
      ],
      description:
          '🥩 Bò khô sa tế đặc biệt — thịt bò Úc loại ngon, tẩm sa tế ớt đỏ thơm nồng, sấy khô đều. Dai mềm vừa phải, cay thơm đậm đà. Túi 100g — ăn vặt đồng hành cùng phim, trà đá!',
    ),
    Product(
      id: '110', name: 'Lẩu mini cay', category: 'DoAnCay',
      basePrice: 55000, originalPrice: 85000,
      rating: 4.8, soldCount: 2100,
      imageUrl: _img('doancay/lauminicay/lau1.jpg'),
      imageUrls: [
        _img('doancay/lauminicay/lau1.jpg'),
        _img('doancay/lauminicay/lau2.jpg'),
        _img('doancay/lauminicay/lau3.jpg'),
        _img('doancay/lauminicay/lau4.jpg'),
        _img('doancay/lauminicay/lau5.jpg'),
        _img('doancay/lauminicay/lau6.jpg'),
        _img('doancay/lauminicay/lau7.jpg'),
      ],
      description:
          '🍲 Lẩu mini cay Tứ Xuyên — nồi lẩu nhỏ xinh cho 1-2 người, nước lèo sichuan cay tê nồng đặc trưng. Đủ rau, bò, tôm, nấm, đậu hũ. Ăn một mình cũng sang — cay mà cứ muốn thêm!',
    ),
    Product(
      id: '111', name: 'Gà cay chiên giòn', category: 'DoAnCay',
      basePrice: 38000, originalPrice: 58000,
      rating: 4.8, soldCount: 3900,
      imageUrl: _img('doancay/gacaychiengion/gacay2.jpg'),
      imageUrls: [
        _img('doancay/gacaychiengion/gacay2.jpg'),
        _img('doancay/gacaychiengion/gacay3.jpg'),
        _img('doancay/gacaychiengion/gacay4.jpg'),
        _img('doancay/gacaychiengion/gacay5.jpg'),
        _img('doancay/gacaychiengion/gacay6.jpg'),
        _img('doancay/gacaychiengion/gacay7.jpg'),
        _img('doancay/gacaychiengion/gacay8.jpg'),
      ],
      description:
          '🍗 Gà cay chiên giòn kiểu Hàn — gà ta ướp gochujang, phủ bột crispy chiên vàng giòn rụm. Cay nồng đậm đà, bên trong mọng nước. Chấm sốt mayo cay — combo hoàn hảo không thể cưỡng!',
    ),
    Product(
      id: '112', name: 'Mực rim sa tế', category: 'DoAnCay',
      basePrice: 32000, originalPrice: 50000,
      rating: 4.6, soldCount: 2400,
      imageUrl: _img('doancay/mucrimsate/muc1.jpg'),
      imageUrls: [
        _img('doancay/mucrimsate/muc1.jpg'),
        _img('doancay/mucrimsate/muc2.jpg'),
        _img('doancay/mucrimsate/muc3.jpg'),
        _img('doancay/mucrimsate/muc6.jpg'),
        _img('doancay/mucrimsate/muc7.jpg'),
        _img('doancay/mucrimsate/mucrim4.jpg'),
        _img('doancay/mucrimsate/mucrim5.jpg'),
      ],
      description:
          '🦑 Mực rim sa tế cay đặc biệt — mực ống tươi cắt khoanh, rim cùng sa tế tôm ớt thơm lừng đến cạn nước. Mực ngọt, cay thơm, đậm đà. Ăn kèm cơm trắng hoặc nhậu đều tuyệt hảo!',
    ),
    Product(
      id: '113', name: 'Trứng vịt lộn sốt cay', category: 'DoAnCay',
      basePrice: 20000, originalPrice: 30000,
      rating: 4.7, soldCount: 4500,
      imageUrl: _img('doancay/trungvitlonsotcay/trungcay1.jpg'),
      imageUrls: [
        _img('doancay/trungvitlonsotcay/trungcay1.jpg'),
        _img('doancay/trungvitlonsotcay/trungcay2.jpg'),
        _img('doancay/trungvitlonsotcay/trungcay3.jpg'),
        _img('doancay/trungvitlonsotcay/trungcay4.jpg'),
        _img('doancay/trungvitlonsotcay/trungcay5.jpg'),
        _img('doancay/trungvitlonsotcay/trungcay6.jpg'),
        _img('doancay/trungvitlonsotcay/trungcay7.jpg'),
      ],
      description:
          '🥚 Trứng vịt lộn sốt cay đặc biệt — trứng hột vịt lộn cổ điển phủ sốt cay sa tế ớt, thêm rau răm thơm và muối tiêu. Vừa bổ vừa ngon, đường phố Sài Gòn huyền thoại. 2 trứng/phần!',
    ),

    // ══════════════════════════════════════════
    //  🥤 Nước uống (Trà đào, Trà tắc, Trà sữa, Cacao, Nước ép)
    // ══════════════════════════════════════════
    
    // --- 🍑 Trà đào (tradao) ---
    Product(
      id: '13', name: 'Trà đào truyền thống', category: 'NuocUong',
      subcategory: 'tradao',
      basePrice: 28000, originalPrice: 40000,
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
          '🍑 Trà đào truyền thống thơm ngát vị đào tươi, miếng đào giòn ngọt mọng nước cùng vị trà thanh mát dịu nhẹ.',
    ),
    Product(
      id: '201', name: 'Trà đào cam sả', category: 'NuocUong',
      subcategory: 'tradao',
      basePrice: 32000, originalPrice: 48000,
      rating: 4.8, soldCount: 4600,
      imageUrl: _img('nuocuong/tradao/dao2.jpg'),
      imageUrls: [
        _img('nuocuong/tradao/dao2.jpg'),
        _img('nuocuong/tradao/dao3.jpg'),
        _img('nuocuong/tradao/dao4.jpg'),
        _img('nuocuong/tradao/dao5.jpg'),
        _img('nuocuong/tradao/dao6.jpg'),
        _img('nuocuong/tradao/dao7.jpg'),
        _img('nuocuong/tradao/dao8.jpg'),
      ],
      description:
          '🍊 Trà đào cam sả thanh lọc, kết hợp hoàn hảo giữa vị cam chua ngọt, sả thơm the mát và đào giòn ngọt.',
    ),
    Product(
      id: '202', name: 'Trà đào sữa đá', category: 'NuocUong',
      subcategory: 'tradao',
      basePrice: 30000, originalPrice: 45000,
      rating: 4.7, soldCount: 3900,
      imageUrl: _img('nuocuong/tradao/dao3.jpg'),
      imageUrls: [
        _img('nuocuong/tradao/dao3.jpg'),
        _img('nuocuong/tradao/dao4.jpg'),
        _img('nuocuong/tradao/dao5.jpg'),
        _img('nuocuong/tradao/dao6.jpg'),
        _img('nuocuong/tradao/dao7.jpg'),
        _img('nuocuong/tradao/dao8.jpg'),
        _img('nuocuong/tradao/dao1.jpg'),
      ],
      description:
          '🍑 Trà đào sữa đá béo ngậy pha lẫn hương trà thanh thoảng và miếng đào giòn dai sảng khoái.',
    ),
    Product(
      id: '203', name: 'Trà đào kem cheese', category: 'NuocUong',
      subcategory: 'tradao',
      basePrice: 35000, originalPrice: 50000,
      rating: 4.9, soldCount: 5100,
      imageUrl: _img('nuocuong/tradao/dao4.jpg'),
      imageUrls: [
        _img('nuocuong/tradao/dao4.jpg'),
        _img('nuocuong/tradao/dao5.jpg'),
        _img('nuocuong/tradao/dao6.jpg'),
        _img('nuocuong/tradao/dao7.jpg'),
        _img('nuocuong/tradao/dao8.jpg'),
        _img('nuocuong/tradao/dao1.jpg'),
        _img('nuocuong/tradao/dao2.jpg'),
      ],
      description:
          '🧀 Lớp màng kem phô mai sánh mịn mặn mặn béo ngậy phủ trên nền trà đào thanh ngọt đậm đà.',
    ),

    // --- 🍋 Trà tắc (tratac) ---
    Product(
      id: '117', name: 'Trà tắc mật ong', category: 'NuocUong',
      subcategory: 'tratac',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.8, soldCount: 6200,
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
          '🍋 Trà tắc mật ong thơm lừng ngào ngạt, chua thanh từ tắc tươi kết hợp mật ong rừng ngọt êm cổ họng.',
    ),
    Product(
      id: '204', name: 'Trà tắc xí muội', category: 'NuocUong',
      subcategory: 'tratac',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 4300,
      imageUrl: _img('nuocuong/tratac/tac2.jpg'),
      imageUrls: [
        _img('nuocuong/tratac/tac2.jpg'),
        _img('nuocuong/tratac/tac3.jpg'),
        _img('nuocuong/tratac/tac4.jpg'),
        _img('nuocuong/tratac/tac5.jpg'),
        _img('nuocuong/tratac/tac6.jpg'),
        _img('nuocuong/tratac/tac7.jpg'),
        _img('nuocuong/tratac/tac8.jpg'),
      ],
      description:
          '🍋 Chua chua ngọt ngọt mặn mà của xí muội dầm hòa quyện cùng nước cốt tắc tươi mát lịm.',
    ),
    Product(
      id: '205', name: 'Trà tắc hoa đậu biếc', category: 'NuocUong',
      subcategory: 'tratac',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.8, soldCount: 3700,
      imageUrl: _img('nuocuong/tratac/tac3.jpg'),
      imageUrls: [
        _img('nuocuong/tratac/tac3.jpg'),
        _img('nuocuong/tratac/tac4.jpg'),
        _img('nuocuong/tratac/tac5.jpg'),
        _img('nuocuong/tratac/tac6.jpg'),
        _img('nuocuong/tratac/tac7.jpg'),
        _img('nuocuong/tratac/tac8.jpg'),
        _img('nuocuong/tratac/tac1.jpg'),
      ],
      description:
          '🌸 Màu tím biếc huyền ảo của hoa đậu biếc chuyển sắc khi gặp chanh tắc, hương vị thơm dịu thanh mát.',
    ),
    Product(
      id: '206', name: 'Trà tắc khổng lồ', category: 'NuocUong',
      subcategory: 'tratac',
      basePrice: 25000, originalPrice: 40000,
      rating: 4.9, soldCount: 7100,
      imageUrl: _img('nuocuong/tratac/tac4.jpg'),
      imageUrls: [
        _img('nuocuong/tratac/tac4.jpg'),
        _img('nuocuong/tratac/tac5.jpg'),
        _img('nuocuong/tratac/tac6.jpg'),
        _img('nuocuong/tratac/tac7.jpg'),
        _img('nuocuong/tratac/tac8.jpg'),
        _img('nuocuong/tratac/tac1.jpg'),
        _img('nuocuong/tratac/tac2.jpg'),
      ],
      description:
          '🥤 Ly 1 lít siêu to khổng lồ giải nhiệt ngày hè cực đã, đậm vị tắc chua ngọt sảng khoái.',
    ),

    // --- 🧋 Trà sữa (trasua) ---
    Product(
      id: '9', name: 'Trà sữa trân châu đường đen', category: 'NuocUong',
      subcategory: 'trasua',
      basePrice: 35000, originalPrice: 50000,
      rating: 4.9, soldCount: 9800,
      imageUrl: _img('nuocuong/trasua/duongden/den1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/duongden/den1.jpg'),
        _img('nuocuong/trasua/duongden/den2.jpg'),
        _img('nuocuong/trasua/duongden/den3.jpg'),
        _img('nuocuong/trasua/duongden/den4.jpg'),
        _img('nuocuong/trasua/duongden/den5.jpg'),
        _img('nuocuong/trasua/duongden/den6.jpg'),
        _img('nuocuong/trasua/duongden/den7.jpg'),
      ],
      description:
          '🧋 Trà sữa trân châu đường đen trứ danh, sốt đường đen đậm vị dẻo quánh cùng trân châu dai giòn sần sật.',
    ),
    Product(
      id: '10', name: 'Trà sữa matcha', category: 'NuocUong',
      subcategory: 'trasua',
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
          '🍵 Bột matcha Uji thượng hạng hòa quyện sữa tươi thanh trùng béo nhẹ, đắng dịu chuẩn gu Nhật Bản.',
    ),
    Product(
      id: '11', name: 'Trà sữa truyền thống', category: 'NuocUong',
      subcategory: 'trasua',
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
          '🥛 Trà đen tuyển chọn ủ đậm vị kết hợp sữa béo thơm lừng, hương vị tuổi thơ đậm đà khó quên.',
    ),
    Product(
      id: '114', name: 'Trà sữa ô long', category: 'NuocUong',
      subcategory: 'trasua',
      basePrice: 32000, originalPrice: 48000,
      rating: 4.8, soldCount: 5300,
      imageUrl: _img('nuocuong/trasua/olong/olong1.jpg'),
      imageUrls: [
        _img('nuocuong/trasua/olong/olong1.jpg'),
        _img('nuocuong/trasua/olong/olong2.jpg'),
        _img('nuocuong/trasua/olong/olong3.jpg'),
        _img('nuocuong/trasua/olong/olong5.jpg'),
        _img('nuocuong/trasua/olong/olong6.jpg'),
        _img('nuocuong/trasua/olong/olong7.jpg'),
        _img('nuocuong/trasua/olong/olong.jpg'),
      ],
      description:
          '🍵 Trà ô long nướng thơm khói dịu dàng, vị trà hậu ngọt đậm sâu quyện cùng sữa tươi mịn béo.',
    ),
    Product(
      id: '115', name: 'Trà sữa Thái', category: 'NuocUong',
      subcategory: 'trasua',
      basePrice: 30000, originalPrice: 45000,
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
          '🧡 Trà sữa Thái thơm nồng hương thảo mộc đặc trưng, béo ngậy sữa đặc và sữa tươi bốc khói đá mát.',
    ),

    // --- 🍫 Cacao (cacao) ---
    Product(
      id: '118', name: 'Cacao nóng đá', category: 'NuocUong',
      subcategory: 'cacao',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.7, soldCount: 3200,
      imageUrl: _img('nuocuong/cacao/cacaonongda/nongda1.jpg'),
      imageUrls: [
        _img('nuocuong/cacao/cacaonongda/nongda1.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda2.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda3.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda4.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda5.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda6.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda7.jpg'),
      ],
      description:
          '☕ Bột cacao Đắk Lắk nguyên chất 100%, đắng thơm đậm vị socola quyến rũ, uống đá hay nóng đều tuyệt đỉnh.',
    ),
    Product(
      id: '207', name: 'Cacao sữa béo ngậy', category: 'NuocUong',
      subcategory: 'cacao',
      basePrice: 30000, originalPrice: 45000,
      rating: 4.8, soldCount: 4100,
      imageUrl: _img('nuocuong/cacao/caccaosua/ccsua1.jpg'),
      imageUrls: [
        _img('nuocuong/cacao/caccaosua/ccsua1.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua2.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua3.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua4.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua5.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua6.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua7.jpg'),
      ],
      description:
          '🥛 Cacao sữa béo ngậy kem đặc thơm lừng, lớp bột cacao rắc phủ trên mặt tạo điểm nhấn khó quên.',
    ),
    Product(
      id: '208', name: 'Cacao dừa đá tuyết', category: 'NuocUong',
      subcategory: 'cacao',
      basePrice: 35000, originalPrice: 52000,
      rating: 4.9, soldCount: 4600,
      imageUrl: _img('nuocuong/cacao/cacaodua/ccdua5.jpg'),
      imageUrls: [
        _img('nuocuong/cacao/cacaodua/ccdua5.jpg'),
        _img('nuocuong/cacao/cacaodua/ccdua6.jpg'),
        _img('nuocuong/cacao/cacaodua/ccdua7.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda1.jpg'),
        _img('nuocuong/cacao/cacaonongda/nongda2.jpg'),
        _img('nuocuong/cacao/caccaosua/ccsua1.jpg'),
      ],
      description:
          '🥥 Cốt dừa đá tuyết xay sánh mịn rót sốt cacao đậm đặc sánh ngậy lên trên, siêu phẩm giải nhiệt.',
    ),

    // --- 🍊 Nước ép (nuocep) ---
    Product(
      id: '12', name: 'Nước ép cam tươi', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.8, soldCount: 5300,
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
          '🍊 Cam sành tươi mọng nước vắt nguyên chất, dồi dào vitamin C giúp tăng sức đề kháng tự nhiên.',
    ),
    Product(
      id: '116', name: 'Nước ép dừa tươi', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.7, soldCount: 3900,
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
          '🥥 Nước dừa tươi ngọt thanh mát lành bổ sung chất điện giải tự nhiên cho cơ thể.',
    ),
    Product(
      id: '120', name: 'Nước ép dưa hấu', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.8, soldCount: 4200,
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
          '🍉 Dưa hấu ruột đỏ ngọt lịm ép chậm giữ trọn vitamin, thanh mát ngày oi ả.',
    ),
    Product(
      id: '209', name: 'Nước ép lê tươi', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.7, soldCount: 3100,
      imageUrl: _img('nuocuong/nuocep/le/le1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/le/le1.jpg'),
        _img('nuocuong/nuocep/le/le2.jpg'),
        _img('nuocuong/nuocep/le/le3.jpg'),
        _img('nuocuong/nuocep/le/le4.jpg'),
        _img('nuocuong/nuocep/le/le5.jpg'),
        _img('nuocuong/nuocep/le/le6.jpg'),
        _img('nuocuong/nuocep/le/le7.jpg'),
      ],
      description:
          '🍐 Quả lê vàng mọng nước ép thanh ngọt, mát gan bổ phế nhuận tràng.',
    ),
    Product(
      id: '210', name: 'Nước ép nho tươi', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 30000, originalPrice: 45000,
      rating: 4.8, soldCount: 3800,
      imageUrl: _img('nuocuong/nuocep/nho/nho1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/nho/nho1.jpg'),
        _img('nuocuong/nuocep/nho/nho2.jpg'),
        _img('nuocuong/nuocep/nho/nho3.jpg'),
        _img('nuocuong/nuocep/nho/nho4.jpg'),
        _img('nuocuong/nuocep/nho/nho5.jpg'),
        _img('nuocuong/nuocep/nho/nho6.jpg'),
        _img('nuocuong/nuocep/nho/nho7.jpg'),
      ],
      description:
          '🍇 Nho tím chín mọng nước chua ngọt thanh tao giàu chất chống oxy hóa tự nhiên.',
    ),
    Product(
      id: '211', name: 'Nước ép táo tươi', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.8, soldCount: 4500,
      imageUrl: _img('nuocuong/nuocep/tao/tao1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/tao/tao1.jpg'),
        _img('nuocuong/nuocep/tao/tao2.jpg'),
        _img('nuocuong/nuocep/tao/tao3.jpg'),
        _img('nuocuong/nuocep/tao/tao4.jpg'),
        _img('nuocuong/nuocep/tao/tao5.jpg'),
        _img('nuocuong/nuocep/tao/tao6.jpg'),
        _img('nuocuong/nuocep/tao/tao7.jpg'),
      ],
      description:
          '🍎 Táo Envy tươi giòn ngọt ép nguyên chất thơm lừng, bổ sung khoáng chất tuyệt vời.',
    ),
    Product(
      id: '212', name: 'Nước ép xoài tươi', category: 'NuocUong',
      subcategory: 'nuocep',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.8, soldCount: 4300,
      imageUrl: _img('nuocuong/nuocep/xoai/xoai1.jpg'),
      imageUrls: [
        _img('nuocuong/nuocep/xoai/xoai1.jpg'),
        _img('nuocuong/nuocep/xoai/xoai2.jpg'),
        _img('nuocuong/nuocep/xoai/xoai4.jpg'),
        _img('nuocuong/nuocep/xoai/xoai5.jpg'),
        _img('nuocuong/nuocep/xoai/xoai6.jpg'),
        _img('nuocuong/nuocep/xoai/xoai7.jpg'),
        _img('nuocuong/nuocep/xoai/xoai8.jpg'),
      ],
      description:
          '🥭 Xoài cát chín vàng ươm ngọt lịm thơm nồng, giàu vitamin A và khoáng chất tự nhiên.',
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
      imageUrl: _img('banh&dongot/banhdonutphuduong/donut1.jpg'),
      imageUrls: [
        _img('banh&dongot/banhdonutphuduong/donut1.jpg'),
        _img('banh&dongot/banhdonutphuduong/donut2.jpg'),
        _img('banh&dongot/banhdonutphuduong/donut3.jpg'),
        _img('banh&dongot/banhdonutphuduong/donut4.jpg'),
        _img('banh&dongot/banhdonutphuduong/donut5.jpg'),
        _img('banh&dongot/banhdonutphuduong/donut6.jpg'),
        _img('banh&dongot/banhdonutphuduong/donut7.jpg'),
      ],
      description:
          '🍩 Bánh donut phủ đường nhiều vị — vòng donut xốp mềm chiên vàng, phủ chocolate, dâu, matcha, caramel. Rắc thêm sprinkle màu sắc bắt mắt. Mỗi chiếc là một niềm vui ngọt ngào!',
    ),
    Product(
      id: '123', name: 'Bánh mochi nhân đậu đỏ', category: 'BanhNgot',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.8, soldCount: 2700,
      imageUrl: _img('banh&dongot/banhmochinhandaudo/mo1.jpg'),
      imageUrls: [
        _img('banh&dongot/banhmochinhandaudo/mo1.jpg'),
        _img('banh&dongot/banhmochinhandaudo/mo2.jpg'),
        _img('banh&dongot/banhmochinhandaudo/mo3.jpg'),
        _img('banh&dongot/banhmochinhandaudo/mo4.jpg'),
        _img('banh&dongot/banhmochinhandaudo/mo5.jpg'),
        _img('banh&dongot/banhmochinhandaudo/mo6.jpg'),
        _img('banh&dongot/banhmochinhandaudo/mo7.jpg'),
      ],
      description:
          '🍡 Bánh mochi nhân đậu đỏ Nhật Bản — vỏ mochi dẻo thơm nếp trắng tinh, nhân đậu đỏ azuki ngọt bùi. Mềm mịn tan chảy trong miệng. Hộp 4 chiếc — quà tặng ngọt ngào tinh tế!',
    ),
    Product(
      id: '124', name: 'Bánh crepe matcha', category: 'BanhNgot',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.7, soldCount: 2900,
      imageUrl: _img('banh&dongot/crepematcha/cm1.jpg'),
      imageUrls: [
        _img('banh&dongot/crepematcha/cm1.jpg'),
        _img('banh&dongot/crepematcha/cm2.jpg'),
        _img('banh&dongot/crepematcha/cm3.jpg'),
        _img('banh&dongot/crepematcha/cm4.jpg'),
        _img('banh&dongot/crepematcha/cm5.jpg'),
        _img('banh&dongot/crepematcha/cm6.jpg'),
        _img('banh&dongot/crepematcha/cm7.jpg'),
      ],
      description:
          '🍵 Bánh crepe matcha Nhật — lớp crepe mỏng xanh matcha Uji, cuộn kem tươi đánh bông mịn và trái cây tươi. Thanh mát, ngọt dịu, đẹp mắt cực chụp hình. Tráng miệng sang chảnh!',
    ),
    Product(
      id: '125', name: 'Bánh waffle', category: 'BanhNgot',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.8, soldCount: 3100,
      imageUrl: _img('banh&dongot/waffle/w1.jpg'),
      imageUrls: [
        _img('banh&dongot/waffle/w1.jpg'),
        _img('banh&dongot/waffle/w2.jpg'),
        _img('banh&dongot/waffle/w3.jpg'),
        _img('banh&dongot/waffle/w4.jpg'),
        _img('banh&dongot/waffle/w5.jpg'),
        _img('banh&dongot/waffle/w6.jpg'),
        _img('banh&dongot/waffle/w7.jpg'),
      ],
      description:
          '🧇 Bánh waffle giòn vàng — bánh waffle Bỉ nướng vàng giòn bên ngoài, mềm xốp bên trong. Phủ kem tươi, mứt dâu, siro maple. Nhiều topping lựa chọn — bữa sáng hoặc tráng miệng đều ngon!',
    ),
    Product(
      id: '126', name: 'Pudding caramel', category: 'BanhNgot',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 2500,
      imageUrl: _img('banh&dongot/puddingcaramel/pudca1.jpg'),
      imageUrls: [
        _img('banh&dongot/puddingcaramel/pudca1.jpg'),
        _img('banh&dongot/puddingcaramel/pudca2.jpg'),
        _img('banh&dongot/puddingcaramel/pudca3.jpg'),
        _img('banh&dongot/puddingcaramel/pudca4.jpg'),
        _img('banh&dongot/puddingcaramel/pudca5.jpg'),
        _img('banh&dongot/puddingcaramel/pudca6.jpg'),
        _img('banh&dongot/puddingcaramel/pudca7.jpg'),
      ],
      description:
          '🍮 Pudding caramel kinh điển — trứng sữa hấp mịn mượt như lụa, phủ caramel vàng đắng ngọt hoàn hảo. Rung rinh nhẹ, tan chảy tức thì. Tráng miệng Pháp thanh lịch, đơn giản mà đẳng cấp!',
    ),
    Product(
      id: '127', name: 'Bánh tart sữa dừa', category: 'BanhNgot',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.6, soldCount: 2300,
      imageUrl: _img('banh&dongot/tartsuadua/sd1.jpg'),
      imageUrls: [
        _img('banh&dongot/tartsuadua/sd1.jpg'),
        _img('banh&dongot/tartsuadua/sd2.jpg'),
        _img('banh&dongot/tartsuadua/sd3.jpg'),
        _img('banh&dongot/tartsuadua/sd4.jpg'),
        _img('banh&dongot/tartsuadua/sd5.jpg'),
        _img('banh&dongot/tartsuadua/sd6.jpg'),
        _img('banh&dongot/tartsuadua/sd7.jpg'),
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
      imageUrl: _img('snack&keo/snackmucthai/mt1.jpg'),
      imageUrls: [
        _img('snack&keo/snackmucthai/mt1.jpg'),
        _img('snack&keo/snackmucthai/mt2.jpg'),
        _img('snack&keo/snackmucthai/mt3.jpg'),
        _img('snack&keo/snackmucthai/mt4.jpg'),
        _img('snack&keo/snackmucthai/mt5.jpg'),
        _img('snack&keo/snackmucthai/mt6.jpg'),
        _img('snack&keo/snackmucthai/mt7.jpg'),
      ],
      description:
          '🦑 Snack mực sấy Thái Lan — mực ống tươi tẩm gia vị Thái đặc trưng, sấy giòn dai thơm phức. Ngọt tự nhiên từ mực, cay nhẹ hậu vị. Túi 80g — ăn vặt cùng trà đá siêu đỉnh!',
    ),
    Product(
      id: '129', name: 'Kẹo caramel mềm', category: 'SnackKeo',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.6, soldCount: 3200,
      imageUrl: _img('snack&keo/caramelmem/mem1.jpg'),
      imageUrls: [
        _img('snack&keo/caramelmem/mem1.jpg'),
        _img('snack&keo/caramelmem/mem2.jpg'),
        _img('snack&keo/caramelmem/mem3.jpg'),
        _img('snack&keo/caramelmem/mem4.jpg'),
        _img('snack&keo/caramelmem/mem5.jpg'),
        _img('snack&keo/caramelmem/mem6.jpg'),
        _img('snack&keo/caramelmem/mem7.jpg'),
      ],
      description:
          '🍬 Kẹo caramel bơ mềm Pháp — caramel sữa tan chảy mượt, bơ Normandy thơm béo ngậy, mặn ngọt hài hòa tuyệt vời. Mỗi viên gói giấy bạc tinh tế. Hộp 200g — quà tặng sang trọng!',
    ),
    Product(
      id: '130', name: 'Bánh quy bơ', category: 'SnackKeo',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.7, soldCount: 3800,
      imageUrl: _img('snack&keo/banhquybo/bo1.jpg'),
      imageUrls: [
        _img('snack&keo/banhquybo/bo1.jpg'),
        _img('snack&keo/banhquybo/bo2.jpg'),
        _img('snack&keo/banhquybo/bo3.jpg'),
        _img('snack&keo/banhquybo/bo4.jpg'),
        _img('snack&keo/banhquybo/bo5.jpg'),
        _img('snack&keo/banhquybo/bo6.jpg'),
        _img('snack&keo/banhquybo/bo7.jpg'),
      ],
      description:
          '🍪 Bánh quy bơ Đan Mạch giòn tan — làm từ bơ Lurpak chính hãng, giòn nhẹ thơm béo không ngấy. Nhiều hình dáng dễ thương, vị vani và phô mai. Hộp thiếc 400g — bánh nhà làm chuẩn vị!',
    ),
    Product(
      id: '131', name: 'Snack khoai lang', category: 'SnackKeo',
      basePrice: 12000, originalPrice: 20000,
      rating: 4.5, soldCount: 4500,
      imageUrl: _img('snack&keo/snackkhoailang/kl1.jpg'),
      imageUrls: [
        _img('snack&keo/snackkhoailang/kl1.jpg'),
        _img('snack&keo/snackkhoailang/kl2.jpg'),
        _img('snack&keo/snackkhoailang/kl3.jpg'),
        _img('snack&keo/snackkhoailang/kl4.jpg'),
        _img('snack&keo/snackkhoailang/kl5.jpg'),
        _img('snack&keo/snackkhoailang/kl6.jpg'),
        _img('snack&keo/snackkhoailang/kl7.jpg'),
      ],
      description:
          '🍠 Snack khoai lang sấy giòn — khoai lang Nhật tím và vàng thái lát mỏng, sấy giòn tự nhiên không dầu chiên. Ngọt bùi tự nhiên, lành mạnh ít calo. Snack ăn kiêng mà vẫn ngon!',
    ),
    Product(
      id: '132', name: 'Kẹo lollipop', category: 'SnackKeo',
      basePrice: 8000, originalPrice: 15000,
      rating: 4.4, soldCount: 2900,
      imageUrl: _img('snack&keo/keololipop/lo1.jpg'),
      imageUrls: [
        _img('snack&keo/keololipop/lo1.jpg'),
        _img('snack&keo/keololipop/lo2.jpg'),
        _img('snack&keo/keololipop/lo3.jpg'),
        _img('snack&keo/keololipop/lo4.jpg'),
        _img('snack&keo/keololipop/lo5.jpg'),
        _img('snack&keo/keololipop/lo6.jpg'),
        _img('snack&keo/keololipop/lo7.jpg'),
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
      imageUrl: _img('traicay&dochua/khechuamuoiot/khe1.jpg'),
      imageUrls: [
        _img('traicay&dochua/khechuamuoiot/khe1.jpg'),
        _img('traicay&dochua/khechuamuoiot/khe2.jpg'),
        _img('traicay&dochua/khechuamuoiot/khe3.jpg'),
        _img('traicay&dochua/khechuamuoiot/khe4.jpg'),
        _img('traicay&dochua/khechuamuoiot/khe5.jpg'),
        _img('traicay&dochua/khechuamuoiot/khe6.jpg'),
        _img('traicay&dochua/khechuamuoiot/khe7.jpg'),
      ],
      description:
          '⭐ Khế chua chấm muối ớt đặc biệt — khế vàng chua giòn thái lát, chấm muối ớt xanh tây ninh. Vị chua gắt kích thích vị giác ngay lập tức. Đặc sản vỉa hè Nam Bộ khó quên!',
    ),
    Product(
      id: '134', name: 'Sấu ngâm đường', category: 'TraiCayChua',
      basePrice: 15000, originalPrice: 24000,
      rating: 4.6, soldCount: 2300,
      imageUrl: _img('traicay&dochua/saungamduong/sau1.jpg'),
      imageUrls: [
        _img('traicay&dochua/saungamduong/sau1.jpg'),
        _img('traicay&dochua/saungamduong/sau2.jpg'),
        _img('traicay&dochua/saungamduong/sau3.jpg'),
        _img('traicay&dochua/saungamduong/sau4.jpg'),
        _img('traicay&dochua/saungamduong/sau5.jpg'),
        _img('traicay&dochua/saungamduong/sau6.jpg'),
        _img('traicay&dochua/saungamduong/sau7.jpg'),
      ],
      description:
          '🟢 Sấu ngâm đường chua ngọt — sấu Hà Nội chua gắt ngâm đường phèn qua đêm, vị chua dịu lại, ngọt thanh. Đặc sản mùa hè miền Bắc, giải nhiệt tuyệt vời. Hũ thủy tinh đẹp, tặng quà cũng hay!',
    ),
    Product(
      id: '135', name: 'Dứa lắc muối', category: 'TraiCayChua',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 3600,
      imageUrl: _img('traicay&dochua/dualacmuoi/dua1.jpg'),
      imageUrls: [
        _img('traicay&dochua/dualacmuoi/dua1.jpg'),
        _img('traicay&dochua/dualacmuoi/dua2.jpg'),
        _img('traicay&dochua/dualacmuoi/dua3.jpg'),
        _img('traicay&dochua/dualacmuoi/dua4.jpg'),
        _img('traicay&dochua/dualacmuoi/dua5.jpg'),
        _img('traicay&dochua/dualacmuoi/dua6.jpg'),
        _img('traicay&dochua/dualacmuoi/dua7.jpg'),
      ],
      description:
          '🍍 Dứa (thơm) lắc muối ớt chua ngọt — dứa tươi thái miếng, lắc muối ớt đỏ cay nồng. Ngọt chua tự nhiên, cay thơm đặc trưng. Ăn vặt đường phố huyền thoại. Hộp 200g đủ no bụng!',
    ),
    Product(
      id: '136', name: 'Chuối sấy', category: 'TraiCayChua',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.6, soldCount: 3200,
      imageUrl: _img('traicay&dochua/chuoisay/cs1.jpg'),
      imageUrls: [
        _img('traicay&dochua/chuoisay/cs1.jpg'),
        _img('traicay&dochua/chuoisay/cs2.jpg'),
        _img('traicay&dochua/chuoisay/cs3.jpg'),
        _img('traicay&dochua/chuoisay/cs4.jpg'),
        _img('traicay&dochua/chuoisay/cs5.jpg'),
        _img('traicay&dochua/chuoisay/cs6.jpg'),
        _img('traicay&dochua/chuoisay/cs7.jpg'),
      ],
      description:
          '🍌 Chuối sấy dẻo thơm ngọt — chuối già Nam Bộ chín vàng, sấy dẻo ở nhiệt độ thấp giữ nguyên dinh dưỡng. Ngọt tự nhiên, dai dẻo, thơm thơm. Snack lành mạnh không đường không dầu!',
    ),
    Product(
      id: '137', name: 'Chôm chôm tươi', category: 'TraiCayChua',
      basePrice: 20000, originalPrice: 32000,
      rating: 4.5, soldCount: 2100,
      imageUrl: _img('traicay&dochua/chomchomtuoi/chom1.jpg'),
      imageUrls: [
        _img('traicay&dochua/chomchomtuoi/chom1.jpg'),
        _img('traicay&dochua/chomchomtuoi/chom2.jpg'),
        _img('traicay&dochua/chomchomtuoi/chom3.jpg'),
        _img('traicay&dochua/chomchomtuoi/chom4.jpg'),
        _img('traicay&dochua/chomchomtuoi/chom5.jpg'),
        _img('traicay&dochua/chomchomtuoi/chom6.jpg'),
        _img('traicay&dochua/chomchomtuoi/chom7.jpg'),
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
      imageUrl: _img('anvathanquoc/Hotteok/hok1.jpg'),
      imageUrls: [
        _img('anvathanquoc/Hotteok/hok1.jpg'),
        _img('anvathanquoc/Hotteok/hok2.jpg'),
        _img('anvathanquoc/Hotteok/hok3.jpg'),
        _img('anvathanquoc/Hotteok/hok4.jpg'),
        _img('anvathanquoc/Hotteok/hok5.jpg'),
        _img('anvathanquoc/Hotteok/hok6.jpg'),
        _img('anvathanquoc/Hotteok/hok7.jpg'),
      ],
      description:
          '🥞 Hotteok bánh nóng Hàn Quốc — bánh dẹp nhân đường đen hạt dẻ, chiên áp chảo vàng giòn. Cắn vào chảy ngọt ấm bên trong, vỏ giòn thơm mùi bơ. Đặc sản mùa đông Seoul cực hút!',
    ),
    Product(
      id: '139', name: 'Dalgona kẹo bong', category: 'AnVatHanQuoc',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.7, soldCount: 3400,
      imageUrl: _img('anvathanquoc/Dalgona/dal1.jpg'),
      imageUrls: [
        _img('anvathanquoc/Dalgona/dal1.jpg'),
        _img('anvathanquoc/Dalgona/dal2.jpg'),
        _img('anvathanquoc/Dalgona/dal3.jpg'),
        _img('anvathanquoc/Dalgona/dal4.jpg'),
        _img('anvathanquoc/Dalgona/dal5.jpg'),
        _img('anvathanquoc/Dalgona/dal6.jpg'),
        _img('anvathanquoc/Dalgona/dal7.jpg'),
      ],
      description:
          '🍬 Dalgona kẹo đường bong bóng — đường caramel đun chảy đổ khuôn hình thú độc đáo (squid game). Mỏng giòn, ngọt caramel thơm. Thử thách tách khuôn cực vui! Đặc sản viral TikTok!',
    ),
    Product(
      id: '140', name: 'Tteok bánh gạo nướng', category: 'AnVatHanQuoc',
      basePrice: 25000, originalPrice: 40000,
      rating: 4.7, soldCount: 2800,
      imageUrl: _img('anvathanquoc/tteokbanhgaonuong/teo1.jpg'),
      imageUrls: [
        _img('anvathanquoc/tteokbanhgaonuong/teo1.jpg'),
        _img('anvathanquoc/tteokbanhgaonuong/teo2.jpg'),
        _img('anvathanquoc/tteokbanhgaonuong/teo3.jpg'),
        _img('anvathanquoc/tteokbanhgaonuong/teo4.jpg'),
        _img('anvathanquoc/tteokbanhgaonuong/teo5.jpg'),
        _img('anvathanquoc/tteokbanhgaonuong/teo6.jpg'),
        _img('anvathanquoc/tteokbanhgaonuong/teo7.jpg'),
      ],
      description:
          '🍢 Tteok bánh gạo nướng than — bánh gạo dẹt xiên que nướng trên than hoa, phết gochujang ngọt cay. Ngoài cháy xém thơm, trong dẻo dai. Đường phố Hàn Quốc hương vị không đâu có!',
    ),
    Product(
      id: '141', name: 'Japchae miến xào', category: 'AnVatHanQuoc',
      basePrice: 32000, originalPrice: 50000,
      rating: 4.7, soldCount: 2400,
      imageUrl: _img('anvathanquoc/Japchae/jap1.jpg'),
      imageUrls: [
        _img('anvathanquoc/Japchae/jap1.jpg'),
        _img('anvathanquoc/Japchae/jap2.jpg'),
        _img('anvathanquoc/Japchae/jap3.jpg'),
        _img('anvathanquoc/Japchae/jap4.jpg'),
        _img('anvathanquoc/Japchae/jap5.jpg'),
        _img('anvathanquoc/Japchae/jap6.jpg'),
        _img('anvathanquoc/Japchae/jap7.jpg'),
      ],
      description:
          '🍜 Japchae miến xào Hàn Quốc — miến khoai lang dai trong xào cùng thịt bò, rau củ ngũ sắc, sốt ganjang mè thơm. Ăn nóng hoặc nguội đều ngon, vị ngọt mặn đặc trưng xứ Hàn!',
    ),
    Product(
      id: '142', name: 'Gimbap cơm cuộn đặc biệt', category: 'AnVatHanQuoc',
      basePrice: 30000, originalPrice: 48000,
      rating: 4.8, soldCount: 3100,
      imageUrl: _img('anvathanquoc/Gimbap/gb1.jpg'),
      imageUrls: [
        _img('anvathanquoc/Gimbap/gb1.jpg'),
        _img('anvathanquoc/Gimbap/gb2.jpg'),
        _img('anvathanquoc/Gimbap/gb3.jpg'),
        _img('anvathanquoc/Gimbap/gb4.jpg'),
        _img('anvathanquoc/Gimbap/gb5.jpg'),
        _img('anvathanquoc/Gimbap/gb6.jpg'),
        _img('anvathanquoc/Gimbap/gb7.jpg'),
      ],
      description:
          '🍱 Gimbap cơm cuộn đặc biệt — cơm dẻo trộn mè dầu mè, cuộn nori với bò bulgogi, trứng chiên, cà rốt, rau bina. Thơm ngon đậm vị Hàn. Hộp 10 miếng — bữa trưa hoàn hảo!',
    ),
    Product(
      id: '143', name: 'Bingsoo đá bào', category: 'AnVatHanQuoc',
      basePrice: 45000, originalPrice: 70000,
      rating: 4.9, soldCount: 2900,
      imageUrl: _img('anvathanquoc/Bingsoo/bs1.jpg'),
      imageUrls: [
        _img('anvathanquoc/Bingsoo/bs1.jpg'),
        _img('anvathanquoc/Bingsoo/bs2.jpg'),
        _img('anvathanquoc/Bingsoo/bs3.jpg'),
        _img('anvathanquoc/Bingsoo/bs4.jpg'),
        _img('anvathanquoc/Bingsoo/bs5.jpg'),
        _img('anvathanquoc/Bingsoo/bs6.jpg'),
        _img('anvathanquoc/Bingsoo/bs7.jpg'),
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
      imageUrl: _img('monnonhe/banhmiopla/opla1.jpg'),
      imageUrls: [
        _img('monnonhe/banhmiopla/opla1.jpg'),
        _img('monnonhe/banhmiopla/opla2.jpg'),
        _img('monnonhe/banhmiopla/opla3.jpg'),
        _img('monnonhe/banhmiopla/opla4.jpg'),
        _img('monnonhe/banhmiopla/opla5.jpg'),
        _img('monnonhe/banhmiopla/opla6.jpg'),
        _img('monnonhe/banhmiopla/opla7.jpg'),
      ],
      description:
          '🍳 Bánh mì ốp la đặc biệt — bánh mì nóng giòn kẹp trứng ốp la lòng đào, chả lụa, pate, dưa chua, rau thơm. Sốt mayo và tương ớt đặc biệt. Bữa sáng đường phố Sài Gòn cực đỉnh!',
    ),
    Product(
      id: '145', name: 'Cơm chiên Dương Châu', category: 'MonNoNhe',
      basePrice: 35000, originalPrice: 55000,
      rating: 4.8, soldCount: 5200,
      imageUrl: _img('monnonhe/comchienduongchau/dc1.jpg'),
      imageUrls: [
        _img('monnonhe/comchienduongchau/dc1.jpg'),
        _img('monnonhe/comchienduongchau/dc2.jpg'),
        _img('monnonhe/comchienduongchau/dc3.jpg'),
        _img('monnonhe/comchienduongchau/dc4.jpg'),
        _img('monnonhe/comchienduongchau/dc5.jpg'),
        _img('monnonhe/comchienduongchau/dc6.jpg'),
        _img('monnonhe/comchienduongchau/dc7.jpg'),
      ],
      description:
          '🍚 Cơm chiên Dương Châu kinh điển — cơm nguội xào với tôm, lạp xưởng, trứng, đậu Hà Lan và hành. Thơm lừng, hạt cơm tơi rời. Nấu đúng lửa to, đúng điệu nhà hàng Trung Hoa!',
    ),
    Product(
      id: '146', name: 'Phở cuộn rau', category: 'MonNoNhe',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.6, soldCount: 2900,
      imageUrl: _img('monnonhe/phocuonrau/pho1.jpg'),
      imageUrls: [
        _img('monnonhe/phocuonrau/pho1.jpg'),
        _img('monnonhe/phocuonrau/pho2.jpg'),
        _img('monnonhe/phocuonrau/pho3.jpg'),
        _img('monnonhe/phocuonrau/pho4.jpg'),
        _img('monnonhe/phocuonrau/pho5.jpg'),
        _img('monnonhe/phocuonrau/pho6.jpg'),
        _img('monnonhe/phocuonrau/pho7.jpg'),
      ],
      description:
          '🌯 Phở cuộn rau thanh mát — bánh phở mỏng cuộn rau xà lách, dưa leo, cà rốt và tôm thịt, chấm tương đậu phộng đặc sệt. Lành mạnh, ít calo, ngon miệng. Bữa ăn nhẹ healthy cực yêu!',
    ),
    Product(
      id: '147', name: 'Sandwich cá ngừ', category: 'MonNoNhe',
      basePrice: 28000, originalPrice: 42000,
      rating: 4.7, soldCount: 3100,
      imageUrl: _img('monnonhe/sandwichcangu/sw1.jpg'),
      imageUrls: [
        _img('monnonhe/sandwichcangu/sw1.jpg'),
        _img('monnonhe/sandwichcangu/sw2.jpg'),
        _img('monnonhe/sandwichcangu/sw3.jpg'),
        _img('monnonhe/sandwichcangu/sw4.jpg'),
        _img('monnonhe/sandwichcangu/sw5.jpg'),
        _img('monnonhe/sandwichcangu/sw6.jpg'),
        _img('monnonhe/sandwichcangu/sw7.jpg'),
      ],
      description:
          '🥪 Sandwich cá ngừ kem phô mai — bánh mì sandwich mềm kẹp cá ngừ trộn mayo phô mai, rau diếp tươi, cà chua. Protein cao, béo ngon vừa phải. Bữa trưa nhanh gọn mà no bụng!',
    ),
    Product(
      id: '148', name: 'Bánh ướt cuộn thịt', category: 'MonNoNhe',
      basePrice: 22000, originalPrice: 35000,
      rating: 4.6, soldCount: 3500,
      imageUrl: _img('monnonhe/banhuotcuonthit/bc1.jpg'),
      imageUrls: [
        _img('monnonhe/banhuotcuonthit/bc1.jpg'),
        _img('monnonhe/banhuotcuonthit/bc2.jpg'),
        _img('monnonhe/banhuotcuonthit/bc3.jpg'),
        _img('monnonhe/banhuotcuonthit/bc4.jpg'),
        _img('monnonhe/banhuotcuonthit/bc5.jpg'),
        _img('monnonhe/banhuotcuonthit/bc6.jpg'),
        _img('monnonhe/banhuotcuonthit/bc7.jpg'),
      ],
      description:
          '🌮 Bánh ướt cuộn thịt đặc biệt — bánh ướt mỏng mềm mịn cuộn thịt heo luộc, chả lụa, hành phi giòn. Chan nước mắm chua ngọt đặc trưng. Ăn nóng vừa thổi vừa ăn — ngon xuất sắc!',
    ),
    Product(
      id: '149', name: 'Cháo yến mạch', category: 'MonNoNhe',
      basePrice: 25000, originalPrice: 38000,
      rating: 4.5, soldCount: 2200,
      imageUrl: _img('monnonhe/chaoyenmach/chao1.jpg'),
      imageUrls: [
        _img('monnonhe/chaoyenmach/chao1.jpg'),
        _img('monnonhe/chaoyenmach/chao2.jpg'),
        _img('monnonhe/chaoyenmach/chao3.jpg'),
        _img('monnonhe/chaoyenmach/chao4.jpg'),
        _img('monnonhe/chaoyenmach/chao5.jpg'),
        _img('monnonhe/chaoyenmach/chao6.jpg'),
        _img('monnonhe/chaoyenmach/chao7.jpg'),
      ],
      description:
          '🥣 Cháo yến mạch dinh dưỡng — yến mạch nguyên hạt nấu sữa tươi, thêm chuối, mật ong và hạt chia. Mịn sánh, ngọt dịu tự nhiên. Bữa sáng lành mạnh, giàu chất xơ — no lâu cực kỳ!',
    ),
    Product(
      id: '150', name: 'Xôi bắp', category: 'MonNoNhe',
      basePrice: 18000, originalPrice: 28000,
      rating: 4.7, soldCount: 4200,
      imageUrl: _img('monnonhe/xoibap/xoi1.jpg'),
      imageUrls: [
        _img('monnonhe/xoibap/xoi1.jpg'),
        _img('monnonhe/xoibap/xoi2.jpg'),
        _img('monnonhe/xoibap/xoi3.jpg'),
        _img('monnonhe/xoibap/xoi4.jpg'),
        _img('monnonhe/xoibap/xoi5.jpg'),
        _img('monnonhe/xoibap/xoi6.jpg'),
        _img('monnonhe/xoibap/xoi7.jpg'),
      ],
      description:
          '🌽 Xôi bắp dừa nước cốt dừa — nếp dẻo nấu cùng bắp ngọt Đà Lạt, chan nước cốt dừa béo và muối mè thơm. Ngọt bùi đặc trưng, ăn nóng mới đúng vị. Bữa sáng quốc dân cực ngon!',
    ),
    Product(
      id: '151', name: 'Bánh giò', category: 'MonNoNhe',
      basePrice: 15000, originalPrice: 25000,
      rating: 4.6, soldCount: 3800,
      imageUrl: _img('monnonhe/banhgio/gio1.jpg'),
      imageUrls: [
        _img('monnonhe/banhgio/gio1.jpg'),
        _img('monnonhe/banhgio/gio2.jpg'),
        _img('monnonhe/banhgio/gio3.jpg'),
        _img('monnonhe/banhgio/gio4.jpg'),
        _img('monnonhe/banhgio/gio5.jpg'),
        _img('monnonhe/banhgio/gio6.jpg'),
        _img('monnonhe/banhgio/gio7.jpg'),
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
