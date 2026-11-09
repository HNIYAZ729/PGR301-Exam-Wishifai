package no.pgr301.exam.controller;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;

import no.pgr301.exam.model.AnalyzeResponse;
import no.pgr301.exam.service.WishlistService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Instant;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class AppController {

    private final WishlistService wishlist;
    private final Counter analysisCounter;

    public AppController(WishlistService wishlist, MeterRegistry meterRegistry) {
    this.wishlist = wishlist;
    this.analysisCounter = Counter.builder("wishifai.analysis.count")
            .description("Number of image analysis requests")
            .register(meterRegistry);
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("status", "UP", "timestamp", Instant.now().toString());
    }

    @PostMapping(value = "/analyze", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public AnalyzeResponse analyze(@RequestParam("image") MultipartFile image) throws IOException {
        analysisCounter.increment();
        return wishlist.process(image.getBytes(), image.getOriginalFilename(), image.getContentType());
    }

}
