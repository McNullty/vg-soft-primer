package hr.vgsoft.primer.test.example;

public class TestCoverageExample {
  public Boolean testByUnitTest(Integer i) {
    if (i > 100) {
      return true;
    } else if (i < 0) {
      throw new IllegalArgumentException("Input can't bew lesser then zero");
    }

    return false;
  }

  public Boolean testByIntegrationTest(Integer i) {
    if (i > 100) {
      return true;
    } else if (i < 0) {
      throw new IllegalArgumentException("Input can't bew lesser then zero");
    }

    return false;
  }
}
