package hr.vgsoft.primer.item;

import java.util.UUID;

public interface ItemService {
  Item getItemByUuid(final UUID uuid);
}
