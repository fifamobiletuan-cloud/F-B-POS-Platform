# BÁO CÁO ĐỀ XUẤT ĐỀ TÀI CHUYÊN ĐỀ CÔNG NGHỆ THÔNG TIN
**(Định hướng phát triển và hoàn thiện thành Đồ án Tốt nghiệp)**

---

* **Tên đề tài (Tiếng Việt):** Xây dựng hệ sinh thái ứng dụng gọi món tại bàn qua mã QR và quản lý vận hành quán trà sữa - đồ ăn vặt
* **Tên đề tài (Tiếng Anh):** Smart F&B POS & Contactless Table-Ordering Platform
* **Sinh viên thực hiện:** Nguyễn Huỳnh Anh Tuấn
* **Lớp:** S26K65CNTT
* **Giảng viên hướng dẫn:** [Họ và tên Thầy/Cô]
* **Thời gian thực hiện:** 2026
* **File báo cáo Word đính kèm:** [📄 NguyenHuynhAnhTuan_S26K65CNTT.docx](NguyenHuynhAnhTuan_S26K65CNTT.docx)

---

## MỤC LỤC
1. [LÝ DO CHỌN ĐỀ TÀI & TÍNH CẤP THIẾT](#1-lý-do-chọn-đề-tài--tính-cấp-thiết)
2. [MỤC TIÊU VÀ PHẠM VI CỦA ĐỀ TÀI](#2-mục-tiêu-và-phạm-vi-của-đề-tài)
3. [KIẾN TRÚC HỆ THỐNG VÀ CÔNG NGHỆ ÁP DỤNG](#3-kiến-trúc-hệ-thống-và-công-nghệ-áp-dụng)
4. [PHÂN TÍCH YÊU CẦU CHỨC NĂNG CHI TIẾT](#4-phân-tích-yêu-cầu-chức-năng-chi-tiết)
5. [THIẾT KẾ CƠ SỞ DỮ LIỆU (POSTGRESQL & JPA HIBERNATE)](#5-thiết-kế-cơ-sở-dữ-liệu-postgresql--jpa-hibernate)
6. [ĐẶC TẢ HỆ THỐNG REST API (JAVA SPRING BOOT)](#6-đặc-tả-hệ-thống-rest-api-java-spring-boot)
7. [BẢO MẬT VÀ PHÂN QUYỀN (SPRING SECURITY & OAUTH2/JWT)](#7-bảo-mật-và-phân-quyền-spring-security--oauth2jwt)
8. [QUY TRÌNH PHÁT TRIỂN, KIỂM THỬ VÀ QUẢN LÝ MÃ NGUỒN](#8-quy-trình-phát-triển-kiểm-thử-và-quản-lý-mã-nguồn)
9. [KẾ HOẠCH VÀ LỘ TRÌNH TRIỂN KHAI 2 GIAI ĐOẠN](#9-kế-hoạch-và-lộ-trình-triển-khai-2-giai-đoạn)
10. [TÀI LIỆU THAM KHẢO](#10-tài-liệu-tham-khảo)

---

## 1. LÝ DO CHỌN ĐỀ TÀI & TÍNH CẤP THIẾT

### 1.1. Bối cảnh thực tiễn
Ngành F&B (Food & Beverage), đặc biệt là mô hình quán trà sữa và đồ ăn vặt dành cho giới trẻ, đang phát triển rất mạnh mẽ. Tuy nhiên, các quán quy mô vừa và nhỏ tại Việt Nam hiện đang gặp phải những bài toán vận hành nan giải:
* **Ùn tắc và chờ đợi giờ cao điểm:** Khách phải xếp hàng dài tại quầy thu ngân để chờ gọi món, hoặc ngồi tại bàn phải vẫy gọi nhân viên nhiều lần.
* **Đặc thù tùy biến phức tạp dẫn đến sai sót:** Món trà sữa có vô số tùy chọn đi kèm: *Size (M/L), Mức đường (0%, 30%, 50%, 70%, 100%), Mức đá (Nóng, Không đá, 50% đá, Bình thường), và hàng chục loại Topping (Trân châu đen, Trân châu trắng, Thạch nha đam, Pudding trứng, Phô mai tươi...)*. Việc nhân viên ghi chép tay hoặc truyền đạt qua lời nói rất dễ nhầm lẫn, dẫn đến hủy món, lãng phí nguyên liệu và mất lòng khách hàng.
* **Thất thoát chi phí và tài chính lỏng lẻo:** Các chủ quán thường chỉ kiểm soát tiền thu vào, thiếu công cụ ghi chép chi phí hàng ngày (mua nguyên vật liệu phát sinh, tiền đá lạnh, ly nhựa, ống hút, điện nước). Do đó, chủ quán không tính toán được lợi nhuận thực tế (Doanh thu trừ Chi phí).
* **Quản lý ca làm việc rời rạc:** Nhân viên quán đa số là sinh viên làm bán thời gian (Part-time), giờ giấc xoay ca liên tục. Việc chấm công và xếp ca trên sổ sách hoặc Excel rất mất thời gian và dễ nhầm lẫn khi tính lương.

### 1.2. Giải pháp của đề tài
Xây dựng một hệ sinh thái đồng bộ gồm:
1. **Web App gọi món tại bàn (Flutter Web):** Khách hàng quét mã QR trên bàn, lập tức mở menu trực quan trên trình duyệt di động mà **không cần cài đặt ứng dụng**, tự chọn món theo ý thích và gửi đơn/thanh toán ngay.
2. **Mobile App cho cửa hàng (Flutter Mobile):** Dành riêng cho nhân viên và chủ quán trên điện thoại/máy tính bảng để: nhận đơn pha chế tức thì, quản lý hóa đơn/bàn, ghi chép chi tiêu, thống kê doanh số - lợi nhuận và quản lý ca làm việc của nhân viên.

---

## 2. MỤC TIÊU VÀ PHẠM VI CỦA ĐỀ TÀI

### 2.1. Mục tiêu đề tài
* **Mục tiêu kỹ thuật:** Xây dựng hệ thống hoàn chỉnh theo đúng chuẩn doanh nghiệp: Backend RESTful API mạnh mẽ với **Java Spring Boot**, hệ quản trị CSDL quan hệ **PostgreSQL**, tầng ánh xạ **Spring Data JPA/Hibernate**, bảo mật **Spring Security + OAuth2/JWT**, và ứng dụng đa nền tảng bằng **Flutter (Dart)**.
* **Mục tiêu nghiệp vụ:** Tự động hóa 100% quy trình từ khâu gọi món tại bàn đến khâu pha chế, quản trị tài chính thu-chi và phân ca nhân sự.

### 2.2. Đối tượng sử dụng và phạm vi
* **Khách hàng tại quán:** Sử dụng trình duyệt smartphone quét mã QR đặt món, chọn topping, theo dõi trạng thái đơn và thanh toán.
* **Nhân viên pha chế / Thu ngân:** Sử dụng Mobile App để xem danh sách món cần làm theo bàn, cập nhật trạng thái làm món, quản lý trạng thái bàn ăn, in hóa đơn.
* **Chủ quán (Quản trị viên):** Sử dụng Mobile App để quản lý thực đơn, cấu hình mã QR bàn, ghi chép các khoản chi tiêu, xem báo cáo doanh thu - lợi nhuận, phân ca và theo dõi chấm công nhân viên.

---

## 3. KIẾN TRÚC HỆ THỐNG VÀ CÔNG NGHỆ ÁP DỤNG

Hệ thống được thiết kế theo mô hình kiến trúc đa tầng (**Multi-Tier Client-Server Architecture**) tách biệt rõ ràng giữa Presentation Layer, Business Logic Layer và Data Persistence Layer.

```
+-----------------------------------------------------------------------------------+
|                                 PRESENTATION LAYER                                |
|                                (Flutter SDK - Dart)                               |
|                                                                                   |
|      [Ứng dụng Web Khách hàng (PWA)]           [Mobile App Quản lý Cửa hàng]      |
|         (Flutter Web Engine)                      (Android / iOS App)             |
|    - Quét mã QR theo bàn                     - Màn hình quầy pha chế              |
|    - Tùy chỉnh trà sữa, topping              - Quản lý hóa đơn & trạng thái bàn   |
|    - Đặt món & Thanh toán VietQR             - Quản lý chi tiêu, ca làm, doanh số |
+-----------------------------------------+-----------------------------------------+
                                          |
                        Giao thức: HTTPS / Payload: JSON
                                          |
+-----------------------------------------v-----------------------------------------+
|                                BUSINESS LOGIC LAYER                               |
|                         (Java Spring Boot REST API Service)                       |
|                                                                                   |
|  [Spring Security Filter Chain]  ---> Kiểm tra Token JWT & Phân quyền RBAC        |
|  [REST Controllers]              ---> Tiếp nhận Request, Validate dữ liệu         |
|  [Service Implementations]       ---> Xử lý nghiệp vụ logic (Order, Shift, Report)|
|  [Data Access Layer (JPA/DAO)]   ---> Tầng truy vấn và ánh xạ dữ liệu             |
+-----------------------------------------+-----------------------------------------+
                                          |
                        Spring Data JPA / Hibernate ORM
                                          |
+-----------------------------------------v-----------------------------------------+
|                                DATA STORAGE LAYER                                 |
|                               (PostgreSQL Database)                               |
|                                                                                   |
|  Tables: users, roles, dining_tables, categories, products, product_options,      |
|          orders, order_items, order_item_options, expenses, shifts, work_schedules|
+-----------------------------------------------------------------------------------+
```

### Danh mục công nghệ chi tiết:
* **Frontend:** Flutter framework, ngôn ngữ **Dart**.
  * Sử dụng giải pháp *Single Codebase* biên dịch ra Flutter Web (cho khách) và Flutter Mobile APK (cho quán).
  * Quản lý trạng thái (State Management): **Provider** hoặc **Bloc/Cubit**.
* **Backend:** **Java 17/21 + Spring Boot 3.x**.
  * Kiến trúc RESTful API, chuẩn hóa Response theo `ResponseEntity<ApiResponse<T>>`.
* **Cơ sở dữ liệu:** **PostgreSQL 16**.
  * Hỗ trợ toàn vẹn dữ liệu ACID, kiểu dữ liệu linh hoạt, hiệu năng cao.
* **Tầng ánh xạ ORM:** **Spring Data JPA & Hibernate**.
  * Tự động hóa sinh câu lệnh SQL, quản lý Transaction `@Transactional`, quan hệ `@OneToMany`, `@ManyToOne`, `@ManyToMany`.
* **Bảo mật:** **Spring Security + OAuth2 / JSON Web Token (JWT)**.
  * Cơ chế xác thực không trạng thái (Stateless Session).
* **Định dạng dữ liệu:** HTTP/HTTPS, định dạng **JSON**.
* **Kiểm thử API:** **Postman** (Tạo Mock, Environment, Test Suite tự động).
* **Quản lý mã nguồn:** **Git** trên nền tảng **GitHub / GitLab** (Áp dụng chuẩn Git Flow).

---

## 4. PHÂN TÍCH YÊU CẦU CHỨC NĂNG CHI TIẾT

### 4.1. Phân hệ 1: Web App Khách hàng (Flutter Web)
1. **Nhận diện bàn qua mã QR:** Khách quét QR chứa URL dạng `https://domain.vn/?table=B05` $\rightarrow$ Web tự động khóa cố định mã bàn `B05` cho phiên đặt món.
2. **Khám phá thực đơn:**
   * Phân chia theo nhóm: Trà sữa truyền thống, Trà trái cây, Trà sữa Machiato, Đồ ăn vặt (bánh tráng, khô bò, cá viên...).
   * Tìm kiếm món, xem chi tiết hình ảnh, mô tả nguyên liệu.
3. **Tùy biến món trà sữa (Customization):**
   * Chọn Size: Size M (+0đ), Size L (+6.000đ).
   * Chọn Mức đường: 0%, 30%, 50%, 70%, 100%.
   * Chọn Mức đá: Nóng, 0% đá, 50% đá, 100% đá.
   * Chọn Topping: Chọn nhiều topping cùng lúc (Trân châu đen, Thạch phô mai, Pudding...).
   * Ghi chú cho pha chế (ví dụ: "Ít ngọt nhiều đá giùm em").
4. **Giỏ hàng & Đặt hàng:**
   * Xem lại toàn bộ danh sách món và các tùy biến đã chọn.
   * Tính tổng tiền tự động kèm chi tiết phụ thu topping.
   * Xác nhận gửi order về quầy.
5. **Thanh toán tại bàn:**
   * Hỗ trợ hiển thị mã **VietQR động** (tự động điền đúng số tiền và nội dung bàn `B05`).
   * Tùy chọn thanh toán tiền mặt tại quầy khi rời quán.
6. **Theo dõi trạng thái đơn hàng:** Màn hình tự động cập nhật: *Chờ xác nhận $\rightarrow$ Đang pha chế $\rightarrow$ Đã phục vụ*.

---

### 4.2. Phân hệ 2: Mobile App Cửa hàng (Flutter Mobile)

#### A. Màn hình Pha chế & Phục vụ (Kitchen Display System - KDS)
* Nhận đơn tức thì theo số bàn khi khách gửi về.
* Hiển thị chi tiết từng ly (Size, Đường, Đá, Topping đi kèm).
* Thao tác 1 chạm để chuyển trạng thái: *Tiếp nhận $\rightarrow$ Đang làm $\rightarrow$ Hoàn thành*.

#### B. Quản lý Bàn ăn & Hóa đơn (Table & Billing Management)
* Sơ đồ trực quan: Màu xanh (Bàn trống), Màu đỏ (Bàn đang có khách), Màu vàng (Bàn đang chờ đồ uống).
* Xem tổng hóa đơn của từng bàn, tách/gộp bàn.
* Xác nhận thanh toán, hoàn tất đơn và đưa bàn về trạng thái trống.

#### C. Quản lý Chi tiêu Cửa hàng (Expense Management)
* Cho phép chủ quán và nhân viên ghi chép các khoản tiền chi ra trong ngày:
  * Chi nhập nguyên liệu: Trà, sữa đặc, siro, trân châu.
  * Chi vật phẩm tiêu hao: Ly nhựa, ống hút, màng dập nắp, túi chữ T, khăn giấy.
  * Chi vận hành: Tiền điện nước, tiền đá lạnh mua ngoài, phí sửa máy pha trà.
* Đính kèm ảnh chụp hóa đơn mua hàng (chụp trực tiếp từ camera).
* Báo cáo phân loại chi phí theo danh mục.

#### D. Báo cáo Doanh số & Lợi nhuận (Revenue & Profit Analytics)
* Thống kê tổng doanh thu theo ngày, tuần, tháng.
* Thống kê tổng chi phí theo thời gian tương ứng.
* **Tính toán lợi nhuận ròng:** $\text{Lợi nhuận} = \text{Tổng doanh thu} - \text{Tổng chi phí}$.
* Biểu đồ trực quan: Top món bán chạy nhất (Best-sellers), khung giờ cao điểm trong ngày.

#### E. Quản lý Ca làm việc & Chấm công (Staff Shifts & Attendance)
* **Thiết lập danh mục ca làm:** Ca sáng (07:30 - 12:30), Ca chiều (12:30 - 17:30), Ca tối (17:30 - 22:30).
* **Xếp lịch làm việc:** Chủ quán phân công ca làm việc trong tuần cho nhân viên theo từng ngày.
* **Chấm công nhân viên:** Nhân viên mở app bấm "Vào ca" (Check-in) và "Hết ca" (Check-out).
* **Bảng tổng hợp công:** Tự động tính tổng số giờ làm và số công trong tháng của từng nhân viên để phục vụ tính lương.

---

## 5. THIẾT KẾ CƠ SỞ DỮ LIỆU (POSTGRESQL & JPA HIBERNATE)

Hệ thống thiết kế chuẩn hóa mức 3NF, gồm 12 bảng thực thể chính:

```
[roles] 1---n [user_roles] n---1 [users]
                                   | 1
                                   |--- n [work_schedules] n --- 1 [shifts]
                                   |--- n [expenses]
                                   |--- n [orders]
                                            |
[dining_tables] 1---------------------------|
                                            | 1
                                            |--- n [order_items] n --- 1 [products] n --- 1 [categories]
                                                       | 1
                                                       |--- n [order_item_options] n --- 1 [product_options]
```

### Chi tiết các bảng thực thể:
1. **`users`**: `id` (PK), `username`, `password` (BCrypt), `full_name`, `phone`, `avatar_url`, `is_active`, `created_at`.
2. **`roles`**: `id` (PK), `name` (`ROLE_ADMIN`, `ROLE_STAFF`).
3. **`user_roles`**: `user_id` (FK), `role_id` (FK).
4. **`dining_tables`**: `id` (PK), `table_number` (Vd: Bàn 01), `qr_code_token` (UUID độc nhất), `status` (`EMPTY`, `OCCUPIED`), `created_at`.
5. **`categories`**: `id` (PK), `name` (Trà sữa, Đồ ăn vặt), `icon_url`, `display_order`.
6. **`products`**: `id` (PK), `category_id` (FK), `name`, `base_price`, `image_url`, `description`, `is_available`.
7. **`product_options`**: `id` (PK), `name` (Size L, 50% Đường, Trân châu đen...), `option_type` (`SIZE`, `SUGAR`, `ICE`, `TOPPING`), `additional_price`.
8. **`orders`**: `id` (PK), `table_id` (FK), `created_by_user_id` (FK, nullable), `total_amount`, `payment_method` (`CASH`, `VIETQR`), `payment_status` (`UNPAID`, `PAID`), `order_status` (`PENDING`, `PREPARING`, `COMPLETED`, `CANCELLED`), `note`, `created_at`.
9. **`order_items`**: `id` (PK), `order_id` (FK), `product_id` (FK), `quantity`, `unit_price`, `subtotal`.
10. **`order_item_options`**: `id` (PK), `order_item_id` (FK), `product_option_id` (FK), `additional_price`.
11. **`expenses`**: `id` (PK), `title` (Mua sữa đặc Ông Thọ), `amount`, `category` (`INGREDIENT`, `UTILITY`, `PACKAGING`, `OTHER`), `invoice_image_url`, `created_by` (FK -> users), `created_at`.
12. **`shifts`**: `id` (PK), `shift_name` (Ca Sáng, Ca Chiều, Ca Tối), `start_time` (TIME), `end_time` (TIME), `hourly_rate` (Tiền lương/giờ).
13. **`work_schedules`**: `id` (PK), `user_id` (FK), `shift_id` (FK), `work_date` (DATE), `check_in_time` (TIMESTAMP), `check_out_time` (TIMESTAMP), `status` (`SCHEDULED`, `ATTENDED`, `ABSENT`).

---

## 6. ĐẶC TẢ HỆ THỐNG REST API (JAVA SPRING BOOT)

### 6.1. Nhóm API Xác thực & Tài khoản (`/api/v1/auth`)
* `POST /api/v1/auth/login`: Xác thực đăng nhập qua username/password, trả về JWT Token và thông tin User Role.
* `POST /api/v1/auth/refresh-token`: Cấp lại Access Token mới từ Refresh Token.

### 6.2. Nhóm API Khách hàng gọi món tại bàn (`/api/v1/customer`)
* `GET /api/v1/customer/tables/{qr_token}`: Xác minh mã QR và lấy thông tin bàn ăn tương ứng.
* `GET /api/v1/customer/menu`: Lấy toàn bộ danh mục, món ăn kèm các tùy chọn (size, topping).
* `POST /api/v1/customer/orders`: Gửi giỏ hàng đặt món (kèm mã bàn và chi tiết topping/đường/đá).
* `GET /api/v1/customer/orders/{orderId}/status`: Khách theo dõi tiến độ làm đồ uống.

### 6.3. Nhóm API Vận hành & Quản lý bếp (`/api/v1/staff`)
* `GET /api/v1/staff/orders`: Lấy danh sách đơn cần pha chế theo thời gian thực.
* `PATCH /api/v1/staff/orders/{id}/status`: Đổi trạng thái đơn (*PREPARING*, *COMPLETED*).
* `GET /api/v1/staff/tables`: Lấy trạng thái tất cả các bàn ăn trong quán.
* `POST /api/v1/staff/orders/{id}/checkout`: Xác nhận thanh toán hóa đơn.

### 6.4. Nhóm API Quản lý Chi tiêu (`/api/v1/expenses`)
* `GET /api/v1/expenses`: Xem danh sách phiếu chi (lọc theo ngày, theo danh mục).
* `POST /api/v1/expenses`: Tạo phiếu chi tiêu mới (nhập tiền, lý do, upload hóa đơn).
* `DELETE /api/v1/expenses/{id}`: Xóa phiếu chi (chỉ quyền Admin).

### 6.5. Nhóm API Ca làm & Chấm công (`/api/v1/shifts`)
* `GET /api/v1/shifts`: Danh sách các ca làm chuẩn của quán.
* `GET /api/v1/shifts/schedules`: Lấy lịch phân ca trong tuần của toàn bộ nhân viên.
* `POST /api/v1/shifts/schedules`: Xếp ca làm việc cho nhân viên.
* `POST /api/v1/shifts/check-in`: Nhân viên bấm check-in vào ca.
* `POST /api/v1/shifts/check-out`: Nhân viên bấm check-out kết thúc ca.

### 6.6. Nhóm API Thống kê & Báo cáo (`/api/v1/reports`)
* `GET /api/v1/reports/revenue`: Báo cáo doanh thu theo mốc thời gian.
* `GET /api/v1/reports/profit-loss`: Báo cáo Lợi nhuận (Doanh thu trừ Chi phí).
* `GET /api/v1/reports/top-products`: Danh sách các món trà sữa/đồ ăn bán chạy nhất.

---

## 7. BẢO MẬT VÀ PHÂN QUYỀN (SPRING SECURITY & OAUTH2/JWT)

* **Kiến trúc bảo mật Stateless:** Backend không lưu trữ Session trên server; mọi request từ Mobile App đều gửi kèm Header `Authorization: Bearer <jwt_token>`.
* **Mã hóa mật khẩu:** Sử dụng thuật toán `BCryptPasswordEncoder` với độ dài muối an toàn.
* **Phân quyền theo vai trò (RBAC - Role-Based Access Control):**
  * **Công khai (Public):** API quét QR, xem menu, tạo đơn gọi món tại bàn (dành cho khách hàng dùng Web).
  * **ROLE_STAFF:** Tiếp cận màn hình bếp/pha chế, xem danh sách bàn, đổi trạng thái đơn, thực hiện chấm công ca làm của chính mình.
  * **ROLE_ADMIN (Chủ quán):** Toàn quyền truy cập: Quản lý thực đơn & giá, xem và tạo phiếu chi tiêu, xếp lịch làm việc cho nhân viên, xem báo cáo doanh thu - lợi nhuận.

---

## 8. QUY TRÌNH PHÁT TRIỂN, KIỂM THỬ VÀ QUẢN LÝ MÃ NGUỒN

1. **Kiểm thử API với Postman:**
   * Xây dựng bộ `Postman Collection` bao phủ 100% các API Endpoints.
   * Cấu hình Environment Variables (`{{base_url}}`, `{{bearer_token}}`).
   * Viết Test Script tự động kiểm tra Status Code (`pm.response.to.have.status(200)`), cấu trúc JSON Schema và thời gian phản hồi (< 500ms).
2. **Quản lý mã nguồn với GitHub / GitLab:**
   * Áp dụng quy chuẩn **Git Flow**:
     * Nhánh `main`: Mã nguồn phiên bản ổn định (Release).
     * Nhánh `develop`: Tích hợp các tính năng đang phát triển.
     * Các nhánh `feature/auth`, `feature/order`, `feature/expense`, `feature/shift`: Phát triển riêng lẻ từng tính năng.
   * Commit message rõ ràng theo quy ước Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`).

---

## 9. KẾ HOẠCH VÀ LỘ TRÌNH TRIỂN KHAI 2 GIAI ĐOẠN

### Giai đoạn 1: Môn Chuyên đề Công nghệ Thông tin (Học kỳ hiện tại)
* **Tuần 1 - 2:** Hoàn thiện đề cương, khảo sát thực tế quán trà sữa, thiết kế sơ đồ CSDL PostgreSQL và ERD.
* **Tuần 3 - 5:** 
  * Cài đặt Spring Boot, cấu hình Spring Data JPA, Hibernate Entities.
  * Xây dựng tầng REST Controller & Service cho: Bàn ăn, Menu, Topping, Đơn hàng, Phiếu chi và Ca làm.
  * Cấu hình Spring Security + JWT phân quyền.
  * Viết tài liệu và kiểm thử API hoàn chỉnh trên Postman.
* **Tuần 6 - 8:**
  * Xây dựng **Flutter Web**: Giao diện quét QR bàn, Menu chọn món, chọn size/topping/đường/đá, Giỏ hàng và Đặt món.
  * Xây dựng **Flutter Mobile App**: Màn hình nhận đơn bếp, màn hình ghi chép chi tiêu và màn hình chấm công ca làm.
* **Tuần 9:** Kiểm thử tích hợp toàn diện hệ thống (End-to-End), viết báo cáo tổng kết môn Chuyên đề CNTT.

### Giai đoạn 2: Phát triển lên Đồ án Tốt nghiệp (Học kỳ tới)
* **Nâng cấp Realtime WebSockets:** Sử dụng Spring WebSocket (STOMP protocol) để đơn hàng từ bàn khách nhảy thông báo và rung chuông tức thì trên App pha chế mà không cần reload.
* **Tích hợp thanh toán tự động VietQR:** Tự động bắt Webhook ngân hàng/cổng thanh toán để tự động xác nhận đơn đã trả tiền.
* **In hóa đơn nhiệt:** Tích hợp SDK in bill trực tiếp qua máy in nhiệt Bluetooth/mạng LAN.
* **Triển khai Cloud & DevOps:** Đóng gói Docker Container cho Backend và PostgreSQL, triển khai hệ thống lên máy chủ Cloud (VPS/AWS/GCP), triển khai Web App lên Firebase Hosting/Vercel.

---

## 10. TÀI LIỆU THAM KHẢO

1. **Spring Boot Reference Documentation (v3.x)** - *https://docs.spring.io/spring-boot/docs/current/reference/html/*
2. **Spring Security & OAuth2 JWT Architecture** - *https://spring.io/guides/tutorials/spring-boot-oauth2/*
3. **Flutter Documentation:** *Multi-Platform Development with Flutter (Mobile & Web)* - *https://docs.flutter.dev/*
4. **PostgreSQL 16 Documentation:** *Relational Database Design and Constraints* - *https://www.postgresql.org/docs/16/*
5. **Hibernate ORM User Guide:** *JPA Entity Mapping and Performance Optimization* - *https://hibernate.org/orm/documentation/*
6. **Robert C. Martin:** *Clean Architecture: A Craftsman's Guide to Software Structure and Design*.
