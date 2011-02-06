//
//  CSAssembler.h
//  asm-cs
//
//  Created by ito on 2008/11/06.
//  Copyright 2008 Ito. All rights reserved.
//

#import <Cocoa/Cocoa.h>

struct asm_line {
	int		macroListIndex;
	int		opListIndex;
	NSString* label;
	NSString* opeRand;
	NSString* realStr;
	NSUInteger realLine;
	uint32_t objCode;
	NSUInteger memSize;
};

typedef struct asm_line AsmLine;

struct asm_error {
	int		errorType;
	NSUInteger line;
};

typedef struct asm_error AsmError;

enum AssemblerError {
	AssemblerNoError = 0,
	AssemblerParseError,
	AssemblerLabelExist,
	AssemblerLabelNotFound,
	AssemblerInvalidOperand,
	AssemblerInvalidLabel,//
	AssemblerNoEND,//
	AssemblerNoSTART,//
	AssemblerInvalidConst,//
};


@interface CSAssembler : NSObject {
	
	NSArray*			_asmLinesStr;
	uint16_t			_startAddress;
	NSMutableArray*		_asmLines;
	NSString*			_source;
	NSMutableDictionary*	_labelTable;
	NSMutableArray*		_asmError;
}

- (void)assemble:(id)sender;



@property (retain) NSString* source;
@property (assign, readonly, nonatomic) uint16_t startAddress;
@property (retain, readonly, nonatomic) NSDictionary* labelTable;
@property (retain, readonly, nonatomic) NSArray* error;
@property (retain, readonly, nonatomic) NSArray* asmLines;

@end

