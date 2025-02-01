//+------------------------------------------------------------------+
//|                                                      MyClass.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
double ValPerPnt = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE) * _Point;
input group "Desired Time Zone Settings";
input int UTCOffsetDst = -4; // User-defined UTC offset
input int UTCOffsetNonDst = -5;
input int DSTStartMonth = 3; // Month when DST starts (March = 3)
input int DSTStartDay = 9;   // Day when DST starts (Second Sunday)
input int DSTEndMonth = 11;  // Month when DST ends (November = 11)
input int DSTEndDay = 2;     // Day when DST ends (First Sunday)
input group "Entring Time";
input uint Initial_Time = 1;
input uint Second_Time = 5;
input uint Third_Time = 9;
input group "Server Time Zone";
input int UTCServerNonDst = 0;
input int UTCServerDst = 1;


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
   double            Open;
   double            Close;
   bool              IsSetHourlyTimer;
   bool              IsDataReady;

  };
  
  extern Data data;
 
 
 