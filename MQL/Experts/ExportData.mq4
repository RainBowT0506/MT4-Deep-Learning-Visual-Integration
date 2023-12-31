//+------------------------------------------------------------------+
//|                                                   ExportData.mq4 |
//|                                            Copyright 2019,Jarvis |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Jarvis"
#property link      "https://www.mql5.com"
#property version   "1.00"

input int MATrendPeriod =10;
int handle;
string dSymbol;
string dSymbolName="SPX500";
double Poin;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(Point==0.00001)
     {

      Poin=0.0001;
        }else {
      if(Point==0.001)
        {
         Poin=0.01;
           }else{ Poin=Point;
        }
     }

   dSymbol=0;
   handle = FileOpen("Export_"+dSymbolName+"_"+Period()+".csv",FILE_BIN|FILE_WRITE);

   if(handle<1)
     {
      Print("Err ",GetLastError());
      return(0);
     }
   WriteHeader();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false)
     {
      SetLable("information","程式暫停",5,60,10,"Verdana",Red);
      return;
     }

   if(NewBar())
     {
      WriteDataRow(1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {

   static datetime LastTime=0;

   if(iTime(0,0,0)!=LastTime)
     {
      LastTime=iTime(0,0,0);
      return (true);
     }
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLable(string LableName,string LableDoc,int LableX,int LableY,
              int DocSize,string DocStyle,color DocColor)
  {
   ObjectCreate(LableName,OBJ_LABEL,0,0,0);
   ObjectSetText(LableName,LableDoc,DocSize,DocStyle,DocColor);
   ObjectSet(LableName,OBJPROP_XDISTANCE,LableX);
   ObjectSet(LableName,OBJPROP_YDISTANCE,LableY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteData(string txt)
  {

   FileWriteString(handle,txt,StringLen(txt));

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteHeader()
  {

   WriteData("Symbol,");
   WriteData("Date,");
   WriteData("DayOfWeek,");
   WriteData("DayOfYear,");
   WriteData("Open,");
   WriteData("High,");
   WriteData("Low,");
   WriteData("Close,");
   WriteData("MacdCurrent,MacdPrevious,SignalCurrent,SignalPrevious,MaCurrent,MaPrevious,");
   WriteData("\n");

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteDataRow(int i)
  {

   double  dTime,dOpen,dHigh,dLow,dClose,dVolume;
   int dDayofWk,dDayofYr,iDigits;
   dTime = (iTime(dSymbol,Period(),i));
   dDayofWk = (TimeDayOfWeek(dTime));
   dDayofYr = TimeDayOfYear(dTime);


   dOpen=(iOpen(dSymbol,Period(),i));


   if(dOpen>0)
     {
      WriteData(dSymbolName+",");
      WriteData(TimeToStr(dTime,TIME_DATE|TIME_MINUTES)+",");

      iDigits=MarketInfo(Symbol(),MODE_DIGITS);
      dOpen = (iOpen(dSymbol,Period(),i));
      dHigh = (iHigh(dSymbol,Period(),i));
      dLow=(iLow(dSymbol,Period(),i));
      dClose=(iClose(dSymbol,Period(),i));
      dVolume=(iVolume(dSymbol,Period(),i));

     
     
      double MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
      double MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      double SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
      double SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+1);
      double MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      double MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,i+1);

      WriteData(dDayofWk+","+dDayofYr+",");
      WriteData(DoubleToStr(dOpen,iDigits)+",");
      WriteData(DoubleToStr(dHigh,iDigits)+",");
      WriteData(DoubleToStr(dLow,iDigits)+",");
      WriteData(DoubleToStr(dClose,iDigits)+",");
      
      
      WriteData(DoubleToStr(MacdCurrent,iDigits)+",");
      WriteData(DoubleToStr(MacdPrevious,iDigits)+",");
      WriteData(DoubleToStr(SignalCurrent,iDigits)+",");
      WriteData(DoubleToStr(SignalPrevious,iDigits)+",");
      WriteData(DoubleToStr(MaCurrent,iDigits)+",");
      WriteData(DoubleToStr(MaPrevious,iDigits)+",");
      
     
      WriteData("\n");
     }

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetPeriodName()
  {

   switch(Period())
     {

      case PERIOD_D1:  return("Day");
      case PERIOD_H4:  return("4_Hour");
      case PERIOD_H1:  return("Hour");
      case PERIOD_M1:  return("Minute");
      case PERIOD_M15: return("15_Minute");
      case PERIOD_M30: return("30_Minute");
      case PERIOD_M5:  return("5_Minute");
      case PERIOD_MN1: return("Month");
      case PERIOD_W1:  return("Week");
     }
  }
//+------------------------------------------------------------------+
