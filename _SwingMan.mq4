//+------------------------------------------------------------------+
//|                                                   _SwingMan.mq4 |
//|                                                                 |
//|                                                                 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#define INDICATOR_NAME       ""

#property indicator_chart_window
#property indicator_buffers 8

ENUM_TIMEFRAMES HigherTimeframe = PERIOD_CURRENT;
extern int BarsToProcess = 1000;
 string button_name = "SwingMan ";
extern bool ShowDots = true;
extern bool ShowBears = true;
extern bool ShowBulls = true;
input string High_Note = "------------------------------------------------------------";
extern int swingDeterminer = 89; // HIGH SCAN How many bars to scan for highest or lowest price.
extern int arrowWidth = 4;
extern color BullishColor = clrDodgerBlue;
extern color BearishColor = clrOrangeRed;
input string Low_Note = "------------------------------------------------------------";
extern int swingDeterminer2 = 34; // LOE SCAN How many bars to scan for highest or lowest price.
extern int arrowWidth2 = 1;
extern color BullArrowColor = clrOrangeRed;
extern color BearArrowColor = clrDodgerBlue;


// indicator buffers
double BuyLine[];
double SellLine[];
double BullCandle[];
double BearCandle[];
double BlueDot[];
double RedDot[];
double BlueDot2[];
double RedDot2[];

int signal;
#define NOSIG 0
#define BUYSIG 10
#define SELLSIG 20

datetime signaltime, redrawtime, upperpeaktime, lowerpeaktime;
double signalprice, upperpeak, lowerpeak, prevupperpeak, prevlowerpeak;
datetime upperpeaktime2, lowerpeaktime2;
double  upperpeak2, lowerpeak2, prevupperpeak2, prevlowerpeak2;

bool indicatorOn = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   CreateButton("SwingMan_Button", "SwingMan ON", 10, 115, 100, 20, clrGreen, clrLime);
   SetIndexStyle(0, DRAW_LINE,0,0,BullishColor);
   SetIndexStyle(1, DRAW_LINE,0,0,BearishColor);
   SetIndexStyle(2, DRAW_HISTOGRAM,0,21,BullishColor);
   SetIndexStyle(3, DRAW_HISTOGRAM,0,21,BearishColor);
   SetIndexStyle(4, DRAW_ARROW,0,arrowWidth,BullishColor); SetIndexArrow(4, 159); // BullDot (WingDings character)
   SetIndexStyle(5, DRAW_ARROW,0,arrowWidth,BearishColor); SetIndexArrow(5, 159); // BearDot (WingDings character)
   SetIndexStyle(6, DRAW_ARROW,0,arrowWidth2,BullArrowColor); SetIndexArrow(6, 159); // BullDot (WingDings character)
   SetIndexStyle(7, DRAW_ARROW,0,arrowWidth2,BearArrowColor); SetIndexArrow(7, 159); // BearDot (WingDings character)

   
   SetIndexBuffer(0, BuyLine);
   SetIndexBuffer(1, SellLine);
   SetIndexBuffer(2, BullCandle);
   SetIndexBuffer(3, BearCandle);
   SetIndexBuffer(4, BlueDot);
   SetIndexBuffer(5, RedDot);
   SetIndexBuffer(6, BlueDot2);
   SetIndexBuffer(7, RedDot2);

   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexEmptyValue(7, EMPTY_VALUE);

   SetIndexLabel(0, "BuyLine");
   SetIndexLabel(1, "SellLine");
   SetIndexLabel(2, "");
   SetIndexLabel(3, "");
   SetIndexLabel(4, "");
   SetIndexLabel(5, "");
   SetIndexLabel(6, "");
   SetIndexLabel(7, "");

   IndicatorShortName(INDICATOR_NAME);
   IndicatorDigits(Digits);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Clean up only objects created by this indicator
