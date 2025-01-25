//+------------------------------------------------------------------+
//|                                                   brahim_bot.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#include <Trade/Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
CTrade            Ord;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Order
  {
public:
                     Order(double High, double Low)
     {
      uint   point  = (uint)((High - Low) / _Point);
      Half   = (High - Low) / 2;
      Tp     = Low + Half;
      BySl   = Low - 2 * Half;
      SellSl = NormalizeDouble(High + 2 * Half,1);
      Print("++++++++++ { BySl : ", BySl, " | SellSl: ", SellSl, " } +++++++++++");
      Vl =  CalculateVolume(point);
      Print("Volume: ", Vl);
      Buy();
      Sell();
     }

   double            CalculateVolume(uint point)
     {
      double RiskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (TradeRisk / 100);
      double Volume = NormalizeDouble(RiskAmount / (ValPerPnt * point), 2);

      Print("volume: ",Volume);
      if(Volume < minLot)
         Volume = minLot;
      if(Volume > maxLot)
         Volume = maxLot;
      Print("volume: ", Volume);
      Volume = NormalizeDouble(MathFloor(Volume / lotStep) * lotStep, 2);
      return Volume;
     }

   void              Buy()
     {
      data.BuyTicket = 0;
      Print("=>the low is : ", data.Low);
      Ord.BuyLimit(Vl, data.Low, _Symbol, BySl, Tp);
      if(Ord.ResultRetcode() == TRADE_RETCODE_DONE)
         data.BuyTicket = Ord.ResultOrder();
     }

   void              Sell()
     {
      Print("=>the high is : ", data.High);
      data.SelTicket = 0;
      Ord.SellLimit(Vl, data.High, _Symbol, SellSl, Tp);
      if(Ord.ResultRetcode() == TRADE_RETCODE_DONE)
         data.SelTicket = Ord.ResultOrder();
     }

   double            Half;
   double            Tp;
   double            BySl;
   double            SellSl;
   double            Vl;
  };

///////////////////////// input /////////////
input double TradeRisk = 2;
///////////////////////// global variables //

double ValPerPnt = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE) * _Point;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
         Print("=================================================>the order cancled ");
         Ord.OrderDelete(data.BuyTicket);
         data.reset();
        }
      else
         if(data.IsOrderListed && iLow(_Symbol, PERIOD_M1, 0) <= data.Low)
           {
            Ord.OrderDelete(data.SelTicket);
            data.reset();
           }
  }

/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////

input int UTCOffsetDst = -4; // User-defined UTC offset
input int UTCOffsetNonDst = -5;
input int DSTStartMonth = 3; // Month when DST starts (March = 3)
input int DSTStartDay = 9;   // Day when DST starts (Second Sunday)
input int DSTEndMonth = 11;  // Month when DST ends (November = 11)
input int DSTEndDay = 2;     // Day when DST ends (First Sunday)
input int UTCServerNonDst = 0;
input int UTCServerDst = 1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Data
  {
public:
                     Data(void)
     {
      IsSetHourlyTimer = false;
      reset();
     }

   void              reset()
     {
      IsOrderListed    = false;
      SelTicket        = 0;
      BuyTicket        = 0;
      IsDataReady      = false;
      High             = 0;
      Low              = 0;
     }

   bool              IsOrderListed;
   ulong             SelTicket;
   ulong             BuyTicket;
   double            High;
   double            Low;
   bool              IsSetHourlyTimer;
   bool              IsDataReady;

  };

Data data;

// Function to set the timer for the start of the next hour
void SetHourlyTimer(datetime time)
  {
   MqlDateTime structTime;
   TimeToStruct(time, structTime); // Convert 'time' to MqlDateTime struct

   int currentMinute = structTime.min;               // Get the current minute from the struct
   int secondsToNextHour = (60 - currentMinute) * 60; // Time left until the next hour
   secondsToNextHour += 60 - structTime.sec;

   EventSetTimer(secondsToNextHour + 5); // Set the timer to trigger at the next hour
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
   if(structTime.mon > DSTStartMonth && structTime.mon < DSTEndMonth)
      IsDst = true;
   else
      if(structTime.mon == DSTStartMonth)
        {
         if(structTime.day >= DSTStartDay)
            IsDst = true;
        }
      else
         if(structTime.mon == DSTEndMonth)
           {
            if(structTime.day <= DSTEndDay)
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
   Print("current Time : ", TimeCurrent());
   return (hour == 1); // Check if it's 1 AM in New York
  }

// Function to get the Highest High and Lowest Low between 9 PM and 1 AM
void CalculateHighLow(datetime &time)
  {
// Get the shift for 9 PM (start time of the calculation period)
   int startShift = iBarShift(Symbol(), PERIOD_H1, time - (4 * 3600));

// Get the Highest High and Lowest Low from 9 PM to 1 AM
   data.High = iHigh(Symbol(), PERIOD_H1, startShift);
   data.Low = iLow(Symbol(), PERIOD_H1, startShift);

   for(int i = 0; i < 4; i++)  // Loop through the 4 hours from 9 PM to 1 AM
     {
      data.High = MathMax(data.High, iHigh(Symbol(), PERIOD_H1, startShift - i)); // Find the Highest High
      data.Low = MathMin(data.Low, iLow(Symbol(), PERIOD_H1, startShift - i));    // Find the Lowest Low
     }

   Print("Highest High from 9 PM to 1 AM: ", data.High);
   Print("Lowest Low from 9 PM to 1 AM: ", data.Low);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   datetime currentTime = TimeCurrent();
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
   if(!data.IsSetHourlyTimer)
     {
      Set1HourIntervalTimer();
      data.IsSetHourlyTimer = true;
     }
   if(!data.IsDataReady && Is1AMNewYork(currentTime))
     {
      CalculateHighLow(currentTime);
      data.IsDataReady = true;
     }
  }
//+------------------------------------------------------------------+
