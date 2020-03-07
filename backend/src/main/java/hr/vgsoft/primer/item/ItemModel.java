package hr.vgsoft.primer.item;

import lombok.EqualsAndHashCode;
import lombok.Value;

import org.springframework.hateoas.Link;
import org.springframework.hateoas.RepresentationModel;
import org.springframework.hateoas.server.core.Relation;
import org.springframework.hateoas.server.mvc.WebMvcLinkBuilder;

@EqualsAndHashCode(callSuper = true)
@Value
@Relation(value = "item", collectionRelation = "items")
public class ItemModel extends RepresentationModel<ItemModel> {
  String id;
  String name;
  String description;

  public ItemModel(final Item item) {
    this.id = item.getUuid().toString();
    this.name = item.getName();
    this.description = item.getDescription();

    final Link selfRelLink = WebMvcLinkBuilder
            .linkTo(WebMvcLinkBuilder.methodOn(ItemController.class).findItem(item.getUuid()))
            .withSelfRel()
            ;

    add(selfRelLink);

  }
}
