//+------------------------------------------------------------------+
//|                                              EA HiLo+Fimathe.mq4 |
//|                                                      YURI ODILON |
//|                                    https://github.com/yuriodilon |
//+------------------------------------------------------------------+

//+-----------------------------------------------------------------------------------------+
//| PROXIMA ATIVIDADE                                                                       |
//| ATUALMENTE ELE SÓ ESTÁ VENDENDO, DESCOBRIR O MOTIVO DE SÓ ESTAR VENDENDO E CORRIGIR     |
//+-----------------------------------------------------------------------------------------+

#property copyright "Yuri Odilon"
#property link      "https://github.com/yuriodilon"
#property version   "1.00"

// VARIÁVEIS GLOBAIS

extern int  MAGICMA         = 1994;        // Número Identificador do Algoritmo
extern bool Operar_SELL     = true;        // Operar vendido?
extern bool Operar_BUY      = true;        // Operar Comprado?
extern double lote          = 0.01;        // Valor do Contrato
extern double slippage      = 30;         // Máximo de slip que aceita

// Operacional
extern bool verificaTendencia = true;      //  Ativada Será considerado a tendencia
extern double mediaControle =  21;         // Controle Direcional Tendencia
extern double mediaHiLo     = 9;           // Média do HiLo

// GERENCIAMENTO DE RISCO
// 
extern bool ativarMGale     = false;      // Ativa Martingale?
extern double incrementa    = 2;        // Fator Multiplicador

extern bool ativarSoros     = false;      // Ativa Martingale?
extern double entradaSoros  = 0.01;       // Entrada fixa do soros
extern int nivelSoros    = 2;        // Fator Multiplicador

//Trailing Stop
extern bool ativarTrailing  = true;      // TrailingStop
extern int  pontosTrailing  = 100;       // Pontos do Trailing

extern bool stopNaMin       = true;        // Ativando passa ter Stop na mínina ou máxima do HiLo

// VARIÁVEL NÃO EXTERNA
double stopLoss;





//+------------------------------------------------------------------+
//| EXPRESSÕES ( NÃO ALTERAR ) !!!                                   |
//+------------------------------------------------------------------+

double media    = iMA(NULL, 0, mediaControle, 0, 0, PRICE_CLOSE, 0);
double mediaAnt = iMA(NULL, 0, mediaControle, 0, 0, PRICE_CLOSE, 1);



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

 

 // VERIFICA A SAÍDA
 
  if(stopNaMin==true){
   stopLoss = verificaStop(MAGICMA, slippage);
  }else{
   verificaSaida(MAGICMA);
  }
  // Verificação do gerenciamento de risco | Martingale
  if(ativarMGale==true){
   lote = gerenciamentoGale(MAGICMA, lote, incrementa);
  } 
  
  // VERIFICA O GERENCIAMENTO DE RISCO SOROS | 
  if(ativarSoros==true){
   lote = gerenciaSoros(MAGICMA, nivelSoros, entradaSoros);
   
  }
  
  if(ativarTrailing==true){
   trailingStop(MAGICMA, pontosTrailing);
  }
  

      //Abre Ordem Na tendencia
      CheckForOpen(MAGICMA, 
                  Operar_SELL,
                  Operar_BUY,
                  sinal(OP_BUY),
                  sinal(OP_SELL),
                  lote,
                  150,
                  "EA HiLo Yuri Odilon",
                  stopLoss,
                  0);
 

                  
     
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
    if((sinalvender==true)&& (checkOrdermAberta(MAGICMA_n, OP_SELL)==0) && (checkOrdermAberta(MAGICMA_n, OP_BUY)==0) ){
      res=OrderSend(Symbol(),OP_SELL,entrada,Bid,Slippage,Stop,Take,coment,MAGICMA_n,0,clrRed);
    }
   }
//---- buy conditions
    if(OperarBUY==true){
     if((sinalcomprar==true)&& (checkOrdermAberta(MAGICMA_n, OP_SELL)==0) && (checkOrdermAberta(MAGICMA_n, OP_BUY)==0) ){
      res=OrderSend(Symbol(),OP_BUY,entrada,Ask,Slippage,Stop,Take,coment,MAGICMA_n,0,clrBlue);
     }
    }
  return;
