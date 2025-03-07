//+-----------------------------------------------------------+
//| MT4 CUSTOM INDICATOR                   123PatternsV6.MQ4  |
//| copy to [experts\\indicators] and recompile or restart MT4 |
//+-----------------------------------------------------------+
//| Free software for personal non-commercial use only.       |
//| No guarantees are expressed or implied.                   |
//| Feedback welcome via Forex Factory private message.       |
//+-----------------------------------------------------------+
#property copyright "Copyright © 2010 Robert Dee"
#property link      "www.forexfactory.com/robdee"

#define INDICATOR_VERSION    20101105       // VERSION 6
#define INDICATOR_NAME       "123PatternsV6"
#define RELEASE_LEVEL        "Public"
#define MT4_BUILD            226

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1  DodgerBlue   // UpperLine
#property indicator_color2  OrangeRed    // LowerLine
#property indicator_color3  LimeGreen    // Target1
#property indicator_color4  LimeGreen    // Target2
#property indicator_color5  DodgerBlue   // BuyArrow
#property indicator_color6  OrangeRed    // SellArrow
#property indicator_color7  DodgerBlue   // BullDot
#property indicator_color8  OrangeRed    // BearDot
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  3  // BuyArrow
#property indicator_width6  3  // SellArrow
#property indicator_width7  3  // BullDot
#property indicator_width8  3  // BearDot

extern string Notes           = "15pip RangeBars Basic Setup";
extern string TimeFrame       = "Current time frame";
//extern ENUM_TIMEFRAMES TimeFrame=0;
extern int    ZigZagDepth     = 4;
extern double RetraceDepthMin = 0.4;
extern double RetraceDepthMax = 1.0;
extern bool   ShowAllLines    = True;
extern bool   ShowAllBreaks   = True;
extern bool   ShowTargets     = False;
extern double Target1Multiply = 1.5;
extern double Target2Multiply = 3.0;
extern bool   HideTransitions = True;


//alerts
extern string ahs="***** ALERT settings:";
extern bool AlertsOnBearSignals  = true;
extern bool AlertsOnBullSignals  = true;
extern bool Point2BreakAlerts = true;//123 setup
extern bool BreakUpperLineAlerts = true;//not 123 setup
extern bool BreakLowerLineAlerts = true;//not 123 setup
//
extern bool PopupAlerts         = true;
extern bool EmailAlerts         = false;
extern bool PushNotificationAlerts = false;
extern bool SoundAlerts         = false;
extern string SoundFileBull = "alert.wav";
extern string SoundFileBear = "alert2.wav";
extern bool  ShowScreenComment = true;
int lastP2BreakAlert=3;
int lastLineBreakAlert=3;
string msg;
//end alerts

/*
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsNotify    = true;
extern bool   alertsEmail     = true;

*/
extern string UniqueID        = "GlobalVariable1";
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; 
extern string             btn_text              = "123";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                            
extern color              btn_text_ON_color     = clrLime;
extern color              btn_text_OFF_color    = clrRed;
extern string             btn_pressed           = "123 OFF";            
extern string             btn_unpressed         = "123 ON";
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 260;                                 
extern int                button_y              = 0;                                   
extern int                btn_Width             = 70;                                 
extern int                btn_Height            = 20;                                
extern string             soundBT               = "tick.wav";  
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix ,buttonId ;


// indicator buffers
double UpperLine[];
double LowerLine[];
double Target1[];
double Target2[];
double BuyArrow[];
double SellArrow[];
double BullDot[];
double BearDot[];

double   firsthigh, firstlow, lasthigh, lastlow, prevhigh, prevlow, signalprice, brokenline;
datetime firsthightime, firstlowtime, lasthightime, lastlowtime, prevhightime, prevlowtime, signaltime;
datetime redrawtime;  // remember when the indicator was redrawn

