#include <Timer.h>
#include "DataAggregation.h"
#include "printf.h"

module DataAggregationC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend as AMSender;
  uses interface AMSend as AnswerSend;
  uses interface Receive as ReceiveResponse;
  uses interface Receive as ReceiveRadio;
  uses interface Receive as ReceiveCommunicate;
  uses interface SplitControl as AMControl;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE, switchFlag = FALSE, handleFlag = FALSE, doneFlag = FALSE;
  uint16_t head, tail;
  uint32_t data[DATA_NUM];
  uint32_t max, min, sum, average, median;

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On(); 
    else
      call Leds.led0Off();  
    if (val & 0x02)
      call Leds.led1Toggle();
    if (val & 0x04)
      call Leds.led2Toggle();
  }
  event void Boot.booted() {
    uint16_t i = 0;
    for(i = 0;i <= 2000;i++)
     data[i] = 20000;
    head = 1;
    tail = 2000;
    max = 0;
    min = 20000;
    sum = 0;
    counter = 0;
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      setLeds(1);
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
      setLeds(0);
  }

  task void sendRequest(){
    TransMsg* req;
    uint16_t loopCount = 0;
    if(busy)
      return;
    if(switchFlag) {
      req = (TransMsg*)(call Packet.getPayload(&pkt, sizeof(TransMsg)));
      req->nodeid = TOS_NODE_ID;
      req->sequence = head;
      req->data = 20000;
      do{
        if(head == 2000)
          head = 1;
        else
          head++;
        loopCount++;
        if(loopCount >= 2000){
          break;printf("error!\n");}
      }while(data[head] != 20000);
      if (call AMSender.send(MINORNODE1_ID, &pkt, sizeof(TransMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
    else {
      req = (TransMsg*)(call Packet.getPayload(&pkt, sizeof(TransMsg)));
      req->nodeid = TOS_NODE_ID;
      req->sequence = tail;
      req->data = 20000;
      do{
        if(tail == 1)
          tail = 2000;
        else
          tail--;
        loopCount++;
        if(loopCount >= 2000){
          break;printf("error!\n");}
      }while(data[tail] != 20000);
      if (call AMSender.send(MINORNODE2_ID, &pkt, sizeof(TransMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
    if(switchFlag)
      switchFlag = FALSE;
    else
      switchFlag = TRUE;
    setLeds(3);
  }
  task void sendAnswer(){
    uint32_t minus = (uint32_t)20000000;
    AnswerMsg* ampck = (AnswerMsg*)(call Packet.getPayload(&pkt, sizeof(AnswerMsg)));
    ampck->group_id = 4;
    ampck->min = min-10000;
    ampck->max = max-10000;
    ampck->sum = sum-minus;
    ampck->average = average-10000;
    ampck->median = median-10000;
    printf("sendmax:%ld\n",ampck->max);
    printf("sendmin:%ld\n",ampck->min);
    printf("sendmedian:%ld\n",ampck->median);
    printf("sendaverage:%ld\n",ampck->average);
    printf("sendsum:%ld\n",ampck->sum);
    if(call AnswerSend.send(0, &pkt, sizeof(AnswerMsg)) == SUCCESS) {
      busy = TRUE;
    }
    setLeds(6);
  }
  uint16_t partion(uint32_t a[], uint16_t low, uint16_t high){
    uint32_t i = a[low];
    while(low < high){
      while(low < high && a[high] >= i)
        --high;
      a[low] = a[high];
      while(low < high && a[low] <= i)
        ++low;
      a[high] = a[low];
    }
    a[low] = i;
    return low;
  }
  void qsort(uint32_t a[], uint16_t low, uint16_t high) {
    uint16_t p;
    if (low < high) {
      p = partion(a, low, high);
      qsort(a, low, p - 1);
      qsort(a, p + 1, high);
    }
  }
  task void handleData(){
    printf("computing starts!\n");
    qsort(data, 1, 2000);
    average = sum / 2000;
    median = (data[1000] + data[1001]) / 2;

    printf("max:%ld\n",max);
    printf("min:%ld\n",min);
    printf("median:%ld\n",median);
    printf("average:%ld\n",average);
    printf("sum:%ld\n",sum);
    handleFlag = TRUE;
  }
  event void Timer0.fired() {
    if(busy) {
      return;
    }
    if(doneFlag){
      return;
    }
    if(TOS_NODE_ID == MAJORNODE_ID){
      if(counter >= 2000 && !handleFlag){
        printf("computing starts!\n");
        printf("2000 is done!\n");
        setLeds(0); 
        post handleData();
      }
      else if(handleFlag && !doneFlag){
        post sendAnswer();
      }
      else if(doneFlag){
        setLeds(25); 
      }
      else{
        post sendRequest();
        printf("counter:%d!\n", counter);
      }
    }
  }
  event void AMSender.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event void AnswerSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }
  event message_t* ReceiveCommunicate.receive(message_t* msg, void* payload, uint8_t len){
    if(len == sizeof(TransMsg)){
      TransMsg* rec = (TransMsg*)payload;
      TransMsg* resp = (TransMsg*)(call Packet.getPayload(&pkt, sizeof(TransMsg)));
      if (!busy && rec->nodeid == MAJORNODE_ID) {
        if(data[rec->sequence] != 20000) {
          resp->data = data[rec->sequence];
          resp->nodeid = TOS_NODE_ID;
          resp->sequence = rec->sequence;
          setLeds(3);
          if (call AMSender.send(MAJORNODE_ID, &pkt, sizeof(TransMsg)) == SUCCESS) {
            busy = TRUE;
          } 
        }
        setLeds(5);
      }
      else if(!busy && (rec->nodeid == MINORNODE1_ID || rec->nodeid == MINORNODE2_ID)){
        if(data[rec->sequence] != 20000)
          return msg;
        else{
          data[rec->sequence] = rec->data;
          if(data[rec->sequence] < min)
            min = data[rec->sequence];
          if(data[rec->sequence] > max)
            max = data[rec->sequence];
          sum += data[rec->sequence];
          counter++;
          setLeds(5);
        }
      }
    }
    return msg;
  }
  event message_t* ReceiveRadio.receive(message_t* msg, void* payload, uint8_t len){
    uint32_t temp;
    if (len == sizeof(SourceMsg)) {
      SourceMsg* spkt = (SourceMsg*)payload;
      if(data[spkt->sequence_number] != 20000)
        return msg;
      else{
        temp = spkt->random_integer;
        data[spkt->sequence_number] = temp + 10000;
        if(data[spkt->sequence_number] < min)
          min = data[spkt->sequence_number];
        if(data[spkt->sequence_number] > max)
          max = data[spkt->sequence_number];
        sum += data[spkt->sequence_number];
        counter++;
        setLeds(5);
      }
    }
    return msg;
  }
  event message_t* ReceiveResponse.receive(message_t* msg, void* payload, uint8_t len){
    ResponseMsg* resp = (ResponseMsg*)(call Packet.getPayload(&pkt, sizeof(ResponseMsg)));
    if(len == sizeof(ResponseMsg) && resp->group_id == 4){
      doneFlag = TRUE;
      setLeds(1); 
    }
    return msg;
  }
}
