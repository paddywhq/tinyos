#include <Timer.h>
#include "DataAggregation.h"

configuration DataAggregationAppC {
}
implementation {
  components MainC;
  components LedsC;
  components DataAggregationC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_DATACOMMUNICATE) as CommunicateSender;
  components new AMSenderC(AM_ANSWER) as AnswerSender;
  components new AMReceiverC(AM_DATACOMMUNICATE) as CommunicateReceiver;
  components new AMReceiverC(AM_RADIOBRAODCAST) as BroadcastReceiver;
  components new AMReceiverC(AM_RESPONSE) as ResponseReceiver;

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0; // to get data from minor nodes
  App.Packet -> CommunicateSender;
  App.AMPacket -> CommunicateSender;
  App.AMControl -> ActiveMessageC;
  App.AMSender -> CommunicateSender;
  App.AnswerSend -> AnswerSender;
  App.ReceiveCommunicate -> CommunicateReceiver;
  App.ReceiveRadio -> BroadcastReceiver;
  App.ReceiveResponse -> ResponseReceiver;
}

