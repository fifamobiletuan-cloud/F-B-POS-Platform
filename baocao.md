# BÁO CÁO ĐỀ CƯƠNG ĐỀ TÀI CHUYÊN ĐỀ CÔNG NGHỆ THÔNG TIN
*(Định hướng nghiên cứu và phát triển thành Đồ án Tốt nghiệp)*

---

* **Tên đề tài (Tiếng Việt):** Ứng dụng gọi món tại bàn bằng mã QR và hệ thống quản lý vận hành quán trà sữa
* **Tên đề tài (Tiếng Anh):** Smart F&B POS & Contactless Table-Ordering Platform
* **Sinh viên thực hiện:** Nguyễn Huỳnh Anh Tuấn
* **Lớp:** S26K65CNTT
* **Ngành học:** Công nghệ thông tin / Kỹ thuật phần mềm
* **Năm học:** 2025 - 2026
* **Tài liệu Word đính kèm:** [📄 NguyenHuynhAnhTuan_S26K65CNTT.docx](NguyenHuynhAnhTuan_S26K65CNTT.docx)

---

## PHẦN 1. LÝ DO CHỌN ĐỀ TÀI VÀ MỤC TIÊU THỰC HIỆN

### 1.1. Khảo sát thực tế từ đời sống
Hiện nay, mô hình kinh doanh quán trà sữa, trà trái cây và các món ăn vặt xung quanh các trường đại học, khu ký túc xá phát triển rất nhanh để phục vụ nhu cầu học tập, gặp gỡ của sinh viên. Xuất phát từ chính trải nghiệm của bản thân khi đi uống nước và quan sát tại các quán quen, em nhận thấy quy trình phục vụ tại hầu hết các quán quy mô vừa và nhỏ hiện nay vẫn còn gặp nhiều bất cập:

1. **Áp lực phục vụ vào khung giờ cao điểm:** Vào các buổi tối (khoảng 19h đến 21h) hoặc dịp cuối tuần, lượng khách tập trung cùng một thời điểm rất đông. Khách vào quán thường phải đứng xếp hàng dài chờ đến lượt order tại quầy, hoặc khi đã vào bàn thì phải chờ đợi lâu nhân viên mới mang thực đơn ra ghi món, gây cảm giác sốt ruột và trải nghiệm không thoải mái.

2. **Đặc thù món trà sữa phức tạp, dễ xảy ra nhầm lẫn:** Trà sữa có rất nhiều tùy chỉnh riêng cho từng ly: chọn size M hay size L, chọn mức đường (0%, 30%, 50%, 70%, 100%), chọn mức đá (nóng, không đá, ít đá, bình thường) và hơn 10 loại topping đi kèm (trân châu đen, thạch củ năng, pudding trứng, thạch phô mai). Khi khách gọi món bằng lời nói hoặc nhân viên ghi tay trên giấy nháp lúc quán đông, việc nhớ nhầm hoặc pha chế sai topping xảy ra thường xuyên, dẫn đến việc phải làm lại ly mới, lãng phí nguyên liệu và mất thời gian của khách.

3. **Khó khăn trong việc kiểm soát chi phí thực tế:** Hầu hết các chủ quán nhỏ hiện nay chỉ theo dõi tổng số tiền thu về qua tài khoản ngân hàng hoặc tiền mặt, nhưng lại thiếu công cụ ghi chép các khoản chi tiêu nhỏ lẻ hằng ngày (tiền nhập trà, sữa đặc, đá lạnh, ly nhựa, ống hút, tiền sửa máy dập nắp...). Do không tổng hợp được chi phí, chủ quán không nắm được bức tranh tài chính chính xác và không xác định được lợi nhuận thực tế sau khi trừ đi chi phí phát sinh.

4. **Công tác phân ca và chấm công nhân viên còn thủ công:** Lực lượng nhân sự tại các quán trà sữa chủ yếu là sinh viên làm bán thời gian (Part-time), thường xuyên thay đổi ca học và xin đổi ca làm việc cho nhau. Việc theo dõi ca làm qua bảng viết tay hoặc tin nhắn nhóm Zalo thường dẫn đến nhầm lẫn, thiếu ca trực hoặc tính sai giờ làm khi chốt lương vào cuối tháng.

### 1.2. Giải pháp đề xuất
Để giải quyết trực tiếp các vấn đề thực tiễn trên, em đề xuất xây dựng một hệ thống gồm hai ứng dụng cụ thể:

