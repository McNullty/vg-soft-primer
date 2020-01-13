package hr.vgsoft.primer.item;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;

import org.hibernate.annotations.DynamicUpdate;

@Data
@DynamicUpdate
@Entity
public class Item {
  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  @Column
  private UUID uuid;

  @JsonIgnore
  @Column(nullable = false)
  private String name;

  @JsonIgnore
  @Column(nullable = false)
  private String description;
}
