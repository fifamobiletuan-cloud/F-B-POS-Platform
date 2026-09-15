# ỨNG DỤNG GỌI MÓN TẠI BÀN BẰNG MÃ QR VÀ HỆ THỐNG QUẢN LÝ VẬN HÀNH QUÁN TRÀ SỮA
### Smart F&B POS & Contactless Table-Ordering Platform

---

## 📌 THÔNG TIN ĐỀ TÀI
* **Đề tài:** Báo cáo đề cương Chuyên đề Công nghệ thông tin (Định hướng Đồ án Tốt nghiệp)
* **Sinh viên thực hiện:** Nguyễn Huỳnh Anh Tuấn
* **Lớp:** S26K65CNTT
* **Chuyên ngành:** Công nghệ thông tin / Kỹ thuật phần mềm
* **Năm học:** 2025 - 2026
* **Tài liệu báo cáo chi tiết:** [📄 NguyenHuynhAnhTuan_S26K65CNTT.docx](NguyenHuynhAnhTuan_S26K65CNTT.docx)

---

## 📖 GIỚI THIỆU TỔNG QUAN

Đề tài xuất phát từ bài toán thực tế tại các quán trà sữa, đồ uống và đồ ăn vặt:
1. **Khách hàng:** Vào giờ cao điểm thường phải xếp hàng chờ gọi món lâu; món trà sữa có nhiều tùy biến phức tạp (size, % đường, % đá, nhiều loại topping) nên ghi chép tay rất dễ nhầm lẫn.
2. **Cửa hàng:** Chủ quán khó kiểm soát các khoản chi tiêu lặt vặt hàng ngày (mua nguyên liệu, đá lạnh, ly nhựa), khó tính toán chính xác lợi nhuận thực tế và việc theo dõi xếp ca, chấm công cho nhân viên part-time còn thủ công.

### Giải pháp xây dựng gồm 2 phân hệ chính:
* **Ứng dụng Web Khách hàng (Flutter Web):** Khách ngồi tại bàn quét mã QR để mở thực đơn trực tiếp trên trình duyệt điện thoại (không cần cài app), tự do tùy chỉnh ly trà sữa (chọn đường, đá, topping), gửi đơn về quầy và hỗ trợ thanh toán qua VietQR.
* **Ứng dụng Mobile Cửa hàng (Flutter Mobile):** Cài trên điện thoại/máy tính bảng của quán để: nhận đơn pha chế theo thời gian thực, quản lý sơ đồ bàn, ghi chép phiếu chi tiêu hàng ngày, xem báo cáo doanh thu - lợi nhuận và quản lý lịch ca làm việc kèm chấm công nhân viên.

---

## 🛠 CÔNG NGHỆ ÁP DỤNG (TECH STACK)

| Thành phần | Công nghệ sử dụng | Mô tả chức năng |
| :--- | :--- | :--- |
| **Frontend Web** | Flutter Web (Ngôn ngữ Dart) | Giao diện khách quét QR gọi món nhanh trên trình duyệt |
| **Frontend Mobile** | Flutter Mobile App (Dart) | Ứng dụng cài đặt cho nhân viên và quản lý cửa hàng |
| **Backend REST API** | Java 17, Spring Boot 3.x | Xử lý logic nghiệp vụ, tính toán đơn hàng và cung cấp API |
| **Cơ sở dữ liệu** | PostgreSQL 16 | Lưu trữ dữ liệu quan hệ (bàn ăn, món, đơn hàng, thu chi, ca làm) |
| **Tầng ORM** | Spring Data JPA, Hibernate | Ánh xạ thực thể CSDL sang Java Entity, quản lý giao dịch |
| **Bảo mật & Phân quyền**| Spring Security, JWT | Xác thực tài khoản và phân quyền người dùng (Admin, Staff, Customer) |
| **Giao thức truyền nhận**| HTTPS, Định dạng JSON | Chuẩn trao đổi dữ liệu giữa Flutter và Spring Boot |
| **Kiểm thử & Mã nguồn** | Postman, Git / GitHub | Kiểm thử API tự động và quản lý phiên bản mã nguồn |

---

