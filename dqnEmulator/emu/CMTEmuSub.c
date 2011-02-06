/******************************************
*	CMTEmuSub.c
*	
*	作成者
*		黒岩　亮
*	
*	内容
*		命令モジュール
*	
*	作成日時
*		2008/12/13(土)
*	
*	最終更新日時
*		2008/12/18(木)
******************************************/

#include "CMTEmuSub.h"

const EXECommandDef def_command[25] = {
	{0x10, _EXE_LD},
	{0x11, _EXE_ST},
	{0x12, _EXE_LEA},
	{0x20, _EXE_ADD},
	{0x21, _EXE_SUB},
	{0x30, _EXE_AND},
	{0x31, _EXE_OR},
	{0x32, _EXE_EOR},
	{0x40, _EXE_CPA},
	{0x41, _EXE_CPL},
	{0x50, _EXE_SLA},
	{0x51, _EXE_SRA},
	{0x52, _EXE_SLL},
	{0x53, _EXE_SRL},
	{0x60, _EXE_JPZ},
	{0x61, _EXE_JMI},
	{0x62, _EXE_JNZ},
	{0x63, _EXE_JZE},
	{0x64, _EXE_JMP},
	{0x70, _EXE_PUSH},
	{0x71, _EXE_POP},
	{0x80, _EXE_CALL},
	{0x81, _EXE_RET},
	{END_SYMBOL, 0}
};

//内部モジュール
//メモリからlenの長さだけ読み込む
CMTReturn _EXEGetMemoryBlock(CMTEmu* emu, uint16_t addr, uint16_t* data, size_t len) //正常処理できた
{
	CMTReturn cmt_ret;
	if(addr + len > MEMORY_SIZE){
		cmt_ret = CMTOutOfMemoryArea;
	}
	else{
		int i;
		for (i = 0; i < len; i++){
			data[i] = emu->memory[addr + i];
		}
		cmt_ret = CMTNoError;
	}
	return cmt_ret;
}

//エミュレータモジュールで使用
void _EXEDivideCommand(EXECommand* command, uint16_t* data)
{
	command->op = data[0] >> 8;
	command->gr = (data[0] & 0x00F0) >> 4;
	command->xr = data[0] & 0x000F;
	command->address = data[1];
}

//ジャンプ命令以外の命令はこれでPCを次へセット
CMTReturn _EXESetDefaultPc(CMTEmu* emu)
{
	CMTReturn cmt_ret;
	if(emu->pc < MEMORY_SIZE){
		emu->pc += 2;
		cmt_ret = CMTNoError;
	}
	else{
		cmt_ret = CMTOutOfMemoryArea;
	}
	return cmt_ret;
}

//GRに値をセットするときはこれを使う
CMTReturn _EXESetGr(CMTEmu* emu, uint16_t data, uint8_t addr)
{
	union int16bit{
		uint16_t u;
		int16_t i;
	}temp;
	CMTReturn cmt_ret;
	
	if(addr <= 4){
		emu->gr[addr] = data;
	}
	else{
		//grの添え字が4以上のとき
		//この場合はあるのかわからないけど一応…
		//erorr
		cmt_ret = CMTInvaildOperand;
		return cmt_ret;
	}
	temp.u = data;
	if(temp.i > 0){
		emu->fr = 0;
	}
	else if(temp.i == 0){
		emu->fr = 1;
	}
	else{
		emu->fr = 2;
	}
	cmt_ret = CMTNoError;
	return cmt_ret;
}

//メモリに書き込みを行うときはこれを使う
void _EXESetMemoryWithFlag(CMTEmu* emu, uint16_t addr, uint16_t data, CMTExecuteResult* res)
{
	emu->memory[addr] = data;
	res->addr_changed = CMTTrue;
	res->changed_addr = addr;
}

/**************************************************
 * 命令群
 **************************************************/

/* ロード、ストア命令
 **************************************************/
