#include "pico/stdlib.h"
#include "pico/binary_info.h"

const uint LED_PIN = 25;

int main() {

    bi_decl(bi_program_description("First Light"));
    bi_decl(bi_1pin_with_name(LED_PIN, "On-board LED"));

    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    while (1) {
        gpio_put(LED_PIN, 0);
        sleep_ms(2000);
        gpio_put(LED_PIN, 1);
        sleep_ms(200);
    }
}