## 📋 CÁC PHÂN HỆ VÀ TÍNH NĂNG CHÍNH

### 1. Phân hệ Khách hàng (Quét QR tại bàn)
* Tự động nhận diện số bàn qua mã QR.
* Xem thực đơn phân loại rõ ràng (Trà sữa, Trà trái cây, Đồ ăn vặt).
* Tùy biến chi tiết từng món: Size (M/L), Mức đường (0% - 100%), Mức đá, Chọn nhiều Topping đi kèm.
* Giỏ hàng, kiểm tra lại đơn và gửi order về quầy.
* Hỗ trợ thanh toán VietQR tự động hoặc thanh toán tiền mặt tại quầy.
* Theo dõi trạng thái đồ uống: *Đã nhận đơn $\rightarrow$ Đang pha chế $\rightarrow$ Đã hoàn thành*.

### 2. Phân hệ Cửa hàng (App Quản lý)
* **Quầy pha chế (Bếp):** Nhận thông báo đơn mới theo số bàn, hiển thị chi tiết topping từng ly, bấm hoàn thành khi làm xong.
* **Quản lý Bàn & Hóa đơn:** Sơ đồ bàn trực quan (bàn trống / đang có khách), hỗ trợ đổi bàn, gộp bàn, thanh toán.
* **Quản lý Chi tiêu:** Nhập nhanh các khoản chi mua nguyên liệu, vật tư, điện nước; hỗ trợ chụp ảnh hóa đơn lưu trữ đối soát.
* **Báo cáo Doanh số & Lợi nhuận:** Thống kê doanh thu theo ngày/tháng, tự động tính $\text{Lợi nhuận} = \text{Doanh thu} - \text{Chi phí}$, thống kê top món bán chạy.
* **Quản lý Ca làm việc & Chấm công:** Cấu hình ca làm chuẩn (Sáng/Chiều/Tối), xếp lịch làm việc tuần, nhân viên bấm Check-in / Check-out trên app, tự động tổng hợp giờ công cuối tháng để tính lương.

---

## 🗄 THIẾT KẾ CƠ SỞ DỮ LIỆU (12 BẢNG THỰC THỂ)
* `users`: Tài khoản nhân viên và chủ quán
* `roles`: Bảng phân quyền (`ROLE_ADMIN`, `ROLE_STAFF`)
* `dining_tables`: Danh sách bàn và mã token QR bàn
* `categories`: Phân loại nhóm món (Trà sữa, Trà trái cây, Ăn vặt)
* `products`: Danh mục các món đồ uống, đồ ăn
* `product_options`: Các tùy chọn Size, Đường, Đá và Topping
* `orders`: Đơn hàng theo bàn và trạng thái xử lý
* `order_items`: Chi tiết từng món trong đơn
* `order_item_options`: Tùy chọn đường/đá/topping của từng ly
* `expenses`: Phiếu ghi chép chi tiêu tiền mặt hàng ngày
* `shifts`: Danh mục ca làm việc chuẩn của quán
* `work_schedules`: Lịch phân ca và dữ liệu chấm công thực tế

---

## 🚀 KẾ HOẠCH TRIỂN KHAI 2 GIAI ĐOẠN

* **Giai đoạn 1 (Chuyên đề CNTT):** Xây dựng hoàn thiện CSDL PostgreSQL, viết trọn bộ RESTful API trên Spring Boot, cấu hình bảo mật Spring Security + JWT, kiểm thử 100% trên Postman; xây dựng giao diện Flutter Web gọi món và Flutter App nhận đơn, ghi chi tiêu, chấm công cơ bản (MVP).
* **Giai đoạn 2 (Đồ án Tốt nghiệp):** Nâng cấp thông báo đơn tức thì qua WebSocket, tích hợp tự động xác nhận chuyển khoản VietQR qua Webhook, kết nối máy in nhiệt Bluetooth/LAN để in hóa đơn tại quầy, đóng gói Docker và triển khai Cloud.

---

*Chi tiết toàn bộ đề cương báo cáo vui lòng xem tại file Word đính kèm:* [NguyenHuynhAnhTuan_S26K65CNTT.docx](NguyenHuynhAnhTuan_S26K65CNTT.docx)
