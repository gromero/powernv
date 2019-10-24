#include <unistd.h>
#include <stdbool.h>
#include <inttypes.h>

#define QEMU_UART_BASE 0x60300d00103f8

/* Taken from skiboot. TODO: where is the documentation?! */
#define REG_RBR		0
#define REG_THR		0
#define REG_DLL		0
#define REG_IER		1
#define REG_DLM		1
#define REG_FCR		2
#define REG_IIR		2
#define REG_LCR		3
#define REG_MCR		4
#define REG_LSR		5
#define REG_MSR		6
#define REG_SCR		7

#define LSR_DR		0x01  /* Data ready */
#define LSR_OE		0x02  /* Overrun */
#define LSR_PE		0x04  /* Parity error */
#define LSR_FE		0x08  /* Framing error */
#define LSR_BI		0x10  /* Break */
#define LSR_THRE	0x20  /* Xmit holding register empty */
#define LSR_TEMT	0x40  /* Xmitter empty */
#define LSR_ERR		0x80  /* Error */

#define LCR_DLAB 	0x80  /* DLL access */

#define IER_RX		0x01
#define IER_THRE	0x02
#define IER_ALL		0x0f

static uint64_t qemu_uart_base = QEMU_UART_BASE;

static void qemu_uart_reg_write(uint64_t offset, uint8_t val)
{
	uint64_t addr;

	addr = qemu_uart_base + offset;
	*(volatile uint8_t *)addr = val;
}

static uint8_t qemu_uart_reg_read(uint64_t offset)
{
	uint64_t addr;
	uint8_t val;

	addr = qemu_uart_base + offset;
	val = *(volatile uint8_t *)addr;

	return val;
}

static int qemu_uart_tx_full(void)
{
	return !(qemu_uart_reg_read(REG_LSR) & LSR_THRE);
}

static int qemu_uart_rx_empty(void)
{
	return !(qemu_uart_reg_read(REG_LSR) & LSR_DR);
}

static char qemu_uart_read(void)
{
	return qemu_uart_reg_read(REG_THR);
}

static void qemu_uart_write(char c)
{
	qemu_uart_reg_write(REG_RBR, c);
}

// Receive a single character
int uart_receive_char(void) {
    unsigned char c = 0;
    while (qemu_uart_rx_empty()) ;
    c = qemu_uart_read();
    return c;
}

// Send string of a given length
void uart_send_string(const char *str, int len) {
	int i;
	for (i = 0; i < len; i++) {
		while(qemu_uart_tx_full());
		qemu_uart_write(str[i]);
	}
}

int main() {
  // FDT (r3) is saved to r14 in h.S
  register char *fdtp __asm__ ("r14");
  char msg[]="\n----\n";

  // Dump 4k from device tree
  uart_send_string(fdtp, 1024*4);

  // Print some mark in the end
  uart_send_string(&msg[0], 6);

  // hal
  while (1) ;
}
