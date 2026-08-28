package br.unifebe.minhasaudefeminina.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${midia.diretorio}")
    private String diretorio;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String local = "file:" + Path.of(diretorio).toAbsolutePath() + "/";
        registry.addResourceHandler("/midia/**").addResourceLocations(local);
    }
}
