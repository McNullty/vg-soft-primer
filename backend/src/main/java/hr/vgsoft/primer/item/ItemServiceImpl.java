package hr.vgsoft.primer.item;

import java.util.UUID;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Transactional
@Service
public class ItemServiceImpl implements ItemService {

  private ItemRepository itemRepository;

  public ItemServiceImpl(final ItemRepository itemRepository) {
    this.itemRepository = itemRepository;
  }

  @Cacheable("items")
  @Transactional(readOnly = true)
  @Override
  public Page<Item> findAll(final Pageable pageable) {
    return itemRepository.findAll(pageable);
  }

  @Cacheable("item")
  @Transactional(readOnly = true)
  @Override
  public Item getItemByUuid(final UUID uuid) {
    return itemRepository.findById(uuid).orElseThrow(() -> new ItemNotFoundException(uuid));
  }


  @CachePut(value = "item", key = "#result.uuid")
  @Override
  public Item newItem(final NewItemModel itemModel) {

    final Item item = new Item(UUID.randomUUID(), itemModel.getName(), itemModel.getDescription());

    return itemRepository.save(item);
  }


  @Caching(evict = {
          @CacheEvict(value = "item", key = "#uuid"),
          @CacheEvict(value = "items", allEntries = true),
  })
  @Override
  public void updateItem(final UUID uuid, final NewItemModel updateItem) {

    final Item item =
            itemRepository.findById(uuid).orElseThrow(() -> new ItemNotFoundException(uuid));

    item.setName(updateItem.getName());
    item.setDescription(updateItem.getDescription());
  }

  @Caching(evict = {
          @CacheEvict(value = "item", key = "#uuid"),
          @CacheEvict(value = "items", allEntries = true),
  })
  @Override
  public void deleteItem(final UUID uuid) {
    final Item item =
            itemRepository.findById(uuid).orElseThrow(() -> new ItemNotFoundException(uuid));

    itemRepository.delete(item);
  }
}
