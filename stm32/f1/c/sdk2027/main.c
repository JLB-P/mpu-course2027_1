#include "leds.h"
#include "exti.h"
#include "usart.h"
#include "delay.h"

int main(){
	init_led_pin();
	led_on_off();
	init_exti_pin();
	init_exti();
	init_usart1_pin();
	init_usart1();
	usart1_sendbyte('\n');
	usart1_sendstring("enter character:");
	delay_ms(1000);
	uint8_t receivedbyte;	//variable to receive character
	while(1){
		receivedbyte = usart1_receivebyte();
		usart1_sendbyte('-');
		usart1_sendbyte(receivedbyte); 
	}
}