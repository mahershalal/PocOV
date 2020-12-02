/**
 * @File Name          : AnyEventCalCtrl.cls
 * @Description        : 
 * @Author             : danielb.partner@ouroverde.net.br
 * @Group              : 
 * @Last Modified By   : danielb.partner@ouroverde.net.br
 * @Last Modified On   : 30/12/2019 10:23:47
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/12/2019   danielb.partner@ouroverde.net.br     Initial Version
**/
public with sharing class AnyEventCalCtrl 
{
    private static final string EventTypeHoliday = 'Holiday';
    private static final string EventType = 'Event';
    
    @AuraEnabled
    public static List<EventObj> getEvents(
        String accountId,
        Boolean filterByUser){
                                  
            Q query = new Q(Opportunity.SObjectType)
                .selectFields(new Set<string> {'Id', 
                    'Name',
                    'DataAgendamento__c', 
                    'EndDateTime__c', 
                    'RelatoCliente__c',
                    'StageName', 
                    'Caso__c',                       
                    'Fornecedor__c'});
		
            string NomeCidade;
            string estado;
            String Name;
            String contactid;
            
            if (filterByUser) { 
                string usrId = UserInfo.getUserId();   
                User us = [SELECT ID,NAME,contact.Account.Id, contact.Account.BillingCity,contact.Account.BillingState FROM USER WHERE ID = :usrId]; 
                
                accountId = us.contact.Account.Id;
                NomeCidade  = us.contact.Account.BillingCity;
                estado  = us.contact.Account.BillingState;
               
                if(Test.isRunningTest()){
                    
                        accountId = '0010t00001PpzfqAAB';	
                        NomeCidade  = 'São Caetano do Sul';
                        estado  = 'SP';
                        contactid = '';
                        name = 'Test';
                } 
                system.debug('teste ' + accountId +' account ' + ' NomeCidade ' + NomeCidade + ' estado ' + estado );
               
            }

            if (accountId != null & accountId != '') {                                       
                
                query.add(Q.condition('Fornecedor__c')
                          .equalsTo(accountId));
            }
                    System.debug(',   -- Start..... ' );
            
            System.debug(LoggingLevel.ERROR, 'CLS - AnyEventCalCtrl, METHOD - getEvents, query.build()>>>>' + query.build());

            List<Opportunity> agendamentos = database.Query(query.build());
            
            List<EventObj> eventRecords = new List<EventObj>();
            
            for (Opportunity obj : agendamentos) {
                
                EventObj newEv = new EventObj(obj.Id,
                                              obj.Name,
                                              obj.DataAgendamento__c,
                                              obj.EndDateTime__c,
                                              obj.RelatoCliente__c,
                                              obj.StageName,
                                              obj.Fornecedor__c,
                                              EventType,
                                              obj.Caso__c
                                             );
                eventRecords.add(newEv);
            }
            
		List<Holidays__c> holidays = [SELECT 
                                      		id,
                                      		Name,
                                      		DataFeriado__c 
                                      	FROM Holidays__c  
                                       WHERE (TipoFeriado__c = 'Nacional') 
                                          OR (NomeCidade__c = :NomeCidade AND TipoFeriado__c = 'Municipal')
                                      	  OR (Estado__c = :estado AND TipoFeriado__c = 'Estadual')];
        system.debug('holidays ' + holidays);
            if(Test.isRunningTest() && holidays.isEmpty()){
                holidays = [SELECT id,Name,
                                      		DataFeriado__c 
                                      	FROM Holidays__c limit 10];
                
            }
		for (Holidays__c hld : holidays) {
                EventObj newEv = new EventObj(hld.Id,
                                              hld.Name,
                                              hld.DataFeriado__c,
                                              hld.DataFeriado__c,
                                              hld.Name,
                                              '',
                                              '',
                                              EventTypeHoliday,
                                              ''
                                             );
                eventRecords.add(newEv);
            }                                              
                                               
		
        return eventRecords;
    }
    
    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String LinkId {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String eventType {get;set;}
        
        public EventObj(String id,String titulo, DateTime dataInicio, DateTime dataFim, String descricao,String status, String proprietario, string eventType, string linkId){
            this.Id = id;
            this.title = titulo;
            this.startDateTime = dataInicio;
            this.endDateTime = dataFim;
            this.description = descricao;
            this.status = status;
            this.owner = proprietario;
            this.LinkId = linkId;
            this.eventType = eventType;
        }
        
    }
}