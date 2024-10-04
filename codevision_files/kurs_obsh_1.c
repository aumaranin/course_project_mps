#include <mega8.h>
#include <delay.h>   
#include <stdlib.h>

//���� USART
#define RXCIE 7
#define TXCIE 6
#define RXEN 4
#define TXEN 3         
#define TXC 6 // ���� �������� UCSRA, ����������������� � 1 ��� ���������� ��������  
#define UDRE 5 // ���� �������� UCSRA, ����������������� � 1, ����� ������� ������ ����

//���� TWI (I2C)
#define TWINT 7        
#define TWEA 6     
#define TWSTA 5
#define TWSTO 4
#define TWEN 2  

//���� �������1
#define OCIE1A 4 //��� ��� ���������� ���������� �� ����������    
#define WGM12 3  //��� ��� ������ �������� �������� ��� ���������� 
#define CS10 0   //��� ���� ��������� ��������
#define CS12 2
 

char porog_temp = 5; //��������� �����������.   
unsigned digit[11] = {0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111, 0b01000000}; //������ � ������� ��� ��������������� ����������, 11 ������� - ���� "-"
unsigned razr[5] = {0b11111000, 0b11110100, 0b11101100, 0b11011100, 0b10111100}; //������ � �������� �������� ��������������� ����������


unsigned dat_adr[7] = {0b10010000, 0b10010010, 0b10010100, 0b10010110, 0b10011000, 0b10011010, 0b10011100}; //������ �������� ��� i2c ���������� c ��������� ����� �� 1 ������ (�.�. � i2c ������� ��� - ����� ������� ��� ������)    
char dat_temp1; //����������, � ������� �������� ����� ������ ����������� �������� �������
char dat_temp2; //����������, � ������� �������� ������� ������ ����������� �������� ������� 
unsigned char message[5]; //������ ��� ������ �� �������������� ������� 
unsigned char fl;//���� ��� ������ �� ������ ������ � ������������ �������

void decode(); //������� �������������� ���� ����������������� ����� � ������ �� ���� ���������, ���������� ���� ���� ���������� ������� ��� ��������������� �������
unsigned char dat_num = 1; //����� �������� �������  

void reset() //������� ����� ���� �������� � ����������� � ���������� � ������ ������
{                  
	dat_num = 7;
	
}       

unsigned char usart_message[8]; //���������, ������� ����� ���������� �� USART �� ����
void temp_transmit()  //������� ��� �������� ��������� �� usart �� ����                                                                             
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

//������� ��� ������� ���������� ����������� � ��������
void dat_init();	
void dat_conf(unsigned char adr);

//������� ��������� ����������� �������
void get_temp(unsigned char adr);       


unsigned char re_mes[4];   //���������, ������� ����� ������� �� USART �� ����         
unsigned char us_s = 0;

interrupt [USART_RXC] void u_rec()   //���������� �� ������ ����� � ���������� usart
{ 	                          	                                            
	//������ ���� ������������ � ������ re_mes, ������� 4 �������
	//���� ������ = Enter ������ �������� ��� ��������� ����������� � ����� �������� ���������� �������
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
	fl = 0; //��� ���������� ������� �1 ������������ ����, � ������������� ����� ������������� �������.
}    

void main(void)
{            

	DDRB = 0xFF; //���� B �� ����� ��� ������ � 8�� ���������� �����������
	PORTB = 0x00; //��������� �������� - �������.        
	
	DDRD = 0b11111100; //���� � �� ����� ��� ������ � �������� 8�� ���������� �����������
	PORTD = 0b11111100; //��������� �������� - �� ���� �� �������� �� ��������                                                                 
	
	//��������� USART
	UBRRL = 1; //�������� 250� ���
        UCSRB = (1 << RXCIE) | (1 << RXEN) | (1 << TXEN); // ���������� ����� ���������� ������, ����� � �������� ���������.
        
	//��������� TWI (I2C)
	//������������ ��������������� ����� �������, ����� ������� ������������� 
	//SCL = 100 ��� (��������� ������� ������ ������� ����������� DS1621 �� ������������.)
	//F_SCL = F_CPU / ( 16 + 2 * TWBR * 4^TWPS ) - ������� �������.
	TWBR = 0x20;      //��������� �������� ������� ������ i2c. 
	TWSR = 0x00;      //��������� ������������ ������� ������ i2c, ��������� ��������� ���� - �������.  	
	
	//��������� ������� T1, ������� ����� �������� � ������ "���������". 
	OCR1AH = 0x5B; //������ �������� � ������� ����������, ������� ������� ����, ����� �������
	OCR1AL = 0x8D; //�������� ���������� ������ �� �������� = 3�, �������� �� 1024 � ������� �� = 8���.       
	TIMSK = (1 << OCIE1A); //�������� ���������� �� ���������� �������� �������� ������� �1 ������ A � ��������� ���������
	#asm("sei");  
	TCCR1A = 0;
	TCCR1B = (1 << WGM12); //����� �������� �������� ��� ����������   
	//TCCR1B |= (0 << CS10) | (0 << CS12); //��������� �������� = 1024  ����
	
	
	
	
	
	dat_init(); //���������� ����������� ���������   
	delay_ms(1000); // ����� �� ���������� ����������� ���������                               

	while (1)
	{       		
		unsigned char i; //������� �������� �������� ��������������� ������� 
		unsigned char f2 = 0; //���� ��������: ��������� �� ��������� ������� ��������� ��������.
		//���� f2 = 1, �� �������� ���������� � ���������� �� USART, ���� 0 - ������� � ����.�������
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
	        
	 			
		if (f2) //���� ����������� � ������� ��������� ���������
		{
			decode(); //���������������� ������ ��� ����������� �� ����� �� �������������� �����������
			temp_transmit();
			TCCR1B |= (1 << CS10) | (1 << CS12); //��������� �������� = 1024  ���
							     //����������� ������, ������������� 3 �������
							     //�� ������������ ����������� ����� ������� 
							     
			while (fl)                           //������ � ���� ��������������� ���������� ����������
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
       	
       	//������ ������ �������, ����� ������ � ����������
       	TWDR = adr;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) )); 
       	
       	//�������� ������� ������� �� ���������� �����������
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
       	
       	//������ ������ �������, ����� ������ � ����������
       	TWDR = adr;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));
       	
       	//�������� ������� ������� �� ����� �����������
       	TWDR = 0xAA;
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));        	
       	
	//��������� �����	 
       	TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
       	while (!(TWCR & (1 << TWINT) ));        	
       	
       	//������ ������ �������, ����� ������ � ����������       	   
       	TWDR = (adr | 1);
       	TWCR = (1 << TWINT) | (1 << TWEN); 
       	while (!(TWCR & (1 << TWINT) ));       	       	
       	
   	//�������� TWI, �������� ������ ���� �����������, �������� ����� ACK
   	TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA); 
       	while (!(TWCR & (1 << TWINT) ));             	
        dat_temp1 = TWDR;  
       	
	//�������� TWI, �������� ������ ���� �����������, �������� ����� NAK
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
	usart_message[1] = ' '; // ������
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
	usart_message[7] = 0x0D; //������� �� ��������� ������
}