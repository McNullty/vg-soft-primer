package hr.vgsoft.primer.security.model;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

  /**
   * Fins User entity for given email if it exists.
   *
   * @param email user email to find
   * @return User entity if found, otherwise Optional.empty
   */
  @Query("SELECT u FROM User u LEFT JOIN FETCH u.authorities WHERE u.email = ?1")
  Optional<User> findByEmailWithAuthorities(String email);

  /**
   * Finds User without eager loading.
   *
   * @param email user email to find
   * @return User entity if found, otherwise Optional.empty
   */
  @Query("SELECT u FROM User u WHERE u.email = ?1")
  Optional<User> findByEmail(String email);

  /**
   * Returns page of users.
   * @param email Users email.
   * @param pageable Pageable object
   * @return Page with users
   */
  @Query("SELECT u FROM User u WHERE u.email = ?1")
  Page<User> findByEmail(String email, Pageable pageable);

  /**
   * Find User for given UUID only if user is locked.
   * @param uuid User UUID
   * @return Optional user
   */
  @Query("SELECT u FROM User u WHERE u.uuid = ?1 AND u.locked = TRUE")
  Optional<User> findByUuidAndLockedIsTrue(UUID uuid);
}
