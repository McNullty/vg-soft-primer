package hr.vgsoft.primer.security.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.Setter;
import lombok.ToString;

import org.hibernate.annotations.DynamicUpdate;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.util.Assert;

@Builder
@DynamicUpdate
@Data
@EqualsAndHashCode(exclude = {"authorities"})
@ToString(exclude = {"password", "authorities"})
@Entity
@Table(name = "users")
public class User implements UserDetails {

  private static final long serialVersionUID = -5668709358193217159L;

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column(name = "user_uuid")
  private UUID uuid;

  @Column(unique = true, nullable = false)
  private String email;

  @JsonIgnore
  @Column(nullable = false)
  private String password;

  @Setter(value = AccessLevel.PUBLIC)
  @Column(name = "first_name", nullable = false)
  private String firstName;

  @Setter(value = AccessLevel.PUBLIC)
  @Column(name = "last_name", nullable = false)
  private String lastName;

  @Column(nullable = false)
  private Boolean enabled = Boolean.FALSE;

  @Column(nullable = false)
  private Boolean locked = Boolean.FALSE;

  @Setter(AccessLevel.NONE)
  @ManyToMany(fetch = FetchType.LAZY)
  @JoinTable(
          name = "user_authorities",
          joinColumns = @JoinColumn(name = "user_uuid"),
          inverseJoinColumns = @JoinColumn(name = "authority_id")
  )
  @JsonIgnore
  private Set<Authority> authorities;


  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return authorities.stream()
            .map(authority -> new SimpleGrantedAuthority(authority.getName()))
            .collect(Collectors.toUnmodifiableSet());
  }

  /**
   * Check does user have given authority.
   *
   * @param authority Authority to check
   * @return True if user has authority, otherwise False.
   */
  public Boolean hasAuthority(String authority) {
    Assert.notNull(authority, "Authority must be not null!");

    return authorities.stream().anyMatch(it -> authority.equals(it.getName()));
  }

  @Override
  public String getUsername() {
    return email;
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return !locked;
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return this.enabled;
  }

  /**
   * Enable user.
   */
  public void enable() {
    this.enabled = Boolean.TRUE;
  }

  /**
   * Lock user.
   */
  public void lock() {
    this.locked = Boolean.TRUE;
  }

  /**
   * Unlock user.
   */
  public void unlock() {
    this.locked = Boolean.FALSE;
  }

  public void changePassword(final String password) {
    this.password = password;
  }

  /**
   * Adds authorities to user.
   *
   * @param userAuthorities List of authorities to add to user.
   */
  public void addAllUserAuthority(final List<Authority> userAuthorities) {
    if (authorities == null) {
      authorities = new HashSet<>();
    }
    authorities.addAll(userAuthorities);
  }

  /**
   * Returns a authority if user has it, otherwise Optional.empty is returned.
   * @param authority Authority to find
   * @return Optional Authority
   */
  public Optional<Authority> getAuthority(final UserAuthorityEnum authority) {
    return authorities.stream()
            .filter(it -> it.getName().equalsIgnoreCase(authority.name()))
            .findFirst();
  }

  /**
   * Removes authority from entity.
   * @param authority Authority to remove.
   */
  public void removeAuthority(final Authority authority) {
    authorities.remove(authority);
  }


  public static class UserBuilder {

    /**
     * preventing direct access.
     *
     * @param authorities Set of authorities
     * @return User Builder
     */
    private UserBuilder authorities(Set<Authority> authorities) {
      return this;
    }

    /**
     * Adding name to set of authorities.
     *
     * @param authority name to add to set
     * @return builder
     */
    public UserBuilder addAuthority(final Authority authority) {
      if (this.authorities == null) {
        this.authorities = new HashSet<>();
      }

      this.authorities.add(authority);

      return this;
    }
  }
}
