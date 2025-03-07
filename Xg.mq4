//+------------------------------------------------------------------+
//|                                        Xg.mq4 |
//|                                                                 |
//|                                                                 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

extern ENUM_TIMEFRAMES HigherTimeframe = PERIOD_M5;
extern string button_name = "Xg ";
extern int BarsToProcess = 100;
extern int Shift = 1;
extern bool ShowRectangles = true;
extern color BullishColor = clrDarkViolet;
extern color BearishColor = clrGold;
extern color NeutralColor = clrPurple;
extern color BullArrowColor = clrDarkOrchid;
extern color BearArrowColor = clrYellow;
extern int   styleHL_Lines = 1;                          // Style of High and Low lines
extern int   widthHL_Lines = 1;                          // Width of High and Low lines
extern string button_note1 = "------------------------------";
extern ENUM_BASE_CORNER btn_corner = CORNER_LEFT_UPPER;  // Chart corner for anchoring Button
extern int btn_FontSize = 10;                            // Button font size
extern color btn_text_color = clrMistyRose;              // Button text color when OFF
extern color btn_text_color_on = clrLime;                // Button text color when ON
extern color btn_background_color = clrDimGray;          // Button background color when OFF
extern color btn_background_color_on = clrGreen;         // Button background color when ON
extern int button_x = 10;                                // Horizontal location
extern int button_y = 340;                               // Vertical location
extern int btn_Width = 80;                               // Button width
extern int btn_Height = 20;                              // Button height