* **Ứng dụng Web gọi món tại bàn dành cho khách hàng (Flutter Web):** Khách vào quán ngồi tại bàn nào thì mở camera điện thoại quét mã QR dán trên bàn đó. Trình duyệt trên điện thoại sẽ tự động mở trang thực đơn đúng số bàn của khách mà không cần cài đặt thêm bất kỳ ứng dụng nào vào máy. Khách có thể tự do xem ảnh món, chọn lượng đường, đá, chọn topping theo ý thích và bấm gửi đơn hàng trực tiếp về quầy pha chế, hoặc chọn quét mã VietQR để thanh toán luôn.
* **Ứng dụng di động dành riêng cho cửa hàng (Flutter Mobile App):** Được cài đặt trên điện thoại hoặc máy tính bảng của nhân viên và chủ quán để: nhận đơn từ bàn khách gửi về theo thời gian thực; quản lý sơ đồ bàn xem bàn nào đang có khách; ghi lại các khoản chi tiêu mua sắm hàng ngày; xem thống kê doanh thu - chi phí - lợi nhuận và theo dõi lịch xếp ca cũng như chấm công của nhân viên.

### 1.3. Mục tiêu và phạm vi đề tài
* **Về mặt ứng dụng:** Cung cấp giải pháp phần mềm khép kín từ lúc khách bước vào quán gọi món cho đến khi đơn hàng hoàn thành và được thống kê vào doanh số, góp phần tối ưu nhân công phục vụ và giảm thiểu sai sót pha chế.
* **Về mặt kỹ thuật:** Vận dụng kiến thức chuyên ngành để thiết kế hệ thống theo mô hình Client-Server chuẩn mực; xây dựng Backend RESTful API an toàn, ổn định với Java Spring Boot và cơ sở dữ liệu PostgreSQL; đồng thời khai thác thế mạnh Cross-platform của Flutter để phát triển cả Web và Mobile App từ một cơ sở mã nguồn duy nhất.
* **Phạm vi:** Nghiệp vụ áp dụng cho mô hình quán trà sữa - đồ ăn vặt quy mô vừa và nhỏ (khoảng 10 - 15 bàn, 20 - 30 món ăn uống và 3 - 5 nhân viên).

---

## PHẦN 2. KIẾN TRÚC KỸ THUẬT VÀ CÔNG NGHỆ LỰA CHỌN

### 2.1. Lý do lựa chọn công nghệ
Dựa trên định hướng nghề nghiệp sau khi ra trường theo mảng Phát triển ứng dụng di động (Mobile App) và Lập trình Backend Java, em lựa chọn kiến trúc công nghệ như sau:

* **Giao diện người dùng (Frontend):** Sử dụng Flutter với ngôn ngữ Dart. Điểm mạnh lớn nhất của Flutter là khả năng viết một lần nhưng chạy được trên nhiều nền tảng (Single Codebase). Cụ thể, em sử dụng Flutter Web để làm trang gọi món cho khách (khách quét QR mở ngay trên trình duyệt mà không phải tải app nặng máy) và Flutter Mobile để đóng gói thành ứng dụng Android/iOS cài lên điện thoại của nhân viên và chủ quán.
* **Phía máy chủ (Backend):** Sử dụng Java 17 và nền tảng Spring Boot 3.x để viết các RESTful API. Spring Boot có cấu trúc phân tầng rõ ràng, khả năng xử lý đồng thời tốt và hệ sinh thái thư viện hỗ trợ doanh nghiệp phong phú.
* **Cơ sở dữ liệu và Tầng ORM:** Sử dụng PostgreSQL kết hợp Spring Data JPA và Hibernate. Vì hệ thống liên quan trực tiếp đến hóa đơn, ghi nhận chi phí và tính lương, em chọn PostgreSQL để đảm bảo tính toàn vẹn dữ liệu (chuẩn ACID). Tầng Hibernate giúp ánh xạ trực tiếp các bảng dữ liệu thành các Class Java (Entity), giúp thao tác dữ liệu an toàn và hạn chế tối đa việc viết SQL thủ công.
* **Bảo mật và Phân quyền:** Sử dụng Spring Security kết hợp JSON Web Token (JWT) và OAuth2. Hệ thống áp dụng cơ chế Stateless Session. Phân quyền người dùng được chia thành các nhóm rõ ràng: khách hàng quét QR chỉ được phép xem thực đơn và gửi đơn; nhân viên (`ROLE_STAFF`) được xem màn hình pha chế và chấm công; chủ quán (`ROLE_ADMIN`) mới có quyền xem doanh thu, ghi chi tiêu và quản lý thực đơn.
* **Kiểm thử và Quản lý mã nguồn:** Sử dụng Postman để kiểm tra tính đúng đắn của từng API trước khi ghép nối vào ứng dụng; sử dụng Git và GitHub để quản lý phiên bản mã nguồn theo từng nhánh tính năng.

