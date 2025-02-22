#property description                             "[_mtf_Patternity_01]"
#define Version                                     "[1.00]"
//+------------------------------------------------------------------------------------------------------------------+
#property description "THIS IS A GREAT INDICATOR"
#property description "                                                      "
#property version       "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
extern string Indicator=Version;
//+------------------------------------------------------------------------------------------------------------------+
extern ENUM_TIMEFRAMES    TF_find               = PERIOD_M5;   
extern string             note1                 = "------------------------------";
extern int                arrows = 81;           // Wingdings UPPER\LOWER LINES default=251
extern int                arrowsMid = 158;           // Wingdings MIDLINE
extern color              UpperLineColor        = C'246,103,83';
extern color              MiddleLineColor       = clrMagenta;
extern int                UpperLineWidth        = 0;
extern int                MiddleLineWidth       = 0;
extern string             note0                 = "------------------------------";
extern bool  showGap = true;
extern bool  showInvGap = false;
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
input string              DisplayID             = "B.Pat01 ";              // Display id
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                // btn__font size
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 105;               // Horizontal location
extern int                button_y              = 65;                // Vertical location
extern int                btn_Width             = 80;                // btn__width
extern int                btn_Height            = 20;                // btn__height
extern string             button_note2          = "------------------------------";

bool showInsideBar=true;
double HighBuff[],LowBuff[],MidBuff[],LastHigh,LastLow; int length=5,len=0,Type;
int LowerLineWidth = UpperLineWidth;
color LowerLineColor = UpperLineColor;
//+------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
  if (ObjectFind(DisplayID)!=0)
  {
         
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_STATE,true);
  }
         ObjectCreate    (ChartID(),DisplayID,OBJ_BUTTON,0,0,0);
         ObjectSetString (ChartID(),DisplayID,OBJPROP_TEXT,DisplayID);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_FONTSIZE,btn_FontSize);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_CORNER,btn_corner);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_COLOR,btn_text_color);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_BGCOLOR,btn_background_color);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_YDISTANCE,button_y);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_XDISTANCE,button_x);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_XSIZE,btn_Width);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_YSIZE,btn_Height);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(ChartID(),DisplayID,OBJPROP_HIDDEN,true);
         
   if(TF_find==PERIOD_CURRENT) TF_find=(ENUM_TIMEFRAMES)_Period;
   if(Period()==PERIOD_H4){TF_find=PERIOD_H4;}
   if(Period()==PERIOD_D1){TF_find=PERIOD_D1;}
   LoadHist(); 
   if(showInsideBar)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   if(Period()>PERIOD_D1) {Type=DRAW_NONE;}

   SetIndexBuffer(0,HighBuff); 
   SetIndexBuffer(1,LowBuff);  
   SetIndexBuffer(2,MidBuff);  
   SetIndexArrow(0, arrows); 
   SetIndexArrow(1, arrows);  
   SetIndexArrow(2, arrowsMid);
   IndicatorShortName("_mtf_Patternity_01 ("+TFtoStr(TF_find)+")");   
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   ArrayInitialize(HighBuff,EMPTY_VALUE); 
   ArrayInitialize(LowBuff,EMPTY_VALUE);
   IndicatorDigits(_Digits);  
    
  if (GetButtonState(DisplayID)!="off")
  {
   SetIndexStyle(0,Type,0,UpperLineWidth,UpperLineColor);
   SetIndexStyle(1,Type,0,LowerLineWidth,LowerLineColor);
   SetIndexStyle(2,Type,1,MiddleLineWidth,MiddleLineColor);
   ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, clrLime); // set button color
   ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, clrDarkGreen); // set button color
  }
  else for (int banzai=0; banzai<3; banzai++) 
  {
  SetIndexStyle(banzai,DRAW_NONE);
  ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, btn_text_color); // Reset button color
  ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, btn_background_color); // Reset button color
  }
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{ 
      switch(reason)
      {
         case REASON_PARAMETERS  :
         case REASON_CHARTCHANGE :
         case REASON_RECOMPILE   :
         case REASON_CLOSE       : break;
         default :
         {
            ObjectDelete(DisplayID);
         }                  
      }
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   static string prevState ="";
   if (id==CHARTEVENT_OBJECT_CLICK && sparam==DisplayID)
   {
      string newState = GetButtonState(DisplayID);
         if (newState!=prevState)
         if (newState=="off")
                  { 
                    for (int banzai=0; banzai<3; banzai++) SetIndexStyle(banzai,DRAW_NONE);
                    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, btn_text_color); // Reset button color
                    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, btn_background_color); // Reset button color
                    prevState=newState; 
                  }
            else  { 
                    SetIndexStyle(0,Type,0,UpperLineWidth,UpperLineColor);
                    SetIndexStyle(1,Type,0,LowerLineWidth,LowerLineColor);
                    SetIndexStyle(2,Type,1,MiddleLineWidth,MiddleLineColor);
                    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_COLOR, clrLime); // set button color
                    ObjectSetInteger(ChartID(), DisplayID, OBJPROP_BGCOLOR, clrDarkGreen); // set button color
                    prevState=newState; 
                  }
            ObjectSetString(ChartID(),DisplayID,OBJPROP_TEXT,DisplayID);
   }
}  
//+------------------------------------------------------------------------------------------------------------------+
int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (rates_total-prev_calculated<=0) return(0);
//+------------------------------------------------------------------------------------------------------------------+
   int limit=1;  if (prev_calculated==0 || rates_total-prev_calculated>1){
      ArrayInitialize(HighBuff,EMPTY_VALUE); 
      ArrayInitialize(LowBuff,EMPTY_VALUE);
       limit=iBars(_Symbol,TF_find)-2;}
