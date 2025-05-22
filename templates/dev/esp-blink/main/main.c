#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <stdio.h>

static const char *TAG = "BLINK";

#define BLINK_GPIO 38
#define BLINK_PERIOD 1000

static uint8_t s_led_state = 0;

static void blink_led(void) { gpio_set_level(BLINK_GPIO, s_led_state); }

static void configure_led(void) {
  ESP_LOGI(TAG, "Example configured to blink GPIO LED!");
  gpio_reset_pin(BLINK_GPIO);
  gpio_set_direction(BLINK_GPIO, GPIO_MODE_OUTPUT);
}

static void delay_ms(uint32_t ms) { vTaskDelay(pdMS_TO_TICKS(ms)); }

void app_main(void) {
  configure_led();

  while (1) {
    ESP_LOGI(TAG, "Turning the LED %s!", s_led_state == true ? "ON" : "OFF");
    blink_led();
    s_led_state = !s_led_state;
    delay_ms(BLINK_PERIOD);
  }
}
