package com.milktea.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MilkteaBackendApplication {
    public static void main(String[] args) {
        SpringApplication.run(MilkteaBackendApplication.class, args);
        System.out.println("=========================================================");
        System.out.println("   BACKEND SPRING BOOT 3 DỰ ÁN TRÀ SỮA ĐÃ SẴN SÀNG!");
        System.out.println("   Server REST API: http://localhost:8080/api/v1");
        System.out.println("=========================================================");
    }
}
