// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef DATAAGGREGATION_H
#define DATAAGGREGATION_H

enum {
  AM_RADIOBRAODCAST = 0,
  AM_ANSWER = 10,
  AM_RESPONSE = 5,
  AM_DATACOMMUNICATE = 14,
  TIMER_PERIOD_MILLI = 50,
  DATA_NUM = 2002,
  MAJORNODE_ID = 10,
  MINORNODE1_ID = 11,
  MINORNODE2_ID = 12
};

typedef nx_struct SourceMsg {
  nx_uint16_t sequence_number;
  nx_uint32_t random_integer;
} SourceMsg;

typedef nx_struct TransMsg {
  nx_uint16_t nodeid;
  nx_uint16_t sequence;
  nx_uint32_t data;
} TransMsg;

typedef nx_struct AnswerMsg {
  nx_uint8_t group_id;
  nx_uint32_t max;
  nx_uint32_t min;
  nx_uint32_t sum;
  nx_uint32_t average;
  nx_uint32_t median;
} AnswerMsg;

typedef nx_struct ResponseMsg {
  nx_uint8_t group_id;
} ResponseMsg;

#endif
