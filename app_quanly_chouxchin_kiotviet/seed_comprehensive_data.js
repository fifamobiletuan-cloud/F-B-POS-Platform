const { Pool } = require('pg');

const pool = new Pool({
    host: '127.0.0.1',
    port: 5432,
    database: 'milktea_pos_db',
    user: 'postgres',
    password: '123456'
});

async function seed() {
    try {
        console.log('=== 1. NÂNG CẤP BẢNG EMPLOYEES & WORK_SCHEDULES ===');
        await pool.query(`
            ALTER TABLE employees ADD COLUMN IF NOT EXISTS salary_type_desc VARCHAR(50) DEFAULT 'Theo giờ làm việc';
            ALTER TABLE employees ADD COLUMN IF NOT EXISTS total_salary NUMERIC(12, 2) DEFAULT 0;
            ALTER TABLE work_schedules ADD COLUMN IF NOT EXISTS is_late BOOLEAN DEFAULT false;
            ALTER TABLE work_schedules ADD COLUMN IF NOT EXISTS is_early_leave BOOLEAN DEFAULT false;
            ALTER TABLE work_schedules ADD COLUMN IF NOT EXISTS is_overtime BOOLEAN DEFAULT false;
        `);

        // Cập nhật danh sách nhân viên chuẩn xác theo Ảnh 4 & Ảnh 5
        const employeesData = [
            { code: 'NV001', name: 'Lã Ngọc Anh', pos: 'Quản lý cửa hàng', type: 'FIXED', typeDesc: 'Cố định', rate: 0, salary: 8100000, shift: 1, phone: '0901111222', status: 'ACTIVE' },
            { code: 'NV002', name: 'Lê Thị Bảo Trân', pos: 'Thu ngân & Phục vụ', type: 'HOURLY', typeDesc: 'Theo giờ làm việc', rate: 25000, salary: 385000, shift: 1, phone: '0902345678', status: 'ACTIVE' },
            { code: 'NV003', name: 'Nguyễn Minh Loan', pos: 'Bếp & Đồ ăn vặt', type: 'DAILY', typeDesc: 'Theo ngày công chuẩn', rate: 280000, salary: 280000, shift: 2, phone: '0904567890', status: 'ACTIVE' },
            { code: 'NV004', name: 'Trần Văn Bình', pos: 'Phục vụ bàn', type: 'HOURLY', typeDesc: 'Theo giờ làm việc', rate: 24000, salary: 264000, shift: 3, phone: '0908888999', status: 'ACTIVE' },
            { code: 'NV005', name: 'Hoàng Văn Long', pos: 'Pha chế Trà sữa', type: 'DAILY', typeDesc: 'Theo ngày công chuẩn', rate: 260000, salary: 260000, shift: 2, phone: '0905555666', status: 'ACTIVE' },
            { code: 'NV006', name: 'Nguyễn Thị Hồng Thảo Vân', pos: 'Pha chế Trà sữa', type: 'HOURLY', typeDesc: 'Theo giờ làm việc', rate: 25000, salary: 245000, shift: 2, phone: '0903456789', status: 'ACTIVE' },
            { code: 'NV007', name: 'Nguyễn Huỳnh Anh Tuấn', pos: 'Chủ quán & Dev', type: 'FIXED', typeDesc: 'Cố định', rate: 0, salary: 785000, shift: 1, phone: '0901234567', status: 'ACTIVE' }
        ];

        for (const e of employeesData) {
            await pool.query(`
                INSERT INTO employees (employee_code, full_name, position, salary_type, salary_type_desc, salary_rate, total_salary, shift_id, phone, status, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
                ON CONFLICT (employee_code) DO UPDATE
                SET full_name = EXCLUDED.full_name,
                    position = EXCLUDED.position,
                    salary_type = EXCLUDED.salary_type,
                    salary_type_desc = EXCLUDED.salary_type_desc,
                    salary_rate = EXCLUDED.salary_rate,
                    total_salary = EXCLUDED.total_salary,
                    shift_id = EXCLUDED.shift_id,
                    phone = EXCLUDED.phone,
                    status = EXCLUDED.status,
                    updated_at = NOW();
            `, [e.code, e.name, e.pos, e.type, e.typeDesc, e.rate, e.salary, e.shift, e.phone, e.status]);
        }
        console.log('✓ Đã cập nhật 7 nhân viên khớp chính xác Ảnh 4 và Ảnh 5.');

        // Cập nhật work_schedules ngày hôm nay khớp Ảnh 5:
        // Đi làm: 7, Nghỉ làm: 0, Chờ duyệt: 1, Đi muộn: 1, Về sớm: 1, Làm thêm: 2
        // Top nhân viên làm nhiều giờ:
        // 1. Lê Thị Bảo Trân (9 giờ 30 phút)
        // 2. Nguyễn Thị Hồng Thảo Vân (7 giờ 45 phút)
        // 3. Nguyễn Minh Loan (6 giờ 33 phút)
        await pool.query(`DELETE FROM work_schedules WHERE work_date = CURRENT_DATE`);
        
        const empRows = (await pool.query(`SELECT id, employee_code, full_name FROM employees ORDER BY id`)).rows;
        const empMap = {};
        empRows.forEach(r => empMap[r.employee_code] = r.id);

        const todaySchedules = [
            { empId: empMap['NV002'], hours: 9.5, late: false, early: false, overtime: true, status: 'COMPLETED' }, // Lê Thị Bảo Trân (9h30, làm thêm)
            { empId: empMap['NV006'], hours: 7.75, late: true, early: false, overtime: false, status: 'COMPLETED' }, // Thảo Vân (7h45, đi muộn 1)
            { empId: empMap['NV003'], hours: 6.55, late: false, early: true, overtime: false, status: 'COMPLETED' }, // Minh Loan (6h33, về sớm 1)
            { empId: empMap['NV001'], hours: 8.5, late: false, early: false, overtime: true, status: 'WORKING' }, // Lã Ngọc Anh (làm thêm)
            { empId: empMap['NV004'], hours: 5.5, late: false, early: false, overtime: false, status: 'WORKING' }, // Bình
            { empId: empMap['NV005'], hours: 5.0, late: false, early: false, overtime: false, status: 'WORKING' }, // Long
            { empId: empMap['NV007'], hours: 6.0, late: false, early: false, overtime: false, status: 'WORKING' }  // Tuấn
        ];

        for (const s of todaySchedules) {
            if (!s.empId) continue;
            await pool.query(`
                INSERT INTO work_schedules (employee_id, shift_id, work_date, total_hours, is_late, is_early_leave, is_overtime, status)
                VALUES ($1, 1, CURRENT_DATE, $2, $3, $4, $5, $6)
            `, [s.empId, s.hours, s.late, s.early, s.overtime, s.status]);
        }
        console.log('✓ Đã cập nhật chấm công hôm nay khớp số liệu Ảnh 5.');

        console.log('=== 2. TẠO CƠ SỞ DỮ LIỆU ĐƠN HÀNG ĐA DẠNG (HÔM NAY, HÔM QUA, 7 NGÀY, THÁNG NÀY, THÁNG TRƯỚC) ===');
        
        // Lấy danh sách 93 món ăn vặt & trà sữa thật trong CSDL
        const allProds = (await pool.query(`SELECT id, name, category_code, base_price FROM products ORDER BY id`)).rows;
        if (allProds.length === 0) {
            console.warn('Không có món ăn nào trong database!');
            return;
        }

        // Kiểm tra xem đã có đơn hàng chưa, nếu ít hơn 20 đơn thì tạo thêm các đơn mẫu thực tế
        const orderCount = Number((await pool.query(`SELECT COUNT(*) FROM orders`)).rows[0]?.count || 0);
        console.log(`Số đơn hàng hiện tại: ${orderCount}`);

        // Tạo dữ liệu cho 5 mốc thời gian:
        // - Hôm nay: 4 đơn (3 hoàn thành, 1 đang làm)
        // - Hôm qua: 5 đơn
        // - 7 ngày qua: 18 đơn
        // - Tháng này: 35 đơn
        // - Tháng trước: 25 đơn
        const now = new Date();
        const tables = ['Bàn 01', 'Bàn 02', 'Bàn 03', 'Bàn 04', 'Bàn 05', 'Bàn 06', 'Bàn 07', 'Bàn 08', 'Bàn 09', 'Bàn 10', 'Bàn 11', 'Bàn 12'];
        const paymentMethods = ['TIEN_MAT', 'VIETQR', 'TIEN_MAT', 'VIETQR'];

        // Hàm hỗ trợ tạo đơn
        async function createMockOrder(daysAgo, hourOffset, tableNum, prodIndices, status = 'COMPLETED') {
            const date = new Date(now.getTime() - daysAgo * 24 * 60 * 60 * 1000);
            date.setHours(hourOffset, Math.floor(Math.random() * 50) + 5, 0);

            const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
            const rand = Math.floor(1000 + Math.random() * 9000);
            const orderCode = `CC-${dateStr}-${rand}`;

            let total = 0;
            const items = [];
            for (const idx of prodIndices) {
                const prod = allProds[idx % allProds.length];
                const qty = Math.floor(Math.random() * 2) + 1;
                const unitPrice = Number(prod.base_price || 25000);
                const subtotal = unitPrice * qty;
                total += subtotal;
                items.push({ prod, qty, unitPrice, subtotal });
            }

            const pMethod = paymentMethods[Math.floor(Math.random() * paymentMethods.length)];
            const pStatus = status === 'COMPLETED' ? 'PAID' : (status === 'PREPARING' ? 'PAID' : 'UNPAID');

            const orderRes = await pool.query(`
                INSERT INTO orders (order_code, table_number, total_amount, discount_percent, discount_amount, final_amount, payment_method, payment_status, status, customer_notes, created_at, updated_at)
                VALUES ($1, $2, $3, 0, 0, $3, $4, $5, $6, 'Khách gọi món qua QR', $7, $7)
                RETURNING id
            `, [orderCode, tableNum, total, pMethod, pStatus, status, date]);

            const orderId = orderRes.rows[0].id;

            for (const it of items) {
                await pool.query(`
                    INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal)
                    VALUES ($1, $2, $3, $4, $5, $6)
                `, [orderId, it.prod.id, it.prod.name, it.qty, it.unitPrice, it.subtotal]);
            }
        }

        // Nếu database chưa đủ đơn thì tạo bộ đơn phong phú
        if (orderCount < 25) {
            console.log('Đang tạo thêm các đơn hàng mẫu phong phú cho 5 mốc thời gian...');
            
            // 1. Hôm nay (Day 0)
            await createMockOrder(0, 9, 'Bàn 01', [0, 2]); // Cá viên chiên + Phô mai que
            await createMockOrder(0, 11, 'Bàn 03', [20, 21]); // Trà sữa + Trà đào
            await createMockOrder(0, 14, 'Bàn 07', [6, 12, 1]); // Bánh tráng trộn + Tokbokki + Cá viên
            await createMockOrder(0, 18, 'Bàn 05', [25, 26], 'PREPARING'); // Bàn 05 đang phục vụ

            // 2. Hôm qua (Day 1)
            await createMockOrder(1, 10, 'Bàn 02', [1, 22]);
            await createMockOrder(1, 13, 'Bàn 04', [7, 8, 23]);
            await createMockOrder(1, 16, 'Bàn 06', [3, 20]);
            await createMockOrder(1, 19, 'Bàn 08', [2, 10, 24]);
            await createMockOrder(1, 20, 'Bàn 10', [0, 5, 21]);

            // 3. 7 ngày qua (Days 2 to 6)
            for (let d = 2; d <= 6; d++) {
                await createMockOrder(d, 8 + (d % 4) * 3, tables[d], [d * 2, d * 2 + 1]);
                await createMockOrder(d, 18 + (d % 3), tables[(d + 3) % 12], [d * 3, 20]);
                await createMockOrder(d, 20, tables[(d + 5) % 12], [d, d + 2, 22]);
            }

            // 4. Tháng này (Days 7 to 25)
            for (let d = 7; d <= 25; d += 2) {
                await createMockOrder(d, 12, tables[d % 12], [d % 15, (d + 4) % 15]);
                await createMockOrder(d, 19, tables[(d + 2) % 12], [20 + (d % 5), 1]);
            }

            // 5. Tháng trước (Days 32 to 55)
            for (let d = 32; d <= 55; d += 3) {
                await createMockOrder(d, 11, tables[d % 12], [(d * 3) % 20, 21]);
                await createMockOrder(d, 18, tables[(d + 4) % 12], [(d * 2) % 15, 2]);
            }

            console.log('✓ Đã tạo thành công bộ đơn hàng đa dạng bao quát 5 mốc thời gian!');
        }

        // Cập nhật trạng thái bàn ăn (đảm bảo Bàn 05 đang OCCUPIED có khách phục vụ)
        await pool.query(`UPDATE dining_tables SET status = 'AVAILABLE'`);
        await pool.query(`UPDATE dining_tables SET status = 'OCCUPIED' WHERE table_number IN ('Bàn 02', 'Bàn 05')`);
        console.log('✓ Đã cập nhật trạng thái bàn ăn thực tế (Bàn 02 và Bàn 05 có khách).');

        await pool.end();
        console.log('=== HOÀN TẤT SEED DỮ LIỆU CSDL THỰC TẾ ===');
    } catch (err) {
        console.error('Lỗi seed dữ liệu:', err);
        process.exit(1);
    }
}

seed();
