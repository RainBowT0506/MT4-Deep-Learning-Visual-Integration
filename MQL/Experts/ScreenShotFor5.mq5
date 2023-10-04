//+------------------------------------------------------------------+
//|                                               ScreenShotFor5.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Tools\ButtonTool.mqh>

string           InpName="sell_Button";            // Button name
string           Inp1Name="buy_Button";            // Button name
string           Inp2Name="normal_Button";            // Button name
ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // Chart corner for anchoring
string           InpFont="Arial";             // Font
int              InpFontSize=14;              // Font size
color            InpColor=clrBlack;           // Text color
color            InpBackColor=C'236,233,216'; // Background color
color            InpBorderColor=clrNONE;      // Border color
bool             InpState=false;              // Pressed/Released
bool             InpBack=false;               // Background object
bool             InpSelection=false;          // Highlight to move
bool             InpHidden=true;              // Hidden in the object list
long             InpZOrder=0;                 // Priority for mouse click
//--- chart window size
long x_distance;
long y_distance;

string v_line="v_line";

extern int Save_width = 1600;
extern int Save_height = 600;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    ObjectsDeleteAll(0,0,-1);
    ChartRedraw();


//--- Set the shift of the right edge of the chart
   ChartSetInteger(0,CHART_SHIFT,true);

//---
   Comment("Preparation of the Expert Advisor is completed");

//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Comment("Failed to get the chart width! Error code = ",GetLastError());
      return(INIT_FAILED);
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      Comment("Failed to get the chart height! Error code = ",GetLastError());
      return(INIT_FAILED);
     }

//--- set the button coordinates and its size
   int x=(int)x_distance/50;
   int y=(int)y_distance/30;
   int y2=(int)y_distance/10;
   int y3=(int)y_distance/5;
   int x_size=(int)x_distance*0.08;
   int y_size=(int)y_distance*0.05;
//--- create the button
   if(!ButtonCreate(0,InpName,0,x,y,x_size,y_size,InpCorner,"Sell Pic",InpFont,InpFontSize,
      InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder))
     {
     Print("Create Failed");
      return(INIT_FAILED);
     }

   if(!ButtonCreate(0,Inp1Name,0,x,y2,x_size,y_size,InpCorner,"Buy Pic",InpFont,InpFontSize,
      InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      return(INIT_FAILED);
     }

   if(!ButtonCreate(0,Inp2Name,0,x,y3,x_size,y_size,InpCorner,"Normal P.",InpFont,InpFontSize,
      InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      return(INIT_FAILED);
     }
     
     ObjectCreate(0,v_line,OBJ_VLINE,0,TimeCurrent(),0);
     ObjectSetInteger(0,v_line,OBJPROP_BACK,true);
//--- redraw the chart
   ChartRedraw();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,InpName);
   ObjectDelete(0,Inp1Name);
   ObjectDelete(0,Inp2Name);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id, 
                  const long &lparam, 
                  const double &dparam, 
                  const string &sparam) 
  {
  
      int      temp_x     = x_distance*0.8;
      int      temp_y     =(int)dparam;
      datetime temp_dt    =0;
      double   temp_price =0;
      int      temp_window=0;
      
      ChartXYToTimePrice(0,temp_x,temp_y,temp_window,temp_dt,temp_price);
      
      
    
      
      ObjectMove(0,v_line,0,temp_dt,0);
  
  
//--- Check the event by pressing a mouse button
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
     
    
      string clickedChartObject=sparam;
      
       
      //--- If you click on the object with the name buttonID
      if(clickedChartObject==InpName)
        {
         
         bool selected=ObjectGetInteger(0,InpName,OBJPROP_STATE);
         
          string name= GetName("Sell");
      

         //--- Save in terminal_directory\MQL4\Files\
         if(ChartScreenShot(0,name,Save_width,Save_height,ALIGN_CENTER))
            Print("Saved the screenshot ",name);
         
         Sleep(200);
         ObjectSetInteger(0,InpName,OBJPROP_STATE,false);

        }

      if(clickedChartObject==Inp1Name)
        {
         
         bool selected=ObjectGetInteger(0,Inp1Name,OBJPROP_STATE);
        

         
         string name= GetName("Buy");
      

         //--- Save in terminal_directory\MQL4\Files\
         if(ChartScreenShot(0,name,Save_width,Save_height,ALIGN_CENTER))
            Print("Saved the screenshot ",name);
         

         Sleep(200);
         ObjectSetInteger(0,Inp1Name,OBJPROP_STATE,false);

        }

      if(clickedChartObject==Inp2Name)
        {
        
         bool selected=ObjectGetInteger(0,Inp2Name,OBJPROP_STATE);
         
          string name= GetName("Normal");
       

         //--- Save in terminal_directory\MQL4\Files\
         if(ChartScreenShot(0,name,Save_width,Save_height,ALIGN_CENTER))
            Comment("Saved the screenshot ",name);
         
         Sleep(200);
         ObjectSetInteger(0,Inp2Name,OBJPROP_STATE,false);

        }
      ChartRedraw();// Forced redraw all chart objects
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(int TF) 
  {
   switch(TF) 
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
         return ("MN");
     }
   return ("Unknown TF");
  }
//+------------------------------------------------------------------+

string GetName(string type){
  int num=MathRand()%1000000+1;
   return type+"/"+type+"_"+ string(Symbol()) + "_" + PeriodToString(Period()) +"_"+num+ "_.png";
}

