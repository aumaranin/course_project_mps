#include <mega8.h>
#include <delay.h>   
#include <stdlib.h>

//биты USART
#define RXCIE 7
#define TXCIE 6
#define RXEN 4
#define TXEN 3         
#define TXC 6 // флаг регистра UCSRA, устанавливающийся в 1 при завершении передачи  
#define UDRE 5 // флаг регистра UCSRA, устанавливающийся в 1, когда регистр данных пуст

//биты TWI (I2C)
#define TWINT 7        
#define TWEA 6     
#define TWSTA 5
#define TWSTO 4
#define TWEN 2  

//биты таймера1
#define OCIE1A 4 //бит для разрешения прерывания по совпадению    
#define WGM12 3  //бит для сброса счетного регистра при совпадении 
#define CS10 0   //два бита настройки делителя
#define CS12 2
 

char porog_temp = 5; //пороговая температура.   
unsigned digit[11] = {0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111, 0b01000000}; //массив с числами для семисегментного индикатора, 11 элемент - знак "-"
unsigned razr[5] = {0b11111000, 0b11110100, 0b11101100, 0b11011100, 0b10111100}; //массив с номерами разрядов семисегментного индикатора


unsigned dat_adr[7] = {0b10010000, 0b10010010, 0b10010100, 0b10010110, 0b10011000, 0b10011010, 0b10011100}; //адреса датчиков для i2c интерфейса c сдвинутым влево на 1 разряд (т.к. в i2c нулевой бит - режим чтенияя или записи)    
char dat_temp1; //переменная, в которой хранится целая часить температуры текущего датчика
char dat_temp2; //переменная, в которой хранится дробная часить температуры текущего датчика 
unsigned char message[5]; //массив для печати на семисегментный дисплей 
unsigned char fl;//флаг для выхода из режима печати и переключение датчика

void decode(); //функция преобразования двух шестнадцатиричных чисел в строку из пяти элементов, содержащих биты цифр десятичной системы для семисегментного дислпея
unsigned char dat_num = 1; //номер текущего датчика  

void reset() //функция броса всех настроек к стандартным и подготовки к началу работы
{                  
	dat_num = 7;
	
}       

unsigned char usart_message[8]; //сообщение, которое будет отправлено по USART на ПЭВМ
void temp_transmit()  //функция для передачи сообщение по usart на ПЭВМ                                                                             
{	
	unsigned char sh = 0;   
	while (sh < 8)
	{            
		UDR = usart_message[sh];
		while (!(UCSRA & (1 << UDRE)))
		{
			#asm("nop");	
		}		
		sh++;
	}
}

//функции для запуска вычислений температуры в датчиках
void dat_init();	
void dat_conf(unsigned char adr);

//функция получения результатов датчика
void get_temp(unsigned char adr);       


unsigned char re_mes[4];   //сообщение, которое будет принято по USART от ПЭВМ         
unsigned char us_s = 0;

interrupt [USART_RXC] void u_rec()   //прерывание по приему байта с интерфейса usart
{ 	                          	                                            
	//каждый байт записывается в строку re_mes, длинной 4 символа
	//если символ = Enter данные воодятся как пороговая температура и отчет датчиков начинается сначала
	re_mes[us_s] = UDR;           
	if (re_mes[us_s] == 0x0D)
	{                         
		porog_temp = atoi(re_mes);
		us_s = 0;
		reset();
	}
	else
	{         
		us_s++;
		if (us_s > 3)
			us_s = 0;
	}
}

interrupt [TIM1_COMPA] void timer_int()
{ 	 
	fl = 0; //при прерывании таймера Т1 сбрасывается флаг, и переключается номер отображаемого датчика.
}    

