#!/usr/bin/env python3
# patch_i486.py - Tsugaru aarch64/EmuELEC source patches
# Target commit: 0e31cb4065fd5b7888cb6c13d19f358925f9366e
#
# Patch set (verified against the exact source tree):
#   2. SAL alias (REG=6)      - shift-group opcodes C0/C1/D0-D3: REG=6 is the
#                               undocumented SAL alias of SHL on real i486.
#   5. fssimplenowindow noGL  - build without OpenGL headers on the host.
#   6. quoted flag append     - top CMakeLists: keep toolchain CXXFLAGS a string.
#   7. 0xFE REG=2..7 -> #UD   - Fujitsu BIOS uses invalid opcodes as API traps;
#   8. 0xFF REG=7   -> #UD      raise #UD via the IDT instead of aborting.
#   9. GetSignedByte int8_t   - 'char' is unsigned on aarch64; rel8/simm8 sign
#                               extension must not depend on char signedness.
#
import sys
import os

if len(sys.argv) < 2:
    print("usage: patch_i486.py <PKG_BUILD>")
    sys.exit(1)

ROOT = sys.argv[1]
FAILED = 0


def patch(relpath, old, new, expect, label):
    global FAILED
    path = os.path.join(ROOT, relpath)
    with open(path, "r", encoding="utf-8") as f:
        s = f.read()
    n = s.count(old)
    if n != expect:
        print("FAIL (%d/%d): %s" % (n, expect, label))
        FAILED += 1
        return
    s = s.replace(old, new)
    with open(path, "w", encoding="utf-8") as f:
        f.write(s)
    print("OK (%d/%d): %s" % (n, expect, label))


# --------------------------------------------------------------------------
# Patch 2: SAL alias REG=6 -> SHL (byte / word / dword).
# The Sar<Width> line that follows anchors each pattern to its operand width.
# --------------------------------------------------------------------------
patch(
    "src/cpu/i486runinstruction.h",
    '\t\t\t\tcase 6: \\\n'
    '\t\t\t\t\tAbort("Undefined REG for "+cpputil::Ustox(inst.RealOpCode())); \\\n'
    '\t\t\t\t\tclocksPassed=(OPER_ADDR==op1.operandType ? 4 : 2); \\\n'
    '\t\t\t\t\treturn 0; \\\n'
    '\t\t\t\tcase 7: \\\n'
    '\t\t\t\t\tSarByte(i,ctr); \\\n',
    '\t\t\t\tcase 6: /* SAL: undocumented alias of SHL on real i486 */ \\\n'
    '\t\t\t\t\tShlByte(i,ctr); \\\n'
    '\t\t\t\t\tclocksPassed=(OPER_ADDR==op1.operandType ? 4 : 2); \\\n'
    '\t\t\t\t\tbreak; \\\n'
    '\t\t\t\tcase 7: \\\n'
    '\t\t\t\t\tSarByte(i,ctr); \\\n',
    2,
    "SAL alias REG=6 -> ShlByte",
)

patch(
    "src/cpu/i486runinstruction.h",
    '\t\t\t\t\tcase 6: \\\n'
    '\t\t\t\t\t\tAbort("Undefined REG for "+cpputil::Ustox(inst.RealOpCode())); \\\n'
    '\t\t\t\t\t\tclocksPassed=(OPER_ADDR==op1.operandType ? 4 : 2); \\\n'
    '\t\t\t\t\t\treturn 0; \\\n'
    '\t\t\t\t\tcase 7: \\\n'
    '\t\t\t\t\t\tSarWord(i,ctr); \\\n',
    '\t\t\t\t\tcase 6: /* SAL: undocumented alias of SHL on real i486 */ \\\n'
    '\t\t\t\t\t\tShlWord(i,ctr); \\\n'
    '\t\t\t\t\t\tclocksPassed=(OPER_ADDR==op1.operandType ? 4 : 2); \\\n'
    '\t\t\t\t\t\tbreak; \\\n'
    '\t\t\t\t\tcase 7: \\\n'
    '\t\t\t\t\t\tSarWord(i,ctr); \\\n',
    2,
    "SAL alias REG=6 -> ShlWord",
)

patch(
    "src/cpu/i486runinstruction.h",
    '\t\t\t\t\tcase 6: \\\n'
    '\t\t\t\t\t\tAbort("Undefined REG for "+cpputil::Ustox(inst.RealOpCode())); \\\n'
    '\t\t\t\t\t\tclocksPassed=(OPER_ADDR==op1.operandType ? 4 : 2); \\\n'
    '\t\t\t\t\t\treturn 0; \\\n'
    '\t\t\t\t\tcase 7: \\\n'
    '\t\t\t\t\t\tSarDword(i,ctr); \\\n',
    '\t\t\t\t\tcase 6: /* SAL: undocumented alias of SHL on real i486 */ \\\n'
    '\t\t\t\t\t\tShlDword(i,ctr); \\\n'
    '\t\t\t\t\t\tclocksPassed=(OPER_ADDR==op1.operandType ? 4 : 2); \\\n'
    '\t\t\t\t\t\tbreak; \\\n'
    '\t\t\t\t\tcase 7: \\\n'
    '\t\t\t\t\t\tSarDword(i,ctr); \\\n',
    2,
    "SAL alias REG=6 -> ShlDword",
)

