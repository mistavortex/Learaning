
//+------------------------------------------------------------------+
//|                                          ORanges.mq4 
//|                                                         
//|   ++ modified so that rectangles do not overlay                  |
//|   ++ this makes color selection more versatile                   |
//|   ++ code consolidated                                           |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
 
extern int    NumberOfDays = 5;      
extern int    BorderWidth  =1;
extern bool   ExtendRay   =false;
extern bool   ExtendBack   =true;  

extern string note01 = "SWITCHED";
extern bool   Show_Midnight_Opening_Range   =true;
extern bool   Show_Opening_Range_1   =true;
extern bool   Show_Opening_Range_2   =true;

extern string note02 = "MIDNIGHT OPENING RANGE";
extern string periodBegin    = "06:00"; 
extern string periodEnd      = "06:30";   
extern string BoxEnd         = "23:00"; 
extern color  BoxHLColor         = clrOrange; 
extern color  BoxPeriodColor     = clrOrangeRed;

extern string note03 = "OPENING RANGE 1";
extern string periodBegin1   ="10:00";
extern string periodEnd1     ="10:30";
extern string BoxEnd1        ="23:59";
extern color  BoxHLColor1        =clrLimeGreen;
extern color  BoxPeriodColor1    =clrLime;

extern string note04 = "OPENING RANGE 2";
extern string periodBegin2   ="15:00";
extern string periodEnd2     ="15:30";
extern string BoxEnd2        ="23:59";
extern color  BoxHLColor2        =clrAqua;
extern color  BoxPeriodColor2    =clrDodgerBlue;

extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "ORanges";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                             //btn__font size
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 100;                                     //btn__x
extern int                button_y              = 40;                                     //btn__y
extern int                btn_Width             = 80;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1

//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------+
string buttonId;

int init()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

// put init() here
   
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "CloseButton";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   
   return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
}
//+------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

