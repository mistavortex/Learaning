//https://forex-station.com/viewtopic.php?p=1295478806#p1295478806
//https://forex-station.com/viewtopic.php?p=1295478883#p1295478883
//+---------------------------------------------------+
//|                          Copyright © 2015-23      |
//|                      Custom Metatrader Systems.   |
//| http://forex.timezoneconverter.com/               |
//+---------------------------------------------------+
//https://forex-station.com/viewtopic.php?p=1295449961#p1295449961

#property copyright "Copyright © 2015-23"
#property link      "http://forex.timezoneconverter.com/"

#property indicator_chart_window

//------- Âíåøíèå ïàðàìåòðû èíäèêàòîðà -------------------------------
extern int    NumberOfDays = 15;         // Êîëè÷åñòâî äíåé
extern string AsiaBegin    = "2:00";   // including Sydney, Australia session
extern string AsiaEnd      = "3:00";   // start of London session
extern color  AsiaColor    = clrMidnightBlue; // Öâåò àçèàòñêîé ñåññèè
extern string EurBegin     = "9:30";   // including Frankfurt, Germany session
extern string EurEnd       = "11:00";   // Çàêðûòèå åâðîïåéñêîé ñåññèè
extern color  EurColor     = clrMidnightBlue;       // Öâåò åâðîïåéñêîé ñåññèè
extern string USABegin     = "15:00";   //14 Îòêðûòèå àìåðèêàíñêîé ñåññèè
extern string USAEnd       = "16:00";   // Çàêðûòèå àìåðèêàíñêîé ñåññèè
extern color  USAColor     = clrMidnightBlue;      // Öâåò àìåðèêàíñêîé ñåññèè
extern bool   ShowPrice    = false;      // Ïîêàçûâàòü öåíîâûå óðîâíè
extern color  clFont       = clrDimGray;      // Öâåò øðèôòà
extern int    SizeFont     = 7;         // Ðàçìåð øðèôòà
extern int    OffSet       = 10;        // Ñìåùåíèå

//Forex-Station button template start41; copy and paste
extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow         = 0;                 // What window to put the button on.  If <0, the button will use the same sub-window as the indicator.
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
input string              btn_text              = "BULLET";          // Display id
extern string             btn_Font              = "Arial";           // button font name
extern int                btn_FontSize          = 9;                 // btn__font size
extern color              btn_text_ON_color     = clrLime;           // ON color when the button is turned on
extern color              btn_text_OFF_color    = clrRed;            // OFF color when the button is turned off
extern color              btn_background_color  = clrDimGray;        // background color of the button
extern color              btn_border_color      = clrBlack;          // border color the button
extern int                button_x              = 10;                // Horizontal location
extern int                button_y              = 40;                // Vertical location
extern int                btn_Width             = 75;                // btn__width
extern int                btn_Height            = 20;                // btn__height
extern string             UniqueButtonID        = "SilverBullet3";   // Unique ID for each button        
extern string             button_note2          = "------------------------------";

bool show_data, recalc=false;
string IndicatorObjPrefix, buttonId;
//Forex-Station button template end41; copy and paste

string UniqueDeleteObjectID = "ICTsilverBullet3:";
//+------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   IndicatorDigits(Digits);
   IndicatorObjPrefix = "__" + btn_text + "__";
      
   // The leading "_" gives buttonId a *unique* prefix.  Furthermore, prepending the swin is usually unique unless >2+ of THIS indy are displayed in the SAME sub-window. (But, if >2 used, be sure to shift the buttonId position)
   buttonId = "_" + UniqueButtonID + IndicatorObjPrefix + "_BT_";
   if (ObjectFind(buttonId)<0) 
      createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);

   show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
   
   if (show_data) ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
   else ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);

   init2();

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
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
      // Upon creation, set the initial state to "true" which is "on", so one will see the indicator by default
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
}
//+------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason) 
{
   // This 'ObjectsDeleteAll' is only needed when any objects *besides* the button are created, but this indicator does not, hence, not needed.
   //ObjectsDeleteAll(0, IndicatorObjPrefix);

   // If just changing a TF', the button need not be deleted, therefore the 'OBJPROP_STATE' is also preserved.
   if (reason != REASON_CHARTCHANGE) 
      {
        ObjectDelete(buttonId);
        deinit2();
      }
   deinit2();
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // If another indy on the same chart has enabled events for create/delete/mouse-move, just skip this events up front because they aren't
   //    needed, AND in the worst case, this indy might cause MT4 to hang!!  Skipping the events seems to help, along with other (major) changes to the code below.
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DELETE) return; // This appears to make this indy compatible with other programs that enabled CHART_EVENT_OBJECT_CREATE and/or CHART_EVENT_OBJECT_DELETE
   if(id==CHARTEVENT_MOUSE_MOVE    || id==CHARTEVENT_MOUSE_WHEEL)   return; // If this, or another program, enabled mouse-events, these are not needed below, so skip it unless actually needed. 

   if (id==CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
   {
      show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
      
      if (show_data)
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
         // Is it a problem to call 'start()' ??  Possibly it makes no difference, but now calling "mystart()" instead of "start()"; and "start()" simply runs "mystart()", so should be same as before.
         init2();
         recalc=true;
         mystart();
      }
      else
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
         deinit2();
      }
   }

}
//+------------------------------------------------------------------------------------------------------------------+
int start() 
{
       return(mystart()); 
}
//+------------------------------------------------------------------------------------------------------------------+
int mystart()
  {
   if (show_data)
      {
        datetime dt=CurTime();

        if(recalc) 
        {
           // If a button goes from off-to-on, everything must be recalculated.  The 'recalc' variable is used as a trigger to do this.
           recalc=false;
        }

        for (int i=0; i<NumberOfDays; i++) 
           {
             if (ShowPrice && i==0) {
                 DrawPrices(dt, UniqueDeleteObjectID+"Bullet01", AsiaBegin, AsiaEnd);
                 DrawPrices(dt, UniqueDeleteObjectID+"Bullet02", EurBegin, EurEnd);
                 DrawPrices(dt, UniqueDeleteObjectID+"Bullet03", USABegin, USAEnd);
             }
             DrawObjects(dt, UniqueDeleteObjectID+"Bullet01"+i, AsiaBegin, AsiaEnd);
             DrawObjects(dt, UniqueDeleteObjectID+"Bullet02"+i, EurBegin, EurEnd);
             DrawObjects(dt, UniqueDeleteObjectID+"Bullet03"+i, USABegin, USAEnd);
             dt=decDateTradeDay(dt);
             while (TimeDayOfWeek(dt)<1 || TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
            }
       } //if (show_data)  
   return(0);
}
//+------------------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init2() {
  DeleteObjects();
  for (int i=0; i<NumberOfDays; i++) {
    CreateObjects(UniqueDeleteObjectID+"Bullet01"+i, AsiaColor);
    CreateObjects(UniqueDeleteObjectID+"Bullet02"+i, EurColor);
    CreateObjects(UniqueDeleteObjectID+"Bullet03"+i, USAColor);
  }
  return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit2() {
  DeleteObjects();
}

//+------------------------------------------------------------------+
//| Ñîçäàíèå îáúåêòîâ èíäèêàòîðà                                     |
//| Ïàðàìåòðû:                                                       |
//|   no - íàèìåíîâàíèå îáúåêòà                                      |
//|   cl - öâåò îáúåêòà                                              |
//+------------------------------------------------------------------+
void CreateObjects(string no, color cl) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, True);
}

