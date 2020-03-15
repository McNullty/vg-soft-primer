package hr.vgsoft.primer.security.configuration;

import lombok.Data;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "custom.jwt")
@Data
public class JwtProperties {
  private String signingKey;
}
