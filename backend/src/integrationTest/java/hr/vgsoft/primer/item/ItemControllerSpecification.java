package hr.vgsoft.primer.item;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.BDDMockito;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.hateoas.MediaTypes;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

@DisplayName("Test Item Controller")
@ExtendWith(SpringExtension.class)
@WebMvcTest(ItemController.class)
@Import({ ItemModelAssembler.class })
class ItemControllerSpecification {

  @Autowired
  private MockMvc mvc;

  @Autowired
  ObjectMapper objectMapper;

  @MockBean
  private ItemService itemService;

  @Test
  void shouldReturnPageWithItems() throws Exception {

    final List<Item> items =
            Arrays.asList(
                    new Item(UUID.randomUUID(), "First", "First description"),
                    new Item(UUID.randomUUID(), "Second", "Second description"));

    final Page<Item> page = new PageImpl<>(items);

    BDDMockito.given(itemService.findAll(Mockito.any())).willReturn(page);

    mvc.perform(MockMvcRequestBuilders.get("/api/items"))
            .andDo(MockMvcResultHandlers.print())
            .andExpect(MockMvcResultMatchers.status().isOk())
            .andExpect(header().string(HttpHeaders.CONTENT_TYPE, MediaTypes.HAL_JSON_VALUE))
    ;
  }

  @Test
  void shouldCreateNewItem() throws Exception {

    String itemName = "Test";
    String itemDescription = "Test Description";

    BDDMockito.given(itemService.newItem(Mockito.any(NewItemModel.class)))
            .willAnswer( i -> new Item(UUID.randomUUID(), itemName, itemDescription));

    Map<String, String> itemJson = new HashMap<>();
    itemJson.put("name", itemName);
    itemJson.put("description", itemDescription);

    mvc.perform(MockMvcRequestBuilders.post("/api/items")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(itemJson)))
            .andDo(MockMvcResultHandlers.print())
            .andExpect(MockMvcResultMatchers.status().isCreated())
            .andExpect(MockMvcResultMatchers.header().exists("Location"))
    ;
  }

  @Test
  void shouldFindItemByUUID() throws Exception {
    final UUID uuid = UUID.randomUUID();
    final Item item = new Item(uuid, "Test", "Test description");

    BDDMockito.given(itemService.getItemByUuid(uuid)).willReturn(item);

    mvc.perform(MockMvcRequestBuilders.get("/api/items/" + uuid.toString()))
            .andDo(MockMvcResultHandlers.print())
            .andExpect(MockMvcResultMatchers.status().isOk());
  }

  void shouldRemoveItemByUUID() throws Exception {

  }
}