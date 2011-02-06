/******************************************
*	CMTEmuSub.h
*	
*	作成者
*		黒岩　亮
*	
*	内容
*		実行モジュールのヘッダ
*	
*	作成日時
*		2008/12/13(土)
*	
*	最終更新日時
*		2008/12/18(木)
******************************************/
#include "CMTGeneral.h"

#define MEMORY_LEN sizeof(uint16_t)
#define MEMORY_SIZE 0xFFFF
#define END_SYMBOL 0
#define T_ADDRESS ((com->xr == 0) ? (com->address) : (com->address + emu->gr[com->xr]))    //XRを足したaddress、プリントで言うと有効アドレス
#define GR_CONTENTS (emu->gr[com->gr])				//命令のGRが指定する中身
#define ADDRESS_CONTENTS (emu->memory[T_ADDRESS])		//有効アドレス(+XR)の中身、プリントで言うと(有効アドレス)
#define SP_CONTENTS (emu->memory[*emu->sp])		//(SP)番地

/*****************************
 * 内部で使う変数の定義
 ****************************/
/* 構造体 EXECommand
 * 内容 命令セット　オペコードとオペランド
 */
struct exe_command_struct{
	uint8_t op;
	uint8_t gr;
	uint16_t address;
	uint8_t xr;
};
typedef struct exe_command_struct EXECommand;
/* 構造体 EXECommandDef
 * 内容 命令を定義するためのもの
 */
struct exe_command_list_stract{
	uint8_t op;
	void (*func)(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
};
typedef struct exe_command_list_stract EXECommandDef;


/*****************************
 * 内部で使うモジュール
 ****************************/
extern void _EXEDivideCommand(EXECommand* command, uint16_t* data);
extern CMTReturn _EXESetDefaultPc(CMTEmu* emu);
extern CMTReturn _EXESetGr(CMTEmu* emu, uint16_t data, uint8_t addr);
extern void _EXESetMemoryWithFlag(CMTEmu* emu, uint16_t addr, uint16_t data, CMTExecuteResult* res);
extern CMTReturn _EXEGetMemoryBlock(CMTEmu* emu, uint16_t addr, uint16_t* data, size_t len);

//命令群

extern void _EXE_LD(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_ST(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_LEA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_ADD(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_SUB(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_AND(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_OR(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_EOR(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_CPA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_CPL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_SLA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_SRA(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_SLL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_SRL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_JPZ(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_JMI(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_JNZ(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_JZE(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_JMP(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_PUSH(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_POP(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_CALL(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);
extern void _EXE_RET(CMTEmu* emu, EXECommand* com, CMTExecuteResult* res);

//命令テーブル
extern const EXECommandDef def_command[25];
