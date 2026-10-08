#include <stm32f10x.h>

void led_on_off(){
	RCC->APB2ENR |= (1 << 4);
}