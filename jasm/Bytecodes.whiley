// =========== UNIT Bytecodes ==============
define UNIT as { int kind }
define LOADSTORE as { int kind, byte index }
define BRANCH as { int kind, int16 offset }

define Bytecode as UNIT | LOADSTORE | BRANCH
