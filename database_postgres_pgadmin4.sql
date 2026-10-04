-- =========================================================================================
-- ĐỒ ÁN TỐT NGHIỆP: HỆ THỐNG POS & GỌI MÓN TẠI BÀN QR CODE - THƯƠNG HIỆU CHOUXCHIN
-- Sinh viên: NGUYỄN HUỲNH ANH TUẤN - MSSV: 2351067119 - Lớp: S26-K65CNTT
-- Trường Đại học Thủy Lợi - GVHD: ThS. Hoàng Văn Quý
-- HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU: POSTGRESQL 14+ / PGADMIN 4
-- =========================================================================================
-- KIẾN TRÚC TOÀN DIỆN BAO GỒM:
-- 1. Quản lý Bàn ăn & Deep Link QR Code Vercel theo tiêu chuẩn ISO/IEC 18004
-- 2. Quản lý Danh mục & 93 Món ăn / Đồ uống chuẩn xác 100% theo giao diện Web App
-- 3. Hệ sinh thái Tùy chọn món (Size M/L, Đường, Đá, Topping kèm)
-- 4. Hệ thống Gamification: Minigame Hứng đồ ăn, Lật thẻ bài & Vòng quay may mắn TikTok
-- 5. Quản lý Đơn hàng, Chi tiết món & Cổng thanh toán VietQR động
-- 6. Quản trị Kho nguyên vật liệu định lượng công thức (BOM - Bill of Materials)
-- 7. Thuật toán khai phá luật kết hợp Apriori (Association Rule Mining) gợi ý món
-- 8. Quản lý Sổ chi tiêu hàng ngày (Petty Cash) & Báo cáo Lợi nhuận ròng thực tế
-- 9. Quản trị Nhân sự, Phân quyền hệ thống, Xếp ca & Chấm công tự động
-- 10. Hệ thống Views & Stored Procedures tự động hóa nghiệp vụ
-- =========================================================================================

-- ====================================================================
-- PHẦN 1: DỌN DẸP BẢNG CŨ ĐỂ KHỞI TẠO MỚI (DROP TABLES CASCADE)
-- ====================================================================
DROP VIEW IF EXISTS v_net_profit_summary CASCADE;
DROP VIEW IF EXISTS v_inventory_alert CASCADE;
DROP VIEW IF EXISTS v_daily_revenue_report CASCADE;
DROP VIEW IF EXISTS v_top_selling_products CASCADE;

DROP TABLE IF EXISTS association_rules CASCADE;
DROP TABLE IF EXISTS recipes CASCADE;
DROP TABLE IF EXISTS ingredients CASCADE;
DROP TABLE IF EXISTS inventory_transactions CASCADE;

DROP TABLE IF EXISTS minigame_scores CASCADE;
DROP TABLE IF EXISTS lucky_wheel_rewards CASCADE;
DROP TABLE IF EXISTS vouchers CASCADE;

DROP TABLE IF EXISTS work_schedules CASCADE;
DROP TABLE IF EXISTS shifts CASCADE;
DROP TABLE IF EXISTS order_item_toppings CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_options CASCADE;
DROP TABLE IF EXISTS toppings CASCADE;
DROP TABLE IF EXISTS product_images CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS dining_tables CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ====================================================================
-- PHẦN 2: THIẾT KẾ CÁC BẢNG DỮ LIỆU (DDL - SCHEMA DEFINITION)
-- ====================================================================

-- 1. BẢNG BÀN ĂN & MÃ QR CODE (DINING_TABLES)
CREATE TABLE dining_tables (
    id SERIAL PRIMARY KEY,
    table_number VARCHAR(50) UNIQUE NOT NULL,      -- Bàn 01 -> Bàn 12
    qr_token VARCHAR(100) NOT NULL,               -- Token bảo mật
    qr_code_url TEXT NOT NULL,                    -- Deep Link Vercel quét mã đặt món
    status VARCHAR(30) DEFAULT 'AVAILABLE',       -- AVAILABLE, OCCUPIED, RESERVED
    capacity INT DEFAULT 4,                       -- Số chỗ ngồi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. BẢNG DANH MỤC SẢN PHẨM (CATEGORIES - 8 DANH MỤC CHUẨN APP)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,             -- Mã định danh: AnVatMan, NuocUong...
    name VARCHAR(100) NOT NULL,                    -- Tên hiển thị
    icon VARCHAR(50),                             -- Biểu tượng Emoji
    display_order INT DEFAULT 0,                   -- Thứ tự hiển thị trên Menu
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. BẢNG SẢN PHẨM MÓN ĂN & THỨC UỐNG (PRODUCTS - 93 MÓN ĂN VẶT & TRÀ SỮA)
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_code VARCHAR(50) NOT NULL REFERENCES categories(code) ON UPDATE CASCADE,
    subcategory VARCHAR(50),                       -- Nhóm phụ: trasua, tradao, tratac, cacao, nuocep
    name VARCHAR(255) NOT NULL,                    -- Tên món chính xác 100%
    base_price NUMERIC(12, 2) NOT NULL,            -- Giá bán hiện tại
    original_price NUMERIC(12, 2),                 -- Giá niêm yết gốc (để tính % giảm giá)
    image_url TEXT NOT NULL,                       -- Đường dẫn ảnh đại diện
    description TEXT,                              -- Mô tả chi tiết, cảm giác vị giác
    is_available BOOLEAN DEFAULT TRUE,             -- Còn hàng hay Tạm hết
    rating NUMERIC(3, 1) DEFAULT 4.8,              -- Đánh giá sao (4.5 - 5.0)
    sold_count INT DEFAULT 0,                      -- Số lượt đã bán
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. BẢNG THƯ VIỆN HÌNH ẢNH MÓN ĂN (PRODUCT_IMAGES - CAROUSEL 7 ẢNH/MÓN)
CREATE TABLE product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 1
);

