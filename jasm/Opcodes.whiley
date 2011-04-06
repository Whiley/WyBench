define NOP as 0
define LOADVAR as 1
define STOREVAR as 2	
define LOADCONST as 3
define STORECONST as 4
define ARRAYLOAD as 5
define ARRAYSTORE as 6
define ARRAYLENGTH as 7
define IINC as 8
define NEW as 9
define THROW as 10
define CHECKCAST as 11
define INSTANCEOF as 12
define MONITORENTER as 13
define MONITOREXIT as 14
define SWITCH as 15
define CONVERT as 16	
define WIDE_INSN as 18
define POP as 19
define DUP as 20
define DUPX1 as 21
define DUPX2 as 22
define SWAP as 23
define ADD as 24
define SUB as 25
define MUL as 26
define DIV as 27
define REM as 28
define NEG as 29
define SHL as 30
define SHR as 31
define USHR as 32
define AND as 33
define OR as 34
define XOR as 35
define CMP as 36
define CMPL as 37
define CMPG as 38
define IF as 39
define IFCMP as 40
define GOTO as 41
define JSR as 42
define RET as 43	
define RETURN as 44
define FIELDLOAD as 45
define FIELDSTORE as 46
define INVOKE as 47

define T_VOID as 0     // no result type	
define T_BYTE as 1     
define T_CHAR as 2     
define T_SHORT as 3    
define T_INT as 4
define T_LONG as 5
define T_FLOAT as 6
define T_DOUBLE as 7
define T_REF as 8	
define T_ARRAY as 9	

// INSTRUCTION FORMATS.  These determine the different instruction formats.
define FMT_EMPTY as 0
define FMT_I8 as 1
define FMT_I16 as 2	
define FMT_TYPEINDEX16 as 4         // INDEX into runtime pool for Type Descriptor
define FMT_TYPEAINDEX16 as 5        // INDEX into runtime pool for Type Descriptor
define FMT_TYPEINDEX16_U8 as 6      // INDEX into runtime pool for Type Descriptor
define FMT_CONSTINDEX8 as 7         // INDEX into runtime pool for constant
define FMT_CONSTINDEX16 as 8        // INDEX into runtime pool for constant
define FMT_FIELDINDEX16 as 9        // INDEX into runtime pool for field
define FMT_METHODINDEX16 as 10      // INDEX into runtime pool for method
define FMT_METHODINDEX16_U8_0 as 11 // INDEX into runtime pool
define FMT_VARIDX as 12             // INDEX into local var array (1 byte)
define FMT_VARIDX_I8 as 13
define FMT_ATYPE as 14              // USED ONLY FOR NEWARRAY
define FMT_TABLESWITCH as 15
define FMT_LOOKUPSWITCH as 16
define FMT_TARGET16 as 17
define FMT_TARGET32 as 18
define FMT_INTM1 as 19
define FMT_INT0 as 20
define FMT_INT1 as 21
define FMT_INT2 as 22
define FMT_INT3 as 23
define FMT_INT4 as 24
define FMT_INT5 as 25
define FMT_INTNULL as 26

define S_INT as 0
define S_LONG as 1
define S_FLOAT as 2
define S_DOUBLE as 3

define MOD_VIRTUAL as 0
define MOD_STATIC as 1
define MOD_SPECIAL as 2
define MOD_INTERFACE as 3

