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
@Profile({"default", "test-users"})
@Getter(AccessLevel.PRIVATE)
@Component
public class ItemTestDataCreator implements ApplicationListener<ContextRefreshedEvent> {

  private final ItemRepository itemRepository;

  public ItemTestDataCreator(final ItemRepository itemRepository) {
    this.itemRepository = itemRepository;
  }

  @Override
  public void onApplicationEvent(final ContextRefreshedEvent event) {
    final Item item =
            new Item(UUID.randomUUID(), "TestItem1", "Description for first item");

    itemRepository.save(item);
  }
}