### 2.2. Bảng tổng hợp các công nghệ sử dụng

| Thành phần hệ thống | Công nghệ lựa chọn | Mục đích sử dụng cụ thể |
| :--- | :--- | :--- |
| **Ứng dụng Khách hàng** | Flutter Web (Dart) | Trang web mở nhanh qua mã QR để khách tự chọn món tại bàn |
| **Ứng dụng Cửa hàng** | Flutter Mobile (Dart) | App cài trên điện thoại nhân viên và chủ quán để quản lý |
| **Backend Service** | Java 17, Spring Boot 3.x | Xử lý logic nghiệp vụ, tính tiền, phân quyền và cung cấp REST API |
| **Cơ sở dữ liệu** | PostgreSQL 16 | Lưu trữ dữ liệu bàn ăn, thực đơn, đơn hàng, thu chi và ca làm |
| **Tầng ánh xạ ORM** | Spring Data JPA / Hibernate | Ánh xạ CSDL sang đối tượng Java, quản lý giao dịch an toàn |
| **Bảo mật & Phân quyền**| Spring Security + JWT | Xác thực tài khoản và phân quyền truy cập theo vai trò |
| **Giao thức truyền nhận**| HTTPS, JSON | Chuẩn trao đổi dữ liệu gọn nhẹ, tương thích tốt giữa Flutter và Spring Boot |
| **Kiểm thử & Mã nguồn** | Postman, Git / GitHub | Kiểm thử API tự động và quản lý lịch sử viết mã nguồn |

---

## PHẦN 3. ĐẶC TẢ CÁC CHỨC NĂNG CỦA HỆ THỐNG

### 3.1. Phân hệ Web dành cho Khách hàng (Quét QR tại bàn)
Khách hàng vào quán chỉ sử dụng điện thoại thông minh quét mã QR dán trên bàn, với các chức năng cụ thể:

1. **Nhận diện vị trí bàn:** Khách quét mã QR có chứa đường link kèm mã nhận diện bàn (ví dụ: `.../?table=B05`). Hệ thống tự động xác định khách đang ngồi bàn số 5 và gắn mã bàn này vào đơn hàng.
2. **Xem thực đơn và chọn món:** Thực đơn hiển thị hình ảnh, tên món, giá tiền và phân loại rõ ràng (Trà sữa, Trà hoa quả, Đồ ăn vặt). Khách có thể tìm kiếm món theo tên.
3. **Tùy chọn chi tiết từng ly (Customization):** Khi bấm vào một ly trà sữa, giao diện sẽ cho phép khách chọn kích cỡ (Size M mặc định, Size L +6.000đ); chọn mức độ ngọt theo phần trăm (0%, 30%, 50%, 70%, 100%); chọn lượng đá (nóng, không đá, ít đá, bình thường) và chọn thêm các loại topping như trân châu đen, thạch phô mai, pudding. Tiền topping sẽ tự động cộng dồn vào giá của ly đó.
4. **Giỏ hàng và Đặt món:** Khách kiểm tra lại danh sách các ly đã chọn cùng các ghi chú kèm theo. Sau khi xác nhận, đơn hàng được gửi thẳng về hệ thống của quán.
5. **Thanh toán:** Khách có thể chọn quét mã VietQR để chuyển khoản thanh toán với nội dung và số tiền đã được tạo sẵn tự động, hoặc chọn thanh toán tiền mặt tại quầy khi ra về.
6. **Theo dõi trạng thái:** Khách có thể nhìn thấy đồ uống của mình đang ở bước nào: Đã nhận đơn -> Đang pha chế -> Đã hoàn thành.

### 3.2. Phân hệ Ứng dụng Di động dành cho Cửa hàng
Ứng dụng dành cho nhân viên và chủ quán được tổ chức thành 5 màn hình chức năng rõ ràng:

1. **Màn hình quầy pha chế (Bếp):** Khi có bàn gửi đơn, màn hình của nhân viên pha chế sẽ lập tức hiện đơn mới theo đúng số bàn, kèm chi tiết từng ly (ví dụ: Bàn 02 - 1 Trà sữa Ô long size L, 50% đường, thêm trân châu trắng). Nhân viên pha xong ly nào hoặc bàn nào thì chạm vào nút để chuyển trạng thái sang Đã hoàn thành.
2. **Màn hình quản lý sơ đồ bàn:** Giao diện trực quan hiển thị danh sách các bàn trong quán kèm màu sắc nhận biết: bàn màu xanh là bàn trống, bàn màu đỏ là bàn đang có khách ngồi và đang dùng đồ. Nhân viên có thể hỗ trợ khách đổi bàn hoặc tách gộp bàn khi cần thiết.
3. **Quản lý chi tiêu hàng ngày của quán:** Cho phép người quản lý hoặc nhân viên được ủy quyền nhập nhanh các khoản tiền chi ra trong ngày: mua nguyên liệu (sữa, trà, trân châu), mua vật dụng (ly nhựa, màng ép, ống hút), tiền điện nước hoặc tiền đá lạnh mua lẻ ngoài đại lý. Ứng dụng hỗ trợ chụp lại ảnh hóa đơn mua hàng để lưu trữ làm bằng chứng đối soát.
4. **Báo cáo doanh số và lợi nhuận:** Hệ thống tự động tổng hợp số tiền bán được trong ngày, tuần, tháng; đồng thời trừ đi các khoản chi phí đã nhập ở trên để đưa ra con số lợi nhuận thực tế. Chủ quán cũng xem được danh sách các món bán chạy nhất để biết xu hướng khách thích uống món gì.
5. **Quản lý ca làm việc và chấm công nhân viên:** Chủ quán tạo trước các ca làm việc chuẩn của quán (Ca sáng: 7h30 - 12h30, Ca chiều: 12h30 - 17h30, Ca tối: 17h30 - 22h30) và phân công lịch làm cho nhân viên theo từng tuần. Nhân viên khi đến quán làm việc chỉ cần mở app bấm 'Vào ca' và bấm 'Hết ca' khi tan làm. Cuối tháng, hệ thống tự cộng tổng số giờ làm việc thực tế của từng bạn để tính lương chính xác.

---

## PHẦN 4. THIẾT KẾ CƠ SỞ DỮ LIỆU VÀ REST API

### 4.1. Thiết kế Cơ sở dữ liệu (PostgreSQL)
Cơ sở dữ liệu được thiết kế gồm 12 bảng chính, được liên kết chặt chẽ qua khóa ngoại và ràng buộc toàn vẹn dữ liệu:

| Tên bảng (Entity) | Các cột chính | Mô tả nội dung lưu trữ |
| :--- | :--- | :--- |
| `users` | id, username, password, full_name, phone, role_id | Thông tin tài khoản của nhân viên và chủ quán |
| `roles` | id, name (`ROLE_ADMIN`, `ROLE_STAFF`) | Bảng định nghĩa quyền hạn truy cập |
| `dining_tables` | id, table_number, qr_token, status | Danh sách các bàn trong quán và mã token của mã QR |
| `categories` | id, name, display_order | Phân loại món: Trà sữa, Trà hoa quả, Đồ ăn vặt |
| `products` | id, category_id, name, base_price, image_url, is_active | Danh mục các món ăn và đồ uống của quán |
| `product_options` | id, name, option_type, additional_price | Các lựa chọn đi kèm: Size, Đường, Đá, Topping |
| `orders` | id, table_id, total_amount, payment_method, status, created_at | Thông tin đơn hàng, số tiền và trạng thái xử lý |
| `order_items` | id, order_id, product_id, quantity, unit_price | Danh sách các món được gọi trong một đơn hàng |
| `order_item_options` | id, order_item_id, product_option_id, price | Các tùy chọn đường, đá, topping đi kèm từng món |
| `expenses` | id, title, amount, category, invoice_image, created_by | Các phiếu ghi chép chi tiêu tiền mặt hàng ngày |
| `shifts` | id, shift_name, start_time, end_time, hourly_rate | Danh mục ca làm việc mẫu và mức lương mỗi giờ |
| `work_schedules` | id, user_id, shift_id, work_date, check_in, check_out | Lịch xếp ca và dữ liệu chấm công của nhân viên |

### 4.2. Danh sách các RESTful API chính (Spring Boot)

