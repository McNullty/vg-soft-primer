package hr.vgsoft.primer.item;

import lombok.EqualsAndHashCode;
import lombok.Value;

import org.springframework.hateoas.RepresentationModel;

@EqualsAndHashCode(callSuper = true)
@Value
public class ItemModel extends RepresentationModel<ItemModel> {
  private final String name;
  private final String description;

  public ItemModel(final Item item) {
    this.name = item.getName();
    this.description = item.getDescription();
  }
}
