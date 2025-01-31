//+------------------------------------------------------------------+
//|                                                   TimePart.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include "./MyGlobals.mqh"

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



void MarkPrice(datetime time, double price, color Cl, string t)
{
   string line_name = t + "|" + StringSubstr(TimeToString(time),12,5) + "=>" + DoubleToString(NormalizeDouble(price, _Digits));
   ObjectCreate(0, line_name, OBJ_TREND, 0, time, NormalizeDouble(price, _Digits), time + 60*60*3, NormalizeDouble(price, _Digits));
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, Cl);
   ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
   //ObjectSetString(0, line_name, OBJPROP_TEXT, line_name);
   ObjectSetString(0, line_name, OBJPROP_TOOLTIP, "High only: " + DoubleToString(NormalizeDouble(price, _Digits)));

}

void  MarkHighLow(datetime& time)
{   
   MarkPrice(time - (4 * 3600), data.Low, clrBlue, "Low");
   MarkPrice(time - (4 * 3600), data.High, clrBlue, "High");
   MarkPrice(time - (4 * 3600), data.Open, clrGreen, "Open");
   MarkPrice(time - (4 * 3600), data.Close, clrRed, "Close");
}
// Function to get the Highest High and Lowest Low between 9 PM and 1 AM
void CalculateHighLow(datetime &time)
  {
// Get the shift for 9 PM (start time of the calculation period)
   int startShift = iBarShift(Symbol(), PERIOD_H1, time - (4 * 3600));
// Get the Highest High and Lowest Low from 9 PM to 1 AM
   data.High  = iHigh(Symbol(), PERIOD_H1, startShift);
   data.Low   = iLow(Symbol(), PERIOD_H1, startShift);
   data.Open  = iOpen(Symbol(), PERIOD_H1, startShift);
   data.Close = iClose(Symbol(), PERIOD_H1, startShift - 3);
   for(int i = 0; i < 4; i++)  // Loop through the 4 hours from 9 PM to 1 AM
     {
      data.High = MathMax(data.High, iHigh(Symbol(), PERIOD_H1, startShift - i)); // Find the Highest High
      data.Low = MathMin(data.Low, iLow(Symbol(), PERIOD_H1, startShift - i));    // Find the Lowest Low
     }

   Print("Highest High from 9 PM to 1 AM: ", data.High);
   Print("Lowest Low from 9 PM to 1 AM: ", data.Low);
  }