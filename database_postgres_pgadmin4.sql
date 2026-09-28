-- ====================================================================
-- ĐỒ ÁN TỐT NGHIỆP: HỆ THỐNG POS & GỌI MÓN TẠI BÀN QR CODE (CHOUXCHIN)
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: POSTGRESQL / PGADMIN 4
-- TOÀN BỘ 93 MÓN ĂN VÀ NƯỚC UỐNG CHÍNH XÁC 100% NHƯ TRÊN APP FLUTTER
-- ====================================================================

-- 1. XÓA CÁC BẢNG CŨ (NẾU CÓ) ĐỂ TẠO MỚI TOÀN BỘ SẠCH SẼ
DROP TABLE IF EXISTS order_item_toppings CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS dining_tables CASCADE;
DROP TABLE IF EXISTS toppings CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ====================================================================
-- 2. BẢNG 1: DANH MỤC SẢN PHẨM (CATEGORIES - 8 DANH MỤC CHUẨN)
-- ====================================================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,      -- Mã danh mục
    name VARCHAR(100) NOT NULL,             -- Tên danh mục
    icon VARCHAR(50),                      -- Icon emoji
    display_order INT DEFAULT 0,            -- Thứ tự hiển thị
    is_active BOOLEAN DEFAULT TRUE
);

-- ====================================================================
-- 3. BẢNG 2: MÓN ĂN & NƯỚC UỐNG (PRODUCTS - 93 MÓN CHUẨN APP)
-- ====================================================================
CREATE TABLE products (
    id BIGINT PRIMARY KEY,                 -- Trùng khớp 100% ID sản phẩm trên App (1..151)
    category_code VARCHAR(50) NOT NULL REFERENCES categories(code) ON UPDATE CASCADE,
    subcategory VARCHAR(50),                -- Phân nhóm Nước uống: trasua, tradao, tratac, cacao, nuocep
    name VARCHAR(255) NOT NULL,             -- Tên món chính xác
    base_price NUMERIC(12, 2) NOT NULL,     -- Giá bán (giá khuyến mãi)
    original_price NUMERIC(12, 2),          -- Giá gốc
    image_url TEXT,                         -- Đường dẫn ảnh sản phẩm
    description TEXT,                       -- Mô tả món ăn
    is_available BOOLEAN DEFAULT TRUE,
    rating NUMERIC(3, 1) DEFAULT 5.0,
    sold_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 4. BẢNG 3: TOPPING & TÙY CHỌN MÓN (TOPPINGS)
-- ====================================================================
CREATE TABLE toppings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL DEFAULT 5000,
    is_available BOOLEAN DEFAULT TRUE
);

-- ====================================================================
-- 5. BẢNG 4: BÀN ĂN & MÃ QR (DINING_TABLES - 12 BÀN ĂN)
-- ====================================================================
CREATE TABLE dining_tables (
    id SERIAL PRIMARY KEY,
    table_number VARCHAR(50) UNIQUE NOT NULL, -- Bàn 01 -> Bàn 12
    qr_token VARCHAR(100),
    status VARCHAR(30) DEFAULT 'AVAILABLE',   -- AVAILABLE, OCCUPIED, RESERVED
    capacity INT DEFAULT 4,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 6. BẢNG 5: ĐƠN HÀNG (ORDERS)
-- ====================================================================
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,
    table_number VARCHAR(50) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    discount_percent INT DEFAULT 0,
    discount_amount NUMERIC(12, 2) DEFAULT 0,
    final_amount NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'VIETQR',
    payment_status VARCHAR(30) DEFAULT 'UNPAID',
    status VARCHAR(30) DEFAULT 'PENDING',        -- PENDING, PREPARING, SERVED, COMPLETED, CANCELLED
    customer_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 7. BẢNG 6: CHI TIẾT ĐƠN MÓN (ORDER_ITEMS)
-- ====================================================================
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(12, 2) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    note TEXT
);

-- ====================================================================
-- 8. BẢNG 7: TOPPING KÈM MÓN (ORDER_ITEM_TOPPINGS)
-- ====================================================================
CREATE TABLE order_item_toppings (
    id BIGSERIAL PRIMARY KEY,
    order_item_id BIGINT NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    topping_name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL
);

