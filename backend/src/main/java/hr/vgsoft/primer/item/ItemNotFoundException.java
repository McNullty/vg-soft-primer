package hr.vgsoft.primer.item;

import java.util.UUID;

public class ItemNotFoundException extends RuntimeException {

  private UUID uuid;

  public ItemNotFoundException(final UUID uuid) {
    this.uuid = uuid;
  }
}