# --------------------------------------------------------------------------
# Patch 5: fssimplenowindow must build without OpenGL headers on the host.
# fssimplewindowcommon.cpp includes fssimplewindow.h, which pulls GL/glu.h
# unless FSSIMPLEWINDOW_DONT_INCLUDE_OPENGL_HEADERS is defined.
# --------------------------------------------------------------------------
patch(
    "src/externals/fssimplewindow/src/CMakeLists.txt",
    'add_library(fssimplenowindow fssimplewindowcommon.cpp nownd/fssimplenowindow.cpp)\n',
    'add_library(fssimplenowindow fssimplewindowcommon.cpp nownd/fssimplenowindow.cpp)\n'
    'target_compile_definitions(fssimplenowindow PUBLIC FSSIMPLEWINDOW_DONT_INCLUDE_OPENGL_HEADERS)\n',
    1,
    "fssimplenowindow: no-GL compile definition",
)

# --------------------------------------------------------------------------
# Patch 6: upstream appends -Wno-unused-variable with an unquoted list-style
# set(), which turns pre-populated toolchain CXXFLAGS into a semicolon list.
# The semicolon ends up on the compiler command line and breaks every compile
# ("no input files"). Quote the append so flags stay a single string.
# --------------------------------------------------------------------------
patch(
    "src/CMakeLists.txt",
    '\tset(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} -Wno-unused-variable)\n'
    '\tset(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -Wno-unused-variable)\n',
    '\tset(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-variable")\n'
    '\tset(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-variable")\n',
    1,
    "top CMakeLists: quoted flag append (no semicolon lists)",
)

# --------------------------------------------------------------------------
# Patch 7: opcode 0xFE with REG=2..7 must raise #UD via the IDT instead of
# aborting the VM. The Fujitsu FM Towns BIOS uses invalid opcodes as an API
# dispatch mechanism (the #UD handler decodes the faulting bytes and patches
# the saved register frame). Real i486 behavior is #UD, not a machine halt.
# --------------------------------------------------------------------------
patch(
    "src/cpu/i486runinstruction.h",
    '\t\t\tcase 2:\n'
    '\t\t\tcase 3:\n'
    '\t\t\tcase 4:\n'
    '\t\t\tcase 5:\n'
    '\t\t\tcase 6:\n'
    '\t\t\tcase 7:\n'
    '\t\t\t\tAbort("Undefined REG for "+cpputil::Ustox(inst.RealOpCode()));\n'
    '\t\t\t\treturn 0;\n',
    '\t\t\tcase 2:\n'
    '\t\t\tcase 3:\n'
    '\t\t\tcase 4:\n'
    '\t\t\tcase 5:\n'
    '\t\t\tcase 6:\n'
    '\t\t\tcase 7:\n'
    '\t\t\t\t// aarch64/EmuELEC port: real i486 raises #UD here; FM Towns BIOS relies on it.\n'
    '\t\t\t\tRaiseException(EXCEPTION_UD,0);\n'
    '\t\t\t\tHandleException(true,mem,inst.numBytes);\n'
    '\t\t\t\tclocksPassed+=ClocksForHandlingException();\n'
    '\t\t\t\tEIPIncrement=0;\n'
    '\t\t\t\tbreak;\n',
    1,
    "0xFE REG=2..7 -> #UD via IDT",
)

# --------------------------------------------------------------------------
# Patch 8: opcode 0xFF with REG=7 (e.g. the FF FF byte pair the Towns BIOS
# executes as an API trap) must raise #UD via the IDT instead of aborting.
# --------------------------------------------------------------------------
patch(
    "src/cpu/i486runinstruction.h",
    '\t\t\t\t\tHANDLE_EXCEPTION_PUSH_POP;\n'
    '\t\t\t\t}\n'
    '\t\t\t\tbreak;\n'
    '\t\t\tcase 7:\n'
    '\t\t\t\tAbort("Undefined REG for "+cpputil::Ustox(inst.RealOpCode()));\n'
    '\t\t\t\treturn 0;\n',
    '\t\t\t\t\tHANDLE_EXCEPTION_PUSH_POP;\n'
    '\t\t\t\t}\n'
    '\t\t\t\tbreak;\n'
    '\t\t\tcase 7:\n'
    '\t\t\t\t// aarch64/EmuELEC port: real i486 raises #UD here; FM Towns BIOS relies on it.\n'
    '\t\t\t\tRaiseException(EXCEPTION_UD,0);\n'
    '\t\t\t\tHandleException(true,mem,inst.numBytes);\n'
    '\t\t\t\tclocksPassed=ClocksForHandlingException();\n'
    '\t\t\t\tEIPIncrement=0;\n'
    '\t\t\t\tbreak;\n',
    1,
    "0xFF REG=7 -> #UD via IDT",
)

# --------------------------------------------------------------------------
# Patch 9: cpputil::GetSignedByte uses a bare 'char*' for sign extension.
# 'char' is unsigned on aarch64, so every rel8 branch displacement and every
# signed imm8 in the CPU core gets zero-extended instead of sign-extended,
# derailing the Fujitsu BIOS within microseconds of reset. Use int8_t.
# --------------------------------------------------------------------------
patch(
    "src/cpputil/cpputil.h",
    '\tchar *signedPtr=(char *)&byteData;\n'
    '\treturn *signedPtr;\n',
    '\tconst int8_t *signedPtr=(const int8_t *)&byteData; // aarch64: char is unsigned\n'
    '\treturn *signedPtr;\n',
    1,
    "GetSignedByte: int8_t instead of char (aarch64 sign extension)",
)

if 0 != FAILED:
    print("%d patch(es) FAILED - source layout changed, do not build." % FAILED)
    sys.exit(1)
print("All patches applied.")