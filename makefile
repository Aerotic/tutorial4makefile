SRC=$(shell ls *.c)  #  获取当前目录下以.c为后缀的文件名
SRC+=$(shell ls lib/*.c)  #  获取当前目录下的子目录lib中以.c为后缀的文件名
BS=$(basename $(SRC)) # 去掉拓展名
OBJ=$(addsuffix .o,$(BS)) # 加上.o拓展名

ROOT_SRC=$(shell ls *.c) # 获取根目录下的c源文件

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
clean:
	rm ${ASM}