| Phương thức | Đường dẫn API (Endpoint) | Chức năng thực hiện | Quyền truy cập |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/login` | Đăng nhập tài khoản, trả về mã xác thực JWT | Mọi người |
| `GET` | `/api/v1/customer/tables/{token}` | Đọc mã QR, trả về số bàn tương ứng | Khách tại bàn |
| `GET` | `/api/v1/customer/menu` | Lấy toàn bộ thực đơn kèm danh sách topping | Khách tại bàn |
| `POST` | `/api/v1/customer/orders` | Gửi đơn gọi món của bàn về hệ thống | Khách tại bàn |
| `GET` | `/api/v1/staff/orders` | Lấy danh sách các đơn hàng cần pha chế | Nhân viên, Quản lý |
| `PATCH` | `/api/v1/staff/orders/{id}` | Đổi trạng thái món sang đang làm hoặc đã xong | Nhân viên, Quản lý |
| `POST` | `/api/v1/expenses` | Tạo phiếu ghi chép một khoản chi tiêu mới | Nhân viên, Quản lý |
| `POST` | `/api/v1/shifts/check-in` | Nhân viên bấm chấm công vào ca làm việc | Nhân viên |
| `GET` | `/api/v1/reports/profit` | Lấy báo cáo doanh thu, chi phí và lợi nhuận | Chỉ Quản lý (Admin) |

---

## PHẦN 5. KẾ HOẠCH TRIỂN KHAI VÀ HƯỚNG PHÁT TRIỂN

### 5.1. Kế hoạch thực hiện trong môn Chuyên đề CNTT
Trong phạm vi môn Chuyên đề CNTT của học kỳ này, mục tiêu trọng tâm là hoàn thành sản phẩm cơ bản có thể chạy thực tế được (MVP), bao gồm:
* **Giai đoạn 1 (3 tuần đầu):** Hoàn thành đề cương chi tiết, khảo sát lại thực tế quy trình tại quán trà sữa mẫu; thiết kế chi tiết các bảng trong CSDL PostgreSQL và tạo các Entity Java tương ứng bằng Spring Data JPA.
* **Giai đoạn 2 (3 tuần tiếp theo):** Viết xong toàn bộ các API Backend bằng Spring Boot cho phần bàn ăn, thực đơn, tạo đơn hàng, ghi chi tiêu và chấm công. Cài đặt bảo mật Spring Security và JWT. Kiểm tra kỹ lưỡng các API trên Postman để bảo đảm không có lỗi logic.
* **Giai đoạn 3 (3 tuần cuối):** Xây dựng giao diện Flutter Web cho khách quét QR đặt món và giao diện Flutter App cho quán nhận đơn và chấm công; sau đó tiến hành ghép nối API, kiểm thử và viết báo cáo tổng kết môn học.

### 5.2. Hướng mở rộng phát triển thành Đồ án Tốt nghiệp
Sau khi hoàn thành môn Chuyên đề CNTT, bước sang kỳ làm Đồ án Tốt nghiệp, em sẽ tiếp tục đào sâu kỹ thuật và hoàn thiện hệ thống với các tính năng nâng cao:
* **Tích hợp WebSocket:** Khi khách tại bàn bấm gửi đơn hàng, màn hình quầy pha chế sẽ tự động rung chuông và hiển thị món mới ngay lập tức mà nhân viên không cần phải bấm làm mới (F5) ứng dụng.
* **Kết nối thanh toán tự động:** Tích hợp dịch vụ ngân hàng để khi khách chuyển khoản qua mã VietQR, hệ thống sẽ tự động nhận diện tiền đã vào tài khoản và tự động xác nhận đơn hàng thành công.
* **In hóa đơn trực tiếp:** Kết nối ứng dụng Flutter với máy in nhiệt tại quầy qua mạng LAN hoặc Bluetooth để in phiếu gọi món cho quầy pha chế và in hóa đơn thanh toán cho khách.
* **Đóng gói và triển khai:** Tìm hiểu cách đóng gói hệ thống bằng Docker và đưa ứng dụng lên máy chủ đám mây (Cloud Server) để chạy thử nghiệm thực tế.

### 5.3. Tài liệu tham khảo chính
1. Tài liệu hướng dẫn chính thức của Spring Boot 3: https://docs.spring.io/spring-boot/docs/current/reference/html/
2. Tài liệu phát triển ứng dụng đa nền tảng Flutter & Dart: https://docs.flutter.dev/
3. Hướng dẫn quản trị và thiết kế cơ sở dữ liệu PostgreSQL 16: https://www.postgresql.org/docs/16/
4. Sách *Spring in Action* (Tác giả Craig Walls, Nhà xuất bản Manning Publications).
5. Giáo trình môn Lập trình mạng và Phát triển ứng dụng trên thiết bị di động của trường.
