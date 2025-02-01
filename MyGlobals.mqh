//+------------------------------------------------------------------+
//|                                                      MyClass.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

enum AllTimes
  {
   TIME_00 = 0, // 00:00 (midnight)
   TIME_01 = 1, // 01:00
   TIME_02 = 2, // 02:00
   TIME_03 = 3, // 03:00
   TIME_04 = 4, // 04:00
   TIME_05 = 5, // 05:00
   TIME_06 = 6, // 06:00
   TIME_07 = 7, // 07:00
   TIME_08 = 8, // 08:00
   TIME_09 = 9, // 09:00
   TIME_10 = 10, // 10:00
   TIME_11 = 11, // 11:00
   TIME_12 = 12, // 12:00
   TIME_13 = 13, // 13:00
   TIME_14 = 14, // 14:00
   TIME_15 = 15, // 15:00
   TIME_16 = 16, // 16:00
   TIME_17 = 17, // 17:00
   TIME_18 = 18, // 18:00
   TIME_19 = 19, // 19:00
   TIME_20 = 20, // 20:00
   TIME_21 = 21, // 21:00
   TIME_22 = 22, // 22:00
   TIME_23 = 23  // 23:00
  };

enum GMT_Options
  {
   GMT_Minus_12 = -12,  // GMT -12
   GMT_Minus_11 = -11,  // GMT -11
   GMT_Minus_10 = -10,  // GMT -10
   GMT_Minus_9  = -9,   // GMT -9
   GMT_Minus_8  = -8,   // GMT -8
   GMT_Minus_7  = -7,   // GMT -7
   GMT_Minus_6  = -6,   // GMT -6
   GMT_Minus_5  = -5,   // GMT -5
   GMT_Minus_4  = -4,   // GMT -4
   GMT_Minus_3  = -3,   // GMT -3
   GMT_Minus_2  = -2,   // GMT -2
   GMT_Minus_1  = -1,   // GMT -1
   GMT_0        = 0,    // GMT 0
   GMT_Plus_1   = 1,    // GMT +1
   GMT_Plus_2   = 2,    // GMT +2
   GMT_Plus_3   = 3,    // GMT +3
   GMT_Plus_4   = 4,    // GMT +4
   GMT_Plus_5   = 5,    // GMT +5
   GMT_Plus_6   = 6,    // GMT +6
   GMT_Plus_7   = 7,    // GMT +7
   GMT_Plus_8   = 8,    // GMT +8
   GMT_Plus_9   = 9,    // GMT +9
   GMT_Plus_10  = 10,   // GMT +10
   GMT_Plus_11  = 11,   // GMT +11
   GMT_Plus_12  = 12    // GMT +12
  };
  
double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
double ValPerPnt = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_CONTRACT_SIZE) * _Point;
input group "Desired Time Zone Settings";
input GMT_Options UTCOffsetDst = GMT_Minus_4; // User-defined UTC offset
input GMT_Options UTCOffsetNonDst = GMT_Minus_5;
input int DSTStartMonth = 3; // Month when DST starts (March = 3)
input int DSTStartDay = 9;   // Day when DST starts (Second Sunday)
input int DSTEndMonth = 11;  // Month when DST ends (November = 11)
input int DSTEndDay = 2;     // Day when DST ends (First Sunday)
input group "Entring Time";
input AllTimes Initial_Time = TIME_01;
input AllTimes Second_Time = TIME_05;
input AllTimes Third_Time = TIME_09;
input group "Server Time Zone";
input GMT_Options UTCServerNonDst = GMT_0;
input GMT_Options UTCServerDst = GMT_Plus_1;


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
 
 
 