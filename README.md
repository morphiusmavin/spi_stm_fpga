1) hook up RS-232 conv to STM com2*
2) test output of com port on STM
3) wire up FPGA master to STM slave 
4) route input of spi2 (slave) of STM to com2 
5) FPGA master1 -> STM slave1 & STM master2 -> FPGA slave2 & FPGA com to mon 
6) get TS-7800 into loop using comm2 or spi 
*hook up stm com2 directly to com2 of TS-7800 and pipe to com1 (mon) instead of 
RS-232 conv on stm 