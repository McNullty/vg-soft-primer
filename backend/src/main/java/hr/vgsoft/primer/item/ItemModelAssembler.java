package hr.vgsoft.primer.item;

import org.springframework.hateoas.server.mvc.RepresentationModelAssemblerSupport;
import org.springframework.stereotype.Component;

@Component
public class ItemModelAssembler extends RepresentationModelAssemblerSupport<Item, ItemModel> {

  public ItemModelAssembler() {
    super(ItemController.class, ItemModel.class);
  }

  @Override
  public ItemModel toModel(final Item item) {
    return new ItemModel(item);
  }
}
