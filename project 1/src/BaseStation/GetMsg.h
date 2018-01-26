
#ifndef GETMSG_H
#define GETMSG_H

enum {
  AM_GETMSG = 6,
  TIMER_PERIOD_MILLI = 100,       // default frequency
  UNRECEIVED_QUEUE_LENTH = 1000,  // flag of unreceived packet
  NODE_NUMBER = 2,
};

// message of new frequency setting
typedef nx_struct GetMsg {
  nx_uint16_t nodeid;       // sender's id: 1 or 2
  nx_uint16_t sequence;     // sender's sequence number of message
  nx_uint16_t temperature;  // perceived temperature
  nx_uint16_t humidity;     // perceived humidity
  nx_uint16_t light;        // perceived light
  nx_uint32_t time;         // perceiving time
} GetMsg;

// message of new frequency setting
typedef nx_struct RequestMsg {
  nx_uint16_t nodeid;       // its own id
  nx_uint16_t targetid;     // receiver's id
  nx_uint16_t sequence;     // sequence number of message wanted
} RequestMsg;

#endif