//+------------------------------------------------------------------+
//|                                     _mFvg0.mq4                  |
//+------------------------------------------------------------------+

#property strict

#property indicator_chart_window
#property indicator_buffers 5

//---- input parameters
extern ENUM_TIMEFRAMES TF_find = 0;  // Period to find Inside Bar
input string DisplayID = "_mFvg0 "; // Display id
extern int Barss = 500;
extern int LineSize = 1;
extern color ColorHL = clrPlum;
extern color ColorM = clrMediumOrchid;

extern string title03 = "Pattern Display Setttings"; //
extern bool  showGap = true;
extern bool  showInvGap = false;

extern int ArrowH = 249;
extern int ArrowSize = 1;
extern int ArrowSizeMid = 0;
//extern int ArrowL = 178;
extern string note1 = "158.9=Dots,115.9=Diamond,161-3=Circles";
extern string note2 = "128&139=No Zero, 178,179,181,182=Star";
extern string note3 = "249&250=RECT&Cube.Hollow,160-7.8=square.110-4";

extern string button_note1 = "------------------------------";
extern ENUM_BASE_CORNER btn_corner = CORNER_LEFT_UPPER; // Chart corner for anchoring

extern string btn_Font = "Arial";
extern int btn_FontSize = 10; // Button font size
extern color btn_text_color = clrWhite;
extern color btn_background_color = clrDimGray;
extern color btn_border_color = clrBlack;
extern int button_x = 10; // Horizontal location
extern int button_y = 240; // Vertical location
extern int btn_Width = 80; // Button width
extern int btn_Height = 20; // Button height
extern string button_note2 = "------------------------------";

// Global variables
bool showIndicator = true;

//---- buffers
double HighBuff[];
double LowBuff[];
double HighArrow[];
double LowArrow[];
double MidBuff[]; // Buffer for mid line (average of LastHigh and LastLow)

double LastHigh;
double LastLow;
double lastHighArrow; // Global variable to store the last pattern's high arrow position
double lastLowArrow;  // Global variable to store the last pattern's low arrow position
int length = 5, len = 0, Type, Type1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Create a button if it does not exist
    if (ObjectFind(DisplayID) != 0)
    {
        ObjectSetInteger(ChartID(), DisplayID, OBJPROP_STATE, true);
    }
    // Create the button
    ObjectCreate(ChartID(), DisplayID, OBJ_BUTTON, 0, 0, 0);
    // Set button properties
    ObjectSetString(ChartID(), DisplayID, OBJPROP_TEXT, DisplayID);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_FONTSIZE, btn_FontSize);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_CORNER, btn_corner);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, btn_text_color);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, btn_background_color);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_YDISTANCE, button_y);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_XDISTANCE, button_x);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_XSIZE, btn_Width);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_YSIZE, btn_Height);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_HIDDEN, true);
   
    // Set the time frame to the current period if TF_find is set to PERIOD_CURRENT
    if (TF_find == PERIOD_CURRENT) 
        TF_find = (ENUM_TIMEFRAMES)_Period;

    // Load historical data for the specified time frame
    LoadHist();
    
    // Set the type of drawing (either arrows or none)
    if (showIndicator) {Type = DRAW_ARROW; Type1 = DRAW_LINE; }
    else {Type = DRAW_NONE; Type1 = DRAW_NONE;}
    if (Period() > PERIOD_D1) { Type = DRAW_NONE; }

    // Set arrow properties for the indicator
    SetIndexArrow(2, ArrowH);
    SetIndexArrow(3, ArrowH);
    SetIndexArrow(4, ArrowH);

    // Set styles and colors for the indicator lines and arrows
    SetIndexStyle(0, DRAW_LINE, EMPTY, LineSize, ColorHL);
    SetIndexStyle(1, DRAW_LINE, EMPTY, LineSize, ColorHL);
    SetIndexStyle(2, DRAW_ARROW, EMPTY, ArrowSize, ColorHL);
    SetIndexStyle(3, DRAW_ARROW, EMPTY, ArrowSize, ColorHL);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, ArrowSizeMid, ColorM);

    // Bind the indicator buffers with the arrays
    SetIndexBuffer(0, HighBuff);
    SetIndexBuffer(1, LowBuff);
    SetIndexBuffer(2, HighArrow);
    SetIndexBuffer(3, LowArrow);
    SetIndexBuffer(4, MidBuff);

    // Set the indicator's short name and labels
    IndicatorShortName("_mFvg0 (" + TFtoStr(TF_find) + ")");
    SetIndexLabel(0, "High");
    SetIndexLabel(1, "Low");
    SetIndexLabel(2, "HighArrow");
    SetIndexLabel(3, "LowArrow");
    SetIndexLabel(4, "Mid");

    // Initialize the indicator buffers to EMPTY_VALUE
    SetIndexEmptyValue(0, EMPTY_VALUE);
    SetIndexEmptyValue(1, EMPTY_VALUE);
    SetIndexEmptyValue(2, EMPTY_VALUE);
    SetIndexEmptyValue(3, EMPTY_VALUE);
    SetIndexEmptyValue(4, EMPTY_VALUE);

    ArrayInitialize(HighBuff, EMPTY_VALUE);
    ArrayInitialize(LowBuff, EMPTY_VALUE);
    ArrayInitialize(HighArrow, EMPTY_VALUE);
    ArrayInitialize(LowArrow, EMPTY_VALUE);
    ArrayInitialize(MidBuff, EMPTY_VALUE);

    // Set the number of digits to display in the indicator values
    IndicatorDigits(_Digits);
    
    // Set index styles based on button state
    if (GetButtonState(DisplayID) != "off")
    {
        // Set styles and colors for the indicator lines and arrows
        SetIndexStyle(0, DRAW_LINE, EMPTY, LineSize, ColorHL);
        SetIndexStyle(1, DRAW_LINE, EMPTY, LineSize, ColorHL);
        SetIndexStyle(2, DRAW_ARROW, EMPTY, ArrowSize, ColorHL);
        SetIndexStyle(3, DRAW_ARROW, EMPTY, ArrowSize, ColorHL);
        SetIndexStyle(4, DRAW_ARROW, EMPTY, ArrowSizeMid, ColorM);

        ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, clrLime); // set button color
        ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, clrDarkGreen); // set button color
    }
    else 
    {
        for (int banzai = 0; banzai < 5; banzai++) 
        {
            SetIndexStyle(banzai, DRAW_NONE);
            ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, btn_text_color); // Reset button color
            ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, btn_background_color); // Reset button color
        }
    }

    return 0;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    switch(reason)
    {
        case REASON_PARAMETERS:
        case REASON_CHARTCHANGE:
        case REASON_RECOMPILE:
        case REASON_CLOSE:
            break;
        default:
            ObjectDelete(DisplayID);
    }
    Comment("");
}

