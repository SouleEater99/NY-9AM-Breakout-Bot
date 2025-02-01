//+------------------------------------------------------------------+
//|                                                   brahim_bot.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#include "../include/OrderPart.mqh"
#include "../include/TimePart.mqh"
#include "../include/MyGlobals.mqh"

Data data;
Order orders[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    // Get broker server time
   datetime currentTime = TimeCurrent();
   Print(currentTime);
   int UTCServer = (int)(TimeTradeServer() - TimeGMT()) / 3600;
   Print("+++++++++ UTCServer : ",  UTCServer," ++++++++++++");

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

void OnTick()
  {
   
   if (data.IsDataReady)
     {
      if(data.High > 0 && data.Low > 0)
        {
         Order order(data.High, data.Low);
         data.reset();
         if (!order.isBodyValid())
            return ;
         ArrayResize(orders, ArraySize(orders) + 1);
         orders[ArraySize(orders) -1] = order;
        }
     }
   for (int i = 0; i < ArraySize(orders);i++)
   {
      if (orders[i].Is_Passed())
      {
         for(int j = i;j + 1 < ArraySize(orders); j++)
            orders[j] = orders[j + 1];
         ArrayResize(orders, ArraySize(orders) - 1);
         i--;
      }
   }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   uint  HourTime;
   
   datetime currentTime = TimeCurrent();
   if(!data.IsSetHourlyTimer)
     {
      Set1HourIntervalTimer();
      data.IsSetHourlyTimer = true;
     }
   HourTime = GetUtcTimeHour(currentTime);
   if(!data.IsDataReady && (HourTime == Initial_Time|| HourTime == Second_Time || HourTime == Third_Time))
     {
      Print("============== I Am HEre ++++++++++++++++");
      CalculateHighLow(currentTime);
      MarkHighLow(currentTime);
      data.IsDataReady = true;
     }
  }
//+------------------------------------------------------------------+