//+------------------------------------------------------------------+
//| Óäàëåíèå îáúåêòîâ èíäèêàòîðà                                     |
//+------------------------------------------------------------------+
void DeleteObjects() {
  for (int i=0; i<NumberOfDays; i++) {
    ObjectDelete(UniqueDeleteObjectID+"Bullet01"+i);
    ObjectDelete(UniqueDeleteObjectID+"Bullet02"+i);
    ObjectDelete(UniqueDeleteObjectID+"Bullet03"+i);
  }
  ObjectDelete(UniqueDeleteObjectID+"Bullet01Up");
  ObjectDelete(UniqueDeleteObjectID+"Bullet01Dn");
  ObjectDelete(UniqueDeleteObjectID+"Bullet02Up");
  ObjectDelete(UniqueDeleteObjectID+"Bullet02Dn");
  ObjectDelete(UniqueDeleteObjectID+"Bullet03Up");
  ObjectDelete(UniqueDeleteObjectID+"Bullet03Dn");
}
//+------------------------------------------------------------------+
//| Ïðîðèñîâêà îáúåêòîâ íà ãðàôèêå                                   |
//| Ïàðàìåòðû:                                                       |
//|   dt - äàòà òîðãîâîãî äíÿ                                        |
//|   no - íàèìåíîâàíèå îáúåêòà                                      |
//|   tb - âðåìÿ íà÷àëà ñåññèè                                       |
//|   te - âðåìÿ îêîí÷àíèÿ ñåññèè                                    |
//+------------------------------------------------------------------+
void DrawObjects(datetime dt, string no, string tb, string te) {

      if(show_data)
      {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  ObjectSet(no, OBJPROP_TIME1 , t1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , t2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
      } //if (show_data)  
}

//+------------------------------------------------------------------+
//| Ïðîðèñîâêà öåíîâûõ ìåòîê íà ãðàôèêå                              |
//| Ïàðàìåòðû:                                                       |
//|   dt - äàòà òîðãîâîãî äíÿ                                        |
//|   no - íàèìåíîâàíèå îáúåêòà                                      |
//|   tb - âðåìÿ íà÷àëà ñåññèè                                       |
//|   te - âðåìÿ îêîí÷àíèÿ ñåññèè                                    |
//+------------------------------------------------------------------+
void DrawPrices(datetime dt, string no, string tb, string te) {
   if (show_data)
      {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];

  if (ObjectFind(no+"up")<0) ObjectCreate(no+"up", OBJ_TEXT, 0, 0,0);
  ObjectSet(no+"up", OBJPROP_TIME1   , t2);
  ObjectSet(no+"up", OBJPROP_PRICE1  , p1+(OffSet+SizeFont)*Point);
  ObjectSet(no+"up", OBJPROP_COLOR   , clFont);
  ObjectSet(no+"up", OBJPROP_FONTSIZE, SizeFont);
  ObjectSetText(no+"up", DoubleToStr(p1+Ask-Bid, Digits));

  if (ObjectFind(no+"dn")<0) ObjectCreate(no+"dn", OBJ_TEXT, 0, 0,0);
  ObjectSet(no+"dn", OBJPROP_TIME1   , t2);
  ObjectSet(no+"dn", OBJPROP_PRICE1  , p2-OffSet*Point);
  ObjectSet(no+"dn", OBJPROP_COLOR   , clFont);
  ObjectSet(no+"dn", OBJPROP_FONTSIZE, SizeFont);
  ObjectSetText(no+"dn", DoubleToStr(p2, Digits));
      } //if (show_data)  
}

//+------------------------------------------------------------------+
//| Óìåíüøåíèå äàòû íà îäèí òîðãîâûé äåíü                            |
//| Ïàðàìåòðû:                                                       |
//|   dt - äàòà òîðãîâîãî äíÿ                                        |
//+------------------------------------------------------------------+
datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
//+------------------------------------------------------------------+

