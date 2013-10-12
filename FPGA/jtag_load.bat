CALL C:\Xilinx\14.6\ISE_DS\settings64.bat

cd tools
jtagloader.exe -d -l ..\SD_card_test.srcs\sources_1\imports\SD_card_test\test_program.hex
pause