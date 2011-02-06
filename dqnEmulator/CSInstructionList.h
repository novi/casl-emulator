
struct macro_list {
	NSString* macro;
	uint8_t	 memorySize;
	int asmLineType;
};
typedef struct macro_list MacroList;

struct op_list {
	NSString* operation;
	int		max_opr;
	int		min_opr;
	uint8_t	def_operand;
	BOOL	spec_gr;
	uint8_t def_gr;
	BOOL	spec_xr;
	uint8_t def_xr;
	BOOL	spec_addr;
	uint16_t def_addr;
};

typedef struct op_list OpList;

enum AsmLineType {
	AsmLineGeneral = 1,
	AsmLineSTART,
	AsmLineEND,
	AsmLineDS,
	AsmLineDC,
	AsmLineEXIT,
};



#define kMacroListCount 7

static const MacroList lMacroList[] = {
{nil, 0, 0},
{@"start", 0, AsmLineSTART},
{@"end", 0, AsmLineEND},
{@"ds", 0, AsmLineDS},
{@"dc", 1, AsmLineDC},
{@"exit", 2, AsmLineEXIT},
};

#define kOpListCount 22

static const OpList lOpList[] = {
{nil	, 0, 0, 0x00,  NO, 0x00,  NO, 0x00,  NO, 0x0000},

{@"ret"	, 0, 0, 0x81, YES, 0x0f, YES, 0x00, YES, 0xffff},

{@"jpz"	, 2, 1, 0x60, YES, 0x0f,  NO, 0x00,  NO, 0x0000},
{@"jmi"	, 2, 1, 0x61, YES, 0x0f,  NO, 0x00,  NO, 0x0000},
{@"jnz"	, 2, 1, 0x62, YES, 0x0f,  NO, 0x00,  NO, 0x0000},
{@"jze"	, 2, 1, 0x63, YES, 0x0f,  NO, 0x00,  NO, 0x0000},
{@"jmp"	, 2, 1, 0x64, YES, 0x0f,  NO, 0x00,  NO, 0x0000},

{@"call", 2, 1, 0x80, YES, 0x0f,  NO, 0x00,  NO, 0x0000},

{@"ld"	, 3, 2, 0x10,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"st"	, 3, 2, 0x11,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"lea"	, 3, 2, 0x12,  NO, 0x00,  NO, 0x00,  NO, 0x0000},

{@"add"	, 3, 2, 0x20,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"sub"	, 3, 2, 0x21,  NO, 0x00,  NO, 0x00,  NO, 0x0000},

{@"and"	, 3, 2, 0x30,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"or"	, 3, 2, 0x31,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"eor"	, 3, 2, 0x32,  NO, 0x00,  NO, 0x00,  NO, 0x0000},

{@"cpa"	, 3, 2, 0x40,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"cpl"	, 3, 2, 0x41,  NO, 0x00,  NO, 0x00,  NO, 0x0000},

{@"sla"	, 3, 2, 0x50,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"sra"	, 3, 2, 0x51,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"sll"	, 3, 2, 0x52,  NO, 0x00,  NO, 0x00,  NO, 0x0000},
{@"srl"	, 3, 2, 0x53,  NO, 0x00,  NO, 0x00,  NO, 0x0000},

};

#define kGRListCount 5

static const NSString* lGRList[] = {
@"gr0",
@"gr1", 
@"gr2", 
@"gr3", 
@"gr4"
};


// Built in functions
struct built_in_func {
	NSString*	label;
	uint16_t	addr;
};

#define kBuiltInFunctionsCount 1
static const struct built_in_func lBuiltInFuncs[] = {
{@".rdmpd", 0xf020},
};

