//
//  CSAssembler.m
//  asm-cs
//
//  Created by ito on 2008/11/06.
//  Copyright 2008 Ito. All rights reserved.
//

#import "CSAssembler.h"
#import "CSInstructionList.h"



enum ParseLineError {
	ParseLineNoError = 0,
	ParseLineComponentCountError,
	ParseLineComponentError,
};

int GetMemorySize(AsmLine* a)
{
	if (a->opListIndex != 0) {
		return 2;
	}
	if (a->macroListIndex != 0) {
		if ([lMacroList[a->macroListIndex].macro isEqualToString:@"ds"]) {
			if ([a->opeRand intValue] < 0) {
				return 0;
			}
			return (uint16_t)[a->opeRand intValue];
		} else {
			return lMacroList[a->macroListIndex].memorySize;
		}
	}
	return 0;
}

void PrintAsmLine(AsmLine* a)
{
	NSLog(@"label:%@, macro:%@, operand:%@, opecode:%@, memsize:%d",a->label, lMacroList[a->macroListIndex].macro, lOpList[a->opListIndex].operation, a->opeRand, GetMemorySize(a));
}

AsmError* AsmErrorCreate(void)
{
	AsmError* asmError = malloc(sizeof(asmError));
	asmError->line = 0;
	asmError->errorType = AssemblerNoError;
	return asmError;
}

int GROperandToData(NSString* str)
{
	NSInteger i;
	for (i = 0; i < kGRListCount; i++) {
		if ([lGRList[i] isEqualToString:str]) {
			return i;
		}
	}
	return -1;
}

BOOL IsMacro(NSString* str, int* macroIndex)
{
	NSUInteger i;
	BOOL macroFlag = NO;
	for (i = 0; i < kMacroListCount; i++) {
		if ([lMacroList[i].macro isEqualToString:str] == YES) {
			//NSLog(@"marcro %@", str);
			if (macroIndex) {
				*macroIndex = i;
			}
			macroFlag = YES;
			break;
		}
	}
	return macroFlag;
}

BOOL IsOperation(NSString* str, int* opIndex)
{
	NSUInteger i;
	BOOL opFlag = NO;
	for (i = 0; i < kOpListCount; i++) {
		if ([lOpList[i].operation isEqualToString:str] == YES) {
			//NSLog(@"op: %@", str);
			if (opIndex) {
				*opIndex = i;
			}
			opFlag = YES;
			break;
		}
	}
	return opFlag;
}

BOOL IsLabel(NSString* str)
{
	if (IsOperation(str, NULL) == YES) {
		return NO;
	}
	return YES;
}

int GetIndexOfNoOperandOperation(NSString* str)
{
	NSUInteger i;
	int index = 0;
	for (i = 0; i < kOpListCount; i++) {
		if ([lOpList[i].operation isEqualToString:str] == YES && lOpList[i].min_opr == 0) {
			//NSLog(@"op: %@", str);
			index = i;
			break;
		}
	}
	return index;
}




