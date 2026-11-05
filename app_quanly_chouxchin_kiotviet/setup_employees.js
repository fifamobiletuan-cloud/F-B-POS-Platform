const { Pool } = require('pg');

const pool = new Pool({
    host: '127.0.0.1',
    port: 5432,
    database: 'milktea_pos_db',
    user: 'postgres',
    password: '123456'
});

async function run() {
    try {
        console.log('--- KHỞI TẠO BẢNG EMPLOYEES TRONG POSTGRESQL ---');
        await pool.query(`
            CREATE TABLE IF NOT EXISTS employees (
                id SERIAL PRIMARY KEY,
                employee_code VARCHAR(20) UNIQUE NOT NULL,
                full_name VARCHAR(100) NOT NULL,
                phone VARCHAR(20),
                email VARCHAR(100),
                position VARCHAR(50) NOT NULL DEFAULT 'Nhân viên phục vụ',
                salary_rate NUMERIC(12, 2) DEFAULT 25000,
                salary_type VARCHAR(20) DEFAULT 'HOURLY',
                shift_id INTEGER REFERENCES shifts(id) ON DELETE SET NULL,
                status VARCHAR(30) DEFAULT 'ACTIVE',
                hire_date DATE DEFAULT CURRENT_DATE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log('✓ Bảng employees đã sẵn sàng.');

        await pool.query(`
            ALTER TABLE work_schedules ADD COLUMN IF NOT EXISTS employee_id INTEGER REFERENCES employees(id) ON DELETE SET NULL;
        `);
        console.log('✓ Cột employee_id đã thêm vào work_schedules.');

        // Thêm danh sách nhân viên mẫu thực tế
        const employees = [
            { code: 'NV001', name: 'Nguyễn Huỳnh Anh Tuấn', phone: '0901234567', email: 'anhtuan@chouxchin.vn', pos: 'Chủ quán / Quản lý', rate: 35000, shift: 1, status: 'ACTIVE' },
            { code: 'NV002', name: 'Lê Thị Bảo Trân', phone: '0902345678', email: 'baotran@chouxchin.vn', pos: 'Thu ngân & Phục vụ', rate: 25000, shift: 1, status: 'ACTIVE' },
            { code: 'NV003', name: 'Nguyễn Thị Hồng Thảo Vân', phone: '0903456789', email: 'thaovan@chouxchin.vn', pos: 'Pha chế Trà sữa', rate: 25000, shift: 2, status: 'ACTIVE' },
            { code: 'NV004', name: 'Nguyễn Minh Loan', phone: '0904567890', email: 'minhloan@chouxchin.vn', pos: 'Bếp & Đồ ăn vặt', rate: 25000, shift: 2, status: 'ACTIVE' },
            { code: 'NV005', name: 'Hoàng Văn Nam', phone: '0905678901', email: 'vannam@chouxchin.vn', pos: 'Bán hàng & Tiếp thị', rate: 28000, shift: 3, status: 'ACTIVE' },
            { code: 'NV006', name: 'Đặng Thu Hương', phone: '0906789012', email: 'thuhuong@chouxchin.vn', pos: 'Kế toán & Sổ quỹ', rate: 30000, shift: 1, status: 'ACTIVE' },
            { code: 'NV007', name: 'Trần Quốc Bảo', phone: '0907890123', email: 'quocbao@chouxchin.vn', pos: 'Phục vụ bàn', rate: 25000, shift: 3, status: 'ACTIVE' }
        ];

        for (const e of employees) {
            await pool.query(`
                INSERT INTO employees (employee_code, full_name, phone, email, position, salary_rate, shift_id, status)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ON CONFLICT (employee_code) DO UPDATE 
                SET full_name = EXCLUDED.full_name,
                    phone = EXCLUDED.phone,
                    position = EXCLUDED.position,
                    salary_rate = EXCLUDED.salary_rate,
                    shift_id = EXCLUDED.shift_id,
                    status = EXCLUDED.status,
                    updated_at = NOW();
            `, [e.code, e.name, e.phone, e.email, e.pos, e.rate, e.shift, e.status]);
        }
        console.log('✓ Đã cập nhật 7 nhân viên vào database.');

        // Cập nhật work_schedules ngày hôm nay cho các nhân viên
        const empRows = (await pool.query('SELECT id, employee_code, full_name FROM employees ORDER BY id')).rows;
        
        // Thêm chấm công hôm nay
        const schedules = [
            { empId: empRows[1]?.id, hours: 9.5, checkIn: '07:30', checkOut: '17:00', status: 'COMPLETED' }, // Lê Thị Bảo Trân (9h30)
            { empId: empRows[2]?.id, hours: 7.75, checkIn: '08:00', checkOut: '15:45', status: 'COMPLETED' }, // Thảo Vân (7h45)
            { empId: empRows[3]?.id, hours: 6.55, checkIn: '12:30', checkOut: '19:03', status: 'COMPLETED' }, // Minh Loan (6h33)
            { empId: empRows[0]?.id, hours: 8.0, checkIn: '07:00', checkOut: '15:00', status: 'COMPLETED' }, // Anh Tuấn
            { empId: empRows[4]?.id, hours: 5.0, checkIn: '17:30', checkOut: '22:30', status: 'WORKING' }, // Hoàng Nam
            { empId: empRows[5]?.id, hours: 6.0, checkIn: '08:00', checkOut: '14:00', status: 'COMPLETED' }, // Thu Hương
            { empId: empRows[6]?.id, hours: 4.5, checkIn: '18:00', checkOut: '22:30', status: 'WORKING' }  // Quốc Bảo
        ];

        for (const s of schedules) {
            if (!s.empId) continue;
            await pool.query(`
                INSERT INTO work_schedules (employee_id, shift_id, work_date, check_in, check_out, total_hours, status)
                VALUES ($1, 1, CURRENT_DATE, CURRENT_DATE + $2::time, CURRENT_DATE + $3::time, $4, $5)
                ON CONFLICT DO NOTHING;
            `, [s.empId, s.checkIn, s.checkOut, s.hours, s.status]);
        }
        console.log('✓ Đã khởi tạo lịch làm việc & chấm công trong database.');

        await pool.end();
        console.log('--- HOÀN THÀNH ---');
    } catch (err) {
        console.error('Lỗi khởi tạo:', err);
        process.exit(1);
    }
}

run();
