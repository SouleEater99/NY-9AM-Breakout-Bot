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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    // Get broker server time
   datetime currentTime = TimeCurrent();
   Print(currentTime);
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
   
   if(data.IsDataReady && !data.IsOrderListed)
     {
      if(data.High > 0 && data.Low > 0)
        {
         Order order(data.High, data.Low);
         data.IsOrderListed  = true;
        }
      else
         data.reset();
     }
   else
      if(data.IsOrderListed && iHigh(_Symbol, PERIOD_M1, 0) >= data.High)
        {
         Print("=================================================>the Buy order cancled ");
         Ord.OrderDelete(data.BuyTicket);
         data.reset();
        }
      else
         if(data.IsOrderListed && iLow(_Symbol, PERIOD_M1, 0) <= data.Low)
           {
            Print("=================================================>the Sell order cancled ");
            Ord.OrderDelete(data.SelTicket);
            data.reset();
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   datetime currentTime = TimeCurrent();
   if(!data.IsSetHourlyTimer)
     {
      Set1HourIntervalTimer();
      data.IsSetHourlyTimer = true;
     }
   if(!data.IsDataReady && Is1AMNewYork(currentTime))
     {
      CalculateHighLow(currentTime);
      MarkHighLow(currentTime);
      data.IsDataReady = true;
     }
  }
//+------------------------------------------------------------------+
