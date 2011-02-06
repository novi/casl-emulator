#
# Makefile
#

# 最終目的のファイル
TARGET = test.exe

# ソースファイル(*.c)の一覧
SRCS = Test.c CMTEmulator.c CMTEmuSub.c

# オブジェクトファイル(*.o)の一覧
OBJS = ${SRCS:.c=.o}

# ヘッダファイルの一覧
HEADERS = CMTGeneral.h CMTEmulator.h CMTEmuSub.h

# コンパイラ・リンカの指定
CC = gcc
CCFLAGS = -Wall
LD = gcc
LDFLAGS =
LIBS = 

#OBJSからTARGETを作る方法
$(TARGET) : $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o $(TARGET) $(LIBS)

# *.c から *.o を作る方法
.c.o :
	$(CC) $(CCFLAGS) -c $<

# *.o は HEADERS と Makefile に依存(これらが書き換わったときにも *.o を再構築)
$(OBJS) : $(HEADERS) Makefile

# make clean としたときに実行されるコマンド
clean :
	rm -f $(TARGET) $(OBJS) core *~