NSArray* ParseStringByLine(NSString* string)
{
    NSString* parsedString;
	NSString* noLFString;
    NSRange range, subrange;
    int length;
	NSMutableArray* lines = [NSMutableArray array];
    
    length = [string length];
    range = NSMakeRange(0, length);
    while(range.length > 0) {
        subrange = [string lineRangeForRange:NSMakeRange(range.location, 0)];
        parsedString = [string substringWithRange:subrange];
		
		// Remove return code in line
		noLFString = [parsedString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		[lines addObject:noLFString];
        
        range.location = NSMaxRange(subrange);
        range.length -= subrange.length;
    }
	
	return lines;
}



@implementation CSAssembler

@synthesize asmLines = _asmLines;
@synthesize error = _asmError;
@synthesize startAddress = _startAddress;
@synthesize labelTable = _labelTable;
@synthesize source = _source;

- (id) init
{
	self = [super init];
	if (self != nil) {
		_asmLines = [[NSMutableArray alloc] init];
		_labelTable = [[NSMutableDictionary alloc] init];
		_asmError = [[NSMutableArray alloc] init];
	}
	return self;
}



// Parse line and add parsed line to _asm list
- (int)_parseLinePrepare:(NSString*)line_ realLine:(NSUInteger)rl
{
	NSUInteger i;
	int error;
	
	// Clear comment
	NSString* line;
	NSRange range = [line_ rangeOfString:@";"];
	if (range.location != NSNotFound) {
		line = [line_ substringToIndex:range.location];
		//NSLog(@"subrange %@", line);
	} else {
		line = line_;
	}
	
	
	NSMutableArray* components;
	NSArray* componentsAll = [line componentsSeparatedByString:@" "];
	components = [NSMutableArray array];
	for (NSString* part in componentsAll) {
		if ([part length]) {
			[components addObject:part];
		}
	}
	
	if ([components count] == 0) {
		return ParseLineNoError;
	}
	
	AsmLine* asmLine = malloc(sizeof(AsmLine));
	memset(asmLine, 0, sizeof(AsmLine));
	
	// Components over 7
	if ([components count] > 7) {
		error = ParseLineComponentCountError;
		goto parse_error;
	}
	
	// Components more than 3
	// Marge component of No.3 to 7 to one componet
	if ([components count] > 3) {
		NSMutableString* addOperand = [NSMutableString string];
		for (i = 2; i < [components count]; i++) {
			[addOperand appendString:[components objectAtIndex:i]];
		}
		[components removeObjectsInRange:NSMakeRange(2, [components count] - 2)];
		[components addObject:addOperand];
	}
	
	//NSLog(@"A %@", [components description]);
	
	// Components is 3
	// But 2 division line
	// Marge No.2 and No.3 component
	if ([components count] == 3) { 
		NSString* opa = [[components objectAtIndex:1] stringByAppendingString:[components objectAtIndex:2]];
		if ([[components objectAtIndex:1] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]].location != NSNotFound) {
			[components removeObjectsInRange:NSMakeRange(1, 2)];
			[components addObject:opa];
			//NSLog(@"987432");
		}
	}
	
	//NSLog(@"B %@", [components description]);
	
	int macroIndex = 0;
	int opListIndex = 0;
	
	// 1 Component Division
	if ([components count] == 1) {
		// Macro or not ?
		if (IsMacro([components lastObject], &macroIndex)) {
			asmLine->macroListIndex = macroIndex;
		} else {
			// Operation or not ?
			if ((opListIndex = GetIndexOfNoOperandOperation([components lastObject])) != 0) {
				asmLine->opListIndex = opListIndex;
			} else {
				// Error
				// Not macro and operation
				error = ParseLineComponentError;
				goto parse_error;
			}
		}
	}
	
	// 2 Components Division
	if ([components count] == 2) {
		if (IsOperation([components objectAtIndex:0], &opListIndex)) {
			// pattern 1
			asmLine->opListIndex = opListIndex;
			asmLine->opeRand = [components objectAtIndex:1];
		} else {
			if (IsMacro([components objectAtIndex:0], &macroIndex)) {
				asmLine->macroListIndex = macroIndex;
				//pattern 2
				asmLine->opeRand = [components objectAtIndex:1];
			} else if (IsLabel([components objectAtIndex:0]) && (opListIndex = GetIndexOfNoOperandOperation([components objectAtIndex:1])) != 0) {
				asmLine->label = [components objectAtIndex:0];
				asmLine->opListIndex = opListIndex;
			} else {
				error = ParseLineComponentError;
				goto parse_error;
			}
		}
		
	}
	
	// 3 Components Division
	if ([components count] == 3) {
		if (!IsLabel([components objectAtIndex:0])) {
			error = ParseLineComponentError;
			goto parse_error;
		}
		asmLine->label = [components objectAtIndex:0];
		
		if (!IsOperation([components objectAtIndex:1], &opListIndex)) {
			// not operation
			// may macro
			if (!IsMacro([components objectAtIndex:1], &macroIndex)) {
				// not macro
				// error
				error = ParseLineComponentError;
				goto parse_error;
			} else {
				asmLine->macroListIndex = macroIndex;
				// macro
			}
		} else {
			// operation
			asmLine->opListIndex = opListIndex;
		}
		asmLine->opeRand = [components objectAtIndex:2];
	}
	
	// Print parsed line for debug
//	PrintAsmLine(asmLine);
	asmLine->realStr = line;
	asmLine->realLine = rl;
	/*
	 if (lMacroList[asmLine->macroListIndex].asmLineType == AsmLineSTART) {
	 _startAddress = ParseAddressOperand(asmLine->opeRand, nil);
	 NSLog(@"start at %x", _startAddress);
	 return 0;
	 }*/
	
	// Add parsed line as AsmLine struct
	// Wrapped by NSValue
	[_asmLines addObject:[NSValue valueWithPointer:asmLine]];
	
	// Complete parse line
	return ParseLineNoError;
	
	// If occured error during parse
parse_error:
	free(asmLine);
	return error;
}

