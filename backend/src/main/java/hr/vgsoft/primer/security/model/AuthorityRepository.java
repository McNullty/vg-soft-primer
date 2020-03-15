package hr.vgsoft.primer.security.model;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface AuthorityRepository extends JpaRepository<Authority, Long> {

  /**
   * Finds Authority entity for given name string.
   *
   * @param name String with name, eg. ROLE_USER
   * @return Authority if it exists
   */
  Optional<Authority> findByName(String name);

  /**
   * Finds all authorities for user.
   *
   * @param userUuid Users uuid.
   * @return Collection of users authorities.
   */
  @Query("SELECT u.authorities FROM User u WHERE u.id = ?1")
  Collection<Authority> findAllByUserUuid(UUID userUuid);
}