//+------------------------------------------------------------------------------------------------------------------+
//| Chart event handler function                                               |
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    static string prevState = "";
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == DisplayID)
    {
        string newState = GetButtonState(DisplayID);
        if (newState != prevState)
        {
            if (newState == "off")
            { 
                for (int banzai = 0; banzai < 5; banzai++) 
                {
                    SetIndexStyle(banzai, DRAW_NONE);
                    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, btn_text_color); // Reset button color
                    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, btn_background_color); // Reset button color
                }
                prevState = newState; 
            }
            else 
            { 
                // Set styles and colors for the indicator lines and arrows
                SetIndexStyle(0, DRAW_LINE, EMPTY, LineSize, ColorHL);
                SetIndexStyle(1, DRAW_LINE, EMPTY, LineSize, ColorHL);
                SetIndexStyle(2, DRAW_ARROW, EMPTY, ArrowSize, ColorHL);
                SetIndexStyle(3, DRAW_ARROW, EMPTY, ArrowSize, ColorHL);
                SetIndexStyle(4, DRAW_ARROW, EMPTY, ArrowSizeMid, ColorM);
                ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, clrLime); // set button color
                ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, clrDarkGreen); // set button color
                prevState = newState; 
            }
            ObjectSetString(ChartID(), DisplayID, OBJPROP_TEXT, DisplayID);
        }
    }
}  

