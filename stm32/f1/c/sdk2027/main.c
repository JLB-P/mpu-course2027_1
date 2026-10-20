#include "leds.h"
#include "exti.h"

int main(){
	init_led_pin();
	led_on_off();
	init_exti_pin();
	init_exti();
	while(1){
		
	}
}