bool indicatorOn = true;
string buttonStateKey = button_name + "ThreeCandleRectangleButtonState";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Restore button state from global variable
    double state;
    if (GlobalVariableCheck(buttonStateKey))
    {
        state = GlobalVariableGet(buttonStateKey);
        indicatorOn = state != 0.0;
    }

    // Create button with the restored state
    CreateButton(button_name, button_name + (indicatorOn ? " ON" : " OFF"), button_x, button_y, btn_Width, btn_Height, indicatorOn ? btn_background_color_on : btn_background_color, indicatorOn ? btn_text_color_on : btn_text_color);
                
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Save button state to global variable
    GlobalVariableSet(buttonStateKey, indicatorOn ? 1.0 : 0.0);

    // Clean up only objects created by this indicator
    int totalObjects = ObjectsTotal();
    for (int i = totalObjects - 1; i >= 0; i--)
    {
        string name = ObjectName(i);
        if (StringFind(name, button_name + "_3Can_") == 0)
        {
            ObjectDelete(name);
        }
    }
    ObjectDelete(button_name);
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
    if (!ShowRectangles || !indicatorOn)
    {
        return(rates_total);
    }

    // Your existing logic for plotting rectangles and lines
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

    datetime lastEndTime = 0;
    double lastHigh = 0;
    double lastLow = 0;
    double lastMid = 0;
    color lastColor = clrBlack;
    
    if (BarsToProcess > higherRatesTotal) BarsToProcess = higherRatesTotal;
    if (BarsToProcess < 5) BarsToProcess = 10;

    for (int i = BarsToProcess - 4; i >= 0; i--) {
    
        int bar_now = i+Shift;
        // Analyze the three higher timeframe candles
        double H1 = higherHigh[i + 1];
        double L1 = higherLow[i + 1];
        double H2 = higherHigh[i + 2];
        double L2 = higherLow[i + 2];
        double H3 = higherHigh[i + 3];
        double L3 = higherLow[i + 3];
        double C2 = higherClose[i + 2];
        double O2 = higherOpen[i + 2];

        // Determine the color of the rectangle
        color rectColor;
        if (C2 > O2) {
            rectColor = BullishColor;
        } else if (C2 < O2) {
            rectColor = BearishColor;
        } else {
            rectColor = NeutralColor;
        }

        // Draw rectangles based on conditions
        if (L1 > H3) {
            DrawRectangle(button_name + "_3Can_Rect_Bull_" + IntegerToString(higherTime[bar_now]), H3, L1, rectColor, higherTime[2+bar_now], higherTime[bar_now]);
            DrawLine(button_name + "_3Can_Line_Bull_" + IntegerToString(higherTime[bar_now]), (H3 + L1) / 2, higherTime[2+bar_now], higherTime[bar_now], BullArrowColor, STYLE_DOT,1);
            if (lastEndTime != 0) {
                DrawLine(button_name + "_3Can_HighLine_" + IntegerToString(lastEndTime), lastHigh, lastEndTime, higherTime[bar_now], lastColor, styleHL_Lines, widthHL_Lines);
                DrawLine(button_name + "_3Can_LowLine_" + IntegerToString(lastEndTime), lastLow, lastEndTime, higherTime[bar_now], lastColor, styleHL_Lines, widthHL_Lines);
                DrawLine(button_name + "_3Can_MidLine_" + IntegerToString(lastEndTime), lastMid, lastEndTime, higherTime[bar_now], BullArrowColor, STYLE_DOT,1);
            }
            lastEndTime = higherTime[bar_now];
            lastHigh = H3;
            lastLow = L1;
            lastMid = (H3 + L1) / 2;
            lastColor = rectColor;
            // Plot lines at the close of every other HTF candle
            for (int j = i; j >= 0; j -= 2) {
                int bar_now1 = j+Shift;
                DrawLine(button_name + "_HTF_CloseLine_" + IntegerToString(higherTime[bar_now1]), higherClose[bar_now1], higherTime[bar_now1], higherTime[bar_now1], lastColor, STYLE_SOLID,1);
            }
        } else if (L3 > H1) {
            DrawRectangle(button_name + "_3Can_Rect_Bear_" + IntegerToString(higherTime[bar_now]), L3, H1, rectColor, higherTime[2+bar_now], higherTime[bar_now]);
            DrawLine(button_name + "_3Can_Line_Bear_" + IntegerToString(higherTime[bar_now]), (L3 + H1) / 2, higherTime[2+bar_now], higherTime[bar_now], BearArrowColor, STYLE_DOT,1);
            if (lastEndTime != 0) {
                DrawLine(button_name + "_3Can_HighLine_" + IntegerToString(lastEndTime), lastHigh, lastEndTime, higherTime[bar_now], lastColor, styleHL_Lines, widthHL_Lines);
                DrawLine(button_name + "_3Can_LowLine_" + IntegerToString(lastEndTime), lastLow, lastEndTime, higherTime[bar_now], lastColor, styleHL_Lines, widthHL_Lines);
                DrawLine(button_name + "_3Can_MidLine_" + IntegerToString(lastEndTime), lastMid, lastEndTime, higherTime[bar_now], BearArrowColor, STYLE_DOT,1);
            }
            lastEndTime = higherTime[bar_now];
            lastHigh = L3;
            lastLow = H1;
            lastMid = (L3 + H1) / 2;
            lastColor = rectColor;
            // Plot lines at the close of every other HTF candle
            for (int j = i; j >= 0; j -= 2) {
                int bar_now1 = j+Shift;
                DrawLine(button_name + "_HTF_CloseLine_" + IntegerToString(higherTime[bar_now1]), higherClose[bar_now1], higherTime[bar_now1], higherTime[bar_now1], lastColor, STYLE_SOLID,1);
            }
        }
    }

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
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == button_name)
    {
        indicatorOn = !indicatorOn;
        if (indicatorOn)
        {
            ObjectSetInteger(0, button_name, OBJPROP_BGCOLOR, btn_background_color_on);
            ObjectSetInteger(0, button_name, OBJPROP_COLOR, btn_text_color_on);
            ObjectSetString(0, button_name, OBJPROP_TEXT, button_name + " ON");
        }
        else
        {
            ObjectSetInteger(0, button_name, OBJPROP_BGCOLOR, btn_background_color);
            ObjectSetInteger(0, button_name, OBJPROP_COLOR, btn_text_color);
            ObjectSetString(0, button_name, OBJPROP_TEXT, button_name + " OFF");
            int totalObjects = ObjectsTotal();
            for (int i = totalObjects - 1; i >= 0; i--)
            {
                string name = ObjectName(i);
                if (StringFind(name, button_name + "_3Can_") == 0)
                {
                    ObjectDelete(name);
                }
            }
        }

        // Save button state to global variable
        GlobalVariableSet(buttonStateKey, indicatorOn ? 1.0 : 0.0);
        
        // Force re-calculation of the indicator
        ChartRedraw();
    }
}
//+------------------------------------------------------------------+
//| DrawRectangle function                                           |
//+------------------------------------------------------------------+
void DrawRectangle(string name, double price1, double price2, color rectColor, datetime time1, datetime time2) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2);
        ObjectSetInteger(0, name, OBJPROP_COLOR, rectColor);
        ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, name, OBJPROP_BACK, true);
        ObjectSetInteger(0, name, OBJPROP_RAY, false);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    }
}
//+------------------------------------------------------------------+
//| DrawLine function                                                |
//+------------------------------------------------------------------+
void DrawLine(string name, double price, datetime time1, datetime time2, color lineColor, int lineStyle, int lineWidth) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price);
        ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
        ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWidth);
        ObjectSetInteger(0, name, OBJPROP_RAY, false);
        ObjectSetInteger(0, name, OBJPROP_BACK, true);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    }
}
//+------------------------------------------------------------------+
//| CreateButton function                                            |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int width, int height, color bgColor, color textColor) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
        ObjectSetInteger(0, name, OBJPROP_CORNER, btn_corner);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
        ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, btn_FontSize);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_STATE, true);
    }
}