//+------------------------------------------------------------------------------------------------------------------+
//| Get the state of the button                                               |
//+------------------------------------------------------------------------------------------------------------------+
string GetButtonState(string whichbutton)
{
    bool selected = ObjectGetInteger(ChartID(), whichbutton, OBJPROP_STATE);
    if (selected)
        return ("on");
    else 
        return ("off");
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
    // Check if there are new rates to calculate
    if (rates_total - prev_calculated <= 0) 
        return 0;

    // Ensure the time frame is not more than the specified TF_find
    if (TF_find < _Period)
    {
        Comment("Time frame must be not more than 'Period to find Inside Bar' " + TFtoStr(TF_find));
        return 0;
    }

    int limit = 1;

    // Initialize buffers if new data is available
    if (prev_calculated == 0 || rates_total - prev_calculated > 1)
    {
        ArrayInitialize(HighBuff, EMPTY_VALUE);
        ArrayInitialize(LowBuff, EMPTY_VALUE);
        ArrayInitialize(HighArrow, EMPTY_VALUE);
        ArrayInitialize(LowArrow, EMPTY_VALUE);
        ArrayInitialize(MidBuff, EMPTY_VALUE); // Initialize mid buffer as well
        limit = iBars(_Symbol, TF_find) - 2;
    }
    if (iBars(_Symbol, TF_find) - 2 > Barss)
    {

        limit = Barss;
    }

    // Iterate through the bars and calculate the indicator values
    for (int i = limit; i >= 1; i--)
    {
        datetime time1 = iTime(_Symbol, TF_find, i);
        datetime time2 = time1 + PeriodSeconds(TF_find);
        int bar_now = iBarShift(_Symbol, _Period, time1, false);
        
        int one = i, two = i + 1, three = i + 2, four = i + 3, five = i + 4, six = i + 5, seven = i + 6, eight = i + 7, nine = i + 8, ten = i + 9;
        double O1 = iOpen(_Symbol, TF_find, one), O2 = iOpen(_Symbol, TF_find, two), O3 = iOpen(_Symbol, TF_find, three), O4 = iOpen(_Symbol, TF_find, four);
        double O5 = iOpen(_Symbol, TF_find, five), O6 = iOpen(_Symbol, TF_find, six), O7 = iOpen(_Symbol, TF_find, seven), O8 = iOpen(_Symbol, TF_find, eight);
        double H1 = iHigh(_Symbol, TF_find, one), H2 = iHigh(_Symbol, TF_find, two), H3 = iHigh(_Symbol, TF_find, three), H4 = iHigh(_Symbol, TF_find, four);
        double H5 = iHigh(_Symbol, TF_find, five), H6 = iHigh(_Symbol, TF_find, six), H7 = iHigh(_Symbol, TF_find, seven), H8 = iHigh(_Symbol, TF_find, eight);
        double L1 = iLow(_Symbol, TF_find, one), L2 = iLow(_Symbol, TF_find, two), L3 = iLow(_Symbol, TF_find, three), L4 = iLow(_Symbol, TF_find, four);
        double L5 = iLow(_Symbol, TF_find, five), L6 = iLow(_Symbol, TF_find, six), L7 = iLow(_Symbol, TF_find, seven), L8 = iLow(_Symbol, TF_find, eight);
        double C1 = iClose(_Symbol, TF_find, one), C2 = iClose(_Symbol, TF_find, two), C3 = iClose(_Symbol, TF_find, three), C4 = iClose(_Symbol, TF_find, four);
        double C5 = iClose(_Symbol, TF_find, five), C6 = iClose(_Symbol, TF_find, six), C7 = iClose(_Symbol, TF_find, seven), C8 = iClose(_Symbol, TF_find, eight);
        
        bool upCandle1 = C1 > O1; bool dnCandle1 = C1 < O1; bool upCandle2 = C2 > O2; bool dnCandle2 = C2 < O2;
        bool upCandle3 = C3 > O3; bool dnCandle3 = C3 < O3; bool upCandle4 = C4 > O4; bool dnCandle4 = C4 < O4;
        bool upCandle5 = C5 > O5; bool dnCandle5 = C5 < O5; bool upCandle6 = C6 > O6; bool dnCandle6= C6 < O6;
        bool upCandle7 = C7 > O7; bool dnCandle7 = C7 < O7; bool upCandle8 = C8 > O8; bool dnCandle8= C8 < O8;
        //bool upCandle9 = C9 > O9; bool dnCandle9 = C9 < O9; bool upCandle10 = C10 > O10; bool dnCandle10 = C10 < O10; 
 
        double min_O1C1 = MathMin(O1, C1), min_O2C2 = MathMin(O2, C2), min_O3C3 = MathMin(O3, C3);
        double max_O1C1 = MathMax(O1, C1), max_O2C2 = MathMax(O2, C2), max_O3C3 = MathMax(O3, C3);
        double min_L1L2 = MathMin(L1, L2), min_L1L3 = MathMin(L1, L3), min_L2L3 = MathMin(L2, L3); 
        double min_H1H2 = MathMin(H1, H2), min_H1H3 = MathMin(H1, H3), min_H2H3 = MathMin(H2, H3);
        double max_L1L2 = MathMax(L1, L2), max_L1L3 = MathMax(L1, L3), max_L2L3 = MathMax(L2, L3);
        double max_H1H2 = MathMax(H1, H2), max_H1H3 = MathMax(H1, H3), max_H2H3 = MathMax(H2, H3);
        
        double maxOfMin_OC12 = MathMax(min_O1C1, min_O2C2), maxOfMin_OC23 = MathMax(min_O2C2, min_O3C3);
        double minOfMax_OC12 = MathMin(max_O1C1, max_O2C2), minOfMax_OC23 = MathMin(max_O2C2, max_O3C3);
        double minOfMin_OC12 = MathMin(min_O1C1, min_O2C2), minOfMin_OC23 = MathMin(min_O2C2, min_O3C3);
        double maxOfMax_OC12 = MathMax(max_O1C1, max_O2C2), maxOfMax_OC23 = MathMax(max_O2C2, max_O3C3);
        
        double minL1L2L3 = MathMin(min_L1L2, min_L2L3), maxL1L2L3 = MathMax(max_L1L2, max_L2L3);
        double maxH1H2H3 = MathMax(max_H1H2, max_H2H3), minH1H2H3 = MathMin(min_H1H2, min_H2H3);  
        double minC1C2C3 = MathMin(MathMin(C1, C2), MathMin(C3, C2)), maxC1C2C3 = MathMax(MathMax(C1, C2), MathMax(C3, C2));
        double maxO1O2O3 = MathMax(MathMax(O1, O2), MathMax(O3, O2)), minO1O2O3 = MathMin(MathMin(O1, O2), MathMin(O3, O2));  
        
        double minOf3_OC = MathMin(minOfMin_OC12, minOfMin_OC23);
        double maxOf3_OC = MathMax(maxOfMax_OC12, maxOfMax_OC23);
        
        bool  isPatternDetected_OC12 = (maxOfMin_OC12 > minOfMax_OC12);
        bool  isInvPatternDetected_OC12 = (maxOfMin_OC12 < minOfMax_OC12);
        
        bool barSizeIsGood = H1 - L1 > _Point/2; 

        // Check for specific conditions to update High and Low values
        if (barSizeIsGood)
        {
            if (L1 > H3 )
            {
               LastHigh = L1;
               LastLow = H3;
               HighBuff[bar_now] = LastHigh;
               LowBuff[bar_now] = LastLow;
               len = 1;

               // Draw rectangle and lines
        //DrawRectangle("BullishRect_" + IntegerToString(bar_now), H3, L1, ColorHL, time[bar_now], time[bar_now + 2]);
        //DrawLine("BullishLine_" + IntegerToString(bar_now), (H3 + L1) / 2, time[bar_now], time[bar_now + 2], ColorHL, STYLE_DOT);
   
            }
            if (H1 < L3)
            {
               LastHigh = L3;
               LastLow = H1;
               HighBuff[bar_now] = LastHigh;
               LowBuff[bar_now] = LastLow;
                // Draw rectangle and lines
        //DrawRectangle("BearishRect_" + IntegerToString(bar_now), L3, H1, ColorM, time[bar_now], time[bar_now + 2]);
        //DrawLine("BearishLine_" + IntegerToString(bar_now), (L3 + H1) / 2, time[bar_now], time[bar_now + 2], ColorM, STYLE_DOT);
  
               len = 1;
            }

            // Clear buffer values if conditions are met
            if (bar_now < rates_total - 3 &&
                ((HighBuff[bar_now + 1] != LastHigh && HighBuff[bar_now + 2] != EMPTY_VALUE) ||
                 (LowBuff[bar_now + 1] != LastLow && LowBuff[bar_now + 2] != EMPTY_VALUE)))
            {
                HighBuff[bar_now + 1] = EMPTY_VALUE;
                LowBuff[bar_now + 1] = EMPTY_VALUE;
                HighArrow[bar_now] = LastHigh;
                LowArrow[bar_now] = LastLow;
                MidBuff[bar_now] = (LastHigh + LastLow) / 2.0;              
                
            }

            // Update buffer values within the specified time range
            while (bar_now < rates_total - 2 && time[bar_now] >= time1 && time[bar_now] < time2)
            {
                HighBuff[bar_now] = LastHigh;
                LowBuff[bar_now] = LastLow;
                // Calculate mid point based on the last high and low and assign to MidBuff
                MidBuff[bar_now] = (LastHigh + LastLow) / 2.0;
                bar_now--;
            }
        }
        else
        {
            // Replicate buffer values until a new pattern is found
            if (len > 0 && len < length)
            {
                while (bar_now < rates_total - 2 && time[bar_now] >= time1 && time[bar_now] < time2)
                {
                    HighBuff[bar_now] = HighBuff[bar_now + 1];
                    LowBuff[bar_now] = LowBuff[bar_now + 1]; 
                    // Continue plotting mid line during replication
                    MidBuff[bar_now] = (LastHigh + LastLow) / 2.0;
                    bar_now--;
                }
                len++;
            }
            else if (len > length)
            {
                len = 0;
                HighBuff[bar_now] = EMPTY_VALUE;
                LowBuff[bar_now] = EMPTY_VALUE;
                MidBuff[bar_now] = EMPTY_VALUE;
            }
        }
    }
    return rates_total;
}

