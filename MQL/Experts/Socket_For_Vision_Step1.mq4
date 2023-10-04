//+------------------------------------------------------------------+
//|                                              Socket_Template.mq4 |
//|                                            Copyright 2019,Jarvis |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Jarvis"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//載入套件
#include <socket.mqh>
#import "stdlib.ex4"
string ErrorDescription(int e);
#import

//定義變數
input ushort server_port=5555;
input string server_ip="127.0.0.1";
int server_socket=INVALID_SOCKET;
int msg_socket=INVALID_SOCKET;

#define  ShortName  "Socket_Template"
extern int MagicNumber=20190730;
extern int Slippage=2;
int handle;
string dSymbol;
string dSymbolName="GLD";
double Poin;


//--- chart window size
long x_distance;
long y_distance;
//初始化
int OnInit()
  {

  // ChartApplyTemplate(0,"Vision.tpl");
   ChartRedraw();
//--- Set the shift of the right edge of the chart
   ChartSetInteger(0,CHART_SHIFT,true);

//---
   Print("Preparation of the Expert Advisor is completed");

//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return(INIT_FAILED);
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart height! Error code = ",GetLastError());
      return(INIT_FAILED);
     }

//建立Socket的服務
   server_socket=sock_connect(server_ip,server_port);

   if(server_socket==INVALID_SOCKET)
     {
      //如果連不上就回傳錯誤代碼
      return(INIT_FAILED);
     }
   
   //設定輸出資料  
   dSymbol=0;
   handle = FileOpen("Export_"+dSymbolName+"_"+Period()+".csv",FILE_BIN|FILE_WRITE);

   if(handle<1)
     {
      Print("Err ",GetLastError());
      return(0);
     }
   WriteHeader();

   return(INIT_SUCCEEDED);
  }
//程式結束
void OnDeinit(const int reason)
  {
//結束時一定要關掉Socket，這樣MT4才不會凍結不會動
   sock_close(server_socket);
   sock_cleanup();
   FileClose(handle);
  }
//每一次Tick跳動的事件
void OnTick()
  {

   if(NewBar())
     {//確認是否有新的Bar出現
      ObjectsDeleteAll(0,OBJ_TREND);
      ObjectsDeleteAll(0,OBJ_HLINE);
      if(ChartScreenShot(0,GetName(),x_distance,y_distance,ALIGN_CENTER))
        {
         Print("Saved the screenshot ",GetName());

         Sleep(200);

        }

      //Socket送出訊息
      Send_Message();


     }

   if(IsStopped())
     {
      Print("Client closed connection.");
      ExpertRemove();
      return; // return as export remove doesn't immediately terminate
     }

  }
//自定義的Function
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
//轉換JSON格式
string json_string_key_value(string key,string value) 
  {
   return (StringConcatenate( "\"", key, "\"" , " : ", "\"", value , "\"" ));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string json_double_key_value(string key,double value) 
  {
   return (StringConcatenate( "\"", key, "\"" , " : ", DoubleToStr( value, 5) ));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string json_integer_key_value(string key,int value) 
  {
   return (StringConcatenate( "\"", key, "\"" , " : ", value) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetName()
  {

   return string(Symbol())+ ".png";
  }
//未來要調整只要改這邊
string getStatusByJson()
  {

   int history_length=30;
   int init_index=30;

   string body="";

   body=StringConcatenate(body,"{");

   body=StringConcatenate(body,json_string_key_value("msg","Hello World"));//特別要注意這個裡少一個點，在JSON的開頭，不能有多那個點。
   body=StringConcatenate(body,", ",json_string_key_value("Symbol",string(Symbol())));

   body=StringConcatenate(body,", ",json_string_key_value("Back","1"));


   body=StringConcatenate(body,"}");

   return body;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Send_Message()
  {

   string bid_string=getStatusByJson();
// Print("Sending: ",bid_string);

//將JSON的資訊送到Server
   sock_send(server_socket,bid_string);

//因為是阻塞式，所以這邊會卡住，等到有回應才會往下，但如果是斷線就直接中斷
   string resp=sock_receive(server_socket);
   if(StringLen(resp)==0)
     {

      Print("Client closed connection.");
      ExpertRemove();
     }
   else
     {
      Print("接收到的資料: ",resp);//resp可自行定義參數，建議單純回傳整數代碼
      int var1= 3;
      var1=StrToInteger(resp);
     
    
      

      //Event_Handle(var1);//應用代碼
      WriteDataRow(1,var1);//寫入資料以及視覺模型的判斷資料
     }

  }
//調整對應的事件處理
void Event_Handle(int status){

   switch(status)
     {
      case  1:
        //sell
        Print("Sell");
        CloseOrderByType(OP_BUY);
        if(OrdersTotal()==0)
          {
           OpenOrder(OP_SELL,0.1,300,1000);
          }
        
        break;
      case 0:
        //buy
        CloseOrderByType(OP_SELL);
         if(OrdersTotal()==0)
          {
         OpenOrder(OP_BUY,0.1,300,1000);
         }
        break;
      case  2:
        //wait
        break;
      default:
        break;
     }


}

//_OrderType 表示單子的種類
//_Lots 口數
//_LossStop 止損
//_TakeProfit 獲利
void OpenOrder(int _OrderType,double _Lots,int _LossStop,int _TakeProfit)
  {
   int _Spread=MarketInfo(Symbol(),MODE_SPREAD);//獲取市場滑點
   double BuyLossStop=Ask-_LossStop*Point;
   double BuyTakeProfit=Ask+_TakeProfit*Point;
   double SellLossStop=Bid+_LossStop*Point;
   double SellTakeProfit=Bid-_TakeProfit*Point;
   if(_LossStop<=0)//如果止損參數為0
     {
      BuyLossStop=0;
      SellLossStop=0;
     }
   if(_TakeProfit<=0)//如果獲利參數為0
     {
      BuyTakeProfit=0;
      SellTakeProfit=0;
     }
   if(_OrderType==OP_BUY)
     {
      int buy_ticket=OrderSend(Symbol(),OP_BUY,_Lots,Ask,_Spread,BuyLossStop,BuyTakeProfit,NULL,MagicNumber);
      if(buy_ticket<0)
        {
         Print("OrderSend failed with error #",ErrorDescription(GetLastError()));
        }
      else
        {
         Print("OrderSend placed successfully");
        }

     }

   if(_OrderType==OP_SELL)
     {

      int ticket=OrderSend(Symbol(),OP_SELL,_Lots,Bid,_Spread,SellLossStop,SellTakeProfit,NULL,MagicNumber);
      if(ticket<0)
        {
         Print("OrderSend failed with error #",ErrorDescription(GetLastError()));
        }
      else
        {
         Print("OrderSend placed successfully");
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrderByType(int _OrderType)
  {

   bool Result;
   int Error;
   ;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {

      if(OrderSelect(i,SELECT_BY_POS)==true && OrderMagicNumber()==MagicNumber)
        {
         //Print("Close Number",i);

         RefreshRates();
         if(OrderType()==OP_BUY && _OrderType==OP_BUY)
           {

            double ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),Digits);
            if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,Slippage,CLR_NONE))
              {
                Print("Close Buy");
              }
            else
              {
               Print("Order failed to close with error - ",ErrorDescription(GetLastError()));
              }

           }


         if(OrderType()==OP_SELL && _OrderType==OP_SELL)
           {

            double ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),Digits);
           
            if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,Slippage,CLR_NONE))
              {
                Print("Close Sell");
              }
            else
              {
               Print("Order failed to close with error - ",ErrorDescription(GetLastError()));
              }

           }


        }

     }

  }
  