-- 5. BẢNG TOPPING & TÙY CHỌN DÙNG CHUNG (TOPPINGS)
CREATE TABLE toppings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL DEFAULT 5000,
    is_available BOOLEAN DEFAULT TRUE
);

-- 6. BẢNG CÁC TÙY CHỌN RIÊNG CỦA MÓN (PRODUCT_OPTIONS: SIZE, ĐƯỜNG, ĐÁ)
CREATE TABLE product_options (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,                    -- Size M, Size L, 50% Đường, 70% Đá...
    type VARCHAR(50) NOT NULL,                     -- SIZE, SUGAR, ICE, TOPPING
    additional_price NUMERIC(12, 2) DEFAULT 0,     -- Giá cộng thêm (ví dụ Size L +6.000đ)
    is_default BOOLEAN DEFAULT FALSE
);

-- 7. BẢNG MÃ GIẢM GIÁ VOUCHER (VOUCHERS - TÍCH HỢP TỪ GAMIFICATION & MINIGAME)
CREATE TABLE vouchers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,              -- Mã voucher: TIKTOK10, VONGQUAY15...
    discount_percent INT DEFAULT 0,                -- Tỷ lệ giảm (%)
    discount_amount NUMERIC(12, 2) DEFAULT 0,      -- Số tiền giảm cố định (đ)
    min_order_amount NUMERIC(12, 2) DEFAULT 0,     -- Đơn tối thiểu áp dụng
    description VARCHAR(255),                      -- Mô tả điều kiện
    is_active BOOLEAN DEFAULT TRUE,
    expiry_date TIMESTAMP
);

-- 8. BẢNG GIẢI THƯỞNG VÒNG QUAY MAY MẮN TIKTOK (LUCKY_WHEEL_REWARDS)
CREATE TABLE lucky_wheel_rewards (
    id SERIAL PRIMARY KEY,
    reward_name VARCHAR(100) NOT NULL,
    voucher_code VARCHAR(50) REFERENCES vouchers(code),
    probability NUMERIC(5, 2) NOT NULL,            -- Xác suất trúng (%)
    icon VARCHAR(50),
    color_hex VARCHAR(20)
);

-- 9. BẢNG LỊCH SỬ CHƠI MINIGAME & ĐIỂM SỐ (MINIGAME_SCORES)
CREATE TABLE minigame_scores (
    id BIGSERIAL PRIMARY KEY,
    table_number VARCHAR(50) NOT NULL,
    game_type VARCHAR(50) NOT NULL,                -- HUNG_DO_AN, LAT_THE_BAI
    score INT NOT NULL,
    combo_max INT DEFAULT 0,
    duration_seconds INT DEFAULT 45,
    reward_granted BOOLEAN DEFAULT TRUE,           -- Đã cấp lượt quay may mắn chưa
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. BẢNG ĐƠN HÀNG (ORDERS - QUẢN LÝ OMNICHANNEL & GỌI MÓN TẠI BÀN)
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_code VARCHAR(50) UNIQUE NOT NULL,        -- Mã đơn: CC-20261004-0001
    table_number VARCHAR(50) NOT NULL,             -- Bàn gọi món
    total_amount NUMERIC(12, 2) NOT NULL,          -- Tổng tiền tạm tính trước giảm
    voucher_code VARCHAR(50),                      -- Mã voucher áp dụng
    discount_percent INT DEFAULT 0,                -- % Giảm giá
    discount_amount NUMERIC(12, 2) DEFAULT 0,      -- Số tiền giảm
    final_amount NUMERIC(12, 2) NOT NULL,          -- Số tiền thực tế phải thanh toán
    payment_method VARCHAR(50) DEFAULT 'VIETQR',   -- VIETQR, CASH, MOMO
    payment_status VARCHAR(30) DEFAULT 'UNPAID',   -- UNPAID, PAID
    status VARCHAR(30) DEFAULT 'PENDING',          -- PENDING, PREPARING, SERVED, COMPLETED, CANCELLED
    customer_notes TEXT,                           -- Ghi chú của khách tại bàn
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. BẢNG CHI TIẾT ĐƠN HÀNG (ORDER_ITEMS)
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    size VARCHAR(20) DEFAULT 'M',                  -- M, L
    sugar VARCHAR(20) DEFAULT '100%',              -- 0%, 30%, 50%, 70%, 100%
    ice VARCHAR(20) DEFAULT '100%',                -- Nóng, Không đá, 50% đá, 100% đá
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(12, 2) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    note TEXT
);

