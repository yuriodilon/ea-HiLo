//+------------------------------------------------------------------+
//|                                              EA HiLo+Fimathe.mq4 |
//|                                                      YURI ODILON |
//|                                    https://github.com/yuriodilon |
//+------------------------------------------------------------------+
#property copyright "Yuri Odilon"
#property link      "https://github.com/yuriodilon"
#property version   "1.00"

// VARIÁVEIS GLOBAIS

extern int  MAGICMA = 1111;
extern double MediaMaior = 20;
extern double MediaMenor = 3;
extern bool Operar_SELL = true;
extern bool Operar_BUY = true;
extern double lote = 0.01;
extern int takeProfit = 300;





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
   
   
   // Verifica se existe alguma ordem aberta, e se cumpre a condição de saída na média.
   
   
   
   if(checkOrdermAberta(MAGICMA, OP_SELL)> 0){
      check_saidaSinal(MAGICMA, OP_SELL);
      
   }else if(checkOrdermAberta(MAGICMA, OP_BUY) > 0){
      check_saidaSinal(MAGICMA, OP_BUY);
      
   }
  
  // VERIFICA SE EXISTE ORDEM, CASO TENHA NÃO IRÁ ABRIR OUTRA ORDEM. UMA ORDEM POR VEZ
  if((checkOrdermAberta(MAGICMA, OP_SELL) || (checkOrdermAberta(MAGICMA, OP_BUY))) > 0){
   return;
  } 
  
  // IMPEDE DE FICAR ABRINDO VÁRIAS ORDENS UMA ATRÁS DA OUTRA, ESPERA UM NOVO SINAL PARA ENTRAR
  if(nextTrade(MAGICMA) > 0){
   return;
  }
  
  
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
                  string coment  = "",
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

        }
     }
//---- buy conditions
    if(OperarBUY==true){
    
      if(((sinalcomprar==true)&& (checkOrdermAberta(MAGICMA_n, OP_BUY)==0))){
         res=OrderSend(Symbol(),OP_BUY,entrada,Ask,Slippage,Stop,Take,coment,MAGICMA_n,0,clrBlue);
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

void check_saidaSinal(int MAGICMA_n,
                      int BUY_SELL){
                      
   int fecha;
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


               
                 
