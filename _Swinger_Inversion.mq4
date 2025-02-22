//+------------------------------------------------------------------+
//|                                        _Swinger_Inversion.mq4              |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "2025"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

// External parameters for customization
extern string SETTINGS = "-------------------------------------------------------------------------------------";
extern ENUM_TIMEFRAMES HigherTimeframe = PERIOD_M1;
extern string button_name = "SwingInv ";
extern int BarsToProcess = 1000;
extern int ScanRange = 100; // Add new extern variable for scan range
extern int Shift = 2;
extern int arrowShift = 12;
extern string SWITCHES = "-------------------------------------------------------------------------------------";
extern bool enableAlert = false; // ENABLE ALERT
extern bool ShowConflictOnly = true;  // Show only Conflict Arrows and Lines
extern bool ShowNonConflictOnly = false;  // Show only Non-Conflict Arrows and Lines
extern bool ShowArrows = false;  // Show Swing Arrows
extern bool ShowLines = true;   // Show Swing Lines
extern bool ShowIntermediateArrows = false;  // Show Intermediate Arrows
extern bool ShowIntermediateLines = false;   // Show Intermediate Lines
extern string COLORS = "-------------------------------------------------------------------------------------";
extern color BullishColor = clrLime;
extern color BearishColor = clrIvory;
extern color ConflictColor = clrRed;
extern string DIMENSIONS = "-------------------------------------------------------------------------------------";
extern int   widthArrow    = 0;                 // Size of Arrows
extern int   styleHL_Lines = 0;                 // Style of Lines
extern int   widthHL_Lines = 1;                 // Width of Lines

extern string button_note1 = "-------------------------------------------------------------------------------------";
extern ENUM_BASE_CORNER btn_corner = CORNER_LEFT_UPPER;  // Chart corner for anchoring Button
extern int btn_FontSize = 10;                            // Button font size
extern color btn_text_color = clrMistyRose;              // Button text color when OFF
extern color btn_text_color_on = clrLime;                // Button text color when ON
extern color btn_background_color = clrDimGray;          // Button background color when OFF
extern color btn_background_color_on = clrGreen;         // Button background color when ON
extern int button_x = 10;                                // Horizontal location
extern int button_y = 365;                               // Vertical location
extern int btn_Width = 80;                               // Button width
extern int btn_Height = 20;                              // Button height

bool indicatorOn = true;
string buttonStateKey = button_name + "_Swinger_ButtonState";