-- 12. BẢNG TOPPING ĐI KÈM TỪNG MÓN CỦA ĐƠN (ORDER_ITEM_TOPPINGS)
CREATE TABLE order_item_toppings (
    id BIGSERIAL PRIMARY KEY,
    order_item_id BIGINT NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    topping_name VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL
);

-- 13. BẢNG NGUYÊN VẬT LIỆU KHO (INGREDIENTS - BÀI TOÁN QUẢN TRỊ KHO NÂNG CAO)
CREATE TABLE ingredients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,                    -- Trà đen, Sữa đặc, Trân châu...
    category VARCHAR(50) NOT NULL,                 -- TRÀ, SỮA, TOPPING, THỰC_PHẨM, BAO_BÌ
    unit VARCHAR(20) NOT NULL,                     -- gram, ml, cái, que, quả...
    current_stock NUMERIC(12, 2) NOT NULL DEFAULT 0, -- Tồn kho thực tế
    minimum_stock NUMERIC(12, 2) NOT NULL DEFAULT 100, -- Ngưỡng tối thiểu báo động
    unit_cost NUMERIC(12, 2) NOT NULL DEFAULT 0,   -- Giá nhập bình quân
    supplier VARCHAR(150)                          -- Nhà cung ứng
);

-- 14. BẢNG ĐỊNH LƯỢNG CÔNG THỨC (RECIPES - BOM: BILL OF MATERIALS)
CREATE TABLE recipes (
    id SERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    ingredient_id INT NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    quantity_needed NUMERIC(10, 2) NOT NULL,       -- Lượng nguyên liệu tiêu hao cho 1 đơn vị món
    unit VARCHAR(20) NOT NULL
);

-- 15. BẢNG LUẬT KẾT HỢP GỢI Ý MÓN (ASSOCIATION_RULES - THUẬT TOÁN APRIORI)
CREATE TABLE association_rules (
    id SERIAL PRIMARY KEY,
    antecedent_product_id BIGINT REFERENCES products(id),   -- Nếu mua món A
    antecedent_name VARCHAR(255) NOT NULL,
    consequent_product_id BIGINT REFERENCES products(id),   -- Thì gợi ý mua kèm món B
    consequent_name VARCHAR(255) NOT NULL,
    support NUMERIC(5, 4) NOT NULL,                         -- Độ hỗ trợ P(A n B)
    confidence NUMERIC(5, 4) NOT NULL,                      -- Độ tin cậy P(B|A)
    lift NUMERIC(5, 2) NOT NULL,                            -- Độ tương quan tương hỗ (> 1 là tích cực)
    recommendation_text VARCHAR(255)
);

