COMPONENT=BaseStationC
BUILD_EXTRA_DEPS += GetResult.class
CLEAN_EXTRA = *.class GetMsg.java FrequencyControlMsg.java

CFLAGS += -DCC2420_DEF_CHANNEL=31
CFLAGS += -DCC2420_DEF_RFPOWER=5
CFLAGS += -I$(TOSDIR)/lib/T2Hack

GetResult.class: $(wildcard *.java) GetMsg.java FrequencyControlMsg.java
	javac -target 1.4 -source 1.4 *.java

GetMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=GetMsg GetMsg.h GetMsg -o $@

FrequencyControlMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=FrequencyControlMsg FrequencyControlMsg.h FrequencyControlMsg -o $@


include $(MAKERULES)


