package hr.vgsoft.primer.item;

import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ItemService {

  Page<Item> findAll(final Pageable pageable);

  Item getItemByUuid(final UUID uuid);

  Item newItem(final NewItemModel itemModel);

  void updateItem(UUID itemUuid, NewItemModel updateItem);

  void deleteItem(UUID itemUuid);
}
