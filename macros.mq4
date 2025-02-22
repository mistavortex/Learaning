//|  This custom indicator  should draw rectangles representing the       |
//|  highest and lowest prices during a specific period. The period  |
//|  starts at 10 minutes to the end of every hour (i.e. :50) and      |
//|  lasts for 20 minutes (ending at 10 minutes past the hour, i.e. :10).|
//|  Add 1 vertical line style dash at the begining  and a 2nd vertical line style dot dash dash at the end
//|  and ensure that the indicator plots all bects in real time.
//|  All objects created by the indicator are cleaned up on deinit.  |



//+------------------------------------------------------------------+
//|                                                  Macros.mq4 
//|                                                         
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window

 int Hour_Num = 23;
 int Minute_Num = 50;
 int Minute_Num1 = 10;
extern color Line_Color = Navy;
extern color Line_Color1 = Maroon;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
   int ObjectCount = ObjectsTotal();
   for (int i=ObjectCount-1; i>=0; i--)
   {
      if(StringFind(ObjectName(i),"Macro_Begins-") != -1)
      {
         ObjectDelete(ObjectName(i));
      }  
      if(StringFind(ObjectName(i),"Macro_Ends-") != -1)
      {
         ObjectDelete(ObjectName(i));
      }
   }
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int Counted_bars=IndicatorCounted(); // Number of counted bars   
   int i=Bars-Counted_bars-1;           // Index of the first uncounted   
   
   while(i>=0)                      // Loop for uncounted bars     
   {  
      if(TimeHour(Time[i]) <= Hour_Num && TimeMinute(Time[i]) == Minute_Num )
      {
         if (ObjectFind("Macro_Begins-"+Time[i]) != 0)
         {
            ObjectCreate( "Macro_Begins-"+Time[i], OBJ_VLINE, 0, Time[i], 0 );
            ObjectSet( "Macro_Begins-"+Time[i], OBJPROP_COLOR, Line_Color );
            ObjectSet( "Macro_Begins-"+Time[i], OBJPROP_STYLE, 3 );
            ObjectSet("Macro_Begins-"+Time[i], OBJPROP_SELECTABLE, False);
         }
      }
      if(TimeHour(Time[i]) <= Hour_Num && TimeMinute(Time[i]) == Minute_Num1 )
      {
         if (ObjectFind("Macro_Ends-"+Time[i]) != 0)
         {
            ObjectCreate( "Macro_Ends-"+Time[i], OBJ_VLINE, 0, Time[i], 0 );
            ObjectSet( "Macro_Ends-"+Time[i], OBJPROP_COLOR, Line_Color1 );
            ObjectSet( "Macro_Ends-"+Time[i], OBJPROP_STYLE, 2 );
            ObjectSet("Macro_Ends-"+Time[i], OBJPROP_SELECTABLE, False);
         }
      }
      
      i--;
   }
//----
   return(0);
}
//+------------------------------------------------------------------+