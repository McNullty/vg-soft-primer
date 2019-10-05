package hr.vgsoft.primer.test.example;

import org.assertj.core.api.Assertions;
import org.junit.Test;

public class TestCoverageExampleUnitTest {

  @Test
  public void testByUnitTest() {
    final TestCoverageExample testCoverageExample = new TestCoverageExample();
    Assertions.assertThat(testCoverageExample.testByUnitTest(150)).isTrue();
  }
}