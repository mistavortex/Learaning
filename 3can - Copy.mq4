//+------------------------------------------------------------------+
//|                                                         3can.mq4 |
//|                                                                 |
//|                                                                 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

extern ENUM_TIMEFRAMES HigherTimeframe = PERIOD_M5;
extern int BarsToProcess = 1000;
extern bool ShowRectangles = true;
extern color BullishColor = clrSkyBlue;
extern color BearishColor = clrIndianRed;
extern color NeutralColor = clrPurple;
extern color BullArrowColor = clrAqua;
extern color BearArrowColor = clrPink;


bool indicatorOn = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   CreateButton("Fval_Button", "Fval ON", 10, 20, 100, 20, clrGreen, clrLime);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Clean up only objects created by this indicator
   int totalObjects = ObjectsTotal();
   for (int i = totalObjects - 1; i >= 0; i--) {
       string name = ObjectName(i);
       if (StringFind(name, "3Can_") == 0) {
           ObjectDelete(name);
       }
   }
   ObjectDelete("Fval_Button");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   RecalculateIndicator();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if (id == CHARTEVENT_OBJECT_CLICK && sparam == "Fval_Button") {
       indicatorOn = !indicatorOn;
       if (indicatorOn) {
           ObjectSetInteger(0, "Fval_Button", OBJPROP_BGCOLOR, clrGreen);
           ObjectSetInteger(0, "Fval_Button", OBJPROP_COLOR, clrLime);
           ObjectSetString(0, "Fval_Button", OBJPROP_TEXT, "Fval ON");
       } else {
           ObjectSetInteger(0, "Fval_Button", OBJPROP_BGCOLOR, clrDimGray);
           ObjectSetInteger(0, "Fval_Button", OBJPROP_COLOR, clrRed);
           ObjectSetString(0, "Fval_Button", OBJPROP_TEXT, "Fval OFF");
           int totalObjects = ObjectsTotal();
           for (int i = totalObjects - 1; i >= 0; i--) {
               string name = ObjectName(i);
               if (StringFind(name, "3Can_") == 0) {
                   ObjectDelete(name);
               }
           }
       }
       RecalculateIndicator();
   }
  }
//+------------------------------------------------------------------+
void UpdateLastValues(datetime &lastEndTime, double &lastHigh, double &lastLow, double &lastMid, color &lastColor, datetime endTime, double high, double low, color rectColor) {
    lastEndTime = endTime;
    lastHigh = high;
    lastLow = low;
    lastMid = (high + low) / 2;
    lastColor = rectColor;
}
//+------------------------------------------------------------------+
void RecalculateIndicator()
{
    if (!ShowRectangles || !indicatorOn) {
        return;
    }

    // Delete existing lines before drawing new ones
    int totalObjects = ObjectsTotal();
    for (int i = totalObjects - 1; i >= 0; i--) {
        string name = ObjectName(i);
        if (StringFind(name, "3Can_Line_") == 0) {
            ObjectDelete(name);
        }
    }

    int higherRatesTotal = iBars(NULL, HigherTimeframe);
    datetime higherTime[];
    double higherOpen[], higherHigh[], higherLow[], higherClose[];
    ArraySetAsSeries(higherTime, true);
    ArraySetAsSeries(higherOpen, true);
    ArraySetAsSeries(higherHigh, true);
    ArraySetAsSeries(higherLow, true);
    ArraySetAsSeries(higherClose, true);
    CopyTime(NULL, HigherTimeframe, 0, higherRatesTotal, higherTime);
    CopyOpen(NULL, HigherTimeframe, 0, higherRatesTotal, higherOpen);
    CopyHigh(NULL, HigherTimeframe, 0, higherRatesTotal, higherHigh);
    CopyLow(NULL, HigherTimeframe, 0, higherRatesTotal, higherLow);
    CopyClose(NULL, HigherTimeframe, 0, higherRatesTotal, higherClose);

    static datetime lastEndTime = 0;
    static double lastHigh = 0;
    static double lastLow = 0;
    static double lastMid = 0;
    static color lastColor = clrBlack;
    static bool patternFound = false;

    if (BarsToProcess > higherRatesTotal) BarsToProcess = higherRatesTotal;
    if (BarsToProcess < 5) BarsToProcess = 10;

    // First pass: detect and draw all patterns
    for (int i = BarsToProcess - 4; i >= 1; i--) {
        double H3 = higherHigh[i];
        double L3 = higherLow[i];
        double H2 = higherHigh[i + 1];
        double L2 = higherLow[i + 1];
        double H1 = higherHigh[i + 2];
        double L1 = higherLow[i + 2];
        double C2 = higherClose[i + 1];
        double O2 = higherOpen[i + 1];

        color rectColor;
        if (C2 > O2) {
            rectColor = BullishColor;
        } else if (C2 < O2) {
            rectColor = BearishColor;
        } else {
            rectColor = NeutralColor;
        }

        if (L1 > H3) {
            DrawRectangle("3Can_Rect_Bull_" + IntegerToString(higherTime[i]), H3, L1, rectColor, higherTime[i], higherTime[i + 2]);
            UpdateLastValues(lastEndTime, lastHigh, lastLow, lastMid, lastColor, higherTime[i + 2], H3, L1, rectColor);
            patternFound = true;
        } else if (L3 > H1) {
            DrawRectangle("3Can_Rect_Bear_" + IntegerToString(higherTime[i]), L3, H1, rectColor, higherTime[i], higherTime[i + 2]);
            UpdateLastValues(lastEndTime, lastHigh, lastLow, lastMid, lastColor, higherTime[i + 2], L3, H1, rectColor);
            patternFound = true;
        }

        // Draw lines from the current bar to the next if pattern was found
        if (patternFound && i > 1) {
            string lineName = "3Can_Line_" + IntegerToString(higherTime[i]);
            DrawLine(lineName + "_High", lastHigh, higherTime[i], higherTime[i-1], lastColor, STYLE_DASH, 1);
            DrawLine(lineName + "_Mid", lastMid, higherTime[i], higherTime[i-1], lastColor, STYLE_DASH, 1);
            DrawLine(lineName + "_Low", lastLow, higherTime[i], higherTime[i-1], lastColor, STYLE_DASH, 1);
        }
    }
}
//+------------------------------------------------------------------+
void DrawRectangle(string name, double price1, double price2, color rectColor, datetime time1, datetime time2) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
        ObjectSetInteger(0, name, OBJPROP_COLOR, rectColor);
        ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, name, OBJPROP_BACK, true);
        ObjectSetInteger(0, name, OBJPROP_RAY, false);
    }
}

void DrawLine(string name, double price, datetime time1, datetime time2, color lineColor, int lineStyle, int lineWidth) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price);
        ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
        ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWidth);
        ObjectSetInteger(0, name, OBJPROP_RAY, false);
        ObjectSetInteger(0, name, OBJPROP_BACK, true);
    } else {
        ObjectMove(0, name, 0, time1, price);
        ObjectMove(0, name, 1, time2, price);
        ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
        ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWidth);
    }
}
void CreateButton(string name, string text, int x, int y, int width, int height, color bgColor, color textColor) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
        ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetInteger(ChartID(), name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(ChartID(), name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, name, OBJPROP_STATE, true);
    }
}