int     signal;
#define NOSIG   0
#define BUYSIG  1
#define SELLSIG 2

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
int init()
{
int i;
for(i=0; i<=7; i++) SetIndexEmptyValue(i,EMPTY_VALUE);
if(ShowAllLines == True) SetIndexStyle(0,DRAW_LINE); else SetIndexStyle(0,DRAW_NONE);
if(ShowAllLines == True) SetIndexStyle(1,DRAW_LINE); else SetIndexStyle(1,DRAW_NONE);
if(ShowTargets == True) SetIndexStyle(2,DRAW_LINE); else SetIndexStyle(2,DRAW_NONE);
if(ShowTargets == True) SetIndexStyle(3,DRAW_LINE); else SetIndexStyle(3,DRAW_NONE);
SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,SYMBOL_ARROWUP);
SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,SYMBOL_ARROWDOWN);
SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159); // BullDot (WingDings character)
SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,159); // BearDot (WingDings character)
SetIndexBuffer(0,UpperLine);
SetIndexBuffer(1,LowerLine);
SetIndexBuffer(2,Target1);
SetIndexBuffer(3,Target2);
SetIndexBuffer(4,BuyArrow);
SetIndexBuffer(5,SellArrow);
SetIndexBuffer(6,BullDot);
SetIndexBuffer(7,BearDot);
IndicatorShortName(INDICATOR_NAME);
IndicatorDigits(Digits);
if(ShowAllLines == True) SetIndexLabel(0,"UpperLine"); else SetIndexLabel(0,"");
if(ShowAllLines == True) SetIndexLabel(1,"LowerLine"); else SetIndexLabel(1,"");
if(ShowTargets == True) SetIndexLabel(2,"Target1"); else SetIndexLabel(2,"");
if(ShowTargets == True) SetIndexLabel(3,"Target2"); else SetIndexLabel(3,"");
SetIndexLabel(4,"BuyArrow");
SetIndexLabel(5,"SellArrow");
SetIndexLabel(6,"");
SetIndexLabel(7,"");

      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         timeFrame         = stringToTimeFrame(TimeFrame);
         calculateValue    = TimeFrame=="calculateValue";   if (calculateValue) return(0);
      
      //
      //
      //
      //
      //

if(IsTesting() == False)
   {
   Print("Copyright © 2010 Robert Dee, All Rights Reserved");   
   Print("Free software for personal non-commercial use only. No guarantees are expressed or implied.");
   Print(INDICATOR_NAME+" indicator version "+INDICATOR_VERSION+" for "+RELEASE_LEVEL+" release, compiled with MetaTrader4 Build "+MT4_BUILD);
   }
   
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
 //  IndicatorShortName(WindowExpertName());
   IndicatorDigits(Digits);
      double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
   show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix+btn_text;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);  
return(0);
} // end of init()
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
    //  ObjectDelete    (ChartID(),buttonID);
      ObjectCreate (ChartID(),buttonID,OBJ_BUTTON,WindowOnDropped(),0,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (ChartID(),buttonID,OBJPROP_FONT,font);
      ObjectSetString (ChartID(),buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YDISTANCE,9999);
}
 bool recalc = true;
 void handleButtonClicks()
{
   if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}

void OnChartEvent(const int id, 
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
   if (id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
   {
   if (soundBT!="") PlaySound(soundBT);     
   }
}
//
//

int start()
{
 handleButtonClicks();
   recalc = false;
   
   
   
  if(ShowAllLines == True) SetIndexStyle(0,DRAW_LINE); else SetIndexStyle(0,DRAW_NONE);
if(ShowAllLines == True) SetIndexStyle(1,DRAW_LINE); else SetIndexStyle(1,DRAW_NONE);
if(ShowTargets == True) SetIndexStyle(2,DRAW_LINE); else SetIndexStyle(2,DRAW_NONE);
if(ShowTargets == True) SetIndexStyle(3,DRAW_LINE); else SetIndexStyle(3,DRAW_NONE);
SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,SYMBOL_ARROWUP);
SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,SYMBOL_ARROWDOWN);
SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159); // BullDot (WingDings character)
SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,159); // BearDot (WingDings character)
   start2();
   
  
   
      
   
   if (show_data)
      {
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color);
      ObjectSetString(ChartID(),buttonId,OBJPROP_TEXT,btn_unpressed);
     
      }
      else
      {
      ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
      ObjectSetString(ChartID(),buttonId,OBJPROP_TEXT,btn_pressed);
       SetIndexStyle(0,DRAW_NONE);
         SetIndexStyle(1,DRAW_NONE);
        SetIndexStyle(2,DRAW_NONE);
        SetIndexStyle(3,DRAW_NONE);
        SetIndexStyle(4,DRAW_NONE);
        SetIndexStyle(5,DRAW_NONE);
         SetIndexStyle(6,DRAW_NONE);
        SetIndexStyle(7,DRAW_NONE);
         
      GlobalVariableDel(UniqueID+":0");
   GlobalVariableDel(UniqueID+":1");
   GlobalVariableDel(UniqueID+":2");
   Comment(""); 
   
      //template code     
      }
       return(0);
      }
