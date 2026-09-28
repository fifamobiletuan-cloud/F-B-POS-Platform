-- ====================================================================
-- ĐỒ ÁN TỐT NGHIỆP: HỆ THỐNG POS & GỌI MÓN TẠI BÀN QR CODE (CHOUXCHIN)
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: POSTGRESQL / PGADMIN 4
-- BACKEND: JAVA SPRING BOOT 3.x
-- ====================================================================

-- 1. TẠO CƠ SỞ DỮ LIỆU (Nếu tạo thủ công trên pgAdmin 4: chuột phải vào Databases -> Create -> Database -> đặt tên 'milktea_pos_db')
-- CREATE DATABASE milktea_pos_db;

-- 2. XÓA BẢNG CŨ (NẾU ĐÃ TỒN TẠI) THEO THỨ TỰ RÀNG BUỘC KHÓA NGOẠI
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
-- 3. BẢNG 1: DANH MỤC SẢN PHẨM (CATEGORIES)
-- ====================================================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,      -- Mã danh mục: AnVatMan, DoAnCay, NuocUong, BanhNgot, SnackKeo, TraiCayChua, AnVatHanQuoc, MonNoNhe
    name VARCHAR(100) NOT NULL,             -- Tên hiển thị: Ăn vặt mặn, Đồ ăn cay, Nước uống...
    icon VARCHAR(50),                      -- Icon emoji: 🧂, 🌶️, 🥤, 🍰, 🍫, 🥭, 🧀, 🍜
    display_order INT DEFAULT 0,            -- Thứ tự hiển thị trên giao diện
    is_active BOOLEAN DEFAULT TRUE
);

-- ====================================================================
-- 4. BẢNG 2: SẢN PHẨM / MÓN ĂN & THỨC UỐNG (PRODUCTS)
-- ====================================================================
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_code VARCHAR(50) NOT NULL REFERENCES categories(code) ON UPDATE CASCADE,
    subcategory VARCHAR(50),                -- Phân nhóm nhỏ (đặc biệt cho Nước uống: tradao, tratac, trasua, cacao, nuocep)
    name VARCHAR(255) NOT NULL,             -- Tên món
    base_price NUMERIC(12, 2) NOT NULL,     -- Giá bán hiện tại
    original_price NUMERIC(12, 2),          -- Giá gốc trước khi giảm
    image_url TEXT,                         -- Đường dẫn ảnh đại diện
    description TEXT,                       -- Mô tả món ăn
    is_available BOOLEAN DEFAULT TRUE,      -- Còn món hay hết hàng
    rating NUMERIC(3, 1) DEFAULT 5.0,       -- Đánh giá sao (4.8, 5.0)
    sold_count INT DEFAULT 0,               -- Số lượng đã bán
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 5. BẢNG 3: TOPPING & TÙY CHỌN MÓN (TOPPINGS)
-- ====================================================================
CREATE TABLE toppings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,             -- Tên topping: Trân châu đen, Pudding trứng, Phô mai tươi...
    price NUMERIC(12, 2) NOT NULL DEFAULT 5000, -- Giá cộng thêm
    is_available BOOLEAN DEFAULT TRUE
);

-- ====================================================================
-- 6. BẢNG 4: BÀN ĂN & MÃ QR (DINING_TABLES)
-- ====================================================================
CREATE TABLE dining_tables (
    id SERIAL PRIMARY KEY,
    table_number VARCHAR(50) UNIQUE NOT NULL, -- Tên bàn: Bàn 01 -> Bàn 12
    qr_token VARCHAR(100),                    -- Mã token bàn
    status VARCHAR(30) DEFAULT 'AVAILABLE',   -- Trạng thái: AVAILABLE (Trống), OCCUPIED (Có khách đang ngồi), RESERVED (Đã đặt)
    capacity INT DEFAULT 4,                   -- Sức chứa số người
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 7. BẢNG 5: ĐƠN ĐẶT MÓN (ORDERS)
-- ====================================================================
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,    -- Mã đơn hàng: ví dụ CC-20260928-001
    table_number VARCHAR(50) NOT NULL,        -- Bàn gọi món
    total_amount NUMERIC(12, 2) NOT NULL,     -- Tổng tiền tạm tính
    discount_percent INT DEFAULT 0,            -- Phần trăm giảm giá (quay trúng vòng quay may mắn)
    discount_amount NUMERIC(12, 2) DEFAULT 0,  -- Số tiền được giảm
    final_amount NUMERIC(12, 2) NOT NULL,      -- Tổng tiền khách phải thanh toán
    payment_method VARCHAR(50) DEFAULT 'VIETQR', -- Hình thức: VIETQR, CASH (Tiền mặt), MOMO
    payment_status VARCHAR(30) DEFAULT 'UNPAID', -- Trạng thái thanh toán: UNPAID, PAID
    status VARCHAR(30) DEFAULT 'PENDING',        -- Trạng thái đơn: PENDING (Chờ quán nhận), PREPARING (Bếp đang làm món), SERVED (Đã ra món), COMPLETED (Hoàn tất), CANCELLED (Hủy)
    customer_notes TEXT,                       -- Ghi chú của khách: ít ngọt, không cay...
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 8. BẢNG 6: CHI TIẾT ĐƠN MÓN (ORDER_ITEMS)
-- ====================================================================
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT,
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(12, 2) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    note TEXT                                 -- Ghi chú cho từng món: ít đá, 50% đường
);

