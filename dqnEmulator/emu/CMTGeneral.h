/******************************************
*	CMTGeneral.h
*	
*	作成者
*		黒岩　亮
*	
*	内容
*		共通のヘッダ
*	
*	作成日時
*		2008/12/13(土)
*	
*	最終更新日時
*		2008/12/16(火)
******************************************/

#include <stdio.h>
#include <stdint.h>		//uint16_tを使用するため
#include <stdlib.h>
#ifndef CMTGENERAL_H
#define CMTGENERAL_H

#define CMTFalse 0
#define CMTTrue 1

#define CMTSpAddress 0xFF00

typedef char CMTBool;
/*****************************
 * 外部から使われる変数の定義
 ****************************/
/* 構造体 CMTEmu
 * 内容 ハードウェアが保持する内容をまとめる
 */
struct cmt_emu_struct{
	/* memory */
	uint16_t* memory;
	/* registor */
	uint16_t gr[5];
	uint16_t pc;
	uint8_t fr;
	uint16_t* sp;
};
typedef struct cmt_emu_struct CMTEmu;

/* 構造体 CMTEmuRegister
 * 内容 レジスタ内容
 */
struct cmt_emu_reg_struct{
	uint16_t gr[5];
	uint16_t pc;
	uint8_t fr;
};
typedef struct cmt_emu_reg_struct CMTEmuRegister;

/* 列挙データ型 CMTReturn
 * 内容 通常の実行後の戻り値
 */
enum cmt_return_enum {
	CMTNoError = 0,
	CMTOutOfMemoryArea = -1,
	CMTInvalidOperation = -2,
	CMTInvaildOperand = -3,
};
typedef enum cmt_return_enum CMTReturn;

/* 構造体 CMTExecuteResult
 * 内容 アドレスに変更があったか、Step実行後の変化
 */
struct cmt_exe_res_struct{
	CMTReturn return_flag;		// 戻り値
	CMTBool exit_op;			//EXITのフラグ
	CMTBool addr_changed;	//アドレスが変わったかのフラグ
	uint16_t changed_addr;				//変更されたアドレス
};
typedef struct cmt_exe_res_struct CMTExecuteResult;

#endif