// Arrays to store detected patterns
double bullPatterns[];
double bearPatterns[];
datetime bullTimes[];
datetime bearTimes[];
bool bullAlertTriggered = false;
bool bearAlertTriggered = false;
string uniqueID = "_SwingInv_";  // Unique ID string variable
color BullArrowColor = BullishColor;
color BearArrowColor = BearishColor;

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
        if (StringFind(name, button_name + uniqueID) == 0)
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
    if (!indicatorOn)
    {
        return (rates_total);
    }

    static datetime higherTime[];
    static double higherOpen[], higherHigh[], higherLow[], higherClose[];
    static int higherRatesTotal = 0;

    if (prev_calculated == 0)
    {
        higherRatesTotal = iBars(NULL, HigherTimeframe);
        ArrayResize(higherTime, higherRatesTotal);
        ArrayResize(higherOpen, higherRatesTotal);
        ArrayResize(higherHigh, higherRatesTotal);
        ArrayResize(higherLow, higherRatesTotal);
        ArrayResize(higherClose, higherRatesTotal);

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
    }

    if (BarsToProcess > higherRatesTotal) BarsToProcess = higherRatesTotal;
    if (BarsToProcess < 5) BarsToProcess = 10;

    bool patternDetectedBear = false;
    bool patternDetectedBull = false;
    double storedHighLine = 0;
    double storedLowLine = 0;
    static bool conflictPatternDetected = false;

    for (int i = BarsToProcess - 4; i >= 0; i--)
    {
        int bar_now = i + Shift;
        double H1 = higherHigh[i + 1];
        double L1 = higherLow[i + 1];
        double H2 = higherHigh[i + 2];
        double L2 = higherLow[i + 2];
        double H3 = higherHigh[i + 3];
        double L3 = higherLow[i + 3];
        double C1 = higherClose[i + 1];
        double O1 = higherOpen[i + 1];
        double C2 = higherClose[i + 2];
        double O2 = higherOpen[i + 2];

        bool newPatternDetectedBear = false;
        bool newPatternDetectedBull = false;
        color plotColor, lineColor;
        bool SwingInvBull = L2 > L3 && L2 > L1, SwingInvBear = H2 < H3 && H2 < H1;
        bool ArrowUpBull = H2 > H3 && H2 > H1, ArrowUpBear = L2 > L3 && L2 > L1;
        bool ArrowDnBull = H2 < H3 && H2 < H1, ArrowDnBear = L2 < L3 && L2 < L1;
        bool HighBull = H2 == H1 || H2 == L1, LowBear = L2 == L1 || L2 == H1;
        bool CCCO = C2 == C1 || C2 == O1, OOOC = O2 == O1 ||  O2 == C1 ;
        bool CHOH = C2 == H1 || O2 == H1 || H2 == C1 || H2 == O1, CLOL = C2 == L1 ||  O2 == L1 || L2 == C1 ||  L2 == O1 ;

        bool ScanL1 = ScanPastBars(L1, ScanRange, higherOpen, higherHigh, higherLow, higherClose);
        bool ScanH1 = ScanPastBars(H1, ScanRange, higherOpen, higherHigh, higherLow, higherClose);
        bool ScanL2 = ScanPastBars(L2, ScanRange, higherOpen, higherHigh, higherLow, higherClose);
        bool ScanH2 = ScanPastBars(H2, ScanRange, higherOpen, higherHigh, higherLow, higherClose); 
        bool ScanL3 = ScanPastBars(L3, ScanRange, higherOpen, higherHigh, higherLow, higherClose);
        bool ScanH3 = ScanPastBars(H3, ScanRange, higherOpen, higherHigh, higherLow, higherClose); 

        // Bull pattern detection
        if (HighBull && (ScanH2 || ScanL2)) {
            patternDetectedBull = true;
            newPatternDetectedBull = true;
            storedLowLine = L2;
            ArrayResize(bullPatterns, ArraySize(bullPatterns) + 1);
            ArrayResize(bullTimes, ArraySize(bullTimes) + 1);
            bullPatterns[ArraySize(bullPatterns) - 1] = L2;
            bullTimes[ArraySize(bullTimes) - 1] = higherTime[bar_now];
            bullAlertTriggered = false;
        }

        // Bear pattern detection
        if (LowBear && (ScanH2 || ScanL2)) {
            patternDetectedBear = true;
            newPatternDetectedBear = true;
            storedHighLine = H2;
            ArrayResize(bearPatterns, ArraySize(bearPatterns) + 1);
            ArrayResize(bearTimes, ArraySize(bearTimes) + 1);
            bearPatterns[ArraySize(bearPatterns) - 1] = H2;
            bearTimes[ArraySize(bearTimes) - 1] = higherTime[bar_now];
            bearAlertTriggered = false;
        }

        if (newPatternDetectedBull && newPatternDetectedBear) {
            conflictPatternDetected = true;
        } else if (newPatternDetectedBull || newPatternDetectedBear) {
            if (conflictPatternDetected) {
                conflictPatternDetected = false;
            }
        }

        // Bull pattern actions
        if (patternDetectedBull && (!ShowConflictOnly || conflictPatternDetected) && (!ShowNonConflictOnly || !conflictPatternDetected)) {
            plotColor = conflictPatternDetected ? ConflictColor : BullishColor;
            if (newPatternDetectedBull) {
                newPatternDetectedBull = false;
                if (ShowArrows) {
                    DrawArrow(button_name + uniqueID + "Arrow_Bull_" + IntegerToString(higherTime[bar_now]), storedLowLine - (arrowShift * Point / 2.5), higherTime[bar_now], plotColor, 217); // Up arrow for bullish pattern
                }
            }
            if (ShowLines) {
                lineColor = conflictPatternDetected ? ConflictColor : BullishColor;
                DrawLine(button_name + uniqueID + "LowLine_" + IntegerToString(higherTime[bar_now]), storedLowLine, higherTime[bar_now], higherTime[bar_now - 1], lineColor, styleHL_Lines, widthHL_Lines);
            }
        }

        // Bear pattern actions
        if (patternDetectedBear && (!ShowConflictOnly || conflictPatternDetected) && (!ShowNonConflictOnly || !conflictPatternDetected)) {
            plotColor = conflictPatternDetected ? ConflictColor : BearishColor;
            if (newPatternDetectedBear) {
                newPatternDetectedBear = false;
                if (ShowArrows) {
                    DrawArrow(button_name + uniqueID + "Arrow_Bear_" + IntegerToString(higherTime[bar_now]), storedHighLine + (arrowShift * Point), higherTime[bar_now], plotColor, 218); // Down arrow for bearish pattern
                }
            }
            if (ShowLines) {
                lineColor = conflictPatternDetected ? ConflictColor : BearishColor;
                DrawLine(button_name + uniqueID + "HighLine_" + IntegerToString(higherTime[bar_now]), storedHighLine, higherTime[bar_now], higherTime[bar_now - 1], lineColor, styleHL_Lines, widthHL_Lines);
            }
        }

        // Check for second-tier patterns
        if (ShowIntermediateArrows) {
            if (ArraySize(bullPatterns) >= 3) {
                double bull1 = bullPatterns[ArraySize(bullPatterns) - 3];
                double bull2 = bullPatterns[ArraySize(bullPatterns) - 2];
                double bull3 = bullPatterns[ArraySize(bullPatterns) - 1];
                datetime time2 = bullTimes[ArraySize(bullTimes) - 2];
                if (bull3 > bull2 && bull1 > bull2 && (!ShowConflictOnly || (ShowConflictOnly && ShowIntermediateArrows)) && !bullAlertTriggered) {
                    DrawArrow(button_name + uniqueID + "IntermediateLow_" + IntegerToString(time2), bull2 - (arrowShift * 2) * Point / 2.5, time2, BullArrowColor, 233); // Different arrow code for second-tier pattern
                    if (enableAlert) {
                        Alert("Intermediate Bullish Pattern Detected at ", TimeToStr(time2));
                        PlaySound("alert.wav");
                    }
                    bullAlertTriggered = true; // Set the flag to true to prevent further alerts for this pattern
                }
            }

            if (ArraySize(bearPatterns) >= 3) {
                double bear1 = bearPatterns[ArraySize(bearPatterns) - 3];
                double bear2 = bearPatterns[ArraySize(bearPatterns) - 2];
                double bear3 = bearPatterns[ArraySize(bearPatterns) - 1];
                datetime time2 = bearTimes[ArraySize(bearTimes) - 2];
                if (bear3 < bear2 && bear1 < bear2 && (!ShowConflictOnly || (ShowConflictOnly && ShowIntermediateArrows)) && !bearAlertTriggered) {
                    DrawArrow(button_name + uniqueID + "IntermediateHigh_" + IntegerToString(time2), bear2 + (arrowShift * 2) * Point / 2.5, time2, BearArrowColor, 234); // Different arrow code for second-tier pattern
                    if (enableAlert) {
                        Alert("Intermediate Bearish Pattern Detected at ", TimeToStr(time2));
                        PlaySound("alert.wav");
                    }
                    bearAlertTriggered = true; // Set the flag to true to prevent further alerts for this pattern
                }
            }
        }
    }

    return (rates_total);
}
//+------------------------------------------------------------------+
//| Scan past bars function                                          |
//+------------------------------------------------------------------+
bool ScanPastBars(double price, int range, const double &open[], const double &high[], const double &low[], const double &close[])
{
    for (int i = 0; i < range; i++)
    {
        if (price == open[i] || price == high[i] || price == low[i] || price == close[i])
        {
            return true;
        }
    }
    return false;
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
                if (StringFind(name, button_name + uniqueID) == 0)
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
//| DrawArrow function                                               |
//+------------------------------------------------------------------+
void DrawArrow(string name, double price, datetime time, color arrowColor, int arrowCode)
{
    if (ObjectFind(0, name) == -1)
    {
        ObjectCreate(0, name, OBJ_ARROW, 0, time, price);
        ObjectSetInteger(0, name, OBJPROP_COLOR, arrowColor);
        ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrowCode);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, widthArrow);
        ObjectSetInteger(0, name, OBJPROP_BACK, false); // Ensure object is in front
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
        ObjectSetInteger(0, name, OBJPROP_BACK, false); // Ensure object is in front
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