package hr.vgsoft.primer.rest;

import java.util.concurrent.atomic.AtomicLong;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {

  private static final String template = "Hello, %s!";
  private final AtomicLong counter = new AtomicLong();

  @RequestMapping("/api/greeting")
  public Greeting greeting(@RequestParam(value="name", defaultValue="World from backend!") String name) {

    try {
      Thread.sleep(1000L);
    } catch (InterruptedException e) {
      e.printStackTrace();
    }

    return new Greeting(counter.incrementAndGet(),
            String.format(template, name));
  }
}
