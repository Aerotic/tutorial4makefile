default:help
.PHONY: help
help:
	@echo 基于 MakeFile 的C代码编译管理示例教程
	@echo 


# 编译lib文件夹下的所有源文件的obj
LIB_SRC=$(shell ls lib/*.c) #  获取lib目录下以.c为后缀的文件名
LIB_SRC_BASENAME=$(basename $(LIB_SRC)) # 获取没有后缀名的文件名
LIB_ODJ=$(addsuffix .o,$(LIB_SRC_BASENAME)) # 加上.o拓展名
lib/%.o:lib/%.c # 
	gcc -c $< -o $@
.PHONY: lib_obj
lib_obj:${LIB_ODJ}

.PHONY: main main_obj
INC_SRC=lib
main_obj:main.c
	${CC} -c $< -I${INC_SRC}
main:main_obj lib_obj
	${CC} main.o ${LIB_ODJ} -o $@.out

# 生成一个汇编 这里生成汇编一个是为了展示gcc生成汇编的步骤另一个是为了给汇编和C代码联合编译准备个汇编文件
# ${ASM}:${ASM_SRC} $@是${ASM}，也即TARGET；$<是${ASM_SRC}，也即前置依赖的第一个
ASM_SRC=lib/p.c # 这个文件名带有以根目录为参照的相对路径
ASM_SRC_BASENAME=$(basename $(ASM_SRC)) # 获取没有后缀名的文件名
ASM=$(addsuffix .s,$(basename $(ASM_SRC))) # makefile的函数可以嵌套使用
${ASM}:${ASM_SRC}
	gcc -S -o $@ $<

# 汇编和c代码联合编译
# asm-c: ${ROOT_SRC} ${ASM} 
# $@是${ASM}，也即TARGET；$^是所有的前置依赖
# ${CC} 指的是shell指令cc 默认为本机默认的gcc
# CC可以通过 例如 “ make CC=gcc asm-c ”的方式指定
# 这也是一个从命令行送入未初始化脚本变量值的方法
ROOT_SRC=$(shell ls *.c)
INC_SRC=lib
asm-c: ${ROOT_SRC} ${ASM} 
	${CC} -o $@.out -I$(INC_SRC) $^


# 生成一个动态链接库 目的一个是为了展示gcc生成动态链接库的步骤另一个是为了给动态链接库和C代码联合编译准备个dll
# ${DLL}:${DLL_SRC} $@是${DLL}，也即TARGET；$<是${DLL_SRC}，也即前置依赖的第一个
DLL_SRC=lib/p.c # 这个文件名带有以根目录为参照的相对路径
DLL_SRC_BASENAME=$(basename $(DLL_SRC)) # 获取没有后缀名的文件名
DLL_PATH=${dir ${DLL_SRC_BASENAME}} # 获取文件的路径，即获取“lib/p.c”中 / 自身及之前的字符，此例中即为“lib/”
DLL_NAME=lib${notdir ${DLL_SRC_BASENAME}}.so # 获取文件的名称，即获取“lib/p.c”中 / 之后的内容，此例中为“p" (.c后缀在之前的步骤中消去了)
DLL=$(join ${DLL_PATH},${DLL_NAME})
# -shared选项说明编译成的文件为动态链接库，不使用该选项相当于可执行文件
# -fPIC 表示编译为位置独立的代码，不用此选项的话编译后的代码是位置相关的。所以动态载入时是通过代码拷贝的方式来满足不同进程的需要，而不能达到真正代码段共享的目的
DLL_CFLAGS=-shared -fPIC
${DLL}:${DLL_SRC}
	gcc ${DLL_CFLAGS} -o $@ $^

# 动态链接库和c代码联合编译
# asm-c: ${ROOT_SRC} ${ASM} 
# $@是${ASM}，也即TARGET；$^是所有的前置依赖
# ${CC} 指的是shell指令cc 默认为本机默认的gcc
# CC可以通过 例如 “ make CC=gcc asm-c ”的方式指定
# 这也是一个从命令行送入未初始化脚本变量值的方法
# 以下代码未调通
ROOT_SRC=$(shell ls *.c)
INC_SRC=lib
LDLIBS=-lp
DLL_C_CFLAGS=-Llib
dll-c: ${ROOT_SRC} ${DLL} 
	${CC} ${DLL_C_CFLAGS} ${LDLIBS} -o $@.out -I$(INC_SRC) $< 


clean:
	rm ${ASM} ${DLL} ${LIB_ODJ} *.o