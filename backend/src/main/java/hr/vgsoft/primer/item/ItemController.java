package hr.vgsoft.primer.item;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.validation.Valid;

import lombok.extern.slf4j.Slf4j;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PagedResourcesAssembler;
import org.springframework.hateoas.IanaLinkRelations;
import org.springframework.hateoas.Link;
import org.springframework.hateoas.MediaTypes;
import org.springframework.hateoas.PagedModel;
import org.springframework.hateoas.server.ExposesResourceFor;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.DigestUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
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
  public ResponseEntity<PagedModel<ItemModel>> findAllItems(
          final Pageable pageable, final PagedResourcesAssembler<Item> assembler,
          @RequestHeader final HttpHeaders headers) throws IOException {

    log.debug("If-None-Match: {}", headers.getIfNoneMatch() );
    final Optional<String> receivedEtag = headers.getIfNoneMatch().stream().findFirst();

    final Page<Item> items = itemService.findAll(pageable);

    String calculatedEtag = getEtagFromPageOfItems(items);

    if (etagsMatching(receivedEtag.orElse("\"NOT-ETAG\""), calculatedEtag)) {
      return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
    }

    return ResponseEntity.ok()
            .cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS))
            .eTag(calculatedEtag)
            .body(assembler.toModel(items, itemModelAssembler))
            ;
  }

  @PostMapping
  public ResponseEntity<?> newItem(@RequestBody @Valid final NewItemModel newItemModel) {

    Item item = itemService.newItem(newItemModel);

    final ItemModel itemModel = new ItemModel(item);
    final Optional<Link> link = itemModel.getLink(IanaLinkRelations.SELF);

    if (link.isEmpty()) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }

    return ResponseEntity.created(link.get().toUri()).build();
  }

  @GetMapping(
          value = "/{itemUuid}",
          produces = {MediaTypes.HAL_JSON_VALUE, MediaType.APPLICATION_JSON_VALUE})
  public ResponseEntity<ItemModel> findItem(
          @PathVariable final UUID itemUuid, @RequestHeader final HttpHeaders headers) {

    log.debug("If-None-Match: {}", headers.getIfNoneMatch() );
    final Optional<String> receivedEtag = headers.getIfNoneMatch().stream().findFirst();

    final Item item = itemService.getItemByUuid(itemUuid);

    String calculatedEtag = getEtagFromItem(item);
    log.debug("Calculated etag: {}", calculatedEtag);

    if (etagsMatching(receivedEtag.orElse("\"NOT-ETAG\""), calculatedEtag)) {
      return ResponseEntity.status(HttpStatus.NOT_MODIFIED).build();
    }

    final ItemModel itemModel = new ItemModel(item);


    return ResponseEntity.ok()
            .cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS))
            .eTag(calculatedEtag)
            .body(itemModel)
            ;
  }

  @PutMapping(value = "/{itemUuid}")
  public ResponseEntity<?> updateItem(
          @PathVariable final UUID itemUuid, @RequestBody @Valid final NewItemModel updateItem) {

    itemService.updateItem(itemUuid, updateItem);

    // TODO: Check correct response
    return ResponseEntity.ok().build();
  }

  @DeleteMapping(value = "/{itemUuid}")
  public ResponseEntity<?> deleteItem(@PathVariable final UUID itemUuid) {

    itemService.deleteItem(itemUuid);

    // TODO: Check correct response
    return ResponseEntity.ok().build();
  }

  private String getEtagFromItem(final Item item) {
    return DigestUtils.md5DigestAsHex(item.getVersion().toString().getBytes());
  }

  private String getEtagFromPageOfItems(final Page<Item> items) throws IOException {
    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    ObjectOutputStream oos = new ObjectOutputStream(bos);
    oos.writeObject(items);

    return DigestUtils.md5DigestAsHex(bos.toByteArray());
  }

  private boolean etagsMatching(String receivedEtag, final String calculatedEtag) {
    final String etag = receivedEtag.substring(1, receivedEtag.length() - 1);

    return etag.equals(calculatedEtag);
  }
}
