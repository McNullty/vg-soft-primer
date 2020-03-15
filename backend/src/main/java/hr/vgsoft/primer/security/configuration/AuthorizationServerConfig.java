package hr.vgsoft.primer.security.configuration;

import lombok.AccessLevel;
import lombok.Getter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableAuthorizationServer;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.JwtAccessTokenConverter;
import org.springframework.security.oauth2.provider.token.store.JwtTokenStore;

@Getter(AccessLevel.PRIVATE)
@Configuration
@EnableAuthorizationServer
public class AuthorizationServerConfig {

  private final JwtProperties jwtProperties;

  @Autowired
  public AuthorizationServerConfig(final JwtProperties jwtProperties) {
    this.jwtProperties = jwtProperties;
  }

  /**
   * Configure JwtAccessTokenConverter.
   *
   * @return JwtAccessTokenConverter
   */
  @Bean
  public JwtAccessTokenConverter accessTokenConverter() {
    JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
    converter.setSigningKey(jwtProperties.getSigningKey());
    return converter;
  }

  /**
   * Configure TokenStore.
   *
   * @return JwtTokenStore with converter
   */
  @Bean
  public TokenStore tokenStore() {
    return new JwtTokenStore(accessTokenConverter());
  }

}