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
double InitMonthBalance = AccountInfoDouble(ACCOUNT_BALANCE);
string LastMonth = StringSubstr(TimeToString(TimeCurrent()), 0, 7);


int OnInit()
  {
   char result[];
   char headers[];
   string response;
   int timeout = 5000;
   
   int res = WebRequest("GET", "http://127.0.0.1:8000/", "", timeout, headers, result, response); 
   if (res == -1)
      Print("error", GetLastError());
      
   datetime currentTime = TimeCurrent();
   Print(currentTime);
   int UTCServer = (int)(TimeTradeServer() - TimeGMT()) / 3600;
   Print("+++++++++ UTCServer : ",  UTCServer," ++++++++++++");

   SetHourlyTimer(currentTime);
   return (INIT_SUCCEEDED);
  }
  
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
         ArrayResize(orders, ArraySize(orders) + 1);
         orders[ArraySize(orders) - 1] = order;
        }
       data.reset();
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
  
  bool IsPermitedToEnter(datetime &currentTime) //check is all good to enter
  {
   uint  HourTime = GetUtcTimeHour(currentTime);
   double Balanace = AccountInfoDouble(ACCOUNT_BALANCE);
   double Diff = Balanace - InitMonthBalance;
   bool IsTheHour = HourTime == Initial_Time|| HourTime == Second_Time || HourTime == Third_Time; // is one of the hours to enter
   bool IsWithinLimits =  Diff <= InitMonthBalance * MonthTarget / 100 && -Diff <= InitMonthBalance * MonthLost / 100; // in lost<x<profit
   
   return (!data.IsDataReady && IsTheHour && IsWithinLimits);
  }
  
void OnTimer()
  {
   datetime currentTime = TimeCurrent();
   if(!data.IsSetHourlyTimer) // adjust the ontime function to be called exactly every hours in hour:00:03
     {
      Set1HourIntervalTimer();
      data.IsSetHourlyTimer = true;
     }
   string CurrentMonth = StringSubstr(TimeToString(TimeCurrent()), 0, 7);
   if (CurrentMonth != LastMonth) // check if we still in the same month
   {
      InitMonthBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      LastMonth = CurrentMonth;
      DrawMonthlyBalance();
   }
   if(IsPermitedToEnter(currentTime))
     {
      Print("============== I Am HEre ++++++++++++++++");
      CalculateHighLow(currentTime);
      MarkHighLow(currentTime);
      data.IsDataReady = true;
     }
  }