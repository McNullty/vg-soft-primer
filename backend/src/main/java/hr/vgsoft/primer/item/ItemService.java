package hr.vgsoft.primer.item;

import java.util.Collection;
import java.util.UUID;

public interface ItemService {

  Collection<Item> findAll();

  Item getItemByUuid(final UUID uuid);
}
