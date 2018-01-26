#include <Timer.h>
#include "DataCollection.h"
#include "printf.h"

module DataCollectionC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Read<uint16_t> as ReadT;
  uses interface Read<uint16_t> as ReadH;
  uses interface Read<uint16_t> as ReadL;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  uint16_t frequency = 100;
  DataMsg localStorage[LOCAL_STORAGE_NUM+1];
  bool readTemperatureDone = FALSE;
  bool readHumidityDone = FALSE;
  bool readLightDone = FALSE;

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {
    counter = 1;
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(frequency);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    
    if(!busy && readTemperatureDone == FALSE) {
      call ReadT.read();
    }
    if(!busy && readHumidityDone == FALSE) {
      call ReadH.read();
    }
    if(!busy && readLightDone == FALSE) {
      call ReadL.read();
    }
    if(readTemperatureDone && readHumidityDone && readLightDone) {
      setLeds(1);
      localStorage[counter].time = call Timer0.getNow();
      readTemperatureDone = FALSE;
      readHumidityDone = FALSE;
      readLightDone = FALSE; 
      counter = (counter+1)%LOCAL_STORAGE_NUM;
    }
  }

  event void ReadT.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS){
      localStorage[counter].temperature = val;
    }
    else
      localStorage[counter].temperature = 0xffff;
    readTemperatureDone = TRUE;
  }

  event void ReadH.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS){
      localStorage[counter].humidity = val;
    }
    else
      localStorage[counter].humidity = 0xffff;
    readHumidityDone = TRUE;
  }

  event void ReadL.readDone(error_t result, uint16_t val) {
    if (result == SUCCESS){
      localStorage[counter].light = val;
    }
    else
      localStorage[counter].light = 0xffff;
    readLightDone = TRUE;
  }

  void sendData(uint16_t sequence) {
    if (!busy) {
      DataMsg* dmpkt = (DataMsg*)(call Packet.getPayload(&pkt, sizeof(DataMsg)));
      if(dmpkt == NULL) {
        return;
      }
      if(!localStorage[sequence%LOCAL_STORAGE_NUM].temperature
      ||!localStorage[sequence%LOCAL_STORAGE_NUM].humidity)
        return;
      dmpkt->node = TOS_NODE_ID;
      dmpkt->sequence = sequence;
      dmpkt->temperature = localStorage[sequence%LOCAL_STORAGE_NUM].temperature;
      dmpkt->humidity = localStorage[sequence%LOCAL_STORAGE_NUM].humidity;
      dmpkt->light = localStorage[sequence%LOCAL_STORAGE_NUM].light;
      dmpkt->time = localStorage[sequence%LOCAL_STORAGE_NUM].time;
      if(call AMSend.send(TOS_NODE_ID - 1, &pkt, sizeof(DataMsg)) == SUCCESS){
        busy = TRUE;
      }
    }
    setLeds(4);
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  void transfer(message_t* msg, void* payload) {
    if(TOS_NODE_ID == 1){
      DataMsg* dmpkt = (DataMsg*)payload;
      if(dmpkt->node == 2 && !busy){
        DataMsg* transferpkt = (DataMsg*)(call Packet.getPayload(&pkt, sizeof(DataMsg)));
        if(transferpkt == NULL) {
          return;
        }
        transferpkt->node = dmpkt->node;
        transferpkt->sequence = dmpkt->sequence;
        transferpkt->temperature = dmpkt->temperature;
        transferpkt->humidity = dmpkt->humidity;
        transferpkt->light = dmpkt->light;
        transferpkt->time = dmpkt->time;
        if(call AMSend.send(0, &pkt, sizeof(DataMsg)) == SUCCESS){
          busy = TRUE;
        }
      }
    }
  }

  void setFre(nx_uint16_t freq) {
    counter = 1;
    frequency = freq;
    call Timer0.startPeriodic(frequency);
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(DataMsg)) {
      transfer(msg, payload);
    }
    else if(len == sizeof(FrequencyControlMsg)){
      FrequencyControlMsg* fcmpkt = (FrequencyControlMsg*)payload;
      if(fcmpkt->node == 0){
        setFre(fcmpkt->frequency);
      }
    }
    else if(len == sizeof(RequestMsg)){
      RequestMsg* request = (RequestMsg*)payload;
      if(request->node == 0) {
        if(TOS_NODE_ID == request->target){
          sendData(request->sequence);
        }
      }
    }
    setLeds(2);
    return msg;
  }
}

