package hr.vgsoft.primer.item;

import java.util.Collection;
import java.util.UUID;

import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.MediaTypes;
import org.springframework.hateoas.server.ExposesResourceFor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/items")
@ExposesResourceFor(Item.class)
public class ItemController {

  private final ItemService itemService;
  private final ItemModelAssembler itemModelAssembler;

  public ItemController(
          final ItemService itemService, final ItemModelAssembler itemModelAssembler) {
    this.itemService = itemService;
    this.itemModelAssembler = itemModelAssembler;
  }

  @GetMapping
  public ResponseEntity<CollectionModel<ItemModel>> findAllItems() {

    final Collection<Item> items = itemService.findAll();

    final CollectionModel<ItemModel> itemModels = itemModelAssembler.toCollectionModel(items);

    return ResponseEntity.ok(itemModels);
  }

  @PostMapping
  public ResponseEntity<?> newItem(@RequestBody final Item item) {
    // TODO: fix
    return null;
  }

  @GetMapping(
          value = "/{itemUuid}",
          produces = {MediaTypes.HAL_JSON_VALUE, MediaType.APPLICATION_JSON_VALUE})
  public ResponseEntity<ItemModel> findItem(@PathVariable final UUID itemUuid) {
    final Item item = itemService.getItemByUuid(itemUuid);

    final ItemModel itemModel = new ItemModel(item);

    return ResponseEntity.ok(itemModel);
  }

  @PutMapping(value = "/{itemUuid}")
  public ResponseEntity<?> updateItem(
          @PathVariable final UUID itemUuid, @RequestBody final ItemModel updateItem) {
    return ResponseEntity.ok().build();
  }

  public ResponseEntity<?> deleteItem(@PathVariable final UUID itemUuid) {
    // TODO: fix
    return null;
  }
}
