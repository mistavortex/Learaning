//+------------------------------------------------------------------+
//|                                        123_Pattern_BT.mq4              |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 4"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrBlue
#property indicator_color2 clrMagenta
#property indicator_color3 clrLime
#property indicator_color4 clrCrimson
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2

// Inputs for customization
input int   barLimit      = 1000;       // Limit bars to process
input bool  drawZigZag    = true;       // Enable ZigZag drawing
input int   widthZZ       = 3;          // ZigZag width
input bool  drawArrow     = true;       // Enable arrow drawing
input int   UpArrowCode   = 233;        // Up arrow code
input int   DownArrowCode = 234;        // Down arrow code
input int   Distance      = 20;         // Arrow distance from High/Low

// Enum for alert settings
enum alert
  {
   Off = 0,         // No alerts
   Current = 1,     // Alerts on current bar
   Previous = 2     // Alerts on previous closed bar
  };

// Inputs for notifications
input alert  notificationsOn       = 1;                      // Notifications setting
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Sound file for notifications

// Inputs for button customization
extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow         = 0;                               // Sub-window for button
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER;               // Button corner for anchoring
extern string             btn_text              = "123";                           // Button text
extern string             btn_Font              = "Arial";                         // Button font name
extern int                btn_FontSize          = 9;                               // Button font size
extern color              btn_text_ON_color     = clrLime;                         // Text color when button is ON
extern color              btn_text_OFF_color    = clrRed;                          // Text color when button is OFF
extern color              btn_background_color  = clrDimGray;                      // Button background color
extern color              btn_border_color      = clrBlack;                        // Button border color
extern int                button_x              = 100;                             // Button x-coordinate
extern int                button_y              = 40;                              // Button y-coordinate
extern int                btn_Width             = 80;                              // Button width
extern int                btn_Height            = 20;                              // Button height
extern string             UniqueButtonID        = "Pattern123";                    // Unique ID for button
extern string             button_note2          = "------------------------------";
input bool                Interpolate           = true;                // Down arrow size

bool show_data, recalc=false;
string IndicatorObjPrefix, buttonId;

// Indicator buffers for drawing
double BufferUP[], BufferDO[], UpArrow[], DownArrow[];

//+------------------------------------------------------------------------------------------------------------------+
// Indicator initialization
int OnInit()
{
   // Set the number of digits to display
   IndicatorDigits(Digits);
   // Create a unique prefix for indicator objects
   IndicatorObjPrefix = "_" + btn_text + "_";
   
   // Create a unique button ID
   buttonId = "_" + IndicatorObjPrefix + UniqueButtonID + "_BT_";
   
   // If the button does not exist, create it
   if (ObjectFind(buttonId)<0)
      createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   
   // Set button position
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);

   // Initialize the indicator
   init2();

   // Get the button state
   show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
   
   // Set button color based on state
   if (show_data) ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color);
   else ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
