//+-----------------------------------------------------------+
//| MT4 CUSTOM INDICATOR                   _Z1.MQ4  
//| 
//+-----------------------------------------------------------+

#property copyright ""
#property link      ""
#property strict
#define INDICATOR_VERSION    2025
#define INDICATOR_NAME       ""
#define RELEASE_LEVEL        ""
#define MT4_BUILD            ""

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  DodgerBlue   // BuyLine
#property indicator_color2  OrangeRed    // SellLine
#property indicator_color3  DodgerBlue   // BullCandle
#property indicator_color4  OrangeRed    // BearCandle
#property indicator_color5  DodgerBlue   // BlueDot
#property indicator_color6  OrangeRed    // RedDot
#property indicator_width1  1            // BuyLine
#property indicator_width2  1            // SellLine
#property indicator_width3  12            // BullCandle
#property indicator_width4  12            // BearCandle
#property indicator_width5  1            // BlueDot
#property indicator_width6  1            // RedDot

extern string Notes           = "BETA TEST";

extern bool   ShowBears       = True;
extern bool   ShowBulls       = True;
extern bool   ShowStatus      = True;
extern bool   ShowDots        = True;
extern bool   VolFilter       = False;
extern int    VolMaFast       = 12;
extern int    VolMaSlow       = 24;
extern int    swingDeterminer = 34; // How many bars to scan for highest or lowest price.

bool   TestMode        = false;

// indicator buffers
double BuyLine[];
double SellLine[];
double BullCandle[];
double BearCandle[];
double BlueDot[];
double RedDot[];

int     signal;
#define NOSIG   0
#define BUYSIG  10
#define SELLSIG 20

datetime signaltime, redrawtime, upperpeaktime, lowerpeaktime;
double   signalprice, upperpeak, lowerpeak, prevupperpeak, prevlowerpeak;
double   volmafast1, volmaslow1;
double vol[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
{
SetIndexStyle(0,DRAW_LINE);
SetIndexStyle(1,DRAW_LINE);
SetIndexStyle(2,DRAW_HISTOGRAM);
SetIndexStyle(3,DRAW_HISTOGRAM);
SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,159); // BullDot (WingDings character)
SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,159); // BearDot (WingDings character)

SetIndexBuffer(0,BuyLine);
SetIndexBuffer(1,SellLine);
SetIndexBuffer(2,BullCandle);
SetIndexBuffer(3,BearCandle);
SetIndexBuffer(4,BlueDot);
SetIndexBuffer(5,RedDot);
if(VolFilter == True)
{
   SetIndexBuffer(6,vol,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(vol,True);
}
SetIndexEmptyValue(0,EMPTY_VALUE);
SetIndexEmptyValue(1,EMPTY_VALUE);
SetIndexEmptyValue(2,EMPTY_VALUE);
SetIndexEmptyValue(3,EMPTY_VALUE);
SetIndexEmptyValue(4,EMPTY_VALUE);
SetIndexEmptyValue(5,EMPTY_VALUE);
SetIndexLabel(0,"BuyLine");
SetIndexLabel(1,"SellLine");
SetIndexLabel(2,"");
SetIndexLabel(3,"");
SetIndexLabel(4,"");
SetIndexLabel(5,"");
IndicatorShortName(INDICATOR_NAME);
IndicatorDigits(Digits);

   return(INIT_SUCCEEDED);
} // end of init()

//+------------------------------------------------------------------+
//| Status Message prints below OHLC upper left of chart window
//+------------------------------------------------------------------+
void StatusMessage()
   {
   if(IsTesting() == True) return; // do no more
   if(ShowStatus == false) return; // do no more

   double move, pullback;
   double multi = MathPow(10,Digits-1);
   double dayhigh = iHigh(NULL,PERIOD_D1,0);
   double daylow = iLow(NULL,PERIOD_D1,0);
   double atr = iATR(NULL,PERIOD_D1,20,1); // yesterday's ATR(20)
   double range = dayhigh - daylow;
   double ratio = range / atr;
   double volratio = MathMax(Volume[1],Volume[0]) / MathMax(Volume[2],Volume[1]);
   string msg = INDICATOR_NAME+"  "+TimeToStr(TimeCurrent(),TIME_MINUTES)+"  ";
   if(signalprice == BuyLine[0])
      {
      msg = msg + "BUY "+ TimeToStr(signaltime,TIME_MINUTES)+" "+DoubleToStr(signalprice,Digits)+" ";
      move = High[iHighest(NULL,0,MODE_HIGH,iBarShift(NULL,0,signaltime)+1,0)]-signalprice;
      pullback = signalprice-Low[iLowest(NULL,0,MODE_LOW,iBarShift(NULL,0,signaltime)+1,0)];
      msg = msg + "+"+DoubleToStr(move*multi,1)+" -"+DoubleToStr(pullback*multi,1)+"  ";
      }
   if(signalprice == SellLine[0])
      {
      msg = msg + "SELL "+ TimeToStr(signaltime,TIME_MINUTES)+" "+DoubleToStr(signalprice,Digits)+" ";
      move = signalprice-Low[iLowest(NULL,0,MODE_LOW,iBarShift(NULL,0,signaltime)+1,0)];
      pullback = High[iHighest(NULL,0,MODE_HIGH,iBarShift(NULL,0,signaltime)+1,0)]-signalprice;
      msg = msg + "+"+DoubleToStr(move*multi,1)+" -"+DoubleToStr(pullback*multi,1)+"  ";
      }
   msg = msg + "DR="+DoubleToStr(range*multi,1)+"  ";
   msg = msg + "ADR="+DoubleToStr(atr*multi,1)+"  ";
   msg = msg + "Ratio="+DoubleToStr(ratio,2)+"  ";
   msg = msg + "Vol="+DoubleToStr(volratio,2)+"  ";
   msg = msg + "Spread="+DoubleToStr((Ask-Bid)*multi,1)+"  ";
   Comment(msg);
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[]
                )