- (void)_addError:(int)errorCode realLineine:(NSUInteger)line
{
	AsmError* asmError = AsmErrorCreate();
	asmError->line = line;
	asmError->errorType = errorCode;
	[_asmError addObject:[NSValue valueWithPointer:asmError]];
}

- (NSUInteger)_createLabelTable
{
	NSUInteger i;
	
	// Clear label table
	// Add built in functions
	[_labelTable removeAllObjects];
	for (i = 0; i < kBuiltInFunctionsCount; i++) {
		[_labelTable setObject:[NSNumber numberWithUnsignedInteger:lBuiltInFuncs[i].addr] forKey:lBuiltInFuncs[i].label];
	}
	
	int ret = 0;
	NSUInteger memsize = 0;
	AsmLine* al;
	for (i = 0; i < [_asmLines count]; i++) {
		al = [[_asmLines objectAtIndex:i] pointerValue];
		if (!al->label) {
			memsize += GetMemorySize(al);
			// No label
			continue;
		}
		if ([_labelTable objectForKey:al->label]) {
			// Error the label is already exist
			//return i;
			ret = i;
			continue;
		}
		[_labelTable setObject:[NSNumber numberWithUnsignedInteger:memsize] forKey:al->label];
		memsize += GetMemorySize(al);
	}
	
	// No error
	return ret;
}

