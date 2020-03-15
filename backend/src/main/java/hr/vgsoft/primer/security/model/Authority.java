package hr.vgsoft.primer.security.model;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AccessLevel;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Setter(value = AccessLevel.PACKAGE)
@Data
@Getter
@Entity
@Table(name = "authorities")
public class Authority implements Serializable {

  private static final long serialVersionUID = -3710785924989750257L;

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "authority_id")
  private Long id;

  @Column(unique = true, nullable = false)
  private String name;
}