/*   int totalObjects = ObjectsTotal();
   for (int i = totalObjects - 1; i >= 0; i--) {
       string name = ObjectName(i);
       if (StringFind(name, "3Can_") == 0) {
           ObjectDelete(name);
       }
   }
*/   // cleanup display buffers
   for(int i = 0; i < Bars; i++)
   {
       BuyLine[i] = EMPTY_VALUE;
       SellLine[i] = EMPTY_VALUE;
       BullCandle[i] = EMPTY_VALUE;
       BearCandle[i] = EMPTY_VALUE;
       BlueDot[i] = EMPTY_VALUE;
       RedDot[i] = EMPTY_VALUE;
       BlueDot2[i] = EMPTY_VALUE;
       RedDot2[i] = EMPTY_VALUE;
   }
   ObjectDelete("SwingMan_Button");
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
   if (id == CHARTEVENT_OBJECT_CLICK && sparam == "SwingMan_Button") {
       indicatorOn = !indicatorOn;
       if (indicatorOn) {
           ObjectSetInteger(0, "SwingMan_Button", OBJPROP_BGCOLOR, clrGreen);
           ObjectSetInteger(0, "SwingMan_Button", OBJPROP_COLOR, clrLime);
           ObjectSetString(0, "SwingMan_Button", OBJPROP_TEXT, "SwingMan ON");
           
           SetIndexStyle(0, DRAW_LINE);
           SetIndexStyle(1, DRAW_LINE);
           SetIndexStyle(2, DRAW_HISTOGRAM);
           SetIndexStyle(3, DRAW_HISTOGRAM);
           SetIndexStyle(4, DRAW_ARROW); 
           SetIndexStyle(5, DRAW_ARROW); 
           SetIndexStyle(6, DRAW_ARROW); 
           SetIndexStyle(7, DRAW_ARROW);
       } else {
           ObjectSetInteger(0, "SwingMan_Button", OBJPROP_BGCOLOR, clrDimGray);
           ObjectSetInteger(0, "SwingMan_Button", OBJPROP_COLOR, clrRed);
           ObjectSetString(0, "SwingMan_Button", OBJPROP_TEXT, "SwingMan OFF");
           SetIndexStyle(0, DRAW_NONE);
           SetIndexStyle(1, DRAW_NONE);
           SetIndexStyle(2, DRAW_NONE);
           SetIndexStyle(3, DRAW_NONE);
           SetIndexStyle(4, DRAW_NONE); 
           SetIndexStyle(5, DRAW_NONE); 
           SetIndexStyle(6, DRAW_NONE); 
           SetIndexStyle(7, DRAW_NONE);
           
           int totalObjects = ObjectsTotal();
           for (int i = totalObjects - 1; i >= 0; i--) {
               string name = ObjectName(i);
               if (StringFind(name, "3Can_") == 0) {
                   ObjectDelete(name);
               }
           }
           
           // cleanup display buffers
            for(int i = 0; i < Bars; i++)
               {
               BuyLine[i] = EMPTY_VALUE;
               SellLine[i] = EMPTY_VALUE;
               BullCandle[i] = EMPTY_VALUE;
               BearCandle[i] = EMPTY_VALUE;
               BlueDot[i] = EMPTY_VALUE;
               RedDot[i] = EMPTY_VALUE;
               BlueDot2[i] = EMPTY_VALUE;
               RedDot2[i] = EMPTY_VALUE;
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
    if (!indicatorOn) {
        return;
    }
/*    // Delete existing lines before drawing new ones
    int totalObjects = ObjectsTotal();
    for (int i = totalObjects - 1; i >= 0; i--) {
        string name = ObjectName(i);
        if (StringFind(name, "3Can_Line_") == 0) {
            ObjectDelete(name);
        }
    }
*/
    int higherRatesTotal = iBars(NULL, HigherTimeframe);
    datetime higherTime[];
    double higherOpen[], higherHigh[], higherLow[], higherClose[];
    
    double range1, mid1;
    double range2, mid2;
    bool SIBI, BISI;
    
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
        double H1 = higherHigh[i];
        double L1 = higherLow[i];
        double H2 = higherHigh[i + 1];
        double L2 = higherLow[i + 1];
        double H3 = higherHigh[i + 2];
        double L3 = higherLow[i + 2];
        double C2 = higherClose[i + 1];
        double O2 = higherOpen[i + 1];

        if(iHighest(NULL, 0, MODE_HIGH, swingDeterminer, i) == i + 1)
        {
            prevupperpeak = upperpeak; upperpeak = H2; upperpeaktime = higherTime[i + 1]; signal = NOSIG;
        }
        if(iLowest(NULL, 0, MODE_LOW, swingDeterminer, i) == i + 1)
        {
            prevlowerpeak = lowerpeak; lowerpeak = L2; lowerpeaktime = higherTime[i + 1]; signal = NOSIG;
        }
        if(iHighest(NULL, 0, MODE_HIGH, swingDeterminer2, i) == i + 1)
        {
            prevupperpeak2 = upperpeak2; upperpeak2 = H2; upperpeaktime2 = higherTime[i + 1]; signal = NOSIG;
        }
        if(iLowest(NULL, 0, MODE_LOW, swingDeterminer2, i) == i + 1)
        {
            prevlowerpeak2 = lowerpeak2; lowerpeak2 = L2; lowerpeaktime2 = higherTime[i + 1]; signal = NOSIG;
        }
        //////////////////
        // SIGNALS NEW
        if(prevupperpeak == prevlowerpeak)
        { 
            signal = NOSIG;
        }
        if(H1 < L3)
        { 
            SIBI = true;
            range2 = L3 - H1;
            mid2 = (L3 - H1) / 2;        
        } else SIBI = false;
        if(L1 > H3)
        { 
            BISI = true;
            range1 = L1 - H3;
            mid1 = (L1 - H3) / 2;
        } else BISI = false;

        ///////////////////
        // SHOW DOTS
        if(ShowDots == true)
        {
            BlueDot[i + 1] = EMPTY_VALUE;
            RedDot[i + 1] = EMPTY_VALUE;
            RedDot[iBarShift(NULL, 0, upperpeaktime)] = upperpeak + 10 * Point;
            BlueDot[iBarShift(NULL, 0, lowerpeaktime)] = lowerpeak - 10 * Point;
            BlueDot2[i + 1] = EMPTY_VALUE;
            RedDot2[i + 1] = EMPTY_VALUE;
            RedDot2[iBarShift(NULL, 0, upperpeaktime2)] = upperpeak2 + 10 * Point;
            BlueDot2[iBarShift(NULL, 0, lowerpeaktime2)] = lowerpeak2 - 10 * Point;
        }

        ///////////////////
        // BEARISH SIGNAL
        if(ShowBears == true)
        if(SIBI)
        {
            BuyLine[i] = EMPTY_VALUE;
            SellLine[i] = EMPTY_VALUE;
            BullCandle[i] = EMPTY_VALUE;
            BearCandle[i] = EMPTY_VALUE;  
            BearCandle[i + 1] = L3; 
            BullCandle[i + 1] = H1;
            SellLine[i + 1] = H1;
            SellLine[i + 2] = EMPTY_VALUE;
            BuyLine[i + 1] = L3;
            BuyLine[i + 2] = EMPTY_VALUE;
            signal = SELLSIG;
            signalprice = SellLine[i + 1];
            signaltime = higherTime[i];
        }
   
        ///////////////////
        // BULLISH SIGNAL
        if(ShowBulls == true)
        if(BISI) 
        {   BuyLine[i] = EMPTY_VALUE;
            SellLine[i] = EMPTY_VALUE;
            BullCandle[i] = EMPTY_VALUE;
            BearCandle[i] = EMPTY_VALUE;
            BearCandle[i + 1] = H3; 
            BullCandle[i + 1] = L1;
            BuyLine[i + 1] = L1;
            BuyLine[i + 2] = EMPTY_VALUE;
            SellLine[i + 1] = H3;
            SellLine[i + 2] = EMPTY_VALUE;
            signal = BUYSIG;
            signalprice = BuyLine[i + 1];
            signaltime = higherTime[i];     
        }

        ///////////////////
        // CONTINUE LINES Replicate Signal Lines
        SellLine[i] = SellLine[i + 1];
        BuyLine[i] = BuyLine[i + 1];


 
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