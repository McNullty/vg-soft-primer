package hr.vgsoft.primer.item;

import java.util.Optional;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

@DataJpaTest
class ItemServiceImplSpecification {

  @Autowired
  private TestEntityManager entityManager;

  @Autowired
  private ItemRepository itemRepository;

  private ItemService itemService;

  @BeforeEach
  void setup() {
    itemService = new ItemServiceImpl(itemRepository);
  }

  @Test
  void shouldCreateNewItem() {
    final NewItemModel newItemModel = new NewItemModel("Test", "Test Description");

    final Item savedItem = itemService.newItem(newItemModel);

    Assertions.assertThat(savedItem.getUuid()).isNotNull();

    final Optional<Item> queriedItem = itemRepository.findById(savedItem.getUuid());

    Assertions.assertThat(queriedItem.isPresent()).isTrue();
    Assertions.assertThat(savedItem).isEqualTo(queriedItem.get());
  }
}