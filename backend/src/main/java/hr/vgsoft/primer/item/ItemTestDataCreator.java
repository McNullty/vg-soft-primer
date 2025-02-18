package hr.vgsoft.primer.item;

import java.util.UUID;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;

import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Profile;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.stereotype.Component;

@Slf4j
@Profile({"default"})
@Getter(AccessLevel.PRIVATE)
@Component
public class ItemTestDataCreator implements ApplicationListener<ContextRefreshedEvent> {

  private final ItemRepository itemRepository;

  public ItemTestDataCreator(final ItemRepository itemRepository) {
    this.itemRepository = itemRepository;
  }

  @Override
  public void onApplicationEvent(final ContextRefreshedEvent event) {

    UUID itemUuid = UUID.randomUUID();
    log.debug("Generated First Item UUID: {}", itemUuid);

    final Item item =
            new Item(itemUuid, "TestItem1", "Description for first item");

    itemRepository.save(item);

    itemUuid = UUID.randomUUID();
    log.debug("Generated Second Item UUID: {}", itemUuid);
    final Item item2 =
            new Item(itemUuid, "TestItem2", "Description for second item");

    itemRepository.save(item2);

    for (int i = 3; i <= 50; i++) {
      itemUuid = UUID.randomUUID();
      final Item itemX =
              new Item(itemUuid, "TestItem" + i, "Description for " + i + ". item");

      itemRepository.save(itemX);
    }
  }
}
