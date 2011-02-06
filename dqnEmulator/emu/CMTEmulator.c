/******************************************
*	CMTEmulator.c
*	
*	作成者
*		黒岩　亮
*	
*	内容
*		エミュレータモジュール
*	
*	作成日時
*		2008/12/13(土)
*	
*	最終更新日時
*		2008/12/30(火)
******************************************/

#include "CMTEmuSub.h"


CMTEmu* CMTEmuCreate(uint16_t* mainMemory) //できた	
{
	int i;
	CMTEmu* emu;
	emu = malloc(sizeof(CMTEmu));
	if (emu == NULL){
		return NULL;
	}
	
	for(i = 0; i < 4; i++){
		emu->gr[i] = 0;
	}
	emu->memory = mainMemory;
	emu->sp = &(emu->gr[4]);
	emu->gr[4] = CMTSpAddress;
	emu->pc = 0;
	emu->fr = 0;
	return emu;
}

void CMTEmuRelease(CMTEmu* emu)	//できた
{
	free(emu);
	emu = NULL;
}

CMTEmuRegister CMTGetRegister(CMTEmu* emu) //たぶんできた
{
	CMTEmuRegister cmt_reg;
	int i;
	for (i = 0; i < 5; i++){
		cmt_reg.gr[i] = emu->gr[i];
	}
	cmt_reg.pc = emu->pc;
	cmt_reg.fr = emu->fr;
	return cmt_reg;
}

CMTReturn CMTSetPC(CMTEmu* emu, uint16_t data) //正常処理できた
{
	CMTReturn cmt_ret;
	emu->pc = data;
	cmt_ret = CMTNoError;
	return cmt_ret;
}

CMTExecuteResult CMTExecuteStep(CMTEmu* emu)
{
	CMTExecuteResult cmt_exe_res;
	CMTReturn cmt_ret;
	EXECommand command;
	uint16_t data[2];
	int i;
	
	cmt_exe_res.addr_changed = CMTFalse;	//結果を初期化
	cmt_exe_res.exit_op = CMTFalse;			//結果を初期化
	cmt_exe_res.return_flag = CMTNoError;	//結果を初期化
	cmt_ret = _EXEGetMemoryBlock(emu, emu->pc, data, 2);	//メモリから2語長取り込み
	if(cmt_ret == CMTOutOfMemoryArea){	//erorr
		cmt_exe_res.return_flag = CMTOutOfMemoryArea;
		return cmt_exe_res;
	}
	_EXEDivideCommand(&command, data);	//2語長を構造体に格納
	
	//printf("#%02X,%1X,%1X,%04X\n",command.op,command.gr,command.xr,command.address);	//debug
	i = 0;
	while(1){
		if(def_command[i].op == END_SYMBOL){	//オペレーションがないとき
			cmt_exe_res.return_flag = CMTInvalidOperation;
			return cmt_exe_res;
		}
		else if(def_command[i].op == command.op){		//オペレーションが見つかったとき
			def_command[i].func(emu, &command, &cmt_exe_res);	//命令実行
			break;
		}
		i++;
	}
	return cmt_exe_res;
}