//----
  }  
  
  // Função responsável por verificar o sinal de entrada
  bool sinal(int BUY_SELL){
   bool retorno = false;
   
  double mediaHigh = iMA(NULL, 0, mediaHiLo, 0, 0, PRICE_HIGH, 0);
  double mediaLow = iMA(NULL, 0, mediaHiLo, 0, 0, PRICE_LOW, 0);
  
  
  
   if (BUY_SELL==OP_SELL ){
     if (((Close[1] < mediaLow) && (Close[2] > mediaLow))==true)
       retorno = true;
     else
       retorno = false;
   }  
   if (BUY_SELL==OP_BUY){
   
     if (((Close[1] > mediaHigh) && (Close[2] < mediaHigh))==true) 
      retorno = true;
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


double gerenciamentoGale(int MAGICMA_n,
                       double entrada,
                       double fator_incremento){

   double nxtLote = 0.01;
   
   if(ultimoResultado(MAGICMA_n) < 0){
      nxtLote = NormalizeDouble(ultimoLote(MAGICMA_n) * fator_incremento, 2);
      
   }   

return(nxtLote);
}

//ESSA FUNÇÃO IRÁ APENAS SOMAR O ULTIMO LOTE AO LOTE ATUAL, CASO A ULTIMA OPERAÇÃO SEJA VENCEDORA. "NÃO APLICÁVEL A OUTRAS ESTRATÉGIAS, TERIA QUE PASSAR POR ADAPTAÇÕES"
double gerenciaSoros(int MAGICMA_n,
                     int nivel,
                     double entradaFixaSoros){

   double lastLote = ultimoLote(MAGICMA_n);
   double novoLote = entradaFixaSoros;
   
   if(ultimoResultado(MAGICMA_n) > 0){
     for(int i = 0; i < nivel;i++){
       
       if(OrdersHistoryTotal()==0){
       novoLote = entradaFixaSoros;
       break;
       }
       
      novoLote = NormalizeDouble((lastLote + entradaFixaSoros), 2);
     }
   }else{
      novoLote = entradaFixaSoros;
   }
   return(novoLote);
}                 


// FUNÇÃO RETORNANDO O ULTIMO LUCRO
double ultimoResultado(int MAGICMA_n){

   int totalordem       = OrdersHistoryTotal(); // Ordem Aberta
   int ticket_maior     = 0;
   double ultimoLucro = 0;
   
   for(int i=0; i<totalordem;i++){
   
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)==false){
      break;
      }
      
      if((OrderMagicNumber()==MAGICMA_n) && (OrderSymbol()==Symbol())){
         if(OrderTicket() > ticket_maior){
            ticket_maior = OrderTicket();
            ultimoLucro = OrderProfit()+OrderSwap()+OrderCommission();
         }
      }
   
   
 
   }
   return(ultimoLucro);  
}    

double ultimoLote(int MAGICMA_n){

   int totalordem       = OrdersHistoryTotal(); // Ordem Aberta
   int ticket_maior     = 0;
   double ultimoLote = 0;
   
   for(int i=0; i<totalordem;i++){
   
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)==false){
      break;
      }
      
      if((OrderMagicNumber()==MAGICMA_n) && (OrderSymbol()==Symbol())){
         if(OrderTicket() > ticket_maior){
            ticket_maior = OrderTicket();
            ultimoLote = OrderLots();
         }
      }
   
   
 
   }
   return(ultimoLote);  
}    


// Essa função irá verificar se há tendencia de baixa
int checkTendencia(int MAGICMA_n){
                    
   int retorno = -1;                 
   
   RefreshRates();
   if(Ask < media){
     retorno = 1; 
   }
   
   RefreshRates();
   if(Ask > media){
    retorno = 0;
   }
   
   return(retorno);
}
           

 void trailingStop(int MAGICMA_n, int TrailingStop)
  {
  
         int buys=0,sells=0;
         double TrailingStop_aux;
         bool res = false;
         //----

         if(IsTradeContextBusy()==true)
            return;


         TrailingStop_aux=NormalizeDouble(TrailingStop,0);
 
         for(int i=0; i<OrdersTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
               break;

            if(( OrderMagicNumber()==MAGICMA_n) && (OrderSymbol()==Symbol()))
              {

               if((OrderType()==OP_BUY))
                 {
                  if(TrailingStop_aux>0)
                    {
                     if(Bid-OrderOpenPrice()>Point*TrailingStop_aux)
                       {
                        if((OrderStopLoss()<Bid-Point*TrailingStop_aux) || (OrderStopLoss()==0))
                          {
                           res=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop_aux,OrderTakeProfit(),0,Green);
                           if(!res) 
                              Print("Erro OrderModify. código do erro=",GetLastError()); 
                          }
                       }
                    }

                 }

               if((OrderType()==OP_SELL))
                 {
                  if(TrailingStop_aux>0)
                    {
                     if((OrderOpenPrice()-Ask)>(Point*TrailingStop_aux))
                       {
                        if((OrderStopLoss()>(Ask+Point*TrailingStop_aux)) || (OrderStopLoss()==0))
                          {
                           res = OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop_aux,OrderTakeProfit(),0,Red);
                           if(!res) 
                              Print("Erro OrderModify. código do erro = ",GetLastError()); 
                          }
                       }
                    }

                 }
              }

           }
         return;

        }       
        
        
double verificaStop(int MAGICMA_n,
                    int slip){
  double valorStop = -1; 
  double mediaHigh = iMA(NULL, 0, mediaHiLo, 0, 0, PRICE_HIGH, 1);
  double mediaLow = iMA(NULL, 0, mediaHiLo, 0, 0, PRICE_LOW, 1);

   if(sinal(OP_SELL)==true){
      valorStop = mediaHigh+(slip*Point);
   }
   
   if(sinal(OP_BUY)==true){
      valorStop = mediaLow-(slip*Point);
   }
   
   return(valorStop);

} 
  