void main(void)
{            

	DDRB = 0xFF; //порт B на выход для работы с 8ми сегментным индикатором
	PORTB = 0x00; //начальное значение - погашен.        
	
	DDRD = 0b11111100; //порт С на выход для работы с катодами 8ми сегментных индикаторов
	PORTD = 0b11111100; //начальнео значение - ни один из разрядов не работает                                                                 
	
	//настройка USART
	UBRRL = 1; //скорость 250к бод
        UCSRB = (1 << RXCIE) | (1 << RXEN) | (1 << TXEN); // прерывание после завершения приема, прием и передача разрешены.
        
	//настройка TWI (I2C)
	//предделители устанавливаются таким образом, чтобы частота синхросигнала 
	//SCL = 100 КГц (требуемая частота работы датчика температуры DS1621 по спецификации.)
	//F_SCL = F_CPU / ( 16 + 2 * TWBR * 4^TWPS ) - формула расчета.
	TWBR = 0x20;      //установка делителя частоты работы i2c. 
	TWSR = 0x00;      //установка предделителя частоты работы i2c, начальное состояние шины - нулевое.  	
	
	//настройка таймера T1, который будет работать в режиме "сравнения". 
	OCR1AH = 0x5B; //запись значений в регистр совпадения, сначала старший байт, потом младший
	OCR1AL = 0x8D; //значение выбиралось исходя из задержки = 3с, делителя на 1024 и частоты МК = 8МГц.       
	TIMSK = (1 << OCIE1A); //включено прерывание по совпадению счетного регистра таймера Т1 канала A с регистром сравнения
	#asm("sei");  
	TCCR1A = 0;
	TCCR1B = (1 << WGM12); //сброс счетного счетчика при совпадении   
	//TCCR1B |= (0 << CS10) | (0 << CS12); //установка делителя = 1024  выкл
	
	
	
	
	
	dat_init(); //вычисление температуры датчиками   
	delay_ms(1000); // время на вычисление температуры датчиками                               

	while (1)
	{       		
		unsigned char i; //счетчик перебора разрядов семисегментного дисплея 
		unsigned char f2 = 0; //флаг проверки: превышает ли показания датчика пороговое значение.
		//если f2 = 1, то значения печатаются и передаются по USART, если 0 - переход к след.датчику
		fl = 0xFF;

		get_temp(dat_adr[dat_num-1]);
		 
                

	        if ( ((dat_temp1 < 0x80) && (porog_temp < 0x80)) || ((dat_temp1 >= 0x80) && (porog_temp >= 0x80)) )
	        	if (dat_temp1 >= porog_temp)
	        		f2 = 1;
	        	else
	        		f2 = 0;
	        else		
                {
	        	if ((dat_temp1 >= 0x80) && (porog_temp < 0x80))
	        		f2 = 0;
		        if ((dat_temp1 < 0x80) && (porog_temp >= 0x80))
		        	f2 = 1;
	        } 
	        
	 			
		if (f2) //если температура с датчика превышает пороговую
		{
			decode(); //подготавливается строка для отображение на блоке из семисегментных индикаторов
			temp_transmit();
			TCCR1B |= (1 << CS10) | (1 << CS12); //установка делителя = 1024  вкл
							     //запускается таймер, отсчитывающий 3 секунды
							     //на отоборажение результатов этого датчика 
							     
			while (fl)                           //печать в блок семисегментного индикатора ПОРАЗРЯДНО
			{		
				PORTB = message[i];		
				PORTD = razr[4 - i];
				delay_ms(3);      
				PORTB = 0;
				i++;
				if (i > 4)
					i = 0;	
			}
		}
		
		dat_num++;
		if (dat_num == 8)
			dat_num = 1;
	}	
	
	
}

                        
void dat_conf(unsigned char adr)
{     
	//start	 
       	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
       	while (!(TWCR & (1 << TWINT) )); 
       	
       	//вводим адресс датчика, режим записи и отправляем
       	TWDR = adr;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) )); 
       	
       	//передаем команду датчику на вычисление результатов
       	TWDR = 0xEE;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));   
       	
       	//stop
	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);
}

void dat_init()
{           
	unsigned char q = 0;
	while (q < 7)
	{
		dat_conf(dat_adr[q]);
		q++;
	}	
}              

void get_temp(unsigned char adr)
{
	//start	 
       	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
       	while (!(TWCR & (1 << TWINT) )); 
       	
       	//вводим адресс датчика, режим записи и отправляем
       	TWDR = adr;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));
       	
       	//передаем команду датчику на вывод результатов
       	TWDR = 0xAA;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));        	
       	
	//повторный старт	 
       	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
       	while (!(TWCR & (1 << TWINT) ));        	
       	
       	//вводим адресс датчика, режим чтения и отправляем       	   
       	TWDR = (adr | 1);
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));       	       	
       	
   	//включаем TWI, получаем первый байт температуры, посылаем ответ ACK
   	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA); 
       	while (!(TWCR & (1 << TWINT) ));             	
        dat_temp1 = TWDR;  
       	
	//включаем TWI, получаем второй байт температуры, посылаем ответ NAK
        TWCR = (1 << TWINT) | (1 << TWEN) | (0 << TWEA);
       	while (!(TWCR & (1 << TWINT) ));             	
       	dat_temp2 = TWDR;  
       	
       	//stop
	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWSTO);		
}

void decode()
{
	unsigned char r1, r2, r3; 
                
	message[0] = digit[dat_num];   
	usart_message[0] = dat_num + 0x30;
	usart_message[1] = ' '; // пробел
	if (dat_temp1 & 0b10000000) 	
	{       		
		dat_temp1 = (dat_temp1 ^ 0b11111111) + 1;  
		if (dat_temp2 == 0x80) dat_temp1--;
		message[1] = digit[10];  
		usart_message[2] = '-';
	}
	else
	{
		r3 = dat_temp1 / 100; 
                message[1] = digit[r3];    
               	usart_message[2] = r3 + 0x30;
  	}
	dat_temp1 %= 100;
	r2 = dat_temp1 / 10;
	message[2] = digit[r2];       
	usart_message[3] = r2 + 0x30;    
	
	dat_temp1 %= 10;       
	r1 = dat_temp1;        
	message[3] = (digit[r1] | 0b10000000);    
	usart_message[4] = r1 + 0x30;
	usart_message[5] = '.';
	if (dat_temp2 == 0x80)
	{
		message[4] = digit[5];
		usart_message[6] = '5';
	}
	else                          
	{
		message[4] = digit[0]; 
		usart_message[6] = '0';
	}    
	usart_message[7] = 0x0D; //переход на следующую строку
}