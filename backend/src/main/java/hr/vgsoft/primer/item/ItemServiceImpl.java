package hr.vgsoft.primer.item;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
  public Page<Item> findAll(final Pageable pageable) {
    return itemRepository.findAll(pageable);
  }

  @Transactional(readOnly = true)
  @Override
  public Item getItemByUuid(final UUID uuid) {
    return itemRepository.findById(uuid).orElseThrow(() -> new ItemNotFoundException(uuid));
  }
}
