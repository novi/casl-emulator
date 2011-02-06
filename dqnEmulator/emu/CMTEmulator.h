/******************************************
*	CMTEmulator.h
*	
*	作成者
*		黒岩　亮
*	
*	内容
*		エミュレータモジュールのヘッダ
*	
*	作成日時
*		2008/12/12(金)
*	
*	最終更新日時
*		2008/12/28(日)
******************************************/

#include "CMTGeneral.h"


/*****************************
 * 外部から使われるモジュール
 ****************************/
/* CMTEmuCreate
 * 内容 CMTEmuを新しく作る　領域確保
 */
extern CMTEmu* CMTEmuCreate(uint16_t* mainMemory);

/* CMTExecuteStep
 * 内容 
 */
extern CMTExecuteResult CMTExecuteStep(CMTEmu* emu);

/* CMTGetRegister
 * 内容 
 */
extern CMTEmuRegister CMTGetRegister(CMTEmu* emu);

/* CMTEmuRelease
 * 内容 
 */
extern void CMTEmuRelease(CMTEmu* emu);

/* CMTSetPc
 * 内容 
 */
extern CMTReturn CMTSetPC(CMTEmu* emu, uint16_t data);
