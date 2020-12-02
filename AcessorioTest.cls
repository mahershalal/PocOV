@isTest public class AcessorioTest {
  @isTest static void acessorioTeste() {

    Test.startTest();
    

    Opportunity opp = InstanceToClassCoverage.createOpportunity('Teste');
    Product2 product = InstanceToClassCoverage.createProduct('Teste');
    PriceBookEntry priceBook =
        InstanceToClassCoverage.createPricebookEntry(product);
    Quote quote = InstanceToClassCoverage.createQuote(opp, 'Teste', priceBook);
    QuoteLineItem lineItem =
        InstanceToClassCoverage.createQuoteLineItem(quote, priceBook, product);

    Acessorio__c acce = new Acessorio__c(Name = 'teste acessorio');

    insert acce;

    AcessorioxItemLinha__c acessorio = new AcessorioxItemLinha__c(ItemLinhaCotacao__c = lineItem.Id,
                                                                  Acessorio__c = acce.Id);

    insert acessorio;

    ProcessControl.ignoredByTrigger = false;

    delete acessorio;

    Test.stopTest();
  }
  public void metodo2teste(){}
  private string MetodoAux1(){
	return 'aux1';
  }
}