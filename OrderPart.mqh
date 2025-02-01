//+------------------------------------------------------------------+
//|                                                    OrderPart.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Trade/Trade.mqh>
#include "./MyGlobals.mqh"

CTrade            Ord;

class Order
  {
public:
                     Order(){}
                     Order(double high, double low)
     {
     High = high;
     Low = low;
      Body     = MathAbs(data.Close - data.Open);
      WickLow  = MathMin(data.Close, data.Open) - data.Low;
      WickHigh = data.High - MathMax(data.Close, data.Open);
      Half     = (High - Low) / 2;
      Tp       = Low + Half;
      BySl     = Low - 2  * Half;
      SellSl   = High + 2 * Half;
      uint   point  = (uint)((High - Low) / _Point);
      if(MathMax(WickHigh, WickLow) > Body)
        {
         Print("############### the body is less then one of the wicks #######################");
         return;
        }
      Print("++++++++++ { BySl : ", BySl, " | SellSl: ", SellSl," Volume: ", Vl ," } +++++++++++");
      Vl =  CalculateVolume(point);
      Buy();
      Sell();
     }
   
   bool Is_Passed()
      {
         if (iHigh(_Symbol, PERIOD_M1, 0) >= High) 
         {
            Ord.OrderDelete(BuyTicket);
            return true;
         }
         else if (iLow(_Symbol, PERIOD_M1, 0) <= Low)
         {
            Ord.OrderDelete(SellTicket);
            return true;
         }
         return false;
      }
      
   double           CalculateVolume(uint point)
     {
      double RiskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (TradeRisk / 100);
      double Volume = NormalizeDouble(RiskAmount / (ValPerPnt * point), 2);

      if(Volume < minLot)
         Volume = minLot;
      if(Volume > maxLot)
         Volume = maxLot;
      Volume = NormalizeDouble(MathFloor(Volume / lotStep) * lotStep, 2);
      return Volume;
     }

   void              Buy()
     {
      data.BuyTicket = 0;
      Ord.BuyLimit(Vl, data.Low, _Symbol, BySl, Tp);
      if(Ord.ResultRetcode() == TRADE_RETCODE_DONE)
         BuyTicket = Ord.ResultOrder();
     }

   void              Sell()
     {
      data.SelTicket = 0;
      Ord.SellLimit(Vl, data.High, _Symbol, SellSl, Tp);
      if(Ord.ResultRetcode() == TRADE_RETCODE_DONE)
         SellTicket = Ord.ResultOrder();
     }

   double            Half;
   double            Tp;
   double            BySl;
   double            SellSl;
   double            Vl;
   double            Body;
   double            WickLow;
   double            WickHigh;
   double High;
   double Low;
   ulong SellTicket;
   ulong BuyTicket;
  };

input group "Risk Management"
input double TradeRisk = 2;