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


//初始化
int OnInit()
  {
   //建立Socket的服務
   server_socket=sock_connect(server_ip,server_port);
   
   if(server_socket==INVALID_SOCKET)
     {
     //如果連不上就回傳錯誤代碼
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

//程式結束
void OnDeinit(const int reason)
  {
  //結束時一定要關掉Socket，這樣MT4才不會凍結不會動
   sock_close(server_socket);
   sock_cleanup();
   
  }

//每一次Tick跳動的事件
void OnTick()
  {
   
   if(NewBar()){//確認是否有新的Bar出現
   
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
string json_string_key_value( string key, string value ) {
   return (StringConcatenate( "\"", key, "\"" , " : ", "\"", value , "\"" ));
}

string json_double_key_value( string key, double value ) {
   return (StringConcatenate( "\"", key, "\"" , " : ", DoubleToStr( value, 5) ));
}

string json_integer_key_value( string key, int value ) {
   return (StringConcatenate( "\"", key, "\"" , " : ", value) );
}


//未來要調整只要改這邊
string getStatusByJson()
  {

   int history_length=30;
   int init_index=30;

   string body="";

   body=StringConcatenate(body,"{");
   
   body=StringConcatenate(body,json_string_key_value("msg","Hello World"));//特別要注意這個裡少一個點，在JSON的開頭，不能有多那個點。
   body=StringConcatenate(body,", ",json_string_key_value("Context","1"));
//    while(init_index>=1)
//     {
//
//      string p=iOpen(NULL,PERIOD_D1,init_index)+", "+iHigh(NULL,PERIOD_D1,init_index)+", "+iLow(NULL,PERIOD_D1,init_index)+", "+iClose(NULL,PERIOD_D1,init_index);
//      string D1 = iMA(NULL,PERIOD_D1,60,0,MODE_SMA,PRICE_CLOSE,init_index);
//      string H4 = iMA(NULL,PERIOD_D1,20,0,MODE_SMA,PRICE_CLOSE,init_index);
//      string H1 = iMA(NULL,PERIOD_D1,10,0,MODE_SMA,PRICE_CLOSE,init_index);
//      string k_main=iStochastic(NULL,PERIOD_D1,9,9,3,MODE_SMA,0,MODE_MAIN,init_index);
//      string k_signal=iStochastic(NULL,PERIOD_D1,9,9,3,MODE_SMA,0,MODE_SIGNAL,init_index);
//      if(init_index==history_length)
//        {
//         body=StringConcatenate(body,json_string_key_value("raw_"+init_index,p));//特別要注意這個裡少一個點，在JSON的開頭，不能有多那個點。
//         body=StringConcatenate(body,", ",json_string_key_value("D1_"+init_index,D1));
//         body=StringConcatenate(body,", ",json_string_key_value("H4_"+init_index,H4));
//         body=StringConcatenate(body,", ",json_string_key_value("H1_"+init_index,H1));
//         body=StringConcatenate(body,", ",json_string_key_value("k_main_"+init_index,k_main));
//         body=StringConcatenate(body,", ",json_string_key_value("k_signal_"+init_index,k_signal));
//        }
//      else
//        {
//         body=StringConcatenate(body,", ",json_string_key_value("raw_"+init_index,p));
//         body=StringConcatenate(body,", ",json_string_key_value("D1_"+init_index,D1));
//         body=StringConcatenate(body,", ",json_string_key_value("H4_"+init_index,H4));
//         body=StringConcatenate(body,", ",json_string_key_value("H1_"+init_index,H1));
//         body=StringConcatenate(body,", ",json_string_key_value("k_main_"+init_index,k_main));
//         body=StringConcatenate(body,", ",json_string_key_value("k_signal_"+init_index,k_signal));
//
//        }
//      //printf(init_index);
//      init_index--;
//
//     }
   
   
    
    
     
      //body=StringConcatenate(body,", ",json_string_key_value("current_open",iOpen(NULL,PERIOD_D1,0)));
      body=StringConcatenate(body,", ",json_string_key_value("Back","1"));
   


   body=StringConcatenate(body,"}");

   return body;

  }


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
     int var1=StrToInteger(resp);
     
     Event_Handle(var1);//應用代碼
     }

  }

//調整對應的事件處理
void Event_Handle(int status){

   switch(status)
     {
      case  0:
        //sell
        break;
      case  1:
        //buy
        break;
      case  2:
        //wait
        break;
      default:
        break;
     }


}