void _EXE_LD(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	//_EXESetGrを使わないのは、FRをセットしないため
	GR_CONTENTS = ADDRESS_CONTENTS;	//(有効アドレス)をGRに設定する
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_ST(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	_EXESetMemoryWithFlag(emu, T_ADDRESS, GR_CONTENTS, res);	//(GR)を有効アドレスが示す番地に格納する
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

/* ロードアドレス命令
 **************************************************/
void _EXE_LEA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	
	cmt_ret = _EXESetGr(emu, T_ADDRESS, com->gr);	//有効アドレスをGRに設定する
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}


/* 算術、論理演算命令
 * (GR)と(有効アドレス)に、指定した演算を施し、結果をGRに設定する
; **************************************************/
void _EXE_ADD(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	
	cmt_ret = _EXESetGr(emu, GR_CONTENTS + ADDRESS_CONTENTS, com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_SUB(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	
	cmt_ret = _EXESetGr(emu, GR_CONTENTS - ADDRESS_CONTENTS, com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_AND(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	
	cmt_ret = _EXESetGr(emu, GR_CONTENTS & ADDRESS_CONTENTS, com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_OR(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	
	cmt_ret = _EXESetGr(emu, GR_CONTENTS | ADDRESS_CONTENTS, com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_EOR(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	
	cmt_ret = _EXESetGr(emu, GR_CONTENTS ^ ADDRESS_CONTENTS, com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

/* 比較演算命令
 **************************************************/
void _EXE_CPA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{

	if( (int16_t)GR_CONTENTS > (int16_t)ADDRESS_CONTENTS){
		emu->fr = 0;
	}
	else if( (int16_t)GR_CONTENTS == (int16_t)ADDRESS_CONTENTS){
		emu->fr = 1;
	}
	else{
		emu->fr = 2;
	}
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_CPL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	
	if( GR_CONTENTS > ADDRESS_CONTENTS){
		emu->fr = 0;
	}
	else if(GR_CONTENTS == ADDRESS_CONTENTS){
		emu->fr = 1;
	}
	else{
		emu->fr = 2;
	}
	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}


/* シフト演算命令
 **************************************************/
void _EXE_SLA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	uint16_t c=GR_CONTENTS;

	c=((GR_CONTENTS<< T_ADDRESS) & 0x7FFF) | (GR_CONTENTS & 0x8000);
	
	cmt_ret = _EXESetGr(emu, c, com->gr);
	
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}

	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_SRA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;
	int i;
	uint16_t c=GR_CONTENTS;
	
	for(i=0;i<T_ADDRESS;i++){
		c=((c >> 1) & 0x7FFF) | (c & 0x8000);
	}
	cmt_ret = _EXESetGr(emu, c, com->gr);
	
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}
res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_SLL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;

	cmt_ret = _EXESetGr(emu, (GR_CONTENTS << T_ADDRESS), com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

void _EXE_SRL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;

	cmt_ret = _EXESetGr(emu, (GR_CONTENTS >> T_ADDRESS), com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}


/* 分岐命令
 **************************************************/
void _EXE_JPZ(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	if(emu->fr == 0 || emu->fr == 1){
		emu->pc = T_ADDRESS;	//有効アドレスに分岐する
		res->return_flag = CMTNoError;
	}
	else{
		res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
	}
}

void _EXE_JMI(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	if(emu->fr == 2){
		emu->pc = T_ADDRESS;	//有効アドレスに分岐する
		res->return_flag = CMTNoError;
	}
	else{
		res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
	}	
}

void _EXE_JNZ(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	if(emu->fr != 1){
		emu->pc = T_ADDRESS;	//有効アドレスに分岐する
		res->return_flag = CMTNoError;
	}
	else{
		res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
	}
}

void _EXE_JZE(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	if(emu->fr== 1){
		emu->pc = T_ADDRESS;	//有効アドレスに分岐する
		res->return_flag = CMTNoError;
	}
	else{
		res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
	}
}

void _EXE_JMP(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	//JMPはEXITを行ったりするので特別な処理
	//ちなみにGR0の中身が0でないときは無限ループになるのでアセンブラのプログラム注意
	//if(T_ADDRESS == 0xF0B0){	//強制終了するためやめておく
	if(com->address == 0xF0B0){	//EXITなら
		res->exit_op = CMTTrue;
	}
	emu->pc = T_ADDRESS;	//有効アドレスに分岐する
	res->return_flag = CMTNoError;
}


/* スタック操作命令 ：
 **************************************************/
/*	 SPから1アドレス減算した後,有効アドレスを(SP)番地に格納する*/
void _EXE_PUSH(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	--*emu->sp;					   //SPから1アドレス減算した
	SP_CONTENTS = T_ADDRESS;	   //有効アドレスを(SP)番地に格納する
	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}

/*（SP）番地の内容をGRに設定した後、SPに１をアドレス加算する*/
void _EXE_POP(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	CMTReturn cmt_ret;

	GR_CONTENTS = SP_CONTENTS; //（SP）番地の内容
	cmt_ret = _EXESetGr(emu, GR_CONTENTS, com->gr);
	if(cmt_ret != CMTNoError){		//GRの設定時にエラーがある場合
		res->return_flag = cmt_ret;
		return;
	}
	++*emu->sp;
	
	res->return_flag = _EXESetDefaultPc(emu);	//PCを次へセット
}


/* コール、リターン命令
 **************************************************/
void _EXE_CALL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	--*emu->sp;
	SP_CONTENTS = emu->pc + 2;		 //(SP)番地
	emu->pc = T_ADDRESS;	//有効アドレスに分岐する
}

void _EXE_RET(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res)
{
	uint16_t sp_add;
	
	sp_add = SP_CONTENTS;
	++*emu->sp;
	emu->pc = sp_add;
}