// The following table is used to simplify decoding of bytecode
// instructions.  Don't ask me where I got it from ... it was a lot of
// hard work to build :)
define decodeTable as [
    (NOP),                         // NOP = 0    
    (LOADCONST, FMT_INTNULL, T_REF),          // ACONST_NULL = 1;
    (LOADCONST, FMT_INTM1, T_INT),            // ICONST_M1 = 2;
    (LOADCONST, FMT_INT0 , T_INT),            // ICONST_0 = 3;
    (LOADCONST, FMT_INT1 , T_INT),            // ICONST_1 = 4;
    (LOADCONST, FMT_INT2 , T_INT),            // ICONST_2 = 5;
    (LOADCONST, FMT_INT3 , T_INT),            // ICONST_3 = 6;
    (LOADCONST, FMT_INT4 , T_INT),            // ICONST_4 = 7;
    (LOADCONST, FMT_INT5 , T_INT),            // ICONST_5 = 8;
    (LOADCONST, FMT_INT0 , T_LONG),           // LCONST_0 = 9;
    (LOADCONST, FMT_INT1 , T_LONG),           // LCONST_1 = 10;
    (LOADCONST, FMT_INT0 , T_FLOAT),          // FCONST_0 = 11;
    (LOADCONST, FMT_INT1 , T_FLOAT),          // FCONST_1 = 12;
    (LOADCONST, FMT_INT2 , T_FLOAT),          // FCONST_2 = 13;
    (LOADCONST, FMT_INT0 , T_DOUBLE),         // DCONST_0 = 14;
    (LOADCONST, FMT_INT1 , T_DOUBLE),         // DCONST_1 = 15;
    (LOADCONST, FMT_I8, T_INT),               // BIPUSH = 16;
    (LOADCONST, FMT_I16, T_INT),              // SIPUSH = 17;
    (LOADCONST, FMT_CONSTINDEX8),             // LDC = 18
    (LOADCONST, FMT_CONSTINDEX16),            // LDC_W = 19
    (LOADCONST, FMT_CONSTINDEX16),            // LDC2_W = 20    
    (LOADVAR, FMT_VARIDX, T_INT),             // ILOAD = 21
    (LOADVAR, FMT_VARIDX, T_LONG),            // LLOAD = 22
    (LOADVAR, FMT_VARIDX, T_FLOAT),           // FLOAD = 23
    (LOADVAR, FMT_VARIDX, T_DOUBLE),          // DLOAD = 24
    (LOADVAR, FMT_VARIDX, T_REF),             // ALOAD = 25
    (LOADVAR, FMT_INT0, T_INT),               // ILOAD_0 = 26
    (LOADVAR, FMT_INT1, T_INT),               // ILOAD_1 = 27
    (LOADVAR, FMT_INT2, T_INT),               // ILOAD_2 = 28
    (LOADVAR, FMT_INT3, T_INT),               // ILOAD_3 = 29
    (LOADVAR, FMT_INT0, T_LONG),              // LLOAD_0 = 30
    (LOADVAR, FMT_INT1, T_LONG),              // LLOAD_1 = 31
    (LOADVAR, FMT_INT2, T_LONG),              // LLOAD_2 = 32
    (LOADVAR, FMT_INT3, T_LONG),              // LLOAD_3 = 33
    (LOADVAR, FMT_INT0, T_FLOAT),             // FLOAD_0 = 34
    (LOADVAR, FMT_INT1, T_FLOAT),             // FLOAD_1 = 35
    (LOADVAR, FMT_INT2, T_FLOAT),             // FLOAD_2 = 36
    (LOADVAR, FMT_INT3, T_FLOAT),             // FLOAD_3 = 37
    (LOADVAR, FMT_INT0, T_DOUBLE),            // DLOAD_0 = 38
    (LOADVAR, FMT_INT1, T_DOUBLE),            // DLOAD_1 = 39
    (LOADVAR, FMT_INT2, T_DOUBLE),            // DLOAD_2 = 40
    (LOADVAR, FMT_INT3, T_DOUBLE),            // DLOAD_3 = 41
    (LOADVAR, FMT_INT0, T_REF),               // ALOAD_0 = 42
    (LOADVAR, FMT_INT1, T_REF),               // ALOAD_1 = 43
    (LOADVAR, FMT_INT2, T_REF),               // ALOAD_2 = 44
    (LOADVAR, FMT_INT3, T_REF),               // ALOAD_3 = 45    
    (ARRAYLOAD, FMT_EMPTY, T_INT),            // IALOAD = 46
    (ARRAYLOAD, FMT_EMPTY, T_LONG),           // LALOAD = 47
    (ARRAYLOAD, FMT_EMPTY, T_FLOAT),          // FALOAD = 48
    (ARRAYLOAD, FMT_EMPTY, T_DOUBLE),         // DALOAD = 49
    (ARRAYLOAD, FMT_EMPTY, T_REF),            // AALOAD = 50
    (ARRAYLOAD, FMT_EMPTY, T_BYTE),           // BALOAD = 51
    (ARRAYLOAD, FMT_EMPTY, T_CHAR),           // AALOAD = 52
    (ARRAYLOAD, FMT_EMPTY, T_SHORT),          // SALOAD = 53    
    (STOREVAR, FMT_VARIDX, T_INT),            // ISTORE = 54;
    (STOREVAR, FMT_VARIDX, T_LONG),           // LSTORE = 55;
    (STOREVAR, FMT_VARIDX, T_FLOAT),          // FSTORE = 56;
    (STOREVAR, FMT_VARIDX, T_DOUBLE),         // DSTORE = 57;
    (STOREVAR, FMT_VARIDX, T_REF),            // ASTORE = 58;    
    (STOREVAR, FMT_INT0, T_INT),              // ISTORE_0 = 59;
    (STOREVAR, FMT_INT1, T_INT),              // ISTORE_1 = 60;
    (STOREVAR, FMT_INT2, T_INT),              // ISTORE_2 = 61;
    (STOREVAR, FMT_INT3, T_INT),              // ISTORE_3 = 62;
    (STOREVAR, FMT_INT0, T_LONG),             // LSTORE_0 = 63;
    (STOREVAR, FMT_INT1, T_LONG),             // LSTORE_1 = 64;
    (STOREVAR, FMT_INT2, T_LONG),             // LSTORE_2 = 65;
    (STOREVAR, FMT_INT3, T_LONG),             // LSTORE_3 = 66;
    (STOREVAR, FMT_INT0, T_FLOAT),            // FSTORE_0 = 67;
    (STOREVAR, FMT_INT1, T_FLOAT),            // FSTORE_1 = 68;
    (STOREVAR, FMT_INT2, T_FLOAT),            // FSTORE_2 = 69;
    (STOREVAR, FMT_INT3, T_FLOAT),            // FSTORE_3 = 70;
    (STOREVAR, FMT_INT0, T_DOUBLE),           // DSTORE_0 = 71;
    (STOREVAR, FMT_INT1, T_DOUBLE),           // DSTORE_1 = 72;
    (STOREVAR, FMT_INT2, T_DOUBLE),           // DSTORE_2 = 73;
    (STOREVAR, FMT_INT3, T_DOUBLE),           // DSTORE_3 = 74;
    (STOREVAR, FMT_INT0, T_REF),              // ASTORE_0 = 75;
    (STOREVAR, FMT_INT1, T_REF),              // ASTORE_1 = 76;
    (STOREVAR, FMT_INT2, T_REF),              // ASTORE_2 = 77;
    (STOREVAR, FMT_INT3, T_REF),              // ASTORE_3 = 78;     
    (ARRAYSTORE, FMT_EMPTY, T_INT),           // IASTORE = 79;
    (ARRAYSTORE, FMT_EMPTY, T_LONG),          // LASTORE = 80;
    (ARRAYSTORE, FMT_EMPTY, T_FLOAT),         // FASTORE = 81;
    (ARRAYSTORE, FMT_EMPTY, T_DOUBLE),        // DASTORE = 82;
    (ARRAYSTORE, FMT_EMPTY, T_REF),           // AASTORE = 83;
    (ARRAYSTORE, FMT_EMPTY, T_BYTE),          // BASTORE = 84
    (ARRAYSTORE, FMT_EMPTY, T_CHAR),          // CASTORE = 85;
    (ARRAYSTORE, FMT_EMPTY, T_SHORT),         // SASTORE = 86;        
    (POP),                                    // POP = 87;
    (POP),                                    // POP2 = 88;    
    (DUP),                                    // DUP = 89    
    (DUPX1),                                  // DUP_X1 = 90
    (DUPX2),                                  // DUP_X2 = 91    
    (DUP),                                    // DUP2 = 92;
    (DUPX1),                                  // DUP2_X1 = 93
    (DUPX2),                                  // DUP2_X2 = 94
    (SWAP),                                   // SWAP = 95;    
    (ADD, FMT_EMPTY, T_INT),                  // IADD = 96
    (ADD, FMT_EMPTY, T_LONG),                 // LADD = 97
    (ADD, FMT_EMPTY, T_FLOAT),                // FADD = 98
    (ADD, FMT_EMPTY, T_DOUBLE),               // DADD = 99        
    (SUB, FMT_EMPTY, T_INT),                  // ISUB = 100
    (SUB, FMT_EMPTY, T_LONG),                 // LSUB = 101
    (SUB, FMT_EMPTY, T_FLOAT),                // FSUB = 102
    (SUB, FMT_EMPTY, T_DOUBLE),               // DSUB = 103        
    (MUL, FMT_EMPTY, T_INT),                  // IMUL = 104
    (MUL, FMT_EMPTY, T_LONG),                 // LMUL = 105
    (MUL, FMT_EMPTY, T_FLOAT),                // FMUL = 106
    (MUL, FMT_EMPTY, T_DOUBLE),               // DMUL = 107    
    (DIV, FMT_EMPTY, T_INT),                  // IDIV = 108
    (DIV, FMT_EMPTY, T_LONG),                 // LDIV = 109
    (DIV, FMT_EMPTY, T_FLOAT),                // FDIV = 110
    (DIV, FMT_EMPTY, T_DOUBLE),               // DDIV = 111    
    (REM, FMT_EMPTY, T_INT),                  // IREM = 112
    (REM, FMT_EMPTY, T_LONG),                 // LREM = 113
    (REM, FMT_EMPTY, T_FLOAT),                // FREM = 114
    (REM, FMT_EMPTY, T_DOUBLE),               // DREM = 115    
    (NEG, FMT_EMPTY, T_INT),                  // INEG = 116
    (NEG, FMT_EMPTY, T_LONG),                 // LNEG = 117
    (NEG, FMT_EMPTY, T_FLOAT),                // FNEG = 118
    (NEG, FMT_EMPTY, T_DOUBLE),               // DNEG = 119    
    (SHL, FMT_EMPTY, T_INT),                  // ISHL = 120
    (SHL, FMT_EMPTY, T_LONG),                 // LSHL = 121        
    (SHR, FMT_EMPTY, T_INT),                  // ISHR = 122
    (SHR, FMT_EMPTY, T_LONG),                 // LSHR = 123    
    (USHR, FMT_EMPTY, T_INT),                 // IUSHR = 124
    (USHR, FMT_EMPTY, T_LONG),                // LUSHR = 125    
    (AND, FMT_EMPTY, T_INT),                  // IAND = 126
    (AND, FMT_EMPTY, T_LONG),                 // LAND = 127    
    (OR, FMT_EMPTY, T_INT),                   // IXOR = 128
    (OR, FMT_EMPTY, T_LONG),                  // LXOR = 129    
    (XOR, FMT_EMPTY, T_INT),                  // IXOR = 130
    (XOR, FMT_EMPTY, T_LONG),                 // LXOR = 131        
    (IINC, FMT_VARIDX_I8),                    // IINC = 132    
    (CONVERT, FMT_EMPTY, S_INT, T_LONG),      // I2L = 133
    (CONVERT, FMT_EMPTY, S_INT, T_FLOAT),     // I2F = 134
    (CONVERT, FMT_EMPTY, S_INT, T_DOUBLE),    // I2D = 135    
    (CONVERT, FMT_EMPTY, S_LONG, T_INT),      // L2I = 136
    (CONVERT, FMT_EMPTY, S_LONG, T_FLOAT),    // L2F = 137
    (CONVERT, FMT_EMPTY, S_LONG, T_DOUBLE),   // L2D = 138    
    (CONVERT, FMT_EMPTY, S_FLOAT, T_INT),     // F2I = 139
    (CONVERT, FMT_EMPTY, S_FLOAT, T_LONG),    // F2L = 140
    (CONVERT, FMT_EMPTY, S_FLOAT, T_DOUBLE),  // F2D = 141    
    (CONVERT, FMT_EMPTY, S_DOUBLE, T_INT),    // D2I = 142
    (CONVERT, FMT_EMPTY, S_DOUBLE, T_LONG),   // D2L = 143
    (CONVERT, FMT_EMPTY, S_DOUBLE, T_FLOAT),  // D2F = 144
    (CONVERT, FMT_EMPTY, S_INT, T_BYTE),      // I2B = 145
    (CONVERT, FMT_EMPTY, S_INT, T_CHAR),      // I2C = 146
    (CONVERT, FMT_EMPTY, S_INT, T_SHORT),     // I2S = 147
    (CMP, FMT_EMPTY, T_LONG),                 // LCMP = 148
    (CMPL, FMT_EMPTY, T_FLOAT),               // FCMPL = 149
    (CMPG, FMT_EMPTY, T_FLOAT),               // FCMPG = 150
    (CMPL, FMT_EMPTY, T_DOUBLE),              // DCMPL = 151
    (CMPG, FMT_EMPTY, T_DOUBLE),              // DCMPG = 152
    (IF, FMT_TARGET16, T_INT),                // IFEQ = 153;
    (IF, FMT_TARGET16, T_INT),                // IFNE = 154;
    (IF, FMT_TARGET16, T_INT),                // IFLT = 155;
    (IF, FMT_TARGET16, T_INT),                // IFGE = 156;
    (IF, FMT_TARGET16, T_INT),                // IFGT = 157;
    (IF, FMT_TARGET16, T_INT),                // IFLE = 158;        
    (IFCMP, FMT_TARGET16, T_INT),             // IF_ICMPEQ = 159;
    (IFCMP, FMT_TARGET16, T_INT),             // IF_ICMPNE = 160;
    (IFCMP, FMT_TARGET16, T_INT),             // IF_ICMPLT = 161;
    (IFCMP, FMT_TARGET16, T_INT),             // IF_ICMPGE = 162;
    (IFCMP, FMT_TARGET16, T_INT),             // IF_ICMPGT = 163;
    (IFCMP, FMT_TARGET16, T_INT),             // IF_ICMPLE = 164;
    (IFCMP, FMT_TARGET16, T_REF),             // IF_ACMPEQ = 165;
    (IFCMP, FMT_TARGET16, T_REF),             // IF_ACMPNE = 166;    
    (GOTO, FMT_TARGET16),                     // GOTO = 167;    
    (JSR, FMT_TARGET16),                      // JSR = 168;    
    (RET),                                    // RET = 169;    
    (SWITCH, FMT_TABLESWITCH),                // TABLESWITCH = 170;
    (SWITCH, FMT_LOOKUPSWITCH),               // LOOKUPSWITCH = 171;    
    (RETURN, FMT_EMPTY, T_INT),               // IRETURN = 172;
    (RETURN, FMT_EMPTY, T_LONG),              // LRETURN = 173;
    (RETURN, FMT_EMPTY, T_FLOAT),             // FRETURN = 174;
    (RETURN, FMT_EMPTY, T_DOUBLE),            // DRETURN = 175;
    (RETURN, FMT_EMPTY, T_REF),               // ARETURN = 176;
    (RETURN),                                 // RETURN = 177;    	
    (FIELDLOAD, MOD_STATIC, FMT_FIELDINDEX16),// GETSTATIC = 178;
    (FIELDSTORE, MOD_STATIC, FMT_FIELDINDEX16),  // PUTSTATIC = 179;
    (FIELDLOAD, FMT_FIELDINDEX16),            // GETFIELD = 180;
    (FIELDSTORE, FMT_FIELDINDEX16),           // PUTFIELD = 181; 
    (INVOKE, FMT_METHODINDEX16),              // INVOKEVIRTUAL = 182;    
    (INVOKE, MOD_SPECIAL, FMT_METHODINDEX16), // INVOKESPECIAL = 183;
    (INVOKE, MOD_STATIC, FMT_METHODINDEX16),  // INVOKESTATIC = 184;
    (INVOKE, MOD_INTERFACE, FMT_METHODINDEX16_U8_0), // INVOKEINTERFACE = 185;    
    null,                                     // UNUSED = 186;    
    (NEW, FMT_TYPEINDEX16),                   // NEW = 187
    (NEW, FMT_ATYPE),                         // NEWARRAY = 188
    (NEW, FMT_TYPEAINDEX16),                  // ANEWARRAY = 189    	
    (ARRAYLENGTH),                            // ARRAYLENGTH = 190;        
    (THROW),                                  // ATHROW = 191    
    (CHECKCAST, FMT_TYPEINDEX16),             // CHECKCAST = 192;    
    (INSTANCEOF, FMT_TYPEINDEX16),            // INSTANCEOF = 193;    
    (MONITORENTER),                           // MONITORENTER = 194;
    (MONITOREXIT),                            // MONITOREXIT = 195;    
    (WIDE_INSN),                              // WIDE = 196;    
    (NEW, FMT_TYPEINDEX16_U8),                // MULTIANEWARRAY = 197;    
    (IF, FMT_TARGET16, T_REF),                // IFNULL = 198;
    (IF, FMT_TARGET16, T_REF),                // IFNONNULL = 199;
    (GOTO, FMT_TARGET32),                     // GOTO_W = 200;
    (JSR, FMT_TARGET32)                       // JSR_W = 201;
]