-- ====================================================================
-- 9. BẢNG 8: QUẢN LÝ THU CHI (EXPENSES)
-- ====================================================================
CREATE TABLE expenses (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    note TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 10. BẢNG 9: TÀI KHOẢN NHÂN VIÊN & BẾP (USERS)
-- ====================================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'STAFF', -- ADMIN, STAFF, KITCHEN
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 11. INDEXES TỐI ƯU TRUY VẤN
-- ====================================================================
CREATE INDEX idx_products_category ON products(category_code);
CREATE INDEX idx_products_subcategory ON products(subcategory);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_table ON orders(table_number);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- ====================================================================
-- 12. CHÈN 8 DANH MỤC SẢN PHẨM (TRÙNG KHỚP 100% APP)
-- ====================================================================
INSERT INTO categories (code, name, icon, display_order) VALUES
('AnVatMan', 'Ăn vặt mặn', '🧂', 1),
('DoAnCay', 'Đồ ăn cay', '🌶️', 2),
('NuocUong', 'Nước uống', '🥤', 3),
('BanhNgot', 'Bánh & đồ ngọt', '🍰', 4),
('SnackKeo', 'Snack & kẹo', '🍫', 5),
('TraiCayChua', 'Trái cây & chua', '🥭', 6),
('AnVatHanQuoc', 'Ăn vặt Hàn Quốc', '🧀', 7),
('MonNoNhe', 'Món no nhẹ', '🍜', 8);

-- ====================================================================
-- 13. CHÈN 12 BÀN ĂN (BÀN 01 -> BÀN 12)
-- ====================================================================
INSERT INTO dining_tables (table_number, qr_token, status, capacity) VALUES
('Bàn 01', 'token_table_01', 'AVAILABLE', 4),
('Bàn 02', 'token_table_02', 'AVAILABLE', 4),
('Bàn 03', 'token_table_03', 'AVAILABLE', 4),
('Bàn 04', 'token_table_04', 'AVAILABLE', 4),
('Bàn 05', 'token_table_05', 'AVAILABLE', 4),
('Bàn 06', 'token_table_06', 'AVAILABLE', 4),
('Bàn 07', 'token_table_07', 'AVAILABLE', 4),
('Bàn 08', 'token_table_08', 'AVAILABLE', 4),
('Bàn 09', 'token_table_09', 'AVAILABLE', 4),
('Bàn 10', 'token_table_10', 'AVAILABLE', 6),
('Bàn 11', 'token_table_11', 'AVAILABLE', 6),
('Bàn 12', 'token_table_12', 'AVAILABLE', 8);

-- ====================================================================
-- 14. CHÈN DANH SÁCH TOPPINGS
-- ====================================================================
INSERT INTO toppings (name, price) VALUES
('Thêm ớt tươi / bột ớt', 2000),
('Thêm sốt đặc biệt', 3000),
('Phần lớn hơn (Size L)', 5000),
('Đóng gói hộp riêng mang về', 2000),
('Trân châu đen dẻo', 5000),
('Trân châu trắng giòn', 7000),
('Pudding trứng béo ngậy', 8000),
('Thạch củ năng phô mai', 8000),
('Kem Cheese Macchiato', 10000);

-- ====================================================================
-- 15. CHÈN TOÀN BỘ 93 MÓN ĂN & THỨC UỐNG CHÍNH XÁC NHƯ TRÊN APP FLUTTER
-- ====================================================================

INSERT INTO products (id, category_code, subcategory, name, base_price, original_price, image_url, description, rating, sold_count) VALUES
(1, 'AnVatMan', NULL, 'Cá viên chiên', 15000, 25000, 'assets/images/anvatman/cavienchien/cavien1.jpg', '🐟 Cá viên chiên giòn rụm, nhân cá thật béo ngậy, sốt tương ớt đặc biệt. Được làm từ cá biển tươi, không chất bảo quản. Ăn nóng ngon hơn — mỗi xiên 5 viên cá viên vàng ươm giòn tan!', 4.9, 3200),
(2, 'AnVatMan', NULL, 'Xúc xích nướng', 12000, 20000, 'assets/images/anvatman/xucxich/xucxich1.jpg', '🌭 Xúc xích heo nướng than hoa thơm lừng, da giòn bên ngoài, bên trong mọng nước. Ăn kèm tương ớt & tương cà. Đặc biệt không phẩm màu, không chất bảo quản — an toàn tuyệt đối!', 4.7, 2800),
(3, 'AnVatMan', NULL, 'Khoai tây chiên', 18000, 30000, 'assets/images/anvatman/khoaitaychien/khoaitay1.jpg', '🍟 Khoai tây chiên vàng giòn kiểu Mỹ, được cắt lát đều tay, chiên ngập dầu ở nhiệt độ cao. Rắc muối tiêu phô mai, ăn kèm sốt mayonnaise Nhật Bản. Giòn từ đầu đến cuối!', 4.8, 4100),
(4, 'AnVatMan', NULL, 'Phô mai que', 20000, 35000, 'assets/images/anvatman/phomaique/phomai1.jpg', '🧀 Phô mai que mozzarella kéo sợi cực đã, lớp bột chiên giòn vàng ươm bên ngoài, phô mai chảy dẻo bên trong. Ăn với sốt marinara cà chua hoặc tương ớt ngọt Thái Lan. Kéo sợi siêu đã!', 4.9, 2100),
(5, 'AnVatMan', NULL, 'Nem chua rán', 10000, 18000, 'assets/images/anvatman/nemchuaran/images (1).jpg', '🥟 Nem chua rán đặc sản truyền thống — lớp vỏ giòn, nhân nem chua thơm đậm đà. Chua cay ngọt hài hòa, ăn kèm tỏi ớt. Mỗi phần 3 chiếc, ăn vặt cực đã buổi chiều!', 4.6, 5600),
(101, 'AnVatMan', NULL, 'Bắp xào bơ', 20000, 32000, 'assets/images/anvatman/bapxaobo/bap1.jpg', '🌽 Bắp xào bơ tươi thơm lừng — bắp ngọt lựa chọn từ vùng Đà Lạt, xào với bơ Anchor béo ngậy, muối tiêu và đường. Ngọt giòn từng hạt, ăn là ghiền. Món ăn vặt lành mạnh số 1!', 4.7, 2900),
(102, 'AnVatMan', NULL, 'Trứng cút chiên', 8000, 14000, 'assets/images/anvatman/trungcutchien/cut1.jpg', '🥚 Trứng cút chiên giòn vàng — trứng cút tươi luộc vừa chín, chiên ngập dầu vàng giòn bên ngoài. Chấm muối tiêu chanh hoặc tương ớt cay. Xiên 5 trứng, ăn vặt vỉa hè kinh điển!', 4.5, 4200),
(103, 'AnVatMan', NULL, 'Đậu hũ chiên mắm', 15000, 22000, 'assets/images/anvatman/dauhuchienmam/dauhu1.jpg', '🍢 Đậu hũ chiên mắm tỏi ớt — đậu hũ non chiên giòn vàng ươm, sốt mắm tỏi ớt đặc biệt thấm đều. Ngoài giòn, trong mềm mịn. Ăn kèm rau sống, đậm đà không ngán. Món chay ngon đỉnh!', 4.6, 3100),
(104, 'AnVatMan', NULL, 'Bánh gạo chiên', 18000, 28000, 'assets/images/anvatman/banhgaochien/bgao1.jpg', '🍘 Bánh gạo chiên giòn kiểu Hàn — bánh gạo hình trụ dài chiên phồng giòn rụm, rắc muối mè thơm. Ngoài giòn trong dai, vị nhạt dịu ăn kèm tương ớt ngọt. Snack lành mạnh đang hot!', 4.7, 2700),
(106, 'AnVatMan', NULL, 'Bò viên nướng', 20000, 30000, 'assets/images/anvatman/boviennuong/bo1.jpg', '🔥 Bò viên nướng than hoa đặc biệt — bò viên thật 100% thịt bò Úc xay nhuyễn, nướng trên than hoa thơm phức. Chấm sốt mắm tỏi ớt đặc trưng. Mỗi xiên 4 viên — đã miệng cực kỳ!', 4.8, 3800),
(6, 'DoAnCay', NULL, 'Bánh tráng cuộn', 20000, 32000, 'assets/images/doancay/banhtrangcuon/cuon1.jpg', '🌯 Bánh tráng cuộn cay đặc biệt — bánh tráng mỏng cuộn các loại rau, thịt, tôm và sốt mắm tỏi ớt chua ngọt. Ăn vặt tuổi thơ, ngon mà không ngấy. Cuộn to tay, ăn thật đã miệng!', 4.8, 5400),
(7, 'DoAnCay', NULL, 'Bánh tráng trộn', 15000, 25000, 'assets/images/doancay/banhtrangtron/tron1.jpg', '🥗 Bánh tráng trộn cay ngọt — bánh tráng bóc trộn cùng bơ khô, trứng cút, khô bò, sa tế mắm ruốc. Đặc sản vỉa hè Sài Gòn, hương vị cay ngọt mặn đậm đà không thể quên!', 4.9, 8200),
(8, 'DoAnCay', NULL, 'Chân gà cay', 25000, 40000, 'assets/images/doancay/changacay/changa1.jpg', '🍗 Chân gà ngâm sả ớt cay nồng — chân gà tươi luộc chín, ngâm nước mắm sả ớt đặc biệt 24 giờ. Thấm đẫm gia vị, vừa chua vừa cay vừa thơm. Ăn vặt ghiền nhất mùa mưa!', 4.7, 3900),
(107, 'DoAnCay', NULL, 'Mì cay Hàn cấp 5', 35000, 55000, 'assets/images/doancay/micayHancap5/micay1.jpg', '🔥 Mì cay Hàn Quốc cấp độ 5 — thách thức vị giác! Mì dai đậm đà, sốt gochujang đặc quánh cay nồng, thêm kimchi và trứng lòng đào. Cấp độ cay cao nhất — chỉ dành cho người gan dạ!', 4.8, 5100),
(108, 'DoAnCay', NULL, 'Tokbokki cay ngọt', 28000, 42000, 'assets/images/doancay/tokbokkicayngot/to1.jpg', '🌶️ Tokbokki cay ngọt đường phố — bánh gạo mềm dai sốt gochujang truyền thống pha thêm đường nâu ngọt dịu. Kèm chả cá và trứng luộc. Ăn nóng, húp nước sốt — mê không lối thoát!', 4.9, 4700),
(109, 'DoAnCay', NULL, 'Bò khô sa tế', 30000, 48000, 'assets/images/doancay/bokhosate/bo1.jpg', '🥩 Bò khô sa tế đặc biệt — thịt bò Úc loại ngon, tẩm sa tế ớt đỏ thơm nồng, sấy khô đều. Dai mềm vừa phải, cay thơm đậm đà. Túi 100g — ăn vặt đồng hành cùng phim, trà đá!', 4.7, 3200),
(110, 'DoAnCay', NULL, 'Lẩu mini cay', 55000, 85000, 'assets/images/doancay/lauminicay/lau1.jpg', '🍲 Lẩu mini cay Tứ Xuyên — nồi lẩu nhỏ xinh cho 1-2 người, nước lèo sichuan cay tê nồng đặc trưng. Đủ rau, bò, tôm, nấm, đậu hũ. Ăn một mình cũng sang — cay mà cứ muốn thêm!', 4.8, 2100),
(111, 'DoAnCay', NULL, 'Gà cay chiên giòn', 38000, 58000, 'assets/images/doancay/gacaychiengion/gacay2.jpg', '🍗 Gà cay chiên giòn kiểu Hàn — gà ta ướp gochujang, phủ bột crispy chiên vàng giòn rụm. Cay nồng đậm đà, bên trong mọng nước. Chấm sốt mayo cay — combo hoàn hảo không thể cưỡng!', 4.8, 3900),
(112, 'DoAnCay', NULL, 'Mực rim sa tế', 32000, 50000, 'assets/images/doancay/mucrimsate/muc1.jpg', '🦑 Mực rim sa tế cay đặc biệt — mực ống tươi cắt khoanh, rim cùng sa tế tôm ớt thơm lừng đến cạn nước. Mực ngọt, cay thơm, đậm đà. Ăn kèm cơm trắng hoặc nhậu đều tuyệt hảo!', 4.6, 2400),
(113, 'DoAnCay', NULL, 'Trứng vịt lộn sốt cay', 20000, 30000, 'assets/images/doancay/trungvitlonsotcay/trungcay1.jpg', '🥚 Trứng vịt lộn sốt cay đặc biệt — trứng hột vịt lộn cổ điển phủ sốt cay sa tế ớt, thêm rau răm thơm và muối tiêu. Vừa bổ vừa ngon, đường phố Sài Gòn huyền thoại. 2 trứng/phần!', 4.7, 4500),
(13, 'NuocUong', 'tradao', 'Trà đào truyền thống', 28000, 40000, 'assets/images/nuocuong/tradao/dao1.jpg', '🍑 Trà đào truyền thống thơm ngát vị đào tươi, miếng đào giòn ngọt mọng nước cùng vị trà thanh mát dịu nhẹ.', 4.9, 5800),
(201, 'NuocUong', 'tradao', 'Trà đào cam sả', 32000, 48000, 'assets/images/nuocuong/tradao/dao2.jpg', '🍊 Trà đào cam sả thanh lọc, kết hợp hoàn hảo giữa vị cam chua ngọt, sả thơm the mát và đào giòn ngọt.', 4.8, 4600),
(202, 'NuocUong', 'tradao', 'Trà đào sữa đá', 30000, 45000, 'assets/images/nuocuong/tradao/dao3.jpg', '🍑 Trà đào sữa đá béo ngậy pha lẫn hương trà thanh thoảng và miếng đào giòn dai sảng khoái.', 4.7, 3900),
(203, 'NuocUong', 'tradao', 'Trà đào kem cheese', 35000, 50000, 'assets/images/nuocuong/tradao/dao4.jpg', '🧀 Lớp màng kem phô mai sánh mịn mặn mặn béo ngậy phủ trên nền trà đào thanh ngọt đậm đà.', 4.9, 5100),
(117, 'NuocUong', 'tratac', 'Trà tắc mật ong', 20000, 32000, 'assets/images/nuocuong/tratac/tac1.jpg', '🍋 Trà tắc mật ong thơm lừng ngào ngạt, chua thanh từ tắc tươi kết hợp mật ong rừng ngọt êm cổ họng.', 4.8, 6200),
(204, 'NuocUong', 'tratac', 'Trà tắc xí muội', 22000, 35000, 'assets/images/nuocuong/tratac/tac2.jpg', '🍋 Chua chua ngọt ngọt mặn mà của xí muội dầm hòa quyện cùng nước cốt tắc tươi mát lịm.', 4.7, 4300),
(205, 'NuocUong', 'tratac', 'Trà tắc hoa đậu biếc', 25000, 38000, 'assets/images/nuocuong/tratac/tac3.jpg', '🌸 Màu tím biếc huyền ảo của hoa đậu biếc chuyển sắc khi gặp chanh tắc, hương vị thơm dịu thanh mát.', 4.8, 3700),
(206, 'NuocUong', 'tratac', 'Trà tắc khổng lồ', 25000, 40000, 'assets/images/nuocuong/tratac/tac4.jpg', '🥤 Ly 1 lít siêu to khổng lồ giải nhiệt ngày hè cực đã, đậm vị tắc chua ngọt sảng khoái.', 4.9, 7100),
(9, 'NuocUong', 'trasua', 'Trà sữa trân châu đường đen', 35000, 50000, 'assets/images/nuocuong/trasua/duongden/den1.jpg', '🧋 Trà sữa trân châu đường đen trứ danh, sốt đường đen đậm vị dẻo quánh cùng trân châu dai giòn sần sật.', 4.9, 9800),
(10, 'NuocUong', 'trasua', 'Trà sữa matcha', 38000, 55000, 'assets/images/nuocuong/trasua/matcha/matcha1.jpg', '🍵 Bột matcha Uji thượng hạng hòa quyện sữa tươi thanh trùng béo nhẹ, đắng dịu chuẩn gu Nhật Bản.', 4.8, 6700),
(11, 'NuocUong', 'trasua', 'Trà sữa truyền thống', 28000, 40000, 'assets/images/nuocuong/trasua/truyenthong/tt1.jpg', '🥛 Trà đen tuyển chọn ủ đậm vị kết hợp sữa béo thơm lừng, hương vị tuổi thơ đậm đà khó quên.', 4.7, 7200),
(114, 'NuocUong', 'trasua', 'Trà sữa ô long', 32000, 48000, 'assets/images/nuocuong/trasua/olong/olong1.jpg', '🍵 Trà ô long nướng thơm khói dịu dàng, vị trà hậu ngọt đậm sâu quyện cùng sữa tươi mịn béo.', 4.8, 5300),
(115, 'NuocUong', 'trasua', 'Trà sữa Thái', 30000, 45000, 'assets/images/nuocuong/trasua/thai/thai1.jpg', '🧡 Trà sữa Thái thơm nồng hương thảo mộc đặc trưng, béo ngậy sữa đặc và sữa tươi bốc khói đá mát.', 4.7, 4800),
(118, 'NuocUong', 'cacao', 'Cacao nóng đá', 28000, 42000, 'assets/images/nuocuong/cacao/cacaonongda/nongda1.jpg', '☕ Bột cacao Đắk Lắk nguyên chất 100%, đắng thơm đậm vị socola quyến rũ, uống đá hay nóng đều tuyệt đỉnh.', 4.7, 3200),
(207, 'NuocUong', 'cacao', 'Cacao sữa béo ngậy', 30000, 45000, 'assets/images/nuocuong/cacao/caccaosua/ccsua1.jpg', '🥛 Cacao sữa béo ngậy kem đặc thơm lừng, lớp bột cacao rắc phủ trên mặt tạo điểm nhấn khó quên.', 4.8, 4100),
(208, 'NuocUong', 'cacao', 'Cacao dừa đá tuyết', 35000, 52000, 'assets/images/nuocuong/cacao/cacaodua/ccdua5.jpg', '🥥 Cốt dừa đá tuyết xay sánh mịn rót sốt cacao đậm đặc sánh ngậy lên trên, siêu phẩm giải nhiệt.', 4.9, 4600),
(12, 'NuocUong', 'nuocep', 'Nước ép cam tươi', 25000, 38000, 'assets/images/nuocuong/nuocep/cam/cam1.jpg', '🍊 Cam sành tươi mọng nước vắt nguyên chất, dồi dào vitamin C giúp tăng sức đề kháng tự nhiên.', 4.8, 5300),
(116, 'NuocUong', 'nuocep', 'Nước ép dừa tươi', 25000, 38000, 'assets/images/nuocuong/nuocep/dua/dua1.jpg', '🥥 Nước dừa tươi ngọt thanh mát lành bổ sung chất điện giải tự nhiên cho cơ thể.', 4.7, 3900),
(120, 'NuocUong', 'nuocep', 'Nước ép dưa hấu', 25000, 38000, 'assets/images/nuocuong/nuocep/duahau/hau1.jpg', '🍉 Dưa hấu ruột đỏ ngọt lịm ép chậm giữ trọn vitamin, thanh mát ngày oi ả.', 4.8, 4200),
(209, 'NuocUong', 'nuocep', 'Nước ép lê tươi', 28000, 42000, 'assets/images/nuocuong/nuocep/le/le1.jpg', '🍐 Quả lê vàng mọng nước ép thanh ngọt, mát gan bổ phế nhuận tràng.', 4.7, 3100),
(210, 'NuocUong', 'nuocep', 'Nước ép nho tươi', 30000, 45000, 'assets/images/nuocuong/nuocep/nho/nho1.jpg', '🍇 Nho tím chín mọng nước chua ngọt thanh tao giàu chất chống oxy hóa tự nhiên.', 4.8, 3800),
(211, 'NuocUong', 'nuocep', 'Nước ép táo tươi', 28000, 42000, 'assets/images/nuocuong/nuocep/tao/tao1.jpg', '🍎 Táo Envy tươi giòn ngọt ép nguyên chất thơm lừng, bổ sung khoáng chất tuyệt vời.', 4.8, 4500),
(212, 'NuocUong', 'nuocep', 'Nước ép xoài tươi', 28000, 42000, 'assets/images/nuocuong/nuocep/xoai/xoai1.jpg', '🥭 Xoài cát chín vàng ươm ngọt lịm thơm nồng, giàu vitamin A và khoáng chất tự nhiên.', 4.8, 4300),
(14, 'BanhNgot', NULL, 'Bánh su kem', 18000, 28000, 'assets/images/banh&dongot/banhsukem/sukem1.jpg', '🍮 Bánh su kem Nhật Bản — vỏ choux phồng giòn, bên trong kem custard vani mịn màng thơm phức. Rắc đường bột trắng tinh. Mỗi phần 2 chiếc to — thơm ngon chuẩn tiệm bánh Nhật!', 4.8, 4600),
(15, 'BanhNgot', NULL, 'Tiramisu matcha', 45000, 65000, 'assets/images/banh&dongot/tiramisu/misu1.jpg', '🍵 Tiramisu trà xanh matcha Uji cao cấp — kem mascarpone béo nhẹ, bánh ladyfinger thấm cà phê, rắc matcha Nhật đặc. Vị đắng nhẹ, ngọt thanh. Hộp 4 phần cá nhân, sang trọng!', 4.9, 2100),
(16, 'BanhNgot', NULL, 'Cupcake nhiều vị', 22000, 35000, 'assets/images/banh&dongot/cupcake/cake1.jpg', '🧁 Cupcake kem bơ nhiều màu — bánh cupcake mềm ẩm, phủ kem bơ trang trí rực rỡ. 6 vị: vani, socola, dâu, chanh, matcha, caramel. Mỗi chiếc là một tác phẩm nghệ thuật ngọt ngào!', 4.7, 3200),
(17, 'BanhNgot', NULL, 'Bánh bông lan', 15000, 22000, 'assets/images/banh&dongot/banhbonglan/bonglan1.jpg', '🍰 Bánh bông lan trứng muối — bánh mềm xốp vị vani nhẹ nhàng, lòng trứng muối chảy vàng ươm bên trong. Nướng tươi mỗi ngày, ăn còn ấm là đỉnh nhất. Bánh tuổi thơ cực yêu!', 4.6, 5800),
(122, 'BanhNgot', NULL, 'Bánh donut phủ đường', 20000, 32000, 'assets/images/banh&dongot/banhdonutphuduong/donut1.jpg', '🍩 Bánh donut phủ đường nhiều vị — vòng donut xốp mềm chiên vàng, phủ chocolate, dâu, matcha, caramel. Rắc thêm sprinkle màu sắc bắt mắt. Mỗi chiếc là một niềm vui ngọt ngào!', 4.7, 3400),
(123, 'BanhNgot', NULL, 'Bánh mochi nhân đậu đỏ', 18000, 28000, 'assets/images/banh&dongot/banhmochinhandaudo/mo1.jpg', '🍡 Bánh mochi nhân đậu đỏ Nhật Bản — vỏ mochi dẻo thơm nếp trắng tinh, nhân đậu đỏ azuki ngọt bùi. Mềm mịn tan chảy trong miệng. Hộp 4 chiếc — quà tặng ngọt ngào tinh tế!', 4.8, 2700),
(124, 'BanhNgot', NULL, 'Bánh crepe matcha', 25000, 38000, 'assets/images/banh&dongot/crepematcha/cm1.jpg', '🍵 Bánh crepe matcha Nhật — lớp crepe mỏng xanh matcha Uji, cuộn kem tươi đánh bông mịn và trái cây tươi. Thanh mát, ngọt dịu, đẹp mắt cực chụp hình. Tráng miệng sang chảnh!', 4.7, 2900),
(125, 'BanhNgot', NULL, 'Bánh waffle', 28000, 42000, 'assets/images/banh&dongot/waffle/w1.jpg', '🧇 Bánh waffle giòn vàng — bánh waffle Bỉ nướng vàng giòn bên ngoài, mềm xốp bên trong. Phủ kem tươi, mứt dâu, siro maple. Nhiều topping lựa chọn — bữa sáng hoặc tráng miệng đều ngon!', 4.8, 3100),
(126, 'BanhNgot', NULL, 'Pudding caramel', 22000, 35000, 'assets/images/banh&dongot/puddingcaramel/pudca1.jpg', '🍮 Pudding caramel kinh điển — trứng sữa hấp mịn mượt như lụa, phủ caramel vàng đắng ngọt hoàn hảo. Rung rinh nhẹ, tan chảy tức thì. Tráng miệng Pháp thanh lịch, đơn giản mà đẳng cấp!', 4.7, 2500),
(127, 'BanhNgot', NULL, 'Bánh tart sữa dừa', 20000, 32000, 'assets/images/banh&dongot/tartsuadua/sd1.jpg', '🥥 Bánh tart sữa dừa nhân chảy — vỏ tart giòn bơ thơm, nhân sữa dừa béo ngậy chảy nhẹ khi cắn. Thêm dừa tươi nạo mỏng phía trên. Hương dừa đặc trưng miền Nam — ngọt dịu tinh tế!', 4.6, 2300),
(18, 'SnackKeo', NULL, 'Snack Oishi phô mai', 12000, 18000, 'assets/images/snack&keo/oishi/oshi1.jpg', '🍿 Snack Oishi phô mai Cheddar — giòn tan, béo bùi, vị phô mai đậm đà quen thuộc. Snack khoái khẩu quốc dân số 1 Việt Nam, ăn mãi không chán. Gói lớn chia sẻ cùng bạn bè!', 4.7, 9100),
(19, 'SnackKeo', NULL, 'Poca khoai tây', 15000, 22000, 'assets/images/snack&keo/poca/poca1.jpg', '🥔 Poca khoai tây lát mỏng — khoai tây thái lát siêu mỏng, chiên giòn rụm vàng đều. Vị phô mai & kem chua, mặn ngọt hài hòa. Bỏ vào miệng tan ngay — giòn đỉnh của giòn!', 4.6, 7800),
(20, 'SnackKeo', NULL, 'Kẹo dẻo các vị', 20000, 30000, 'assets/images/snack&keo/keodeo/deo1.jpg', '🐻 Kẹo dẻo gấu nhiều vị — 5 vị trái cây phủ đường, dai mềm, màu sắc bắt mắt cực cute. Ngọt thơm, bên trong có nhân trái cây thật. Gói 200g — kẹo dẻo tuổi thơ ai cũng nhớ!', 4.6, 4500),
(21, 'SnackKeo', NULL, 'Socola các vị', 35000, 55000, 'assets/images/snack&keo/chocolate/socola1.jpg', '🍫 Socola premium nhiều vị — đắng nhẹ, hương thơm tinh tế, tan chảy mượt trên đầu lưỡi. Nhiều vị: đen 70%, sữa, dâu, hạnh nhân, caramel. Không chất bảo quản, sang trọng!', 4.8, 2800),
(22, 'SnackKeo', NULL, 'Snack rong biển', 8000, 12000, 'assets/images/snack&keo/rongbien/rongbien1.jpg', '🌿 Snack rong biển nướng mè vàng — rong biển Hàn Quốc mỏng giòn, nướng dầu mè thơm ngậy, rắc mè trắng béo. Ăn không ngán, tốt cho sức khỏe, ít calo. Snack sạch cực trending!', 4.5, 6200),
(128, 'SnackKeo', NULL, 'Snack mực Thái', 18000, 28000, 'assets/images/snack&keo/snackmucthai/mt1.jpg', '🦑 Snack mực sấy Thái Lan — mực ống tươi tẩm gia vị Thái đặc trưng, sấy giòn dai thơm phức. Ngọt tự nhiên từ mực, cay nhẹ hậu vị. Túi 80g — ăn vặt cùng trà đá siêu đỉnh!', 4.7, 4100),
(129, 'SnackKeo', NULL, 'Kẹo caramel mềm', 15000, 25000, 'assets/images/snack&keo/caramelmem/mem1.jpg', '🍬 Kẹo caramel bơ mềm Pháp — caramel sữa tan chảy mượt, bơ Normandy thơm béo ngậy, mặn ngọt hài hòa tuyệt vời. Mỗi viên gói giấy bạc tinh tế. Hộp 200g — quà tặng sang trọng!', 4.6, 3200),
(130, 'SnackKeo', NULL, 'Bánh quy bơ', 22000, 35000, 'assets/images/snack&keo/banhquybo/bo1.jpg', '🍪 Bánh quy bơ Đan Mạch giòn tan — làm từ bơ Lurpak chính hãng, giòn nhẹ thơm béo không ngấy. Nhiều hình dáng dễ thương, vị vani và phô mai. Hộp thiếc 400g — bánh nhà làm chuẩn vị!', 4.7, 3800),
(131, 'SnackKeo', NULL, 'Snack khoai lang', 12000, 20000, 'assets/images/snack&keo/snackkhoailang/kl1.jpg', '🍠 Snack khoai lang sấy giòn — khoai lang Nhật tím và vàng thái lát mỏng, sấy giòn tự nhiên không dầu chiên. Ngọt bùi tự nhiên, lành mạnh ít calo. Snack ăn kiêng mà vẫn ngon!', 4.5, 4500),
(132, 'SnackKeo', NULL, 'Kẹo lollipop', 8000, 15000, 'assets/images/snack&keo/keololipop/lo1.jpg', '🍭 Kẹo lollipop màu sắc cực cute — kẹo que xoắn ốc nhiều màu rực rỡ, vị dâu, cam, nho, táo. Ngọt thơm, màu tự nhiên. Cute cực chụp ảnh, làm quà sinh nhật hay trang trí đều tuyệt!', 4.4, 2900),
(23, 'TraiCayChua', NULL, 'Xoài lắc muối ớt', 20000, 30000, 'assets/images/traicay&dochua/xoailac/xoai1.jpg', '🥭 Xoài cát Hòa Lộc xanh chua lắc muối ớt — xoài non cứng chắc thái hạt lựu, lắc cùng muối ớt xanh Tây Ninh đặc biệt. Chua cay mặn ngọt đủ vị — đồ ăn vặt huyền thoại tuổi học trò!', 4.9, 7800),
(24, 'TraiCayChua', NULL, 'Ổi lắc muối ớt', 15000, 22000, 'assets/images/traicay&dochua/oilac/oi1.jpg', '🍈 Ổi đào giòn lắc muối ớt — ổi non cứng chắc, lắc muối ớt cay nồng. Ăn vào giòn sần sật, chua ngọt dịu dàng, cực kích thích vị giác. Phần 300g — ăn vặt sạch healthy!', 4.7, 5100),
(25, 'TraiCayChua', NULL, 'Me chua ngâm', 12000, 18000, 'assets/images/traicay&dochua/me/me1.jpg', '🟤 Me chua ngâm muối ớt đặc biệt — me Bình Phước chín tới, vừa chua vừa ngọt, ngâm muối ớt đỏ cay nồng. Chua kích thích vị giác tức thì. Hộp 200g — ăn vặt kinh điển Nam Bộ!', 4.6, 4900),
(26, 'TraiCayChua', NULL, 'Mận ngâm cay', 18000, 28000, 'assets/images/traicay&dochua/man/man1.jpg', '🍑 Mận ngâm nước muối ớt thơm — mận tươi Bắc ngâm đường gừng muối ớt, chua ngọt cay đặc trưng. Ăn lạnh ngon tuyệt, giải nhiệt mùa hè. Hộp nhỏ tiện lợi, ăn vặt đường phố!', 4.7, 4100),
(27, 'TraiCayChua', NULL, 'Cóc lắc muối', 15000, 22000, 'assets/images/traicay&dochua/coclac/coclac1.jpg', '🌿 Cóc non lắc muối ớt sấy — cóc xanh giòn sần sật, lắc muối ớt sấy đặc biệt vị cay nồng mặn ngọt. Đặc sản vỉa hè Nam Bộ, ai ăn một lần là nhớ mãi. Túi lớn 300g đã tay!', 4.6, 3800),
(133, 'TraiCayChua', NULL, 'Khế chua muối ớt', 12000, 20000, 'assets/images/traicay&dochua/khechuamuoiot/khe1.jpg', '⭐ Khế chua chấm muối ớt đặc biệt — khế vàng chua giòn thái lát, chấm muối ớt xanh tây ninh. Vị chua gắt kích thích vị giác ngay lập tức. Đặc sản vỉa hè Nam Bộ khó quên!', 4.5, 2900),
(134, 'TraiCayChua', NULL, 'Sấu ngâm đường', 15000, 24000, 'assets/images/traicay&dochua/saungamduong/sau1.jpg', '🟢 Sấu ngâm đường chua ngọt — sấu Hà Nội chua gắt ngâm đường phèn qua đêm, vị chua dịu lại, ngọt thanh. Đặc sản mùa hè miền Bắc, giải nhiệt tuyệt vời. Hũ thủy tinh đẹp, tặng quà cũng hay!', 4.6, 2300),
(135, 'TraiCayChua', NULL, 'Dứa lắc muối', 18000, 28000, 'assets/images/traicay&dochua/dualacmuoi/dua1.jpg', '🍍 Dứa (thơm) lắc muối ớt chua ngọt — dứa tươi thái miếng, lắc muối ớt đỏ cay nồng. Ngọt chua tự nhiên, cay thơm đặc trưng. Ăn vặt đường phố huyền thoại. Hộp 200g đủ no bụng!', 4.7, 3600),
(136, 'TraiCayChua', NULL, 'Chuối sấy', 15000, 25000, 'assets/images/traicay&dochua/chuoisay/cs1.jpg', '🍌 Chuối sấy dẻo thơm ngọt — chuối già Nam Bộ chín vàng, sấy dẻo ở nhiệt độ thấp giữ nguyên dinh dưỡng. Ngọt tự nhiên, dai dẻo, thơm thơm. Snack lành mạnh không đường không dầu!', 4.6, 3200),
(137, 'TraiCayChua', NULL, 'Chôm chôm tươi', 20000, 32000, 'assets/images/traicay&dochua/chomchomtuoi/chom1.jpg', '🔴 Chôm chôm Java ngọt lịm — chôm chôm đỏ tươi trồng vùng Đông Nam Bộ, thịt dày ngọt mát, hạt nhỏ. Bóc vỏ ăn ngay, mọng nước tự nhiên. Phần 400g — trái cây tươi ngon mùa hè!', 4.5, 2100),
(28, 'AnVatHanQuoc', NULL, 'Kimbap cuộn', 25000, 38000, 'assets/images/anvathanquoc/kimbap/kb1.jpg', '🇰🇷 Kimbap cuộn nhân gà nướng — cơm dẻo trộn dầu mè thơm, cuộn rong biển nori, nhân gà nướng teriyaki, dưa muối, trứng chiên. 8 miếng/phần — bữa ăn nhẹ chuẩn Hàn!', 4.8, 4800),
(29, 'AnVatHanQuoc', NULL, 'Tokbokki cay ngọt', 28000, 45000, 'assets/images/anvathanquoc/tokbokki/tobokki1.jpg', '🔴 Tokbokki bánh gạo Hàn Quốc — bánh gạo dai mềm nấu sốt gochujang cay ngọt đặc quánh. Thêm trứng cút và chả cá. Ăn nóng trong bát sứ đúng kiểu Hàn — chuẩn vị Seoul!', 4.9, 6200),
(30, 'AnVatHanQuoc', NULL, 'Mandu bánh bao chiên', 22000, 35000, 'assets/images/anvathanquoc/mandu/mandu1.jpg', '🥟 Mandu chiên giòn — bánh bao nhân thịt heo & kimchi kiểu Hàn, chiên áp chảo giòn vàng đáy. Vỏ giòn sần sật, nhân đậm đà thơm. Chấm sốt gochujang pha — đỉnh!', 4.7, 3500),
(31, 'AnVatHanQuoc', NULL, 'Chả cá Hàn Quốc', 20000, 32000, 'assets/images/anvathanquoc/chaca/chaca1.jpg', '🐟 Chả cá Hàn Quốc (Eomuk) — chả cá dẹt xiên que hầm trong nước dùng cá thơm ngọt. Dai mềm, không tanh, ăn kèm nước dùng nóng hổi. Kinh điển đường phố Seoul đúng điệu!', 4.6, 2900),
(138, 'AnVatHanQuoc', NULL, 'Hotteok bánh nóng', 22000, 35000, 'assets/images/anvathanquoc/Hotteok/hok1.jpg', '🥞 Hotteok bánh nóng Hàn Quốc — bánh dẹp nhân đường đen hạt dẻ, chiên áp chảo vàng giòn. Cắn vào chảy ngọt ấm bên trong, vỏ giòn thơm mùi bơ. Đặc sản mùa đông Seoul cực hút!', 4.8, 2700),
(139, 'AnVatHanQuoc', NULL, 'Dalgona kẹo bong', 15000, 25000, 'assets/images/anvathanquoc/Dalgona/dal1.jpg', '🍬 Dalgona kẹo đường bong bóng — đường caramel đun chảy đổ khuôn hình thú độc đáo (squid game). Mỏng giòn, ngọt caramel thơm. Thử thách tách khuôn cực vui! Đặc sản viral TikTok!', 4.7, 3400),
(140, 'AnVatHanQuoc', NULL, 'Tteok bánh gạo nướng', 25000, 40000, 'assets/images/anvathanquoc/tteokbanhgaonuong/teo1.jpg', '🍢 Tteok bánh gạo nướng than — bánh gạo dẹt xiên que nướng trên than hoa, phết gochujang ngọt cay. Ngoài cháy xém thơm, trong dẻo dai. Đường phố Hàn Quốc hương vị không đâu có!', 4.7, 2800),
(141, 'AnVatHanQuoc', NULL, 'Japchae miến xào', 32000, 50000, 'assets/images/anvathanquoc/Japchae/jap1.jpg', '🍜 Japchae miến xào Hàn Quốc — miến khoai lang dai trong xào cùng thịt bò, rau củ ngũ sắc, sốt ganjang mè thơm. Ăn nóng hoặc nguội đều ngon, vị ngọt mặn đặc trưng xứ Hàn!', 4.7, 2400),
(142, 'AnVatHanQuoc', NULL, 'Gimbap cơm cuộn đặc biệt', 30000, 48000, 'assets/images/anvathanquoc/Gimbap/gb1.jpg', '🍱 Gimbap cơm cuộn đặc biệt — cơm dẻo trộn mè dầu mè, cuộn nori với bò bulgogi, trứng chiên, cà rốt, rau bina. Thơm ngon đậm vị Hàn. Hộp 10 miếng — bữa trưa hoàn hảo!', 4.8, 3100),
(143, 'AnVatHanQuoc', NULL, 'Bingsoo đá bào', 45000, 70000, 'assets/images/anvathanquoc/Bingsoo/bs1.jpg', '❄️ Bingsoo đá bào sữa truyền thống — đá bào mịn như tuyết tưới siro đậu đỏ, thêm trân châu, mochi, condensed milk. Mát lạnh, ngọt ngào, đẹp mắt hết nấc. Dessert Hàn số 1 mùa hè!', 4.9, 2900),
(32, 'MonNoNhe', NULL, 'Mì trộn cay', 22000, 35000, 'assets/images/monnonhe/mitron/tron1.jpg', '🍜 Mì trộn cay đặc biệt — mì dai mềm trộn sốt cay mắm tỏi ớt, thêm trứng lòng đào, thịt heo băm, hành phi giòn. No nhẹ mà đầy đủ dưỡng chất. Ăn một tô là no cả buổi chiều!', 4.8, 7200),
(33, 'MonNoNhe', NULL, 'Nui xào hải sản', 30000, 45000, 'assets/images/monnonhe/nuixao/nui1.jpg', '🦐 Nui xào hải sản — nui ống dai ngon xào cùng tôm, mực, nghêu tươi, sốt cà chua đặc. Ngọt tự nhiên từ hải sản, không bột ngọt. No nhẹ mà đủ chất, ăn buổi tối ngon miệng!', 4.7, 4100),
(144, 'MonNoNhe', NULL, 'Bánh mì ốp la', 20000, 32000, 'assets/images/monnonhe/banhmiopla/opla1.jpg', '🍳 Bánh mì ốp la đặc biệt — bánh mì nóng giòn kẹp trứng ốp la lòng đào, chả lụa, pate, dưa chua, rau thơm. Sốt mayo và tương ớt đặc biệt. Bữa sáng đường phố Sài Gòn cực đỉnh!', 4.7, 4800),
(145, 'MonNoNhe', NULL, 'Cơm chiên Dương Châu', 35000, 55000, 'assets/images/monnonhe/comchienduongchau/dc1.jpg', '🍚 Cơm chiên Dương Châu kinh điển — cơm nguội xào với tôm, lạp xưởng, trứng, đậu Hà Lan và hành. Thơm lừng, hạt cơm tơi rời. Nấu đúng lửa to, đúng điệu nhà hàng Trung Hoa!', 4.8, 5200),
(146, 'MonNoNhe', NULL, 'Phở cuộn rau', 25000, 38000, 'assets/images/monnonhe/phocuonrau/pho1.jpg', '🌯 Phở cuộn rau thanh mát — bánh phở mỏng cuộn rau xà lách, dưa leo, cà rốt và tôm thịt, chấm tương đậu phộng đặc sệt. Lành mạnh, ít calo, ngon miệng. Bữa ăn nhẹ healthy cực yêu!', 4.6, 2900),
(147, 'MonNoNhe', NULL, 'Sandwich cá ngừ', 28000, 42000, 'assets/images/monnonhe/sandwichcangu/sw1.jpg', '🥪 Sandwich cá ngừ kem phô mai — bánh mì sandwich mềm kẹp cá ngừ trộn mayo phô mai, rau diếp tươi, cà chua. Protein cao, béo ngon vừa phải. Bữa trưa nhanh gọn mà no bụng!', 4.7, 3100),
(148, 'MonNoNhe', NULL, 'Bánh ướt cuộn thịt', 22000, 35000, 'assets/images/monnonhe/banhuotcuonthit/bc1.jpg', '🌮 Bánh ướt cuộn thịt đặc biệt — bánh ướt mỏng mềm mịn cuộn thịt heo luộc, chả lụa, hành phi giòn. Chan nước mắm chua ngọt đặc trưng. Ăn nóng vừa thổi vừa ăn — ngon xuất sắc!', 4.6, 3500),
(149, 'MonNoNhe', NULL, 'Cháo yến mạch', 25000, 38000, 'assets/images/monnonhe/chaoyenmach/chao1.jpg', '🥣 Cháo yến mạch dinh dưỡng — yến mạch nguyên hạt nấu sữa tươi, thêm chuối, mật ong và hạt chia. Mịn sánh, ngọt dịu tự nhiên. Bữa sáng lành mạnh, giàu chất xơ — no lâu cực kỳ!', 4.5, 2200),
(150, 'MonNoNhe', NULL, 'Xôi bắp', 18000, 28000, 'assets/images/monnonhe/xoibap/xoi1.jpg', '🌽 Xôi bắp dừa nước cốt dừa — nếp dẻo nấu cùng bắp ngọt Đà Lạt, chan nước cốt dừa béo và muối mè thơm. Ngọt bùi đặc trưng, ăn nóng mới đúng vị. Bữa sáng quốc dân cực ngon!', 4.7, 4200),
(151, 'MonNoNhe', NULL, 'Bánh giò', 15000, 25000, 'assets/images/monnonhe/banhgio/gio1.jpg', '🌿 Bánh giò nhân thịt đặc biệt — bột gạo tẻ trắng hấp mịn bọc lá chuối, nhân thịt heo mộc nhĩ nấm hương đậm đà. Mềm mịn, thơm mùi lá chuối. Ăn kèm giò chả — chuẩn vị Bắc Bộ!', 4.6, 3800);


-- Đồng bộ sequence của bảng products sau khi chèn id thủ công
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));

