#include <stdint.h>

#define IO_BASE   0xC0000000
#define UART_BASE (IO_BASE + (2 << 7))
#define I2C_BASE  (IO_BASE + (3 << 7))

#define UART_CONF  (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_SPEED (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_TX    (*(volatile uint32_t *)(UART_BASE + 0x08))

#define I2C_CTRL (*(volatile uint32_t *)(I2C_BASE + 0x00))
#define I2C_STAT (*(volatile uint32_t *)(I2C_BASE + 0x04))
#define I2C_TEMP (*(volatile uint32_t *)(I2C_BASE + 0x08))

static void delay(volatile int d) { while (d--); }

static void uart_putc(char c) {
    UART_TX = c;
    UART_CONF = 1;
    delay(3000);
    UART_CONF = 0;
}

static void uart_puts(const char *s) {
    while (*s) uart_putc(*s++);
}

static void uart_print_int(int v) {
    char buf[8];
    int i = 0;
    if (v < 0) { uart_putc('-'); v = -v; }
    do { buf[i++] = '0' + v % 10; v /= 10; } while (v);
    while (i--) uart_putc(buf[i]);
}

int main() {
    UART_SPEED = 10416;
    delay(100000);

    uart_puts("\r\nADT7420 I2C TEST\r\n");

    while (1) {
        I2C_CTRL = 1;
        while (I2C_STAT & 1);

        int8_t temp = (int8_t)I2C_TEMP;

        uart_puts("Temp: ");
        uart_print_int(temp);
        uart_puts(" C\r\n");

        delay(8000000);
    }
}
