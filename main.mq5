//+------------------------------------------------------------------+
//|                                                   brahim_bot.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"

input int UTCOffsetDst = -4; // User-defined UTC offset
input int UTCOffsetNonDst = -5;
input int DSTStartMonth = 3; // Month when DST starts (March = 3)
input int DSTStartDay = 9;   // Day when DST starts (Second Sunday)
input int DSTEndMonth = 11;  // Month when DST ends (November = 11)
input int DSTEndDay = 2;     // Day when DST ends (First Sunday)
input int UTCServerNonDst = 0;
input int UTCServerDst = 1;

input ENUM_TIMEFRAMES tm = PERIOD_M5;
ENUM_TIMEFRAMES timeframe = tm;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Data
{
public:
  double high;
  double low;
  bool IsSetHourlyTimer;
  bool isTradeMaked;
  Data(void)
  {
    IsSetHourlyTimer = false;
    isTradeMaked = false;
    high = 0;
    low = 0;
  }
};

Data data;

// Function to set the timer for the start of the next hour
void SetHourlyTimer(datetime time)
{
  MqlDateTime structTime;
  TimeToStruct(time, structTime); // Convert 'time' to MqlDateTime struct

  int currentMinute = structTime.min;                // Get the current minute from the struct
  int secondsToNextHour = (60 - currentMinute) * 60; // Time left until the next hour

  EventSetTimer(secondsToNextHour); // Set the timer to trigger at the next hour
}

// Function to set the timer for 1-hour intervals after the initial start
void Set1HourIntervalTimer()
{
  EventSetTimer(3600); // Set timer for every 1 hour (3600 seconds)
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isDstActive(datetime &time)
{
  bool IsDst = false;
  MqlDateTime structTime;
  TimeToStruct(time, structTime);

  // Check if within DST period
  if (structTime.mon > DSTStartMonth && structTime.mon < DSTEndMonth)
    IsDst = true;
  else if (structTime.mon == DSTStartMonth)
  {
    if (structTime.day >= DSTStartDay)
      IsDst = true;
  }
  else if (structTime.mon == DSTEndMonth)
  {
    if (structTime.day <= DSTEndDay)
      IsDst = true;
  }
  return IsDst;
}

// Function to check if it's 1 AM New York time
bool Is1AMNewYork(datetime &time)
{
  MqlDateTime structTime;
  TimeToStruct(time, structTime); // Convert the input 'time' to MqlDateTime struct

  int offset = isDstActive(time) ? UTCOffsetDst + (-1 * UTCServerDst) : UTCOffsetNonDst + (-1 * UTCServerNonDst); // Adjust for New York time (or user-defined UTC offset)
  datetime newYorkTime = time + (offset * 3600);                                                                  // Convert to New York time

  // Convert the New York time to MqlDateTime struct for hour extraction
  MqlDateTime newYorkStructTime;
  TimeToStruct(newYorkTime, newYorkStructTime);

  int hour = newYorkStructTime.hour; // Extract the hour from the new time
  Print("+++++++++++ {Offset: ", offset, "} ++++++++++++\n");
  return (hour == 1); // Check if it's 1 AM in New York
}

// Function to get the highest high and lowest low between 9 PM and 1 AM
void CalculateHighLow(datetime &time)
{
  // Get the shift for 9 PM (start time of the calculation period)
  int startShift = iBarShift(Symbol(), PERIOD_H1, time - (4 * 3600));

  // Get the highest high and lowest low from 9 PM to 1 AM
  data.high = iHigh(Symbol(), PERIOD_H1, startShift);
  data.low = iLow(Symbol(), PERIOD_H1, startShift);

  for (int i = 0; i < 4; i++) // Loop through the 4 hours from 9 PM to 1 AM
  {
    data.high = MathMax(data.high, iHigh(Symbol(), PERIOD_H1, startShift - i)); // Find the highest high
    data.low = MathMin(data.low, iLow(Symbol(), PERIOD_H1, startShift - i));    // Find the lowest low
  }

  Print("Highest High from 9 PM to 1 AM: ", data.high);
  Print("Lowest Low from 9 PM to 1 AM: ", data.low);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  datetime currentTime = TimeCurrent();
  if (timeframe == 0)
    timeframe = PERIOD_H4;
  SetHourlyTimer(currentTime);
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  //--- destroy timer
  EventKillTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
  //---
  datetime currentTime = TimeCurrent();
  if (!data.IsSetHourlyTimer)
  {
    Set1HourIntervalTimer();
    data.IsSetHourlyTimer = true;
  }
  if (!data.isTradeMaked && Is1AMNewYork(currentTime))
  {
    CalculateHighLow(currentTime);
    data.isTradeMaked = true;
  }
}
//+------------------------------------------------------------------+