//+------------------------------------------------------------------+
//| Status Message prints below OHLC upper left of chart window
//+------------------------------------------------------------------+
void StatusMessage()
   {
   if(IsTesting() == True) return; // do no more
   if (timeFrame!=Period())
   {
      signal      = GlobalVariableGet(UniqueID+":0");
      signaltime  = GlobalVariableGet(UniqueID+":1");
      signalprice = GlobalVariableGet(UniqueID+":2");
   }
   string symbol = Symbol(); if (StringSubstr(symbol,0,2)=="_t") symbol = StringSubstr(symbol,2);
   double multi  = 1;
  	int    digits = MarketInfo(symbol,MODE_DIGITS);
   if (digits==3 || digits==5) multi = 10.0;
   string msg = INDICATOR_NAME+"  "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  ";
   if(signal == NOSIG) msg = msg + "NOSIG  ";
   if(signal == BUYSIG) msg = msg + "BUYSIG  "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
   if(signal == SELLSIG) msg = msg + "SELLSIG  "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
   msg = msg + "ZigZagDepth="+ZigZagDepth+"  ";
   //msg = msg + "RetraceDepth="+DoubleToStr(RetraceDepthMin,2)+" "+DoubleToStr(RetraceDepthMax,2)+"  ";
   //msg = msg + "Target1="+DoubleToStr(Target1Multiply,2)+"  ";
   //msg = msg + "Target2="+DoubleToStr(Target2Multiply,2)+"  ";
   msg = msg + "Spread="+DoubleToStr(MarketInfo(symbol,MODE_SPREAD)/ multi,2)+"  ";
   msg = msg + "Range="+(iHigh(symbol,timeFrame,0) - iLow(symbol,timeFrame,0))/(MarketInfo(symbol,MODE_POINT)*multi)+"  ";
   Comment(msg);
      if (timeFrame==Period() || calculateValue)
      {
         GlobalVariableSet(UniqueID+":0",signal);
         GlobalVariableSet(UniqueID+":1",signaltime);
         GlobalVariableSet(UniqueID+":2",signalprice);
      }      
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start2()
{
   
// REDRAW ONLY ONE TIME PER CANDLE
if(redrawtime == Time[0]) {StatusMessage(); return(0);} // if already redrawn on this candle then do no more
else redrawtime = Time[0];                              // remember when the indicator was redrawn

   if (calculateValue || timeFrame == Period())
   {
      double   zigzag, range, retracedepth, one, two, three;
      datetime onetime, twotime, threetime;
      int      shift = Bars-1;
      while(shift >= 0)
      {
         // UPPERLINES and LOWERLINES based on ZIGZAG
         UpperLine[shift] = UpperLine[shift+1];
         LowerLine[shift] = LowerLine[shift+1];
         Target1[shift]   = Target1[shift+1];
         Target2[shift]   = Target2[shift+1];
         BuyArrow[shift]  = EMPTY_VALUE;
         SellArrow[shift] = EMPTY_VALUE;
         BullDot[shift]   = EMPTY_VALUE;
         BearDot[shift]   = EMPTY_VALUE;
         zigzag           = iCustom(NULL,0,"ZigZag",ZigZagDepth,5,3,0,shift);
         if(zigzag == High[shift])
         {
            UpperLine[shift] = High[shift];
            firsthigh = prevhigh; firsthightime = prevhightime;
            prevhigh = lasthigh;  prevhightime = lasthightime;
            lasthigh = zigzag;    lasthightime = Time[shift];
         }
         if(zigzag == Low[shift])
         {
            LowerLine[shift] = Low[shift];
            firstlow = prevlow; firstlowtime = prevlowtime;
            prevlow = lastlow;  prevlowtime = lastlowtime;
            lastlow = zigzag;   lastlowtime = Time[shift];
         }

         ///////////////////////////
         // BULLISH BREAK ABOVE #2
         
         one   = prevlow; onetime = prevlowtime;
         two   = lasthigh; twotime = lasthightime; if(twotime == Time[shift]){two = prevhigh; twotime = prevhightime;}
         three = lastlow; threetime = lastlowtime;
         if(one - two != 0) retracedepth = (three - two) / (one - two);  // retrace depth
         // signal rules
         if(shift > 0)
         if(retracedepth > RetraceDepthMin)                  // minimum retrace depth for 123 pattern
         if(retracedepth < RetraceDepthMax)                  // maximum retrace depth for 123 pattern
         if(brokenline != UpperLine[shift])                  // if this line has not already been broken
         if(Low[shift] < UpperLine[shift])                   // low of rangebar is below the line
         if(Close[shift] > UpperLine[shift])                 // close of rangebar body is above the line (break)
         {
            range = MathAbs(two - three);                    // range is the distance between two and three
            Target1[shift] = two+(range*Target1Multiply);
            Target2[shift] = two+(range*Target2Multiply);
            BuyArrow[shift] = Low[shift]-(High[shift]-Low[shift])/3;
            BullDot[iBarShift(NULL,0,onetime)] = one;        // ONE
            BullDot[iBarShift(NULL,0,twotime)] = two;        // TWO
            BullDot[iBarShift(NULL,0,threetime)] = three;    // THREE
            signal = BUYSIG;
            signaltime = Time[shift];
            signalprice = BuyArrow[shift];
            brokenline = UpperLine[shift];
            
              //alerts added
            if (shift<=1 && Point2BreakAlerts && AlertsOnBullSignals && signal==BUYSIG && lastP2BreakAlert!=1) {
             msg = INDICATOR_NAME+": "+Symbol()+", period "+TFtoStr(Period())+": "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  " + "BULLISH SIGNAL (P2 break), signaltime: "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
             doAlerts(msg,SoundFileBull);
             lastP2BreakAlert=1;
            }
      //end alerts
      
      
         }

         /////////////////////////////////////////////
         // BULLISH BREAK OF UPPERLINE (NOT 123 SETUP)
         // signal rules
         if(shift > 0)
         if(ShowAllBreaks == True)
         if(brokenline != UpperLine[shift])                  // if this line has not already been broken
         if(Low[shift] < UpperLine[shift])                   // low of rangebar is below the line
         if(Close[shift] > UpperLine[shift])                 // close of rangebar body is above the line (break)
         {
            range = UpperLine[shift]-LowerLine[shift];
            Target1[shift] = UpperLine[shift]+(range*Target1Multiply);
            Target2[shift] = UpperLine[shift]+(range*Target2Multiply);
            BuyArrow[shift] = Low[shift]-(High[shift]-Low[shift])/3;
            signal = BUYSIG;
            signaltime = Time[shift];
            signalprice = BuyArrow[shift];
            brokenline = UpperLine[shift];
            
              //not 123 setup alerts:
            if (shift<=1 && BreakUpperLineAlerts && AlertsOnBullSignals && lastLineBreakAlert!=2) {
             msg = INDICATOR_NAME+": "+Symbol()+", period "+TFtoStr(Period())+": "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  " + "BULLISH breakout, signaltime: "+TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
             doAlerts(msg,SoundFileBull);
             lastLineBreakAlert=2;
            }//end alerts
      
      
         }

         ///////////////////////////
         // BEARISH BREAK BELOW #2

         one   = prevhigh; onetime = prevhightime;
         two   = lastlow; twotime = lastlowtime; if(twotime == Time[shift]){two = prevlow; twotime = prevlowtime;}
         three = lasthigh; threetime = lasthightime;
         if(one - two != 0) retracedepth = (three - two) / (one - two);  // retrace depth
         // signal rules
         if(shift > 0)
         if(retracedepth > RetraceDepthMin)                  // minimum retrace depth for 123 pattern
         if(retracedepth < RetraceDepthMax)                  // maximum retrace depth for 123 pattern
         if(brokenline != LowerLine[shift])                  // if this line has not already been broken
         if(High[shift] > LowerLine[shift])                  // high of rangebar is above the line
         if(Close[shift] < LowerLine[shift])                 // close of rangebar is below the line (break)
         {
            range = MathAbs(two - three);                    // range is the distance between two and three
            Target1[shift] = two-(range*Target1Multiply);
            Target2[shift] = two-(range*Target2Multiply);
            SellArrow[shift] = High[shift]+(High[shift]-Low[shift])/3;
            BearDot[iBarShift(NULL,0,onetime)] = one;        // ONE
            BearDot[iBarShift(NULL,0,twotime)] = two;        // TWO
            BearDot[iBarShift(NULL,0,threetime)] = three;    // THREE
            signal = SELLSIG;
            signaltime = Time[shift];
            signalprice = SellArrow[shift];
            brokenline = LowerLine[shift];
      //alerts added
      if (shift<=1 && Point2BreakAlerts && AlertsOnBearSignals && signal==SELLSIG && lastP2BreakAlert!=2) {
       msg = INDICATOR_NAME+": "+Symbol()+", period "+TFtoStr(Period())+": "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  " + "BEARISH SIGNAL (P2 break), signaltime: "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
       doAlerts(msg,SoundFileBear);
       lastP2BreakAlert=2;
      }
      //end alerts
      
      }

         /////////////////////////////////////////////
         // BEARISH BREAK OF LOWERLINE (NOT 123 SETUP)
         // signal rules
   
         if(shift > 0)
         if(ShowAllBreaks == True)
         if(brokenline != LowerLine[shift])                  // if this line has not already been broken
         if(High[shift] > LowerLine[shift])                  // high of rangebar is above the line
         if(Close[shift] < LowerLine[shift])                 // close of rangebar is below the line (break)
         {
            range = UpperLine[shift]-LowerLine[shift];
            Target1[shift] = LowerLine[shift]-(range*Target1Multiply);
            Target2[shift] = LowerLine[shift]-(range*Target2Multiply);
            SellArrow[shift] = High[shift]+(High[shift]-Low[shift])/3; 
            signal = SELLSIG;
            signaltime = Time[shift];
            signalprice = SellArrow[shift];
            brokenline = LowerLine[shift];
            
      //not 123 setup alerts:
      if (shift<=1 && BreakLowerLineAlerts && AlertsOnBearSignals && lastLineBreakAlert!=1) {
       msg = INDICATOR_NAME+": "+Symbol()+", period "+TFtoStr(Period())+": "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  " + "BEARISH breakout, signaltime: "+ TimeToStr(signaltime,TIME_MINUTES)+"  "+DoubleToStr(signalprice,Digits)+"  ";
       doAlerts(msg,SoundFileBear);
       lastLineBreakAlert=1;
      }//end alerts
      
      }

         // TARGET LINE RULES
         if(signal == BUYSIG)
         {
            if(Low[shift] > Target1[shift]) Target1[shift] = EMPTY_VALUE;
            if(Low[shift] > Target2[shift]) Target2[shift] = EMPTY_VALUE;
         }
         if(signal == SELLSIG)
         {
            if(High[shift] < Target1[shift]) Target1[shift] = EMPTY_VALUE;
            if(High[shift] < Target2[shift]) Target2[shift] = EMPTY_VALUE;
         }

         // HIDE LINE TRANSITIONS
         if(HideTransitions == True)
         {
            if(UpperLine[shift] != UpperLine[shift+1]) UpperLine[shift+1] = EMPTY_VALUE;
            if(LowerLine[shift] != LowerLine[shift+1]) LowerLine[shift+1] = EMPTY_VALUE;
            if(Target1[shift] != Target1[shift+1]) Target1[shift+1] = EMPTY_VALUE;
            if(Target2[shift] != Target2[shift+1]) Target2[shift+1] = EMPTY_VALUE;
         }

         shift--; // move ahead one candle
      }
      
      /*
      if (alertsOn)
      {
        if (alertsOnCurrent)
             int whichBar = 0;
        else     whichBar = 1; 
      
        //
        //
        //
        //
        //
      
        if (BuyArrow[whichBar+1]  == EMPTY_VALUE && BuyArrow[whichBar]  != EMPTY_VALUE) doAlert(whichBar,"current signal is BUY signal");
        if (SellArrow[whichBar+1] == EMPTY_VALUE && SellArrow[whichBar] != EMPTY_VALUE) doAlert(whichBar,"current signal is SELL signal");
      }   
      */
            
      StatusMessage();
      return(0);
   }
   
   //
   //
   //
   //
   //      

   for (int i=Bars-1; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
      int z = iBarShift(NULL,timeFrame,Time[i+1]);
         UpperLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,0,y);
         LowerLine[i] = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,1,y);
         Target1[i]   = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,2,y);
         Target2[i]   = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,3,y);
         BuyArrow[i]  = EMPTY_VALUE;
         SellArrow[i] = EMPTY_VALUE;
         BullDot[i]   = EMPTY_VALUE;
         BearDot[i]   = EMPTY_VALUE;
            if (y!=z)
            {
               BuyArrow[i]  = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,4,y);
               SellArrow[i] = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,5,y);
               BullDot[i]   = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,6,y);
               BearDot[i]   = iCustom(NULL,timeFrame,indicatorFileName,"","calculateValue",ZigZagDepth,RetraceDepthMin,RetraceDepthMax,ShowAllLines,ShowAllBreaks,ShowTargets,Target1Multiply,Target2Multiply,HideTransitions,7,y);
            }
   }
   StatusMessage();
   return(0);
}// end of start()

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   GlobalVariableDel(UniqueID+":0");
   GlobalVariableDel(UniqueID+":1");
   GlobalVariableDel(UniqueID+":2");
   Comment(""); 
   ObjectsDeleteAll(0,"123");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);  
   return(0);
}// end of deinit()