// Function to create a button
void createButton(string buttonID,string buttonText,int width2,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,btn_Subwindow,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width2);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      // Set the initial state to "true" which is "on"
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
}
//+------------------------------------------------------------------------------------------------------------------+
// Indicator deinitialization
void OnDeinit(const int reason)
{
   // If not changing the time frame, delete the button
   if(reason != REASON_CHARTCHANGE) ObjectDelete(buttonId);
   // Deinitialize the indicator
   deinit2();
}
//+------------------------------------------------------------------------------------------------------------------+
// Handle chart events (e.g., button clicks)
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Skip unnecessary events
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DELETE) return;
   if(id==CHARTEVENT_MOUSE_MOVE || id==CHARTEVENT_MOUSE_WHEEL) return;
   
   // Handle button click event
   if (id==CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
   {
      // Toggle show_data based on button state
      show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
      
      if (show_data)
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color);
         init2();
         recalc=true;
         mystart();
      }
      else
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
         deinit2();
         for (int ForexStation2=0; ForexStation2<indicator_buffers; ForexStation2++)
              SetIndexStyle(ForexStation2,DRAW_NONE);
      }
   }
}
//+------------------------------------------------------------------------------------------------------------------+
// Initialize indicator buffers and settings
int init2()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0, BufferUP);
   SetIndexBuffer(1, BufferDO);
   SetIndexLabel(0, "UP");
   SetIndexLabel(1, "DOWN");
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexBuffer(2, UpArrow);
   SetIndexBuffer(3, DownArrow);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(2, UpArrowCode);
   SetIndexArrow(3, DownArrowCode);
   SetIndexLabel(2,"Up Arrow");
   SetIndexLabel(3,"Down Arrow");
   IndicatorShortName("1-2-3");
   return(0);
}
//+------------------------------------------------------------------+
// Deinitialize indicator settings
int deinit2()
{
   ObjectsDeleteAll(0, "d123a_");
   ObjectsDeleteAll(0, "d123b_");
   ObjectsDeleteAll(0, "u123a_");
   ObjectsDeleteAll(0, "u123b_");
   return(0);
}
//+------------------------------------------------------------------+
// Start function for the indicator
int start() {return(mystart()); }
//+------------------------------------------------------------------+
// Main function for the indicator
int mystart()
{
   int S, counted_bars=IndicatorCounted();
   if (show_data)
   {
      if(recalc)
      {
         // Recalculate everything if button goes from off-to-on
         counted_bars = 0;
         recalc=false;
      }

      if(counted_bars > 0)
         counted_bars--;
      int limit = Bars - counted_bars;
      if(limit > barLimit)
         limit = barLimit;
      for(int i = 0; i < limit - 1; i++)
      {
         S = form(i);
         BufferUP[i] = EMPTY_VALUE;
         BufferDO[i] = EMPTY_VALUE;
         switch(S)
         {
            case 1:
               if(drawArrow) {
                  BufferUP[i] = Low[i] - Distance * Point;
                  UpArrow[i] = Low[i] - Distance * Point;
               }
               break;
            case -1:
               if(drawArrow) {
                  BufferDO[i] = High[i] + Distance * Point;
                  DownArrow[i] = High[i] + Distance * Point;
               }
               break;
         }
      }
   }
   return(0);
}
//+------------------------------------------------------------------+
// Function to detect patterns and return signal
int form(int b)
{
   int lookBack = 40;
   if(b + lookBack > iBars(Symbol(), Period()))
      return 0;
   int cup = 0, clo = 0, i;
   int fup[2], flo[2];
   double fupPrice[2], floPrice[2];
   double f;

   ArrayInitialize(fup, 0);
   ArrayInitialize(flo, 0);
   ArrayInitialize(fupPrice, 0.0);
   ArrayInitialize(floPrice, 0.0);

   for(i = b; i < b + lookBack; i++)
   {
      f = iFractals(Symbol(), Period(), MODE_UPPER, i);
      if(f > 0.0)
      {
         fup[cup] = i;
         fupPrice[cup] = f;
         cup++;
      }
      f = iFractals(Symbol(), Period(), MODE_LOWER, i);
      if(f > 0.0)
      {
         flo[clo] = i;
         floPrice[clo] = f;
         clo++;
      }
      if(cup >= 2 || clo >= 2)
      {
         break;
      }
   }
   if(fup[0] < flo[0] && flo[0] < fup[1] && flo[1] == 0 &&
      fupPrice[0] > floPrice[0] &&
      fupPrice[1] > floPrice[0] &&
      fupPrice[0] < fupPrice[1] &&
      (Open[b] > floPrice[0] || Close[b + 1] > floPrice[0]) &&
      Close[b] < floPrice[0])
   {
      if(drawZigZag)
         drawZZ(fup[0], flo[0], fup[1], -1, i);
      return -1;
   }
   if(flo[0] < fup[0] && fup[0] < flo[1] && fup[1] == 0 &&
      floPrice[0] < fupPrice[0] &&
      floPrice[1] < fupPrice[0] &&
      floPrice[0] > floPrice[1] &&
      (Open[b] < fupPrice[0] || Close[b + 1] < fupPrice[0]) &&
      Close[b] > fupPrice[0])
   {
      if(drawZigZag)
         drawZZ(flo[0], fup[0], flo[1], 1, i);
      return 1;
   }
   return 0;
}
//+------------------------------------------------------------------+
// Function to draw ZigZag lines
void drawZZ(int a, int b, int c, int dir, int bar)
{
   if(dir == -1)
   {
      ObjectCreate(0, "d123a_" + (string)bar, OBJ_TREND, 0, iTime(Symbol(), Period(), b), Low[b], iTime(Symbol(), Period(), a), High[a]);
      ObjectCreate(0, "d123b_" + (string)bar, OBJ_TREND, 0, iTime(Symbol(), Period(), c), High[c], iTime(Symbol(), Period(), b), Low[b]);
      ObjectSetInteger(0, "d123a_" + (string)bar, OBJPROP_COLOR, indicator_color2);
      ObjectSetInteger(0, "d123b_" + (string)bar, OBJPROP_COLOR, indicator_color2);
      ObjectSetInteger(0, "d123a_" + (string)bar, OBJPROP_WIDTH, widthZZ);
      ObjectSetInteger(0, "d123b_" + (string)bar, OBJPROP_WIDTH, widthZZ);
      ObjectSetInteger(0, "d123a_" + (string)bar, OBJPROP_RAY, 0);
      ObjectSetInteger(0, "d123b_" + (string)bar, OBJPROP_RAY, 0);
   }
   if(dir == 1)
   {
      ObjectCreate(0, "u123a_" + (string)bar, OBJ_TREND, 0, iTime(Symbol(), Period(), b), High[b], iTime(Symbol(), Period(), a), Low[a]);
      ObjectCreate(0, "u123b_" + (string)bar, OBJ_TREND, 0, iTime(Symbol(), Period(), c), Low[c], iTime(Symbol(), Period(), b), High[b]);
      ObjectSetInteger(0, "u123a_" + (string)bar, OBJPROP_COLOR, indicator_color1);
      ObjectSetInteger(0, "u123b_" + (string)bar, OBJPROP_COLOR, indicator_color1);
      ObjectSetInteger(0, "u123a_" + (string)bar, OBJPROP_WIDTH, widthZZ);
      ObjectSetInteger(0, "u123b_" + (string)bar, OBJPROP_WIDTH, widthZZ);
      ObjectSetInteger(0, "u123a_" + (string)bar, OBJPROP_RAY, 0);
      ObjectSetInteger(0, "u123b_" + (string)bar, OBJPROP_RAY, 0);
   }
}
//+------------------------------------------------------------------+
// Function to check and handle alerts
bool alerted;
void checkAlert()
{
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
   {
      if(BufferUP[0] > 0 && BufferUP[0] != EMPTY_VALUE)
      {
         Notify(1);
         alerted = true;
      }
      if(BufferDO[0] > 0 && BufferDO[0] != EMPTY_VALUE)
      {
         Notify(2);
         alerted = true;
      }
   }
   if(notificationsOn == 2 && nb)
   {
      if(BufferUP[1] > 0 && BufferUP[1] != EMPTY_VALUE)
      {
         Notify(11);
      }
      if(BufferDO[1] > 0 && BufferDO[1] != EMPTY_VALUE)
      {
         Notify(22);
      }
   }
}
//+------------------------------------------------------------------+
// Function to check if a new bar is formed
bool IsNewBar()
{
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
   {
      lastbar = curbar;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
// Function to send notifications
void Notify(int type)
{
   string text = "1-2-3: ";
   switch(type)
   {
      case 1:
         text += " Turn UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Turn DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Turn UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Turn DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
   }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
}
//+------------------------------------------------------------------+
// Function to get time frame as string
string GetTimeFrame(int lPeriod)
{
   switch(lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+