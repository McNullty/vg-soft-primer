package hr.vgsoft.primer.error.handling;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import lombok.extern.slf4j.Slf4j;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

@Slf4j
public class CustomEntryPoint implements AuthenticationEntryPoint {
  @Override
  public void commence(
          final HttpServletRequest request,
          final HttpServletResponse response,
          final AuthenticationException authException) throws IOException {
    log.debug("Handle Access Denied exception: {}", authException.toString());

    ApiError apiError = new ApiError(HttpStatus.UNAUTHORIZED);
    apiError.setMessage(authException.getMessage());

    response.setStatus(apiError.getStatus().value());

    Map<String, Object> responseMap = new HashMap<>();
    responseMap.put("status", apiError.getStatus());
    responseMap.put("timestamp", apiError.getTimestamp().toString());
    responseMap.put("message", apiError.getMessage());
    responseMap.put("debugMessage", apiError.getDebugMessage());
    responseMap.put("subErrors", apiError.getSubErrors());

    ObjectMapper objectMapper = new ObjectMapper();
    objectMapper.writeValue(response.getOutputStream(), responseMap);

  }
}