{

   double range1, mid1, midlow1, midhigh1, nearlow1, nearhigh1;
   double range2, mid2, midlow2, midhigh2, nearlow2, nearhigh2;
   bool SIBI, BISI;
   int limit;

   int max = MathMax(VolMaFast,VolMaSlow);
   if (rates_total<max) return(prev_calculated);
   if(prev_calculated==0)
   {
      limit= rates_total - prev_calculated - max -1;
   }
   else limit= rates_total - prev_calculated;
   
   if (limit>0) limit--;
 
///////////////////
// LOAD ARRAYS
if(redrawtime != Time[1])

   {

   if(VolFilter == True) // load vol[] array
   {
      for(int shift = limit; shift >=0; shift--)
      {
         vol[shift] = (double)Volume[shift]; 
      }
      
   }
   redrawtime = Time[1]; // remember this time
   } // end of else

///////////////////
// MAIN LOOP
// shift value is set in two places (above)
   for(int shift = limit; shift >=0; shift--)
   {

   if(VolFilter == True)
      {
      volmafast1 = NormalizeDouble(iMAOnArray(vol,0,VolMaFast,0,MODE_SMA,shift+1),0);
      volmaslow1 = NormalizeDouble(iMAOnArray(vol,0,VolMaSlow,0,MODE_SMA,shift+1),0);
      }
   if(iHighest(NULL,0,MODE_HIGH,swingDeterminer,shift) == shift+1)
      {prevupperpeak = upperpeak; upperpeak = High[shift+1]; upperpeaktime = Time[shift+1]; signal = NOSIG;}
   if(iLowest(NULL,0,MODE_LOW,swingDeterminer,shift) == shift+1)
      {prevlowerpeak = lowerpeak; lowerpeak = Low[shift+1]; lowerpeaktime = Time[shift+1]; signal = NOSIG;}
   //////////////////
   // SIGNALS NEW
   if(prevupperpeak == prevlowerpeak)
      { signal = NOSIG;}
   if(High[shift]<Low[shift+2])
      { SIBI = true;
         range2 = Low[shift+2]-High[shift];
         mid2 = (Low[shift+2]-High[shift])/2;        
      }else SIBI = false;
   if(Low[shift] > High[shift+2])
      { BISI = true;
         range1 = Low[shift]-High[shift+2];
         mid1 = (Low[shift]-High[shift+2])/2;
      }else BISI = false;
      
   ///////////////////
   // SHOW DOTS
   if(ShowDots == True)
      {
      BlueDot[shift+1] = EMPTY_VALUE;
      RedDot[shift+1] = EMPTY_VALUE;
      RedDot[iBarShift(NULL,0,upperpeaktime)] = upperpeak+10*Point;
      BlueDot[iBarShift(NULL,0,lowerpeaktime)] = lowerpeak-10*Point;
      }
   
   ///////////////////
   // BEARISH SIGNAL
   if(ShowBears == True)
   //if(signal != SELLSIG)
   if(SIBI)
   //if(upperpeaktime > Time[shift+8])       // allows three candles only after the peak
   //if(Low[shift] < Low[shift+1]-5*Point)   // current candle breaks the signal candle low
   //if(Low[shift+1] < Low[shift+2]-5*Point) // signal candle breaks the prev candle low
   //if(VolFilter == false || Volume[shift+1] > Volume[shift+2]) // signal bar must have greater volume than previous bar
      {
      BearCandle[shift+1] = Low[shift+2]; BullCandle[shift+1] = High[shift];
      SellLine[shift+1] = High[shift];
      SellLine[shift+2] = EMPTY_VALUE;
      BuyLine[shift+1] = Low[shift+2];
      BuyLine[shift+2] = EMPTY_VALUE;
      signal = SELLSIG;
      signalprice = SellLine[shift+1];
      signaltime = Time[shift];
      }
   
   ///////////////////
   // BULLISH SIGNAL
   if(ShowBulls == True)
   //if(signal != BUYSIG)
   if(BISI)
   //if(lowerpeaktime > Time[shift+8])         // allows three candles only after the peak
   //if(High[shift] > High[shift+1]+5*Point)   // current candle breaks the signal candle high
   //if(High[shift+1] > High[shift+2]+5*Point) // signal candle breaks the prev candle high   
      {
      BearCandle[shift+1] = High[shift+2]; BullCandle[shift+1] = Low[shift];
      BuyLine[shift+1] = Low[shift];
      BuyLine[shift+2] = EMPTY_VALUE;
      SellLine[shift+1] = High[shift+2];
      SellLine[shift+2] = EMPTY_VALUE;
      signal = BUYSIG;
      signalprice = BuyLine[shift+1];
      signaltime = Time[shift];     
      }

   ///////////////////
   // CONTINUE LINES Replicate Signal Lines
   SellLine[shift] = SellLine[shift+1];
   BuyLine[shift] = BuyLine[shift+1];

   //////////////////////////
   // TESTMODE CODE BLOCK
   if(TestMode == True)
      {

      }

   } // end of while()

StatusMessage(); // update the status display
return(rates_total);
}// end of start()

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
// cleanup display buffers
for(int i=0; i<Bars; i++)
   {
   BuyLine[i] = EMPTY_VALUE;
   SellLine[i] = EMPTY_VALUE;
   BullCandle[i] = EMPTY_VALUE;
   BearCandle[i] = EMPTY_VALUE;
   BlueDot[i] = EMPTY_VALUE;
   RedDot[i] = EMPTY_VALUE;
   }
Comment("");   // clear the status display
}// end of deinit()