void doAlerts(string msg,string SoundFile) {


 string emailsubject="123PatternsV6 Alerts: Alert on acc. "+AccountNumber()+", "+WindowExpertName()+" - Alert on "+Symbol()+", period "+TFtoStr(Period());
 if (PopupAlerts) Alert(msg);
 if (EmailAlerts) SendMail(WindowExpertName()+": Alert on "+Symbol()+"(tf:"+Period()+")",msg);
 if (PushNotificationAlerts) SendNotification(msg);
 if (SoundAlerts) PlaySound(SoundFile);
}

string TFtoStr(int period) {
 switch(period) {
  case 1     : return("M1");  break;
  case 5     : return("M5");  break;
  case 15    : return("M15"); break;
  case 30    : return("M30"); break;
  case 60    : return("H1");  break;
  case 240   : return("H4");  break;
  case 1440  : return("D1");  break;
  case 10080 : return("W1");  break;
  case 43200 : return("MN1"); break;
  default    : return(DoubleToStr(period,0));
 }
 return("UNKNOWN");
}//string TFtoStr(int period) {


/*

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

           message =  StringConcatenate(WindowExpertName()," Alerts: ", Symbol(),timeFrameToString(Period())," ",TimeToStr(TimeLocal(),TIME_SECONDS),doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), WindowExpertName()),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

*/

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}