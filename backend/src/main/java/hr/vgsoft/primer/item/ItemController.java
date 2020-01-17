package hr.vgsoft.primer.item;

import java.util.UUID;

import org.springframework.hateoas.MediaTypes;
import org.springframework.hateoas.server.ExposesResourceFor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/items")
@ExposesResourceFor(Item.class)
public class ItemController {

  private final ItemService itemService;

  public ItemController(final ItemService itemService) {
    this.itemService = itemService;
  }

  @GetMapping(
          value = "/{itemUuid}",
          produces = {MediaTypes.HAL_JSON_VALUE, MediaType.APPLICATION_JSON_VALUE})
  public ResponseEntity<ItemModel> getItem(@PathVariable final UUID itemUuid) {
    final Item item = itemService.getItemByUuid(itemUuid);

    final ItemModel itemModel = new ItemModel(item);

    return ResponseEntity.ok(itemModel);
  }
}
