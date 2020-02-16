package hr.vgsoft.primer.item;

import java.util.Collection;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ItemServiceImpl implements ItemService {

  private ItemRepository itemRepository;

  public ItemServiceImpl(final ItemRepository itemRepository) {
    this.itemRepository = itemRepository;
  }

  @Transactional(readOnly = true)
  @Override
  public Collection<Item> findAll() {
    return itemRepository.findAll();
  }

  @Transactional(readOnly = true)
  @Override
  public Item getItemByUuid(final UUID uuid) {
    return itemRepository.findById(uuid).orElseThrow(() -> new ItemNotFoundException(uuid));
  }
}
