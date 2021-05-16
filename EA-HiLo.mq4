//+------------------------------------------------------------------+
//|                                              EA HiLo+Fimathe.mq4 |
//|                                                      YURI ODILON |
//|                                                           gitHub |
//+------------------------------------------------------------------+
#property copyright "Yuri Odilon"
#property link      "www.github.com"
#property version   "1.00"

// VARIÁVEIS GLOBAIS

extern int MAGICMA    = 1994;   // Magicma
extern int takeProfit = 1000;   // Não será usado
extern int stopLoss   = 1000;   // Não será usado
extern double  lote   = 0.01;   // Lote de Entrada

extern bool operaComprado = true;
extern bool operaVendido = true;



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

   // ABRINDO A ORDEM
   
   checkForOpen(MAGICMA,operaVendido, operaComprado, sinal(OP_BUY), sinal(OP_SELL));
                
 
 }
//+------------------------------------------------------------------+

// ESSA FUNÇÃO IRÁ ABRIR AS ORDENS
void checkForOpen(int MAGICMA_n,
                  bool operarVendido = true,
                  bool operarComprado = true,
                  bool sinalCompra    = false,
                  bool sinalVenda     = false){
                  
                  
   int res;
   
   // VERIFICA SE TEM ALGUM TRADE NA FILA PARA SER EXECUTADO
   if(IsTradeContextBusy()==true)
   return;
   RefreshRates();   // ATUALIZA AS VARIÁVEIS ASK E BID
      
   if(operarVendido == true){
      if((sinalVenda == true) && (checkOrdermAberta(MAGICMA_n,OP_SELL) == 0)){
         
         
            res = OrderSend(Symbol(), OP_SELL, lote, Bid, 150, Bid+(stopLoss*Point), Bid-(takeProfit*Point), NULL, MAGICMA_n, 0, clrRed);
         
      }
   }
   
   if(operarComprado == true){
      if((sinalCompra == true)&& (checkOrdermAberta(MAGICMA_n, OP_BUY)==0)){
      
            res = OrderSend(Symbol(), OP_BUY, lote, Ask, 150, Ask-(stopLoss*Point), Ask+(takeProfit*Point), NULL, MAGICMA_n, 0, clrBlue);
         
      }
   }
   
   return;
}
                  

/*
 ESSA FUNÇÃO É RESPONSÁVEL POR VERIFICAR O SINAL DE ENTRADA
*/
bool sinal(int BUY_SELL){
  bool retorno;
  
  int mediaHigh = iMA(0, 0, 9, 0, 0, PRICE_HIGH, 0);
  int mediaLow = iMA(0, 0, 9, 0, 0, PRICE_LOW, 0);
  
  if (BUY_SELL == OP_SELL)
  {
     
     if((Close[1] < mediaLow) && (Close[2] > mediaLow))
        retorno = true;
     else
        retorno = false;   
  }
  else if(BUY_SELL == OP_BUY){
     
     if((Close[1] > mediaHigh) && (Close[2] < mediaHigh))
        retorno = true;
     else
        retorno = false;   
  }
  return(retorno); 
}

void check_saidaSinal(int MAGICMA_n,
                      int BUY_SELL,
                      int mediaHigh,
                      int mediaLow){
                      
   int fecha;                   
   
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
         fecha = OrderClose(OrderTicket(), OrderLots(), Bid, 150, clrRed);
        }
     }
     
     if(OrderType()==OP_SELL){   
        // CASO TENHA UMA VENDA ABERTA
        if(Close[1] > mediaHigh){
         // FECHA ORDEM
         fecha = OrderClose(OrderTicket(), OrderLots(), Bid, 150, clrRed);
        }     
     }
   }                      
                      
                        
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
               
                 
