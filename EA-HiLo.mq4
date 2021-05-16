//+------------------------------------------------------------------+
//|                                              EA HiLo+Fimathe.mq4 |
//|                                                      YURI ODILON |
//|                                    https://github.com/yuriodilon |
//+------------------------------------------------------------------+
#property copyright "Yuri Odilon"
#property link      "https://github.com/yuriodilon"
#property version   "1.00"

// VARIÁVEIS GLOBAIS

extern int  MAGICMA        = 1994;        // Número Identificador do Algoritmo
extern bool Operar_SELL    = true;        // Operar vendido?
extern bool Operar_BUY     = true;        // Operar Comprado?
extern double lote         = 0.01;        // Valor do Contrato
extern double slippage     = 100;         // Máximo de slip que aceita
extern double takeProfit      = 500;        // TAKEPROFIT ( Não UTILIZADO NA ESTRATÉGIA)
extern double stopLoss        = 500;        // STOPLOSS (NÃO UTILIZADO NA ESTRATÉGIA)






//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
/* Não mexer */
takeProfit = takeProfit*Point;
stopLoss   = stopLoss*Point;
/* --------- */


   
   // Verifica se existe alguma ordem aberta, e se cumpre a condição de saída na média.

  

  // VERIFICA A SAÍDA
  verificaSaida(MAGICMA);
  
  // Abre ordem
  CheckForOpen(MAGICMA, 
                  Operar_SELL,
                  Operar_BUY,
                  sinal(OP_BUY),
                  sinal(OP_SELL),
                  lote,
                  150,
                  "Robo EXFXTRADE",
                  0,
                  0
                   );
  
             

  }
//+------------------------------------------------------------------+


// Função Responsável por Abrir Ordem
void CheckForOpen(int MAGICMA_n, 
                  bool OperarSELL = true,
                  bool OperarBUY = true,
                  bool sinalcomprar = false,
                  bool sinalvender = false,
                  double entrada = 0.01,
                  int Slippage = 150,
                  string coment  = "EA HiLo Yuri Odilon",
                  double Stop = 0,
                  double Take = 0){
                  
  int    res;
  
  // Verifica sem existe algum trade na fila para ser executado
  if(IsTradeContextBusy()==true)
      return;
  // Atualiza as variáveis Pré-definidas, Bid, ask e etc
  RefreshRates();
  
//---- sell conditions
   if(OperarSELL==true){
      if(((sinalvender==true)&& (checkOrdermAberta(MAGICMA_n, OP_SELL)==0))){
         res=OrderSend(Symbol(),OP_SELL,entrada,Bid,Slippage,Stop,Take,coment,MAGICMA_n,0,clrRed);
         Print("Valor do Stop: ", Stop);
         Print("Valor do Take: ", Take);

        }
     }
//---- buy conditions
    if(OperarBUY==true){
    
      if(((sinalcomprar==true)&& (checkOrdermAberta(MAGICMA_n, OP_BUY)==0))){
         res=OrderSend(Symbol(),OP_BUY,entrada,Ask,Slippage,Stop,Take,coment,MAGICMA_n,0,clrBlue);
         Print("Valor do Stop: ", Stop);
         Print("Valor do Take: ", Take);
        }
     }
  return;
//----
  }  
  
  // Função responsável por verificar o sinal de entrada
  bool sinal(int BUY_SELL){
   bool retorno = false;
   
  double mediaHigh = iMA(NULL, 0, 9, 0, 0, PRICE_HIGH, 0);
  double mediaLow = iMA(NULL, 0, 9, 0, 0, PRICE_LOW, 0);
  
   if (BUY_SELL==OP_SELL ){
     if (((Close[1] < mediaLow) && (Close[2] > mediaLow))==true)
       retorno = true;
     else
       retorno = false;
   }  
   if (BUY_SELL==OP_BUY){
   
     if (((Close[1] > mediaHigh) && (Close[2] < mediaHigh))==true){ 
       retorno = true;
     }
     else
       retorno = false;
   }  
   return(retorno);
}

double checkOrdermAberta(int MAGICMA_n, int BUY_SELL){
 int totalordem = OrdersTotal();
 int contador =0;
 
 for(int i=0; i < totalordem; i++)
 {
   if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false)
     break;
     
   if ((OrderMagicNumber() == MAGICMA_n) &&
       (OrderType() == BUY_SELL))      
     contador++;
 }
  return(contador);    
}  

/*
void check_saidaSinal(int MAGICMA_n,
                      int BUY_SELL){

   int mediaHigh = iMA(NULL, 0, 9, 0, 0, PRICE_HIGH, 0);
   int mediaLow = iMA(NULL, 0, 9, 0, 0, PRICE_LOW, 0);                   
   
   for(int i=0;i< OrdersTotal();i++){
   
     if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false){
      break;
     }
     
     if(((OrderMagicNumber()==MAGICMA_n) && (OrderType()==BUY_SELL))==false){
      break;
     }
     
     // VERIFICA CONDIÇÃO
     
     //CASO TENHA UMA COMPRA ABERTA
     if(OrderType()==OP_BUY){
        if(Close[1] < mediaLow){
         // FECHA ORDEM
         fechaTodasordens(MAGICMA_n, slippage, OP_BUY);
        }
     }
     
     if(OrderType()==OP_SELL){   
        // CASO TENHA UMA VENDA ABERTA
        if(Close[1] > mediaHigh){
         // FECHA ORDEM
         fechaTodasordens(MAGICMA_n, slippage, OP_SELL);
        }     
     }
   }                      
}
*/

int nextTrade(int MAGICMA_n){
   int contador = -1;
   
   
   if((checkOrdermAberta(MAGICMA_n, OP_SELL) || (checkOrdermAberta(MAGICMA_n, OP_BUY)))){
      contador = 1;
   }
   
   if((sinal(OP_SELL) && (sinal(OP_BUY)) == true)){
      contador = 0;
   }
   
   

   return(contador);
}
               
                 

void verificaSaida(int MAGICMA_n){
       int ticket = -1;
       double fecha = -1;
                   
       for(int i=0;i<OrdersTotal();i++){
       
          if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false){
               break;
         }
         
          if((OrderMagicNumber()==MAGICMA_n)){
          
          if((OrderType()==OP_SELL) && (sinal(OP_BUY)== true)){
            // fecha ordem
            fecha = OrderClose(OrderTicket(),OrderLots(),Ask, slippage, clrRed);
          }
          
          if((OrderType()==OP_BUY) && (sinal(OP_SELL)== true)){
            // fecha ordem
            fecha = OrderClose(OrderTicket(),OrderLots(),Bid, slippage, clrRed);
          }
               
            
          }  
       
       
       }            
     return;              
}
                                    