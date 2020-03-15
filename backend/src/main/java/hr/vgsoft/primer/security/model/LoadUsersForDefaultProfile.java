package hr.vgsoft.primer.security.model;


import java.util.HashMap;
import java.util.Map;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Profile;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Profile({"default", "staging"})
@Getter(AccessLevel.PRIVATE)
@Component
public class LoadUsersForDefaultProfile implements ApplicationListener<ContextRefreshedEvent> {

  public static final String PASSWORD = "password";
  public static final String LAST_NAME = "Calories";
  private final AuthorityRepository authorityRepository;
  private final UserRepository userRepository;


  private Authority user;
  private Authority userManager;
  private Authority admin;

  private Map<String, User> users = new HashMap<>();

  /**
   * bean for inserting test data.
   * @param authorityRepository Authority repository
   * @param userRepository User repository
   */
  public LoadUsersForDefaultProfile(
          final AuthorityRepository authorityRepository,
          final UserRepository userRepository) {
    this.authorityRepository = authorityRepository;
    this.userRepository = userRepository;
  }

  @Override
  public void onApplicationEvent(final ContextRefreshedEvent event) {
    log.info("Creating sample data");

    initializeAuthorities();

    initializeUsers();

  }

  private void initializeUsers() {
    final PasswordEncoder passwordEncoder =
            PasswordEncoderFactories.createDelegatingPasswordEncoder();

    User una = User.builder()
            .email("una@test.com")
            .password(passwordEncoder.encode(PASSWORD))
            .firstName("Una")
            .lastName(LAST_NAME)
            .addAuthority(user)
            .build();
    una.enable();

    User unaSaved = userRepository.save(una);
    users.put("una@test.com", unaSaved);

    logSavedUser(unaSaved);

    User theon = User.builder()
            .email("theon@test.com")
            .password(passwordEncoder.encode(PASSWORD))
            .firstName("Theon")
            .lastName(LAST_NAME)
            .addAuthority(user)
            .build();
    theon.enable();

    User theonSaved = userRepository.save(theon);
    users.put("theon@test.com", theonSaved);

    User frank = User.builder()
            .email("frank@test.com")
            .password(passwordEncoder.encode(PASSWORD))
            .firstName("Frank")
            .lastName(LAST_NAME)
            .addAuthority(user)
            .build();
    frank.enable();

    User frankSaved = userRepository.save(frank);
    users.put("frank@test.com", frankSaved);

    User luka = User.builder()
            .email("luka@test.com")
            .password(passwordEncoder.encode(PASSWORD))
            .firstName("Luka")
            .lastName(LAST_NAME)
            .locked(Boolean.TRUE)
            .addAuthority(user)
            .build();
    luka.enable();

    User lukaSaved = userRepository.save(luka);
    users.put("frank@test.com", lukaSaved);

    logSavedUser(theonSaved);

    User mark = User.builder()
            .email("mark@test.com")
            .password(passwordEncoder.encode(PASSWORD))
            .firstName("Mark")
            .lastName(LAST_NAME)
            .addAuthority(userManager)
            .build();
    mark.enable();

    User markSaved = userRepository.save(mark);
    users.put("mark@test.com", markSaved);

    logSavedUser(markSaved);

    User andrew = User.builder()
            .email("andrew@test.com")
            .password(passwordEncoder.encode(PASSWORD))
            .firstName("Andrew")
            .lastName(LAST_NAME)
            .addAuthority(admin)
            .build();
    andrew.enable();

    User andrewSaved = userRepository.save(andrew);
    users.put("andrew@test.com", andrewSaved);

    logSavedUser(andrewSaved);

  }

  private void logSavedUser(final User user) {
    log.debug("Saved user: {}", user);
  }

  private void initializeAuthorities() {
    user = authorityRepository.save(Authority.builder()
            .name(UserAuthorityEnum.ROLE_USER.name()).build());
    admin = authorityRepository.save(Authority.builder()
            .name(UserAuthorityEnum.ROLE_ADMIN.name()).build());
    userManager = authorityRepository.save(Authority.builder()
            .name(UserAuthorityEnum.ROLE_USER_MANAGER.name()).build());
  }

}