-- ====================================================================
-- 9. BẢNG 7: TOPPING KÈM THEO TỪNG MÓN CỦA ĐƠN (ORDER_ITEM_TOPPINGS)
-- ====================================================================
CREATE TABLE order_item_toppings (
    id BIGSERIAL PRIMARY KEY,
    order_item_id BIGINT NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    topping_name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL
);

-- ====================================================================
-- 10. BẢNG 8: QUẢN LÝ THU CHI / CHI PHÍ QUÁN (EXPENSES)
-- ====================================================================
CREATE TABLE expenses (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,              -- Nội dung chi: Mua nguyên liệu trà sữa, Tiền điện, Đá viên...
    category VARCHAR(100) NOT NULL,           -- Nhóm chi: Nguyên vật liệu, Vận hành, Lương nhân viên
    amount NUMERIC(12, 2) NOT NULL,           -- Số tiền chi
    note TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,   -- Ngày chi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 11. BẢNG 9: TÀI KHOẢN NHÂN VIÊN & BẾP / QUẢN LÝ (USERS)
-- ====================================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,      -- Tên đăng nhập: admin, thu_ngan, bep
    password VARCHAR(255) NOT NULL,            -- Mật khẩu
    full_name VARCHAR(100) NOT NULL,           -- Họ và tên
    role VARCHAR(30) NOT NULL DEFAULT 'STAFF', -- Vai trò: ADMIN (Chủ quán), STAFF (Thu ngân), KITCHEN (Nhân viên bếp làm món)
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 12. TẠO INDEXES ĐỂ TỐI ƯU HIỆU NĂNG TRUY VẤN
-- ====================================================================
CREATE INDEX idx_products_category ON products(category_code);
CREATE INDEX idx_products_subcategory ON products(subcategory);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_table ON orders(table_number);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- ====================================================================
-- 13. CHÈN DỮ LIỆU MẪU BAN ĐẦU (SEED DATA)
-- ====================================================================

-- Chèn 8 Danh mục sản phẩm (Trùng khớp 100% với Frontend Flutter)
INSERT INTO categories (code, name, icon, display_order) VALUES
('AnVatMan', 'Ăn vặt mặn', '🧂', 1),
('DoAnCay', 'Đồ ăn cay', '🌶️', 2),
('NuocUong', 'Nước uống', '🥤', 3),
('BanhNgot', 'Bánh & đồ ngọt', '🍰', 4),
('SnackKeo', 'Snack & kẹo', '🍫', 5),
('TraiCayChua', 'Trái cây & chua', '🥭', 6),
('AnVatHanQuoc', 'Ăn vặt Hàn Quốc', '🧀', 7),
('MonNoNhe', 'Món no nhẹ', '🍜', 8);

-- Chèn 12 Bàn ăn chuẩn của Quán (Bàn 01 -> Bàn 12)
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

-- Chèn Toppings
INSERT INTO toppings (name, price) VALUES
('Trân châu đen dẻo', 5000),
('Trân châu trắng giòn', 7000),
('Pudding trứng béo ngậy', 8000),
('Thạch củ năng phô mai', 8000),
('Phô mai viên tươi', 10000),
('Kem Cheese Macchiato', 12000);

-- Chèn Món Ăn & Thức Uống (Sử dụng ảnh thực tế của đồ án)
INSERT INTO products (category_code, subcategory, name, base_price, original_price, image_url, description, rating, sold_count) VALUES
-- 🧂 Ăn vặt mặn
('AnVatMan', NULL, 'Cá viên chiên nước mắm', 20000, 30000, 'assets/images/anvatman/cavienchien/ca1.jpg', 'Cá viên chiên giòn rụm sốt đậm vị', 4.9, 320),
('AnVatMan', NULL, 'Xúc xích Đức nướng tiêu', 15000, 25000, 'assets/images/anvatman/xucxich/xuc1.jpg', 'Xúc xích Đức vỏ giòn cay nhẹ', 4.8, 280),
('AnVatMan', NULL, 'Khoai tây lắc phô mai', 20000, 30000, 'assets/images/anvatman/khoaitaylac/khoai1.jpg', 'Khoai tây cắt lát phủ phô mai thơm lừng', 4.9, 410),
('AnVatMan', NULL, 'Phô mai que kéo sợi', 22000, 35000, 'assets/images/anvatman/phomaique/que1.jpg', 'Phô mai que ngập tràn Mozzarella nóng hổi', 4.9, 390),
('AnVatMan', NULL, 'Nem chua rán phố cổ', 25000, 35000, 'assets/images/anvatman/nemchua/nem1.jpg', 'Nem chua tẩm bột chiên xù chuẩn vị Hà Nội', 4.8, 250),

-- 🌶️ Đồ ăn cay
('DoAnCay', NULL, 'Bánh tráng cuốn bơ sốt cay', 20000, 30000, 'assets/images/doancay/banhtrangcuon/cuon1.jpg', 'Bánh tráng cuốn hành phi sốt bơ trứng cay', 4.9, 450),
('DoAnCay', NULL, 'Bánh tráng trộn bò sốt me', 20000, 30000, 'assets/images/doancay/banhtrangtron/tron1.jpg', 'Bánh tráng trộn khô bò trứng cút đậu phộng', 4.9, 520),
('DoAnCay', NULL, 'Chân gà sả tắc rút xương', 35000, 50000, 'assets/images/doancay/changa/ga1.jpg', 'Chân gà giòn sần sật ngâm sả tắc chua cay', 4.8, 310),

-- 🥤 Nước uống (Phân theo 5 nhóm nhỏ chuẩn giao diện)
('NuocUong', 'trasua', 'Trà sữa trân châu đường đen', 28000, 42000, 'assets/images/nuocuong/trasua/duongden/den1.jpg', 'Sữa tươi thanh trùng và trân châu đường đen', 5.0, 680),
('NuocUong', 'trasua', 'Trà sữa matcha Uji kem béo', 30000, 45000, 'assets/images/nuocuong/trasua/matcha/mat1.jpg', 'Bột matcha Nhật Bản nguyên chất thơm béo', 4.9, 410),
('NuocUong', 'trasua', 'Trà sữa ChouxChin truyền thống', 25000, 38000, 'assets/images/nuocuong/trasua/truyenthong/tt1.jpg', 'Vị trà đậm đà bí quyết độc quyền của quán', 4.9, 590),
('NuocUong', 'trasua', 'Trà sữa ô long nướng Đài Loan', 30000, 45000, 'assets/images/nuocuong/trasua/olong/olong1.jpg', 'Trà ô long sao khô hương thơm quyến rũ', 4.8, 330),
('NuocUong', 'trasua', 'Trà sữa Thái xanh Thái đỏ', 25000, 38000, 'assets/images/nuocuong/trasua/thai/thai1.jpg', 'Trà sữa phong cách xứ sở Chùa Vàng', 4.7, 290),
('NuocUong', 'tradao', 'Trà đào miếng mật ong', 25000, 38000, 'assets/images/nuocuong/tradao/dao1.jpg', 'Trà thanh mát cùng miếng đào giòn ngọt', 4.9, 510),
('NuocUong', 'tratac', 'Trà tắc xí muội giải nhiệt', 18000, 28000, 'assets/images/nuocuong/tratac/tac1.jpg', 'Vị chua ngọt xí muội giải nhiệt mùa hè', 4.8, 380),
('NuocUong', 'cacao', 'Cacao kem dầm tuyết đá', 28000, 42000, 'assets/images/nuocuong/cacao/ca1.jpg', 'Cacao nguyên chất sánh đặc béo ngậy', 4.9, 270),
('NuocUong', 'nuocep', 'Nước ép cam sành tươi nguyên chất', 25000, 38000, 'assets/images/nuocuong/nuocep/cam/cam1.jpg', 'Cam sành mọng nước bổ sung Vitamin C', 4.8, 300),
('NuocUong', 'nuocep', 'Nước dừa tươi dứa xiêm', 25000, 38000, 'assets/images/nuocuong/nuocep/dua/dua1.jpg', 'Nước dừa xiêm ngọt thanh tự nhiên', 4.9, 240),
('NuocUong', 'nuocep', 'Nước ép dưa hấu thanh mát', 22000, 35000, 'assets/images/nuocuong/nuocep/duahau/hau1.jpg', 'Dưa hấu tươi mát rượi ngọt lành', 4.8, 220),

-- 🍰 Bánh & đồ ngọt
('BanhNgot', NULL, 'Bánh su kem Choux ngập sữa', 18000, 28000, 'assets/images/banh&dongot/sukem/su1.jpg', 'Vỏ bánh phồng xốp nhân kem vani ngập tràn', 4.9, 430),
('BanhNgot', NULL, 'Bánh Tiramisu Ý cacao', 32000, 48000, 'assets/images/banh&dongot/tiramisu/tira1.jpg', 'Bánh mềm mịn thơm cà phê và phô mai Ý', 5.0, 360),
('BanhNgot', NULL, 'Bánh Cupcake dâu ngọt ngào', 20000, 30000, 'assets/images/banh&dongot/cupcake/cup1.jpg', 'Bánh cupcake kem sữa tươi và sốt dâu tây', 4.8, 210),

-- 🧀 Ăn vặt Hàn Quốc
('AnVatHanQuoc', NULL, 'Kimbap chiên xù sốt mayo', 28000, 42000, 'assets/images/anvathanquoc/kimbap/kim1.jpg', 'Cơm cuộn rong biển chiên xù giòn béo', 4.9, 390),
('AnVatHanQuoc', NULL, 'Tokbokki chả cá sốt cay ngọt', 30000, 45000, 'assets/images/anvathanquoc/tokbokki/tok1.jpg', 'Bánh gạo dẻo dai sốt ớt Gochujang chuẩn Hàn', 4.9, 480),
('AnVatHanQuoc', NULL, 'Mandu bánh bao chiên giòn', 25000, 38000, 'assets/images/anvathanquoc/mandu/man1.jpg', 'Mandu nhân thịt băm kim chi chiên vàng', 4.8, 260),

-- 🍜 Món no nhẹ
('MonNoNhe', NULL, 'Mì trộn trứng lòng đào xá xíu', 32000, 48000, 'assets/images/monnonhe/mitron/mi1.jpg', 'Mì trộn sốt đặc biệt, trứng lòng đào béo ngậy', 4.9, 520),
('MonNoNhe', NULL, 'Nui xào bò sốt cà chua', 35000, 52000, 'assets/images/monnonhe/nuixao/nui1.jpg', 'Nui xào thịt bò mềm ngọt giàu dinh dưỡng', 4.8, 310);

-- Chèn Tài khoản nhân viên, bếp và quản lý quán (Mật khẩu mặc định: 123456)
INSERT INTO users (username, password, full_name, role, phone) VALUES
('admin', '123456', 'Nguyễn Huỳnh Anh Tuấn (Chủ quán)', 'ADMIN', '0901234567'),
('thungan', '123456', 'Nhân Viên Thu Ngân POS', 'STAFF', '0902345678'),
('bep', '123456', 'Bộ Phận Bếp (KDS Screen)', 'KITCHEN', '0903456789');

-- Chèn dữ liệu mẫu cho Đơn hàng đặt tại bàn
INSERT INTO orders (order_code, table_number, total_amount, discount_percent, discount_amount, final_amount, payment_method, payment_status, status, customer_notes) VALUES
('CC-20260928-001', 'Bàn 05', 73000, 10, 7300, 65700, 'VIETQR', 'PAID', 'PREPARING', 'Bàn 05: 1 trà sữa ít đường, 1 cá viên sốt đậm'),
('CC-20260928-002', 'Bàn 02', 45000, 0, 0, 45000, 'CASH', 'UNPAID', 'PENDING', 'Khách xin thêm ớt');

INSERT INTO order_items (order_id, product_name, quantity, unit_price, subtotal, note) VALUES
(1, 'Trà sữa trân châu đường đen', 1, 28000, 28000, '50% đường, 70% đá'),
(1, 'Cá viên chiên nước mắm', 1, 20000, 20000, 'Cay nhiều'),
(1, 'Phô mai que kéo sợi', 1, 25000, 25000, 'Chiên giòn'),
(2, 'Tokbokki chả cá sốt cay ngọt', 1, 30000, 30000, 'Ít cay'),
(2, 'Trà tắc xí muội giải nhiệt', 1, 15000, 15000, 'Nhiều đá');

-- ====================================================================
-- HOÀN TẤT KHỞI TẠO CƠ SỞ DỮ LIỆU CHOUXCHIN TRÊN PGADMIN 4!
-- ====================================================================
