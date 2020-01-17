package hr.vgsoft.primer.item;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Setter;

import org.hibernate.annotations.DynamicUpdate;

@Data
@DynamicUpdate
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Setter
@Table(name = "items")
public class Item {

  @Id
  @Column
  private UUID uuid;

  @JsonIgnore
  @Column(nullable = false)
  private String name;

  @JsonIgnore
  @Column(nullable = false)
  private String description;
}
