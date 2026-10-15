#include <stm32f10x.h>

void init_led_pin(void){
	RCC->APB2ENR |= (1 << 4);
	GPIOC->CRH &= ~((1 << 23) | (1 << 22));
	GPIOC->CRH |= (1 << 20);
}

void delay_ms(uint16_t t){
	volatile unsigned long j=0;
	for(uint16_t i = 0; i < t;i++)
	for(j = 0;j < 6000;j++){
	}
}

void led_on_off(void)
{
	for (int x=0; x<3; x++){
	GPIOC ->ODR |= 1 << 13;
	delay_ms(100);
	GPIOC ->ODR &= ~(1 << 13);
	delay_ms(200);}
}

