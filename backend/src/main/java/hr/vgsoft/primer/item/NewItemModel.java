package hr.vgsoft.primer.item;

import javax.validation.constraints.NotEmpty;

import lombok.Data;

@Data
public class NewItemModel {

  @NotEmpty
  private final String name;

  @NotEmpty
  private final String description;
}