//+-----      
   for(int i=limit; i>=1; i--){
     datetime time1=iTime(_Symbol,TF_find,i);
     datetime time2=time1+PeriodSeconds(TF_find);
   int bar_now=iBarShift(_Symbol,_Period,time1,false);
   
   int one = i, two = i + 1, three = i + 2, four = i + 3, five = i + 4, six = i + 5, seven = i + 6, eight = i + 7;
        double O1 = iOpen(_Symbol, TF_find, one), O2 = iOpen(_Symbol, TF_find, two), O3 = iOpen(_Symbol, TF_find, three);
        double H1 = iHigh(_Symbol, TF_find, one), H2 = iHigh(_Symbol, TF_find, two), H3 = iHigh(_Symbol, TF_find, three);
        double L1 = iLow(_Symbol, TF_find, one), L2 = iLow(_Symbol, TF_find, two), L3 = iLow(_Symbol, TF_find, three);
        double C1 = iClose(_Symbol, TF_find, one), C2 = iClose(_Symbol, TF_find, two), C3 = iClose(_Symbol, TF_find, three);
        
        double min_O1C1 = MathMin(O1, C1), min_O2C2 = MathMin(O2, C2), min_O3C3 = MathMin(O3, C3);
        double max_O1C1 = MathMax(O1, C1), max_O2C2 = MathMax(O2, C2), max_O3C3 = MathMax(O3, C3);
        double min_L1L2 = MathMin(L1, L2), min_L1L3 = MathMin(L1, L3), min_L2L3 = MathMin(L2, L3); 
        double min_H1H2 = MathMin(H1, H2), min_H1H3 = MathMin(H1, H3), min_H2H3 = MathMin(H2, H3);
        double max_L1L2 = MathMax(L1, L2), max_L1L3 = MathMax(L1, L3), max_L2L3 = MathMax(L2, L3);
        double max_H1H2 = MathMax(H1, H2), max_H1H3 = MathMax(H1, H3), max_H2H3 = MathMax(H2, H3);
        
        double maxOfMin_OC12 = MathMax(min_O1C1, min_O2C2);
        double minOfMax_OC12 = MathMin(max_O1C1, max_O2C2);
        double minOfMin_OC12 = MathMin(min_O1C1, min_O2C2);
        double maxOfMax_OC12 = MathMax(max_O1C1, max_O2C2);
        
        bool  isPatternDetected_OC12 = (maxOfMin_OC12 > minOfMax_OC12);
        bool  isInvPatternDetected_OC12 = (maxOfMin_OC12 < minOfMax_OC12);
        
   bool barSizeIsGood = iHigh(_Symbol,TF_find,i)-iLow(_Symbol,TF_find,i)>_Point/2;
   
//+-----Find Pattern
   if( barSizeIsGood){
   
       if(L1 > H3 &&  max_L2L3 < min_O2C2 && max_L2L3 < min_O3C3){
         LastHigh = L1; 
         LastLow = H3; 
         HighBuff[bar_now] = LastHigh;
         LowBuff[bar_now] = LastLow;
         MidBuff[bar_now] = (LastHigh+LastLow)/2;
         len=1;}
       if(H1 < L3  && min_H2H3 > max_O2C2 && min_H2H3 > max_O3C3){
         LastHigh = L3; 
         LastLow = H1; 
         HighBuff[bar_now] = LastHigh;
         LowBuff[bar_now] = LastLow;
         MidBuff[bar_now] = (LastHigh+LastLow)/2;
         len=1;}
       else 
            {
               HighBuff[bar_now] = LastHigh;
               LowBuff[bar_now] = LastLow;
               MidBuff[bar_now] = (LastHigh+LastLow)/2;
               len = 1;
            }
      
//+----- Clear buffer values if conditions are met      
   if(bar_now<rates_total-3 && 
      ((HighBuff[bar_now+1]!=LastHigh && HighBuff[bar_now+2]!=EMPTY_VALUE) ||
       (LowBuff[bar_now+1]!=LastLow && LowBuff[bar_now+2]!=EMPTY_VALUE))){
        HighBuff[bar_now+1] = EMPTY_VALUE;
         LowBuff[bar_now+1] = EMPTY_VALUE;}
         
//+----- Update buffer values within the specified time range and     
//+----- Replicate buffer values until a new pattern is found  
   while (bar_now<rates_total-2 && time[bar_now]>=time1 && time[bar_now]<time2){
      HighBuff[bar_now] = LastHigh;
       LowBuff[bar_now] = LastLow; bar_now--;
       MidBuff[bar_now]=(HighBuff[bar_now]+LowBuff[bar_now])/2;}} else {
   if(len>0 && len<length){while (bar_now<rates_total-2 && time[bar_now]>=time1 && time[bar_now]<time2){
      HighBuff[bar_now] = HighBuff[bar_now+1];
       LowBuff[bar_now] = LowBuff[bar_now+1]; 
       MidBuff[bar_now]=(HighBuff[bar_now]+LowBuff[bar_now])/2; bar_now--;}  len++;} else 
   if(len>length){len=0;
      HighBuff[bar_now] = EMPTY_VALUE;
       LowBuff[bar_now] = EMPTY_VALUE;
       MidBuff[bar_now]=(HighBuff[bar_now]+LowBuff[bar_now])/2;}}}  return(rates_total);}
