//+------------------------------------------------------------------+
//|                                                   brahim_bot.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Trade/OrderInfo.mqh>

double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

class Data {
   public:
      Data() {
         Ready     = false;
         SelTicket = 0;
         BuyTicket = 0;
      }
      bool   Ready;
      double MainHigh;
      double MainLow;
      ulong  SelTicket;
      ulong  BuyTicket;
};

class Order {
   public:
      Order(double High, double Low) {
         uint   point  = (uint)((High - Low) / _Point);
         Half   = (High - Low) / 2;
         Tp     = Low + Half;
         BySl   = Low - 2 * Half;
         SellSl = High + 2 * Half;
         Vl =  CalculateVolume(point);
         Print("Volume: ", Vl);
         Buy();
         Sell();
      }
      
      double CalculateVolume(uint point) {
         double RiskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * (TradeRisk / 100);
         double Volume = NormalizeDouble(RiskAmount / (ValPerPnt * point), 2);
         
         Print("volume: ",Volume);
         if (Volume < minLot) Volume = minLot;
         if (Volume > maxLot) Volume = maxLot;
         Print("volume: ", Volume);
         Volume = NormalizeDouble(MathFloor(Volume / lotStep) * lotStep, 2);
         return Volume;
      }
      
      void Buy() {
         data.BuyTicket = 0;
         Ord.BuyLimit(Vl, data.MainLow, _Symbol, BySl, Tp);
         if (Ord.ResultRetcode() == TRADE_RETCODE_DONE)
            data.BuyTicket = Ord.ResultOrder();
      }
 
      void Sell() {
         data.SelTicket = 0;
         Ord.SellLimit(Vl, data.MainHigh, _Symbol, SellSl, Tp);
         if (Ord.ResultRetcode() == TRADE_RETCODE_DONE)
            data.SelTicket = Ord.ResultOrder();
      }
      
      double Half;
      double Tp;
      double BySl;
      double SellSl;
      double Vl;
};

///////////////////////// input /////////////
input ENUM_TIMEFRAMES TimeFrame = PERIOD_M1;
input double TradeRisk = 2;
///////////////////////// global variables //
CTrade Ord;
COrderInfo OrdInfo;
Data data;

double ValPerPnt = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE) * _Point;
datetime currentCandle = iTime(_Symbol, TimeFrame, 0);

int OnInit()
{
   Print("the programme runs successfully");
   
    Print("min: ", minLot, " maxlot: ", maxLot, " steplot: ", lotStep);
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
   
}

void OnTick()
{
   datetime now = iTime(_Symbol, TimeFrame, 0);
 
   if (currentCandle != now){
      Print("try to make the order");
      data.MainHigh = iHigh(_Symbol, TimeFrame, 1);
      data.MainLow  = iLow(_Symbol, TimeFrame, 1);
      Order order(iHigh(_Symbol, TimeFrame, 1), iLow(_Symbol, TimeFrame, 1));
      data.Ready  = true;
      currentCandle = now;
   } else if (data.Ready && data.BuyTicket && iHigh(_Symbol, TimeFrame, 0) >= data.MainHigh ) {
      Ord.OrderDelete(data.BuyTicket);
      data.Ready = false;
      data.BuyTicket = 0;
   }
   else if (data.Ready && data.BuyTicket&& iLow(_Symbol, TimeFrame, 0) <= data.MainHigh ) {
      Ord.OrderDelete(data.SelTicket);
      data.Ready = false;
      data.SelTicket = 0;
   }
}

void OnTesterInit()
{
}

void OnTesterDeinit()
{
   
}