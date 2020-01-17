package hr.vgsoft.primer.item;

import lombok.EqualsAndHashCode;
import lombok.Value;

import org.springframework.hateoas.Link;
import org.springframework.hateoas.RepresentationModel;
import org.springframework.hateoas.server.mvc.WebMvcLinkBuilder;

@EqualsAndHashCode(callSuper = true)
@Value
public class ItemModel extends RepresentationModel<ItemModel> {
  private final String name;
  private final String description;

  public ItemModel(final Item item) {
    this.name = item.getName();
    this.description = item.getDescription();

    final Link selfRelLink = WebMvcLinkBuilder
            .linkTo(WebMvcLinkBuilder.methodOn(ItemController.class).findItem(item.getUuid()))
            .withSelfRel()
            ;

    add(selfRelLink);
    add(selfRelLink.andAffordance(
            WebMvcLinkBuilder.afford(WebMvcLinkBuilder.methodOn(ItemController.class)
                    .updateItem(item.getUuid(), null))));


  }
}
