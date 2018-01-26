#include <Timer.h>
#include "DataCollection.h"

configuration DataCollectionAppC {
}
implementation {
  components MainC;
  components LedsC;
  components DataCollectionC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_DATACOLLECT);
  components new AMReceiverC(AM_DATACOLLECT);
  components new SensirionSht11C();
  components new HamamatsuS1087ParC();


  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.ReadT -> SensirionSht11C.Temperature;
  App.ReadH -> SensirionSht11C.Humidity;
  App.ReadL -> HamamatsuS1087ParC;
}
