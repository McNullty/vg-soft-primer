package hr.vgsoft.primer.security.model;

import java.util.Optional;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Getter(AccessLevel.PRIVATE)
@Service(value = "userService")
@Transactional
public class UserServiceImpl implements UserService {

  private final UserRepository userRepository;

  private final PasswordEncoder passwordEncoder =
          PasswordEncoderFactories.createDelegatingPasswordEncoder();

  /**
   * User service that deals with User entity.
   * @param userRepository User repository
   */
  public UserServiceImpl(
          final UserRepository userRepository) {
    this.userRepository = userRepository;
  }

  @Override
  public UserDetails loadUserByUsername(final String email) throws UsernameNotFoundException {
    Optional<User> user = userRepository.findByEmailWithAuthorities(email);
    if (user.isPresent()) {
      return user.get();
    } else {
      throw new UsernameNotFoundException(email);
    }
  }

}
