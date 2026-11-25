@echo off
chcp 65001 >nul

rem verilog工程文件夹路径
set VERILOG_FOLDER=.

rem 生成循环次数
set N=100
rem 输出hex文件路径
set HEX_FILE=gen_mips_program.hex

if not exist random_mips_generator.exe (
    echo [ ERROR ] 找不到 random_mips_generator.exe
    pause
    exit /b
)
if not exist Mars4_5.jar (
    echo [ ERROR ] 找不到 Mars4_5.jar
    pause
    exit /b
)

echo ==========================================
echo 开始随机程序对拍测试 ， 共执行 %N% 次 ...
echo ==========================================

for /l %%i in ( 1 , 1 , %N% ) do (
    echo.
    echo ------------------------------------------
    echo [ 第 %%i / %N% 次测试 ]
    
    rem 1. 运行生成器 
    echo [ 1 / 2 ] 正在生成随机汇编代码 ...
    random_mips_generator.exe
    
    if not exist gen_mips_source_simulate.asm (
        echo [ FAILED ] 生成器没有生成 gen_mips_source_simulate.asm
        goto :error_stop
    )

    rem 2. 调用 MARS 运行 
    echo [ 2 / 2 ] 正在调用 MARS 执行模拟 ...
    java -jar Mars4_5.jar nc me ic se1 mc CompactDataAtZero 10000 gen_mips_source_simulate.asm > mars_temp.log 2>&1
    
    if errorlevel 1 (
        echo.
        echo [ FAILED ] MARS 运行出错 ， 可能是死循环或指令非法。
    ) else (
        rem 用 findstr 查找是否包含死循环特征字样
        findstr /C:"maximum step limit" mars_temp.log >nul
        if not errorlevel 1 (
            echo.
            echo [ WARNING ] 检测到死循环，已跳过该用例。
            del mars_temp.log
        ) else (
            echo.
            echo [ PASS ] 可用的MIPS源码！开始编译...
            java -jar Mars4_5.jar nc a mc CompactDataAtZero dump .text HexText %HEX_FILE% gen_mips_source.asm

            copy /Y gen_mips_program.hex %VERILOG_FOLDER%\code.txt

            rem 半自动方式：程序会自动将编译结果导入至verilog工程文件夹内，但需要手动重新执行ISim（以及把时间拉到10微秒左右），检查MARS和verilog中GRF等寄存器是否一致（如果有必要也可以检查内存）。随后继续生成。 
            pause


        )
    )
)

echo.
echo ==========================================
echo [ SUCCESS ] 全部 %N% 次测试执行完毕 
echo ==========================================
pause
exit /b 0