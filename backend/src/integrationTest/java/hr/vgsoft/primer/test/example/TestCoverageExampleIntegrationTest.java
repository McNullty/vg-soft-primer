package hr.vgsoft.primer.test.example;

import hr.vgsoft.primer.test.example.TestCoverageExample;

import org.assertj.core.api.Assertions;
import org.junit.Test;

public class TestCoverageExampleIntegrationTest {

  @Test
  public void testByIntegrationTest() {
    final TestCoverageExample testCoverageExample = new TestCoverageExample();
    Assertions.assertThat(testCoverageExample.testByIntegrationTest(150)).isTrue();
  }
}