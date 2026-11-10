/*	Program that uses DMA1 to transfer data
		from source to destination sram memory address
*/

#include <stm32f10x.h>

volatile char transmision_complete =0;

int main(){
	char source[16]="0123456789ABCDEF";
	char destination[16];
	RCC->AHBENR = (1 << 0); //DMA1 clock enable
	
	//Define source and destination address
	DMA1_Channel1->CPAR = (uint32_t) source; 
	DMA1_Channel1->CMAR = (uint32_t) destination;
	
	DMA1_Channel1->CNDTR = 16; //number of bytes to transfer
	/********************************************************/
	/*mem to mem transfer, memory increment, peripheral increment,
	transfer complete interrupt enable & channel enabled*/
	DMA1_Channel1->CCR |= (1 << 14)|(1 << 7)|(1 << 6)|(1 << 1)|(1 << 0);
	
	
	NVIC_EnableIRQ(DMA1_Channel1_IRQn); //Enable interrupt for channel 1
	
	while(transmision_complete == 0); //wait for transmision complete
}

//interrupt handler
void DMA1_Channel1_IRQHandler(void){
	if ((DMA1->ISR & (1 << 1)) != 0) //if transmission complete
	{
		DMA1->IFCR = (1 << 1); //set channel transfer complete
		transmision_complete = 1;
	}
}