-- ====================================================================
-- 16. CHÈN TÀI KHOẢN NHÂN VIÊN & BẾP
-- ====================================================================
INSERT INTO users (username, password, full_name, role, phone) VALUES
('admin', '123456', 'Nguyễn Huỳnh Anh Tuấn (Chủ quán)', 'ADMIN', '0901234567'),
('thungan', '123456', 'Nhân Viên Thu Ngân POS', 'STAFF', '0902345678'),
('bep', '123456', 'Bộ Phận Bếp (KDS Screen)', 'KITCHEN', '0903456789');

-- ====================================================================
-- 17. CHÈN ĐƠN HÀNG MẪU ĐỂ TEST
-- ====================================================================
INSERT INTO orders (order_code, table_number, total_amount, discount_percent, discount_amount, final_amount, payment_method, payment_status, status, customer_notes) VALUES
('CC-20260928-0001', 'Bàn 05', 73000, 10, 7300, 65700, 'VIETQR', 'PAID', 'PREPARING', 'Bàn 05: 1 trà sữa ít đường, 1 cá viên sốt đậm'),
('CC-20260928-0002', 'Bàn 02', 45000, 0, 0, 45000, 'CASH', 'UNPAID', 'PENDING', 'Khách xin thêm ớt cay');

INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal, note) VALUES
(1, 9, 'Trà sữa trân châu đường đen', 1, 28000, 28000, '50% đường, 70% đá'),
(1, 1, 'Cá viên chiên', 1, 15000, 15000, 'Chiên giòn rụm'),
(1, 4, 'Phô mai que', 1, 20000, 20000, 'Kéo sợi nóng'),
(2, 29, 'Tokbokki', 1, 30000, 30000, 'Cay ngọt chuẩn Hàn'),
(2, 13, 'Trà đào', 1, 15000, 15000, 'Nhiều đá mát lạnh');

-- Cập nhật trạng thái bàn 02 và bàn 05 có khách
UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_number IN ('Bàn 02', 'Bàn 05');

-- ====================================================================
-- HOÀN TẤT! ĐÃ TẠO TOÀN BỘ 93 SẢN PHẨM TRÙNG KHỚP 100% VỚI APP FLUTTER!
-- ====================================================================