//put deinit() here
    ObjectsDeleteAll(0, StringConcatenate("OR"));

   return 0;
}
//+------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}
//+------------------------------------------------------------------+
int start()
{
   handleButtonClicks();
   recalc = false;

  datetime dtTradeDate=TimeCurrent();

  for (int i=0; i<NumberOfDays; i++) {
  
    if(Show_Midnight_Opening_Range) {
         DrawObjects(dtTradeDate, "OR_MIDNIGHT  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, periodEnd, BoxPeriodColor,4);
         DrawObjectsTrend(dtTradeDate, "OR_OPEN " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 1);
         DrawObjectsTrend(dtTradeDate, "OR_HIGH " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 2);
         DrawObjectsTrend(dtTradeDate, "OR_LOW  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 3);
      };
     if(Show_Opening_Range_1) {
         DrawObjects(dtTradeDate, "OR_EURO  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, periodEnd1, BoxPeriodColor1,4);
         DrawObjectsTrend(dtTradeDate, "OR_OPEN1 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, BoxEnd1, BoxHLColor1, 1);
         DrawObjectsTrend(dtTradeDate, "OR_HIGH1 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, BoxEnd1, BoxHLColor1, 2);
         DrawObjectsTrend(dtTradeDate, "OR_LOW1  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, BoxEnd1, BoxHLColor1, 3);
      };
     if(Show_Opening_Range_2) {
         DrawObjects(dtTradeDate, "OR_NY  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, periodEnd2, BoxPeriodColor2,4);
         DrawObjectsTrend(dtTradeDate, "OR_OPEN2 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, BoxEnd2, BoxHLColor2, 1);
         DrawObjectsTrend(dtTradeDate, "OR_HIGH2 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, BoxEnd2, BoxHLColor2, 2);
         DrawObjectsTrend(dtTradeDate, "OR_LOW2  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, BoxEnd2, BoxHLColor2, 3);
      };

    dtTradeDate=decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate) > 5) dtTradeDate = decrementTradeDate(dtTradeDate);

      if (show_data)
      {
      if(Show_Midnight_Opening_Range) {
         DrawObjects(dtTradeDate, "OR_MIDNIGHT  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, periodEnd, BoxPeriodColor,4);
         DrawObjectsTrend(dtTradeDate, "OR_OPEN " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 1);
         DrawObjectsTrend(dtTradeDate, "OR_HIGH " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 2);
         DrawObjectsTrend(dtTradeDate, "OR_LOW  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 3);
      };
      if(Show_Opening_Range_1) {
         DrawObjects(dtTradeDate, "OR_EURO  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, periodEnd1, BoxPeriodColor1,4);
         DrawObjectsTrend(dtTradeDate, "OR_OPEN1 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, BoxEnd1, BoxHLColor1, 1);
         DrawObjectsTrend(dtTradeDate, "OR_HIGH1 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, BoxEnd1, BoxHLColor1, 2);
         DrawObjectsTrend(dtTradeDate, "OR_LOW1  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin1, periodEnd1, BoxEnd1, BoxHLColor1, 3);
      };
      if(Show_Opening_Range_2) {
         DrawObjects(dtTradeDate, "OR_NY  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, periodEnd2, BoxPeriodColor2,4);
         DrawObjectsTrend(dtTradeDate, "OR_OPEN2 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, BoxEnd2, BoxHLColor2, 1);
         DrawObjectsTrend(dtTradeDate, "OR_HIGH2 " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, BoxEnd2, BoxHLColor2, 2);
         DrawObjectsTrend(dtTradeDate, "OR_LOW2  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin2, periodEnd2, BoxEnd2, BoxHLColor2, 3);
      };
      }
      else
      {
        ObjectsDeleteAll(0, StringConcatenate("OR"));
      }
   }
   return 0;
}
//+------------------------------------------------------------------+
//| Create Rectangles                                                |
//+------------------------------------------------------------------+

void DrawObjects(datetime dtTradeDate, string sObjName, string sTimeBegin, string sTimeEnd, string sTimeObjEnd, color cObjColor, int iForm) {
  datetime dtTimeBegin, dtTimeEnd, dtTimeObjEnd;
  double   dPriceHigh,  dPriceLow;
  int      iBarBegin,   iBarEnd;

  dtTimeBegin = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeBegin);
  dtTimeEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeEnd);
  dtTimeObjEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeObjEnd);
      
  iBarBegin = iBarShift(NULL, 0, dtTimeBegin);
  iBarEnd = iBarShift(NULL, 0, dtTimeEnd);
  dPriceHigh = High[Highest(NULL, 0, MODE_HIGH, iBarBegin-iBarEnd, iBarEnd)];
  dPriceLow = Low [Lowest (NULL, 0, MODE_LOW , iBarBegin-iBarEnd, iBarEnd)];
 
  ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
  
  ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
  ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
  
//---- High-Low Rectangle
   if(iForm==1){  
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);  
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }
   
//---- Upper Rectangle
  if(iForm==2){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }
 
 //---- Lower Rectangle 
  if(iForm==3){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceLow);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }

//---- Period Rectangle
  if(iForm==4){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, 2);
      ObjectSet(sObjName, OBJPROP_BACK, False);
   }   
      //string sObjDesc = StringConcatenate("High: ",dPriceHigh,"  Low: ", dPriceLow); 
      string sObjDesc = StringConcatenate(" OPENING RANGE ");  
      ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);
}
//+------------------------------------------------------------------+
//| Create Lines                                                     |
//+------------------------------------------------------------------+
  void DrawObjectsTrend(datetime dtTradeDate, string sObjName, string sTimeBegin, string sTimeEnd, string sTimeObjEnd, color cObjColor, int iForm) 
  {
   datetime dtTimeBegin, dtTimeEnd, dtTimeObjEnd;
   double   dPriceHigh,  dPriceLow;
   int      iBarBegin,   iBarEnd;
//----
   dtTimeBegin=StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeBegin);
   dtTimeEnd=StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeEnd);
   dtTimeObjEnd=StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeObjEnd);
//----
   iBarBegin=iBarShift(NULL, 0, dtTimeBegin);
   iBarEnd=iBarShift(NULL, 0, dtTimeEnd);
   dPriceHigh=High[Highest(NULL, 0, MODE_HIGH, iBarBegin-iBarEnd, iBarEnd)];
   dPriceLow=Low [Lowest (NULL, 0, MODE_LOW , iBarBegin-iBarEnd, iBarEnd)];
   double dPriceOpen=iOpen  (NULL, 0 , iBarBegin);
   double dPriceClose=iClose  (NULL, 0 , iBarEnd);
//----
   ObjectDelete    (ChartID(),sObjName);
   ObjectCreate(sObjName, OBJ_TRENDBYANGLE, 0, 0, 0, 0, 0);
   ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
   ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
//---- Period Rectangle OPEN
     if(iForm==1)
     {
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceOpen );
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceOpen );
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, BorderWidth);
      ObjectSet(sObjName, OBJPROP_BACK, ExtendBack);
      ObjectSet(sObjName, OBJPROP_RAY, ExtendRay);
      ObjectSet(sObjName, OBJPROP_SELECTABLE, False);
     }
     if(iForm==2)
     {
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh );
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceHigh );
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, BorderWidth);
      ObjectSet(sObjName, OBJPROP_BACK, ExtendBack);
      ObjectSet(sObjName, OBJPROP_RAY, ExtendRay);
      ObjectSet(sObjName, OBJPROP_SELECTABLE, False);
     }
     if(iForm==3)
     {
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceLow );
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow );
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, BorderWidth);
      ObjectSet(sObjName, OBJPROP_BACK, ExtendBack);
      ObjectSet(sObjName, OBJPROP_RAY, ExtendRay);
      ObjectSet(sObjName, OBJPROP_SELECTABLE, False);
     }
     if(iForm==4)
     {
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh );
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow );
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, BorderWidth);
      ObjectSet(sObjName, OBJPROP_BACK, ExtendBack);
      ObjectSet(sObjName, OBJPROP_RAY, ExtendRay);
      ObjectSet(sObjName, OBJPROP_SELECTABLE, False);
     }
  }

//+------------------------------------------------------------------+
//| Decrement Date to draw objects in the past                       |
//+------------------------------------------------------------------+

datetime decrementTradeDate (datetime dtTimeDate) {
   int iTimeYear=TimeYear(dtTimeDate);
   int iTimeMonth=TimeMonth(dtTimeDate);
   int iTimeDay=TimeDay(dtTimeDate);
   int iTimeHour=TimeHour(dtTimeDate);
   int iTimeMinute=TimeMinute(dtTimeDate);

   iTimeDay--;
   if (iTimeDay==0) {
     iTimeMonth--;
     if (iTimeMonth==0) {
       iTimeYear--;
       iTimeMonth=12;
     }
    
     // Thirty days hath September...  
     if (iTimeMonth==4 || iTimeMonth==6 || iTimeMonth==9 || iTimeMonth==11) iTimeDay=30;
     // ...all the rest have thirty-one...
     if (iTimeMonth==1 || iTimeMonth==3 || iTimeMonth==5 || iTimeMonth==7 || iTimeMonth==8 || iTimeMonth==10 || iTimeMonth==12) iTimeDay=31;
     // ...except...
     if (iTimeMonth==2) if (MathMod(iTimeYear, 4)==0) iTimeDay=29; else iTimeDay=28;
   }
  return(StrToTime(iTimeYear + "." + iTimeMonth + "." + iTimeDay + " " + iTimeHour + ":" + iTimeMinute));
}
//+------------------------------------------------------------------+
