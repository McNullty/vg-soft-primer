package hr.vgsoft.primer.item;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.io.Serializable;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Version;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Setter;

import org.hibernate.annotations.DynamicUpdate;

@Data
@DynamicUpdate
@Entity
@NoArgsConstructor
@Setter
@Table(name = "items")
public class Item implements Serializable {

  @Id
  @Column
  private UUID uuid;

  @JsonIgnore
  @Column(nullable = false)
  private String name;

  @JsonIgnore
  @Column(nullable = false)
  private String description;

  @Version
  private Integer version;

  public Item(final UUID uuid, final String name, final String description) {
    this.uuid = uuid;
    this.name = name;
    this.description = description;
    this.version = 0;
  }
}
