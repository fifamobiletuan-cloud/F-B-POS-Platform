package com.milktea.backend.controller;

import com.milktea.backend.dto.ApiResponse;
import com.milktea.backend.entity.Shift;
import com.milktea.backend.entity.User;
import com.milktea.backend.entity.WorkSchedule;
import com.milktea.backend.repository.ShiftRepository;
import com.milktea.backend.repository.UserRepository;
import com.milktea.backend.repository.WorkScheduleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/shifts")
@CrossOrigin(origins = "*")
public class ShiftController {

    @Autowired
    private ShiftRepository shiftRepository;

    @Autowired
    private WorkScheduleRepository workScheduleRepository;

    @Autowired
    private UserRepository userRepository;

    // API: Lấy danh sách ca làm việc mẫu
    @GetMapping
    public ResponseEntity<ApiResponse<List<Shift>>> getShifts() {
        return ResponseEntity.ok(ApiResponse.ok(shiftRepository.findAll()));
    }

    // API: Lấy lịch làm việc hôm nay
    @GetMapping("/today")
    public ResponseEntity<ApiResponse<List<WorkSchedule>>> getTodaySchedules() {
        return ResponseEntity.ok(ApiResponse.ok(workScheduleRepository.findByWorkDate(LocalDate.now())));
    }

    // API: Nhân viên bấm Chấm công vào ca (Check-in)
    @PostMapping("/check-in")
    public ResponseEntity<ApiResponse<WorkSchedule>> checkIn(@RequestBody Map<String, Object> body) {
        Long userId = Long.valueOf(body.getOrDefault("userId", 2).toString());
        Integer shiftId = Integer.valueOf(body.getOrDefault("shiftId", 1).toString());

        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("Không tìm thấy nhân viên"));
        Shift shift = shiftRepository.findById(shiftId).orElse(null);

        WorkSchedule schedule = new WorkSchedule();
        schedule.setUser(user);
        schedule.setShift(shift);
        schedule.setWorkDate(LocalDate.now());
        schedule.setCheckIn(LocalDateTime.now());
        schedule.setStatus("WORKING");

        return ResponseEntity.ok(ApiResponse.ok("Chấm công vào ca thành công!", workScheduleRepository.save(schedule)));
    }

    // API: Nhân viên bấm Chấm công tan ca (Check-out)
    @PostMapping("/check-out")
    public ResponseEntity<ApiResponse<WorkSchedule>> checkOut(@RequestBody Map<String, Object> body) {
        Long userId = Long.valueOf(body.getOrDefault("userId", 2).toString());

        WorkSchedule schedule = workScheduleRepository.findFirstByUserIdAndStatus(userId, "WORKING")
                .orElseThrow(() -> new RuntimeException("Không tìm thấy ca làm việc đang hoạt động của bạn!"));

        schedule.setCheckOut(LocalDateTime.now());
        schedule.setStatus("COMPLETED");

        if (schedule.getCheckIn() != null) {
            long minutes = Duration.between(schedule.getCheckIn(), schedule.getCheckOut()).toMinutes();
            BigDecimal hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
            schedule.setTotalHours(hours);

            BigDecimal rate = schedule.getShift() != null ? schedule.getShift().getHourlyRate() : new BigDecimal("25000");
            schedule.setSalaryEarned(hours.multiply(rate).setScale(0, RoundingMode.HALF_UP));
        }

        return ResponseEntity.ok(ApiResponse.ok("Chấm công tan ca thành công!", workScheduleRepository.save(schedule)));
    }
}
