/******************************************
*	Test.c
*	
*	作成者
*		黒岩　亮
*	
*	内容
*		エミュレータモジュールの動作確認用
*	
*	作成日時
*		2008/12/13(土)
*	
*	最終更新日時
*		2008/12/28(日)
******************************************/

#include <stdio.h>
#include "CMTEmulator.h"
#define DISP() printf("GR0:%04X, GR1:%04X, GR2:%04X, GR3:%04X, GR4:%04X, FR:%X, PC:%04X\n",emu->gr[0], emu->gr[1], emu->gr[2], emu->gr[3], emu->gr[4], emu->fr, emu->pc)



int main(void)
{
	CMTEmu* emu;
	CMTExecuteResult res;
	
	//uint16_t mem[0xFFFF] = {0x1210,0x0000,0x1231,0x0000,0x1210,0x0001,0x1221,0x0000,0x1130,0x0016,0x2010,0x0016,0x1120,0x0016,0x1221,0x0000,0x4010,0x0017,0x61f0,0x000a,0x64f0,0xf0b0,0x0000,0x2710};
	uint16_t mem[0xFFFF] = {0x80f0,0x0008,0x80f0,0x0008,0x80f0,0x0008,0x64f0,0xf0b0,0x2010,0x0005,0x81f0,0xffff};
	emu = CMTEmuCreate(mem);
	
	DISP();
	while(1){
		//getchar();
		res = CMTExecuteStep(emu);
		DISP();
		if(res.exit_op == CMTTrue){
			printf("ぶれいくったー\n");
			break;
		}
		if(res.return_flag != CMTNoError){
			printf("えらー %d\n",res.return_flag);
			//break;
		}
		if(res.return_flag == CMTInvalidOperation){
			printf("ぶれいく\n");
			break;
		}
	}
	CMTEmuRelease(emu);
	
	return 0;
}
