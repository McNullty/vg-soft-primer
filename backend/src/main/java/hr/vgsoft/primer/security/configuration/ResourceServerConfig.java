package hr.vgsoft.primer.security.configuration;


import hr.vgsoft.primer.error.handling.CustomEntryPoint;
import hr.vgsoft.primer.security.model.UserAuthorityEnum;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableResourceServer;
import org.springframework.security.oauth2.config.annotation.web.configuration.ResourceServerConfigurerAdapter;

@Configuration
@EnableResourceServer
public class ResourceServerConfig extends ResourceServerConfigurerAdapter {

  @Override
  public void configure(HttpSecurity http) throws Exception {
    http
            .authorizeRequests()
            .antMatchers("/h2-console/**").permitAll()
            .antMatchers("/").permitAll()
            .antMatchers("/index.html").permitAll()
            .antMatchers("/api/greeting").permitAll()
            .antMatchers("/api/**")
              .hasAnyRole(
                      UserAuthorityEnum.ROLE_USER.getShortName(),
                      UserAuthorityEnum.ROLE_USER_MANAGER.getShortName(),
                      UserAuthorityEnum.ROLE_ADMIN.getShortName())
            .and().exceptionHandling().authenticationEntryPoint(new CustomEntryPoint())
            .and()
            .csrf().disable()
            .headers().frameOptions().disable()
    ;
  }

}