//+------------------------------------------------------------------+
//| Convert time frame to string                                     |
//+------------------------------------------------------------------+
string TFtoStr(int n)
{
    if (n == 0) n = Period();
    switch (n)
    {
        case PERIOD_M1:  return "M1";
        case PERIOD_M5:  return "M5";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_H1:  return "H1";
        case PERIOD_H4:  return "H4";
        case PERIOD_D1:  return "D1";
        case PERIOD_W1:  return "W1";
        case PERIOD_MN1: return "MN1";
    }
    return "TF?";
}

//+------------------------------------------------------------------+
//| Load historical data                                             |
//+------------------------------------------------------------------+
void LoadHist()
{
    int iPeriod[2];
    iPeriod[0] = TF_find;
    iPeriod[1] = _Period;

    for (int i = 0; i < 2; i++)
    {
        datetime open = iTime(_Symbol, iPeriod[i], 0);
        int error = GetLastError();
        while (error == 4066)
        {
            Comment("Loading history " + TFtoStr(iPeriod[i]));
            Sleep(1000);
            open = iTime(_Symbol, iPeriod[i], 0);
            error = GetLastError();
        }
        Comment("");
    }
}

//+------------------------------------------------------------------+
//| Draw lines on the chart                                          |
//+------------------------------------------------------------------+
void DrawLines(int startBar, double highPrice, double lowPrice)
{
    string highLineName = "HighLine_" + IntegerToString(startBar);
    string lowLineName = "LowLine_" + IntegerToString(startBar);
    string midLineName = "MidLine_" + IntegerToString(startBar);
    double midPrice = (highPrice + lowPrice) / 2;
    
    ObjectCreate(0, highLineName, OBJ_TREND, 0, Time[startBar], highPrice, Time[startBar-1], highPrice);
    ObjectCreate(0, lowLineName, OBJ_TREND, 0, Time[startBar], lowPrice, Time[startBar-1], lowPrice);
    ObjectCreate(0, midLineName, OBJ_TREND, 0, Time[startBar], midPrice, Time[startBar-1], midPrice);
    
    ObjectSetInteger(0, highLineName, OBJPROP_COLOR, ColorHL);
    ObjectSetInteger(0, lowLineName, OBJPROP_COLOR, ColorHL);
    ObjectSetInteger(0, midLineName, OBJPROP_COLOR, ColorM);
    ObjectSetInteger(0, highLineName, OBJPROP_WIDTH, LineSize);
    ObjectSetInteger(0, lowLineName, OBJPROP_WIDTH, LineSize);
    ObjectSetInteger(0, midLineName, OBJPROP_WIDTH, LineSize);
    ObjectSetInteger(0, highLineName, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, lowLineName, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, midLineName, OBJPROP_RAY_RIGHT, false);
}

//+------------------------------------------------------------------+
//| Cleanup objects from the chart                                   |
//+------------------------------------------------------------------+
void CleanupObjects()
{
    // Delete high, low, and mid lines
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string name = ObjectName(i);
        if (StringFind(name, "HighLine_") == 0 || StringFind(name, "LowLine_") == 0 || StringFind(name, "MidLine_") == 0)
        {
            ObjectDelete(name);
        }
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
void DrawLine(string name, double price, datetime time1, datetime time2, color lineColor, int lineStyle) {
    if (ObjectFind(0, name) == -1) {
        ObjectCreate(0, name, OBJ_TREND, 0, time1, price, time2, price);
        ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
        ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, name, OBJPROP_RAY, false);
        ObjectSetInteger(0, name, OBJPROP_BACK, true);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    }
}