-- 16. BẢNG QUẢN LÝ SỔ CHI TIÊU HÀNG NGÀY (EXPENSES - TÍNH LỢI NHUẬN RÒNG)
CREATE TABLE expenses (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,                   -- Mua đá bi, mua túi bóng...
    category VARCHAR(100) NOT NULL,                -- NGUYEN_LIEU, VAT_TU, DIEN_NUOC, TIEN_THUE, KHAC
    amount NUMERIC(12, 2) NOT NULL,
    note TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. BẢNG TÀI KHOẢN HỆ THỐNG (USERS - ADMIN, THU NGÂN, BẾP)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'STAFF',     -- ADMIN, STAFF, KITCHEN
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 18. BẢNG CA LÀM VIỆC (SHIFTS)
CREATE TABLE shifts (
    id SERIAL PRIMARY KEY,
    shift_name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    hourly_rate NUMERIC(12, 2) NOT NULL DEFAULT 25000
);

-- 19. BẢNG XẾP CA & CHẤM CÔNG NHÂN VIÊN (WORK_SCHEDULES)
CREATE TABLE work_schedules (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    shift_id INT REFERENCES shifts(id) ON DELETE SET NULL,
    work_date DATE NOT NULL DEFAULT CURRENT_DATE,
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    total_hours NUMERIC(5, 2) DEFAULT 0,
    salary_earned NUMERIC(12, 2) DEFAULT 0,
    status VARCHAR(30) DEFAULT 'SCHEDULED'         -- SCHEDULED, WORKING, COMPLETED, ABSENT
);

-- ====================================================================
-- PHẦN 3: TẠO INDEXES TỐI ƯU HÓA HIỆU NĂNG TRUY VẤN CƠ SỞ DỮ LIỆU
-- ====================================================================
CREATE INDEX idx_products_category ON products(category_code);
CREATE INDEX idx_products_subcategory ON products(subcategory);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_table ON orders(table_number);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_recipes_product ON recipes(product_id);
CREATE INDEX idx_recipes_ingredient ON recipes(ingredient_id);
CREATE INDEX idx_assoc_antecedent ON association_rules(antecedent_product_id);

-- ====================================================================
-- PHẦN 4: DỮ LIỆU KHỞI TẠO (DML - INSERTION DATA CHUẨN XÁC 100%)
-- ====================================================================

-- 1. CHÈN 12 BÀN ĂN & LINK QR VERCEL
INSERT INTO dining_tables (table_number, qr_token, qr_code_url, status, capacity) VALUES
('Bàn 01', 'token_table_01', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2001', 'AVAILABLE', 4),
('Bàn 02', 'token_table_02', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2002', 'OCCUPIED', 4),
('Bàn 03', 'token_table_03', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2003', 'AVAILABLE', 4),
('Bàn 04', 'token_table_04', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2004', 'AVAILABLE', 4),
('Bàn 05', 'token_table_05', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2005', 'OCCUPIED', 4),
('Bàn 06', 'token_table_06', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2006', 'AVAILABLE', 4),
('Bàn 07', 'token_table_07', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2007', 'AVAILABLE', 4),
('Bàn 08', 'token_table_08', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2008', 'AVAILABLE', 4),
('Bàn 09', 'token_table_09', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2009', 'AVAILABLE', 4),
('Bàn 10', 'token_table_10', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2010', 'AVAILABLE', 6),
('Bàn 11', 'token_table_11', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2011', 'AVAILABLE', 6),
('Bàn 12', 'token_table_12', 'https://nguyenhuynhanhtuans26k65cntt.vercel.app/?table=B%C3%A0n%2012', 'AVAILABLE', 8);

-- 2. CHÈN 8 DANH MỤC SẢN PHẨM
INSERT INTO categories (code, name, icon, display_order) VALUES
('AnVatMan', 'Ăn vặt mặn', '🧂', 1),
('DoAnCay', 'Đồ ăn cay', '🌶️', 2),
('NuocUong', 'Nước uống', '🥤', 3),
('BanhNgot', 'Bánh & đồ ngọt', '🍰', 4),
('SnackKeo', 'Snack & kẹo', '🍫', 5),
('TraiCayChua', 'Trái cây & chua', '🥭', 6),
('AnVatHanQuoc', 'Ăn vặt Hàn Quốc', '🧀', 7),
('MonNoNhe', 'Món no nhẹ', '🍜', 8);

-- 3. CHÈN TOÀN BỘ 93 MÓN ĂN & THỨC UỐNG CHÍNH XÁC NHẤT
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

-- Đồng bộ ID sequence của products

-- Đồng bộ ID sequence của products

-- Đồng bộ ID sequence của products
SELECT setval(pg_get_serial_sequence('products', 'id'), COALESCE((SELECT MAX(id) FROM products), 1));

-- 3.1. CHÈN THƯ VIỆN HÌNH ẢNH MÓN ĂN (PRODUCT_IMAGES - CAROUSEL ẢNH CHI TIẾT)
INSERT INTO product_images (product_id, image_url, display_order)
SELECT id, image_url, 1 FROM products;

-- 4. CHÈN DANH SÁCH TOPPINGS & TÙY CHỌN DÙNG CHUNG
INSERT INTO toppings (name, price) VALUES
('Thêm ớt tươi / bột ớt', 2000),
('Thêm sốt đặc biệt', 3000),
('Phần lớn hơn (Size L)', 6000),
('Đóng gói hộp riêng mang về', 2000),
('Trân châu đen dẻo', 5000),
('Trân châu trắng giòn 3Q', 7000),
('Pudding trứng béo ngậy', 8000),
('Thạch củ năng phô mai', 8000),
('Kem Cheese Macchiato', 10000);

-- 5. CHÈN BẢNG TÙY CHỌN RIÊNG CỦA MÓN (SIZE, ĐƯỜNG, ĐÁ)
INSERT INTO product_options (name, type, additional_price, is_default) VALUES
('Size M (Vừa)', 'SIZE', 0, TRUE),
('Size L (Lớn)', 'SIZE', 6000, FALSE),
('100% Ngọt chuẩn', 'SUGAR', 0, TRUE),
('70% Ngọt vừa', 'SUGAR', 0, FALSE),
('50% Ít ngọt', 'SUGAR', 0, FALSE),
('30% Rất ít ngọt', 'SUGAR', 0, FALSE),
('0% Không đường', 'SUGAR', 0, FALSE),
('100% Đá chuẩn', 'ICE', 0, TRUE),
('50% Ít đá', 'ICE', 0, FALSE),
('Không lấy đá', 'ICE', 0, FALSE),
('Uống nóng', 'ICE', 0, FALSE);

-- 6. CHÈN DANH SÁCH MÃ VOUCHER TỪ VÒNG QUAY MAY MẮN
INSERT INTO vouchers (code, discount_percent, discount_amount, min_order_amount, description, is_active, expiry_date) VALUES
('CHOUX10', 10, 0, 50000, 'Giảm 10% cho đơn từ 50k quay từ Vòng quay TikTok', TRUE, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('CHOUX15', 15, 0, 80000, 'Giảm 15% cho đơn từ 80k - Siêu nhân Hứng đồ ăn vặt', TRUE, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('CHOUX20', 20, 0, 100000, 'Giảm 20% cho đơn từ 100k - Quán quân Lật thẻ tìm cặp', TRUE, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('CHOUX50K', 0, 50000, 150000, 'Voucher giảm 50.000đ cho hóa đơn đại tiệc nhóm từ 150k', TRUE, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('FREESHIP', 0, 15000, 60000, 'Miễn phí giao hàng hoặc đóng gói mang về', TRUE, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('TANGCAVIEN', 0, 15000, 70000, 'Tặng 1 xiên Cá viên chiên vàng giòn rụm', TRUE, CURRENT_TIMESTAMP + INTERVAL '30 days');

-- 7. CHÈN CẤU HÌNH VÒNG QUAY MAY MẮN TIKTOK
INSERT INTO lucky_wheel_rewards (reward_name, voucher_code, probability, icon, color_hex) VALUES
('Giảm 10% Toàn Đơn', 'CHOUX10', 35.0, '🎉', '#FF6B6B'),
('Tặng Xiên Cá Viên', 'TANGCAVIEN', 20.0, '🍢', '#4ECDC4'),
('Giảm 15% Đơn 80k', 'CHOUX15', 20.0, '🔥', '#FFE66D'),
('Voucher 50.000đ', 'CHOUX50K', 5.0, '👑', '#1A535C'),
('Giảm 20% Siêu VIP', 'CHOUX20', 10.0, '⭐', '#FF8C42'),
('Chúc Bạn May Mắn Lần Sau', NULL, 10.0, '🍀', '#A8DADC');

-- 8. CHÈN DỮ LIỆU ĐIỂM MINIGAME MẪU
INSERT INTO minigame_scores (table_number, game_type, score, combo_max, duration_seconds, reward_granted) VALUES
('Bàn 01', 'HUNG_DO_AN', 320, 12, 45, TRUE),
('Bàn 02', 'LAT_THE_BAI', 100, 8, 38, TRUE),
('Bàn 05', 'HUNG_DO_AN', 450, 18, 45, TRUE),
('Bàn 08', 'LAT_THE_BAI', 95, 6, 42, TRUE);

-- 9. CHÈN 25 NGUYÊN VẬT LIỆU KHO THỰC TẾ (BÀI TOÁN KHO & BÁO ĐỘNG HẾT HÀNG)
INSERT INTO ingredients (id, name, category, unit, current_stock, minimum_stock, unit_cost, supplier) VALUES
(1, 'Trà đen Lộc Phát thượng hạng', 'TRÀ', 'gram', 15000, 2000, 0.15, 'Công ty Trà Lộc Phát'),
(2, 'Trà Ô long nướng Đài Loan', 'TRÀ', 'gram', 8500, 1500, 0.22, 'Đài Loan Export'),
(3, 'Bột Matcha Uji Nhật Bản', 'TRÀ', 'gram', 3200, 800, 0.75, 'Uji Kyoto Importer'),
(4, 'Sữa đặc Ngôi Sao Phương Nam', 'SỮA', 'ml', 45000, 5000, 0.06, 'Vinamilk Việt Nam'),
(5, 'Sữa tươi thanh trùng Dalat Milk', 'SỮA', 'ml', 30000, 6000, 0.04, 'Dalat Milk Farm'),
(6, 'Bột béo thực vật B-One Thái Lan', 'SỮA', 'gram', 25000, 4000, 0.09, 'B-One Thailand'),
(7, 'Đường cát trắng Biên Hòa', 'GIA_VỊ', 'gram', 50000, 8000, 0.02, 'Đường Biên Hòa'),
(8, 'Sốt đường đen Hàn Quốc', 'GIA_VỊ', 'ml', 12000, 2000, 0.12, 'CJ Foods Hàn Quốc'),
(9, 'Trân châu đen dẻo Gia Uy', 'TOPPING', 'gram', 22000, 4000, 0.05, 'Gia Uy Foods'),
(10, 'Trân châu trắng 3Q ngọc trai', 'TOPPING', 'gram', 16000, 3000, 0.08, 'Gia Uy Foods'),
(11, 'Bột Pudding trứng cao cấp', 'TOPPING', 'gram', 5000, 1000, 0.18, 'Rich Products'),
(12, 'Kem Cheese Anchor New Zealand', 'TOPPING', 'gram', 6000, 1500, 0.35, 'Anchor Fonterra'),
(13, 'Cá viên basa chiên giòn', 'THỰC_PHẨM', 'viên', 1200, 200, 1200, 'Thực phẩm Biển Cửu Long'),
(14, 'Xúc xích heo xông khói CP', 'THỰC_PHẨM', 'cây', 450, 80, 5000, 'Tập đoàn C.P Việt Nam'),
(15, 'Khoai tây cọng Bỉ chiên giòn', 'THỰC_PHẨM', 'gram', 18000, 3000, 0.08, 'Aviko Belgium'),
(16, 'Phô mai que Mozzarella sợi', 'THỰC_PHẨM', 'que', 350, 60, 9000, 'Phô mai Gia Thịnh'),
(17, 'Nem chua rán Hà Nội', 'THỰC_PHẨM', 'chiếc', 600, 100, 2500, 'Nem chua Phố Cổ'),
(18, 'Bánh gạo Tokbokki Hàn Quốc', 'THỰC_PHẨM', 'gram', 14000, 2500, 0.07, 'CJ Foods Hàn Quốc'),
(19, 'Sốt Gochujang ớt cay ngọt', 'GIA_VỊ', 'gram', 8000, 1500, 0.14, 'Sempio Korea'),
(20, 'Bánh tráng phơi sương Tây Ninh', 'THỰC_PHẨM', 'xấp', 80, 15, 8000, 'Đặc sản Trảng Bàng'),
(21, 'Muối tôm & ớt Tây Ninh', 'GIA_VỊ', 'gram', 6500, 1000, 0.06, 'Muối Như Ý'),
(22, 'Chân gà rút xương tươi sạch', 'THỰC_PHẨM', 'gram', 9500, 2000, 0.12, 'CP Fresh Mart'),
(23, 'Cam sành Hàm Yên mọng nước', 'TRÁI_CÂY', 'quả', 240, 50, 4000, 'Nông sản Việt'),
(24, 'Ly nhựa PP 500ml/700ml kèm nắp', 'BAO_BÌ', 'cái', 3500, 500, 450, 'Bao bì Thuận Phát'),
(25, 'Ống hút trân châu bọc màng OPP', 'BAO_BÌ', 'cái', 4800, 600, 120, 'Bao bì Thuận Phát');

SELECT setval(pg_get_serial_sequence('ingredients', 'id'), COALESCE((SELECT MAX(id) FROM ingredients), 1));

-- 10. CHÈN CÔNG THỨC ĐỊNH LƯỢNG CHO TỪNG MÓN ĂN VÀ NƯỚC UỐNG (BOM - RECIPES)
INSERT INTO recipes (product_id, ingredient_id, quantity_needed, unit) VALUES
-- Món ID 9: Trà sữa trân châu đường đen (Size L)
(9, 1, 15, 'gram'),    -- 15g Trà đen
(9, 6, 25, 'gram'),    -- 25g Bột béo
(9, 4, 30, 'ml'),      -- 30ml Sữa đặc
(9, 8, 20, 'ml'),      -- 20ml Sốt đường đen
(9, 9, 35, 'gram'),    -- 35g Trân châu đen
(9, 24, 1, 'cái'),     -- 1 Ly nhựa
(9, 25, 1, 'cái'),     -- 1 Ống hút

-- Món ID 11: Trà sữa truyền thống
(11, 1, 15, 'gram'),   -- 15g Trà đen
(11, 6, 25, 'gram'),   -- 25g Bột béo
(11, 4, 35, 'ml'),     -- 35ml Sữa đặc
(11, 24, 1, 'cái'),    -- 1 Ly nhựa
(11, 25, 1, 'cái'),    -- 1 Ống hút

-- Món ID 10: Trà sữa matcha
(10, 3, 10, 'gram'),   -- 10g Bột Matcha
(10, 5, 150, 'ml'),    -- 150ml Sữa tươi Dalat
(10, 4, 30, 'ml'),     -- 30ml Sữa đặc
(10, 24, 1, 'cái'),    -- 1 Ly nhựa
(10, 25, 1, 'cái'),    -- 1 Ống hút

-- Món ID 1: Cá viên chiên (1 xiên 5 viên)
(1, 13, 5, 'viên'),    -- 5 viên cá basa
(1, 21, 5, 'gram'),    -- 5g muối ớt tương

-- Món ID 2: Xúc xích nướng
(2, 14, 1, 'cây'),     -- 1 cây xúc xích CP

-- Món ID 3: Khoai tây chiên
(3, 15, 150, 'gram'),  -- 150g khoai tây Bỉ

-- Món ID 4: Phô mai que (1 phần 2 que)
(4, 16, 2, 'que'),     -- 2 que phô mai

-- Món ID 5: Nem chua rán (1 phần 3 chiếc)
(5, 17, 3, 'chiếc'),   -- 3 chiếc nem chua

-- Món ID 7: Bánh tráng trộn
(7, 20, 1, 'xấp'),     -- Bánh tráng phơi sương
(7, 21, 10, 'gram'),   -- Muối tôm sa tế

-- Món ID 29: Tokbokki cay ngọt
(29, 18, 150, 'gram'), -- 150g bánh gạo
(29, 19, 30, 'gram');  -- 30g sốt gochujang

-- 11. CHÈN BẢNG LUẬT KẾT HỢP APRIORI (GỢI Ý MÓN CHUYÊN SÂU THEO TOÁN HỌC)
INSERT INTO association_rules (antecedent_product_id, antecedent_name, consequent_product_id, consequent_name, support, confidence, lift, recommendation_text) VALUES
(1, 'Cá viên chiên', 206, 'Trà tắc khổng lồ', 0.1450, 0.8520, 2.34, 'Ăn cá viên giòn rụm uống kèm Trà tắc giải nhiệt cực đỉnh!'),
(7, 'Bánh tráng trộn', 9, 'Trà sữa trân châu đường đen', 0.1820, 0.8840, 2.75, 'Bánh tráng cay the đi cùng Trà sữa béo ngọt - Cặp đôi quốc dân!'),
(4, 'Phô mai que', 13, 'Trà đào truyền thống', 0.1120, 0.7950, 2.12, 'Phô mai béo ngậy uống cùng Trà đào thanh mát không lo ngấy!'),
(29, 'Tokbokki cay ngọt', 114, 'Trà sữa ô long', 0.0980, 0.8240, 2.45, 'Ăn món cay Hàn Quốc giải cay ngay bằng Trà sữa Ô long nướng!'),
(3, 'Khoai tây chiên', 2, 'Xúc xích nướng', 0.1340, 0.7680, 2.05, 'Combo ăn vặt xế chiều trọn vị: Khoai tây & Xúc xích nướng than!'),
(32, 'Mì trộn cay', 12, 'Nước ép cam tươi', 0.0890, 0.8120, 2.68, 'Ăn mì no nê bổ sung thêm Vitamin C tươi mát từ Cam sành!');

-- 12. CHÈN TÀI KHOẢN HỆ THỐNG
INSERT INTO users (username, password, full_name, role, phone) VALUES
('admin', '123456', 'Nguyễn Huỳnh Anh Tuấn (Chủ quán & Dev)', 'ADMIN', '0901234567'),
('thungan', '123456', 'Nhân Viên Thu Ngân POS', 'STAFF', '0902345678'),
('bep', '123456', 'Bộ Phận Bếp & Pha Chế (KDS Real-time)', 'KITCHEN', '0903456789');

-- 13. CHÈN CA LÀM VIỆC & LỊCH CHẤM CÔNG SINH VIÊN
INSERT INTO shifts (shift_name, start_time, end_time, hourly_rate) VALUES
('Ca sáng', '07:30:00', '12:30:00', 25000),
('Ca chiều', '12:30:00', '17:30:00', 25000),
('Ca tối', '17:30:00', '22:30:00', 28000);

INSERT INTO work_schedules (user_id, shift_id, work_date, check_in, check_out, total_hours, salary_earned, status) VALUES
(2, 1, CURRENT_DATE, CURRENT_DATE + TIME '07:28:00', CURRENT_DATE + TIME '12:32:00', 5.0, 125000, 'COMPLETED'),
(3, 2, CURRENT_DATE, CURRENT_DATE + TIME '12:30:00', NULL, 0, 0, 'WORKING');

-- 14. CHÈN SỔ CHI TIÊU HÀNG NGÀY (EXPENSES)
INSERT INTO expenses (title, category, amount, note, date) VALUES
('Mua 5 bao đá bi giao ca sáng', 'NGUYEN_LIEU', 100000, 'Đá bi sạch pha trà', CURRENT_DATE),
('Mua 10 lốc sữa đặc Ngôi Sao Phương Nam', 'NGUYEN_LIEU', 350000, 'Đại lý sỉ giao', CURRENT_DATE),
('Mua 1000 ly nhựa PP 500ml và màng dập', 'VAT_TU', 450000, 'Kho bao bì Thuận Phát', CURRENT_DATE),
('Nạp tiền điện chiếu sáng quán', 'DIEN_NUOC', 300000, 'Hóa đơn EVN định kỳ', CURRENT_DATE);

-- 15. CHÈN ĐƠN HÀNG THỰC TẾ TRÊN HỆ THỐNG
INSERT INTO orders (id, order_code, table_number, total_amount, voucher_code, discount_percent, discount_amount, final_amount, payment_method, payment_status, status, customer_notes) VALUES
(1, 'CC-20261004-0001', 'Bàn 05', 73000, 'CHOUX10', 10, 7300, 65700, 'VIETQR', 'PAID', 'PREPARING', 'Bàn 05: 1 trà sữa ít đường, 1 cá viên sốt đậm'),
(2, 'CC-20261004-0002', 'Bàn 02', 45000, NULL, 0, 0, 45000, 'CASH', 'UNPAID', 'PENDING', 'Khách xin thêm ớt cay'),
(3, 'CC-20261004-0003', 'Bàn 01', 98000, 'CHOUX15', 15, 14700, 83300, 'VIETQR', 'PAID', 'COMPLETED', 'Đơn hoàn thành thanh toán qua Napas VietQR');

SELECT setval(pg_get_serial_sequence('orders', 'id'), COALESCE((SELECT MAX(id) FROM orders), 1));

INSERT INTO order_items (id, order_id, product_id, product_name, size, sugar, ice, quantity, unit_price, subtotal, note) VALUES
(1, 1, 9, 'Trà sữa trân châu đường đen', 'L', '50%', '70% đá', 1, 35000, 35000, 'Ít ngọt nhiều trân châu'),
(2, 1, 1, 'Cá viên chiên', 'M', '100%', '0%', 1, 15000, 15000, 'Chiên giòn rụm'),
(3, 1, 4, 'Phô mai que', 'M', '100%', '0%', 1, 20000, 20000, 'Kéo sợi nóng hổi'),
(4, 2, 29, 'Tokbokki cay ngọt', 'M', '100%', '0%', 1, 28000, 28000, 'Thêm chả cá'),
(5, 2, 13, 'Trà đào truyền thống', 'M', '100%', '100% đá', 1, 28000, 28000, 'Nhiều đào giòn'),
(6, 3, 206, 'Trà tắc khổng lồ', 'L', '100%', '100% đá', 2, 25000, 50000, 'Ly 1 lít siêu to'),
(7, 3, 7, 'Bánh tráng trộn', 'M', '100%', '0%', 2, 15000, 30000, 'Nhiều khô bò cay');

SELECT setval(pg_get_serial_sequence('order_items', 'id'), COALESCE((SELECT MAX(id) FROM order_items), 1));

INSERT INTO order_item_toppings (order_item_id, topping_name, price) VALUES
(1, 'Trân châu đen dẻo', 5000),
(1, 'Kem Cheese Macchiato', 10000);

-- ====================================================================
-- PHẦN 5: CÁC DATABASE VIEWS HỖ TRỢ PHÂN TÍCH DOANH THU & KHO
-- ====================================================================

-- 1. VIEW BÁO CÁO LỢI NHUẬN RÒNG HÀNG NGÀY: Lợi nhuận = Doanh thu - Chi phí
CREATE OR REPLACE VIEW v_net_profit_summary AS
SELECT 
    CURRENT_DATE AS report_date,
    COALESCE((SELECT SUM(final_amount) FROM orders WHERE DATE(created_at) = CURRENT_DATE AND payment_status = 'PAID'), 0) AS daily_revenue,
    COALESCE((SELECT SUM(amount) FROM expenses WHERE date = CURRENT_DATE), 0) AS daily_expenses,
    (COALESCE((SELECT SUM(final_amount) FROM orders WHERE DATE(created_at) = CURRENT_DATE AND payment_status = 'PAID'), 0) -
     COALESCE((SELECT SUM(amount) FROM expenses WHERE date = CURRENT_DATE), 0)) AS net_profit;

-- 2. VIEW CẢNH BÁO NGUYÊN LIỆU TRONG KHO SẮP HẾT
CREATE OR REPLACE VIEW v_inventory_alert AS
SELECT 
    id AS ingredient_id,
    name AS ingredient_name,
    category,
    current_stock,
    minimum_stock,
    unit,
    (minimum_stock - current_stock) AS shortage_amount,
    supplier
FROM ingredients
WHERE current_stock <= minimum_stock
ORDER BY (current_stock / NULLIF(minimum_stock, 0)) ASC;

-- 3. VIEW TOP MÓN ĂN VẶT & NƯỚC UỐNG BÁN CHẠY NHẤT
CREATE OR REPLACE VIEW v_top_selling_products AS
SELECT 
    p.id,
    p.name,
    c.name AS category_name,
    p.base_price,
    p.sold_count,
    (p.sold_count * p.base_price) AS estimated_revenue,
    p.rating
FROM products p
JOIN categories c ON p.category_code = c.code
ORDER BY p.sold_count DESC
LIMIT 10;

-- ====================================================================
-- PHẦN 6: TRIGGER TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI BÀN KHI CÓ ĐƠN HÀNG
-- ====================================================================
CREATE OR REPLACE FUNCTION fn_update_table_status_on_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('PENDING', 'PREPARING', 'SERVED') THEN
        UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_number = NEW.table_number;
    ELSIF NEW.status IN ('COMPLETED', 'CANCELLED') THEN
        -- Kiểm tra xem còn đơn nào khác đang ăn tại bàn này không
        IF NOT EXISTS (SELECT 1 FROM orders WHERE table_number = NEW.table_number AND status IN ('PENDING', 'PREPARING', 'SERVED') AND id <> NEW.id) THEN
            UPDATE dining_tables SET status = 'AVAILABLE' WHERE table_number = NEW.table_number;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_order_status_sync_table ON orders;
CREATE TRIGGER trg_order_status_sync_table
AFTER INSERT OR UPDATE OF status ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_update_table_status_on_order();

-- =========================================================================================
-- HOÀN TẤT THIẾT KẾ CƠ SỞ DỮ LIỆU ĐỒ SỘ CHUẨN DOANH NGHIỆP TRÊN PGADMIN 4!
-- BẢNG: 19 BẢNG QUAN HỆ TOÀN VẸN | DỮ LIỆU: 93 MÓN ĂN CHUẨN APP + TOÀN BỘ DANH MỤC & KHO
-- =========================================================================================