//寫入檔案  
void WriteData(string txt)
  {

   FileWriteString(handle,txt,StringLen(txt));

   return;
  }

//建立欄位名稱
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


void WriteDataRow(int i,int vision_action)
  {

   double  dSymTime,dSymOpen,dSymHigh,dSymLow,dSymClose,dSymVolume;
   int dDayofWk,dDayofYr,iDigits;
   dSymTime = (iTime(dSymbol,Period(),i));
   dDayofWk = (TimeDayOfWeek(dSymTime));
   dDayofYr = TimeDayOfYear(dSymTime);
   
   int MATrendPeriod = 10;

   dSymOpen=(iOpen(dSymbol,Period(),i));
   

   if(dSymOpen>0)
     {
      WriteData(dSymbolName+",");
      WriteData(TimeToStr(dSymTime,TIME_DATE|TIME_MINUTES)+",");

      iDigits=MarketInfo(Symbol(),MODE_DIGITS);
      dSymOpen = (iOpen(dSymbol,Period(),i));
      dSymHigh = (iHigh(dSymbol,Period(),i));
      dSymLow=(iLow(dSymbol,Period(),i));
      dSymClose=(iClose(dSymbol,Period(),i));
      dSymVolume=(iVolume(dSymbol,Period(),i));

     
     
      double MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
      double MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
      double SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
      double SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+1);
      double MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      double MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,i+1);

      WriteData(dDayofWk+","+dDayofYr+",");
      WriteData(DoubleToStr(dSymOpen,iDigits)+",");
      WriteData(DoubleToStr(dSymHigh,iDigits)+",");
      WriteData(DoubleToStr(dSymLow,iDigits)+",");
      WriteData(DoubleToStr(dSymClose,iDigits)+",");
      
      
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



 

string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   error_string="no error";                                                  break;
      case 2:   error_string="common error";                                              break;
      case 3:   error_string="invalid trade parameters";                                  break;
      case 4:   error_string="trade server is busy";                                      break;
      case 5:   error_string="old version of the client terminal";                        break;
      case 6:   error_string="no connection with trade server";                           break;
      case 7:   error_string="not enough rights";                                         break;
      case 8:   error_string="too frequent requests";                                     break;
      case 9:   error_string="malfunctional trade operation (never returned error)";      break;
      case 64:  error_string="account disabled";                                          break;
      case 65:  error_string="invalid account";                                           break;
      case 128: error_string="trade timeout";                                             break;
      case 129: error_string="invalid price";                                             break;
      case 130: error_string="invalid stops";                                             break;
      case 131: error_string="invalid trade volume";                                      break;
      case 132: error_string="market is closed";                                          break;
      case 133: error_string="trade is disabled";                                         break;
      case 134: error_string="not enough money";                                          break;
      case 135: error_string="price changed";                                             break;
      case 136: error_string="off quotes";                                                break;
      case 137: error_string="broker is busy (never returned error)";                     break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      case 147: error_string="expirations are denied by broker";                          break;
      case 148: error_string="amount of open and pending orders has reached the limit";   break;
      case 149: error_string="hedging is prohibited";                                     break;
      case 150: error_string="prohibited by FIFO rules";                                  break;
      //---- mql4 errors
      case 4000: error_string="no error (never generated code)";                          break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid ticket";                                           break;
      case 4109: error_string="trade is not allowed in the expert properties";            break;
      case 4110: error_string="longs are not allowed in the expert properties";           break;
      case 4111: error_string="shorts are not allowed in the expert properties";          break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
     }
//----
   return(error_string);
  }