- (uint16_t) _parseAddressOperand:(NSString*)opa asmLine:(AsmLine*)al
{
	//NSLog(@"addr parser : %@", opa);
	uint16_t addr = 0;
	const char* addrStr;
	char* tolError = "";
	BOOL error = NO;
	
	if (!opa) {
		opa = al->opeRand;
	}
	
	if (opa == nil || [opa length] == 0) {
		AsmError* asmError = AsmErrorCreate();
		asmError->line = al->realLine;
		asmError->errorType = AssemblerInvalidOperand;
		[_asmError addObject:[NSValue valueWithPointer:asmError]];
		
		return 0;
	}
	
	if ([[opa substringToIndex:1] isEqualToString:@"#"]) {
		// Use string of operand as Hex
		addrStr = [[opa substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding];
		addr = strtol(addrStr, &tolError, 16);		
	} else if ([[opa substringToIndex:1] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound ||
			   [[opa substringToIndex:1] isEqualToString:@"-"] == YES) {
		// Use string of operand as Deciaml
		addrStr = [opa cStringUsingEncoding:NSUTF8StringEncoding];
		addr = strtol(addrStr, &tolError, 10);
	} else {
		// string of operand is label
		// look up label table
		NSNumber* addrLabel = [_labelTable valueForKey:opa];
	//	NSLog(@"look up label table l:%@ %@ = %@\n",al->realStr, opa, [addrLabel description]);
		if (!addrLabel) {
			//NSLog(@"No such label %@", opa);
			
			AsmError* asmError = AsmErrorCreate();
			asmError->line = al->realLine;
			asmError->errorType = AssemblerLabelNotFound;
			[_asmError addObject:[NSValue valueWithPointer:asmError]];
			
			return 0;
			
		} else {
			// No error
				return [addrLabel integerValue];
		}
	}
	
	// If contains invaild character in opa
	if (strncmp(tolError, "", 2)) {
		//NSLog(@"Parse error convert %s", tolError);
		
		AsmError* asmError = AsmErrorCreate();
		asmError->line = al->realLine;
		asmError->errorType = AssemblerInvalidConst;
		[_asmError addObject:[NSValue valueWithPointer:asmError]];
		
		return 0;
	} else {
		if (error) {
			error = NO;
		}
	}
	
	return addr;
}



- (uint32_t) _parseMacroOperationsOperand:(AsmLine*)al
{
	MacroList macro = lMacroList[al->macroListIndex];
	
	if (macro.asmLineType == AsmLineSTART) {
		if (al->opeRand == nil) {
			_startAddress = 0;
		} else {
			_startAddress = [self _parseAddressOperand:nil asmLine:al];
		}
		return 0;
	}
	
	if (macro.asmLineType == AsmLineEXIT) {
		return 0x64f0f0b0;
	}
	if (macro.asmLineType == AsmLineDC) {
		return [self _parseAddressOperand:nil asmLine:al];
	}
	if (macro.asmLineType == AsmLineDS) {
		if ([al->opeRand integerValue] < 0 || [al->opeRand integerValue] > 32768) {
			//error
			[self _addError:AssemblerInvalidConst realLineine:al->realLine];
		}
		return 0;
	}
	if (macro.asmLineType == AsmLineEND) {
		return 0;
	}
	return 0;
}

- (uint32_t) _parseGeneralOperationsOperand:(AsmLine*)al
{
	AsmError* asmError;
	
	uint16_t w1 = lOpList[al->opListIndex].def_operand << 8;
	
	NSArray* componentsAll = [al->opeRand componentsSeparatedByString:@","];
	if (lOpList[al->opListIndex].min_opr > [componentsAll count] || 
		lOpList[al->opListIndex].max_opr < [componentsAll count]) {
		//error
		NSLog(@"Operand parse Error: min %d max %d cur %d", lOpList[al->opListIndex].min_opr, lOpList[al->opListIndex].max_opr, [componentsAll count]);
		PrintAsmLine(al);
		goto error_operand;
	}
	
	NSString* grs = nil;
	NSString* xrs = nil;
	NSString* addrs = nil;
	
	if ([componentsAll count] == 3) {
		grs = [componentsAll objectAtIndex:0];
		addrs = [componentsAll objectAtIndex:1];
		xrs = [componentsAll objectAtIndex:2];
	}
	
	if ([componentsAll count] == 2) {
		if (lOpList[al->opListIndex].spec_gr) {
			addrs = [componentsAll objectAtIndex:0];
			xrs = [componentsAll objectAtIndex:1];
		} else {
			grs = [componentsAll objectAtIndex:0];
			addrs = [componentsAll objectAtIndex:1];
		}
	}
	
	if ([componentsAll count] == 1) {
		if (lOpList[al->opListIndex].spec_gr) {
			addrs = [componentsAll objectAtIndex:0];
		}
	}	
	
	int grt, xrt;
	
	// If op have specify gr definition
	if (lOpList[al->opListIndex].spec_gr) {
		w1 |= lOpList[al->opListIndex].def_gr << 4;
	} else {
		grt = GROperandToData(grs);
		if (grt == -1) {
						NSLog(@"Operand parse Error: GR %@", al->opeRand);
			
			goto error_operand;			
		} else {
			w1 |= grt << 4;
		}
	}
	
	// If op have specify XR definition
	if (lOpList[al->opListIndex].spec_xr) {
		w1 |= lOpList[al->opListIndex].def_xr;
	} else {
		if (xrs) {
			xrt = GROperandToData(xrs);
			if (xrt == -1) {
				goto error_operand;
			} else {
				w1 |= xrt;
			}
		}
	}
	
	uint16_t w2;
	// If op have specify ADDRESS definition
	if (lOpList[al->opListIndex].spec_addr) {
		w2 = lOpList[al->opListIndex].def_addr;
	} else {
		// Convert address string to valid address value
		w2 = [self _parseAddressOperand:addrs asmLine:al];
	}
	
	return w1<<16 | w2;
	
error_operand:
	asmError = AsmErrorCreate();
	asmError->line = al->realLine;
	asmError->errorType = AssemblerInvalidOperand;
	[_asmError addObject:[NSValue valueWithPointer:asmError]];
	
	return 0;
}


- (void)_assemble
{
	NSUInteger i;
	AsmLine* al;
	//	uint16_t word;
	uint32_t lw;
	NSUInteger addr = 0;
	NSUInteger memSize;
	for (i = 0; i < [_asmLines count]; i++) {
		al = [[_asmLines objectAtIndex:i] pointerValue];
		if (al->opListIndex) {
			lw = [self _parseGeneralOperationsOperand:al];
			
			//	NSLog(@"%04x : %08x - %@",addr, lw, al->realStr);
			//			printf("%08x", lw);
			al->objCode = lw;
			al->memSize = 2;
			addr += 2;
		}
		if (al->macroListIndex) {
			lw = [self _parseMacroOperationsOperand:al];
			
			memSize = GetMemorySize(al);
			//if (memSize) {
			//		NSLog(@"%04x : %04x - %@",addr, lw, al->realStr);
			///printf("%04x", lw);
			al->objCode = lw;
			al->memSize = memSize;
			addr += memSize;
			//	}
			
		}
	}
	
}

- (void)assemble:(id)sender
{
	
	///	NSLog(@"%@", _source);
	NSUInteger i;
	// Replace with tab and space
	NSString* nonTabSource = [[_source lowercaseString] stringByReplacingOccurrencesOfString:@"\t" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [_source length])];
	//	NSLog(@"tab %@", nonTabSource);
	
	// Division source by new line code
	NSArray* srcArray = ParseStringByLine(nonTabSource);
	[_asmLinesStr release];
	_asmLinesStr = [srcArray retain];
	
	// Destroy old asmline
	for (NSValue* asmLineObj in _asmLines) {
		free([asmLineObj pointerValue]);
	}
	[_asmLines removeAllObjects];
	_startAddress = 0;
	
	// Destroy old error info
	for (NSValue* asmErrorObj in _asmError) {
		free([asmErrorObj pointerValue]);
	}
	[_asmLines removeAllObjects];
	
	// Parse line
	int parseError;
	for (i = 0; i < [srcArray count]; i++) {
		NSLog(@"--line-- : %@", [srcArray objectAtIndex:i]);
		parseError = [self _parseLinePrepare:[srcArray objectAtIndex:i] realLine:i];
		if (parseError != ParseLineNoError) {
			//NSLog(@"Parse Error; %d : %@",i+1, [srcArray objectAtIndex:i]);
			AsmError* asmError = AsmErrorCreate();
			asmError->line = i;
			asmError->errorType = AssemblerParseError;
			[_asmError addObject:[NSValue valueWithPointer:asmError]];
		} 
	}
	
	// Create label table
	NSUInteger labelTableError;
	labelTableError = [self _createLabelTable];
	if (labelTableError) {
		AsmLine* al = [[_asmLines objectAtIndex:labelTableError] pointerValue];
		//NSLog(@"Error. Already exists label, %d: %@",labelTableError+1, al->label);
		AsmError* asmError = AsmErrorCreate();
		asmError->line = al->realLine;
		asmError->errorType = AssemblerLabelExist;
		[_asmError addObject:[NSValue valueWithPointer:asmError]];
	}
	
	//NSLog(@"LT %@", [_labelTable description]);
	
	
	// Assemble
	[self _assemble];
	
	
	
}

@end
