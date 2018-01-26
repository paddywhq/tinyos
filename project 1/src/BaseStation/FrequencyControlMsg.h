
#ifndef FREQMSG_H
#define FREQMSG_H

enum {
  AM_FREQUENCYCONTROLMSG = 6,
};

// message of new frequency setting
typedef nx_struct FrequencyControlMsg {
  nx_uint16_t nodeid;       // its own id
  nx_uint16_t frequency;  // ms
} FrequencyControlMsg;

#endif