//+------------------------------------------------------------------------------------------------------------------+
   string TFtoStr(int n){if(n==0)n=Period(); switch(n){
      case PERIOD_M1:  return ("M1");
      case PERIOD_M5:  return ("M5");
      case PERIOD_M15: return ("M15");
      case PERIOD_M30: return ("M30");
      case PERIOD_H1:  return ("H1");
      case PERIOD_H4:  return ("H4");
      case PERIOD_D1:  return ("D1");
      case PERIOD_W1:  return ("W1");
      case PERIOD_MN1: return ("MN1");}  return("TF?");}
//+------------------------------------------------------------------------------------------------------------------+
   void LoadHist(){int iPeriod[2];
   iPeriod[0]=TF_find;  iPeriod[1]=_Period;
   for(int i=0;i<2;i++){datetime open = iTime(_Symbol,iPeriod[i],0);
   int error=GetLastError(); while(error==4066){Comment("Loading history "+TFtoStr(iPeriod[i]));
      Sleep(1000); open = iTime(_Symbol,iPeriod[i],0); error=GetLastError();} Comment("");}}
//+------------------------------------------------------------------------------------------------------------------+
string GetButtonState(string whichbutton)
{
      bool selected = ObjectGetInteger(ChartID(),whichbutton,OBJPROP_STATE);
      if (selected)
           { return ("on"); } 
      else { return ("off");}
}
//+------------------------------------------------------------------------------------------------------------------+
