package br.unifebe.minhasaudefeminina;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MinhaSaudeFemininaApplication {
    public static void main(String[] args) {
        SpringApplication.run(MinhaSaudeFemininaApplication.class, args);
    }
}
