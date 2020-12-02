/**
 * @File Name          : AccountBO.cls
 * @Description        : 
 * @Author             : Rogers Ribeiro
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 13/12/2019 16:38:48
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/12/2019        Rogers Ribeiro          Initial Version
**/
public class AccountBO {
    private static final AccountBO instance = new AccountBO(); 
    
    private  AccountBO() {}

    public  static AccountBO getInstance() { return instance; }

 // Método que dispara a precificação de disp. leves para o motor de preços
    public void criaFilaIntegracaoInsert(List<Account> accounts) {
        List<Queue__c> queueList = new List<Queue__c>();
        
        String recordTypeidEmpresa = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Empresa').getRecordTypeId();

        List<Account> accountList = new List<Account>();        
        for (Account account : accounts) {        
            if(account.recordTypeId == recordTypeidEmpresa)
            {
                queueList.add(new Queue__c(
                    EventName__c = QueueEventNames.ACCOUNT_RATTING.name(),
                    Status__c = 'CREATED',
                    RecordId__c = account.id,
                    keyField__c = account.id,
                    Payload__c = SerasaIntegrationBO.getJsonRequest(account),
                    IgnoredByTrigger__c = true)); 
            }
        }

        insert queueList;

        executeNextQueues(QueueEventNames.ACCOUNT_RATTING.name());
    }

    public static void executeNextQueues(String evtName) {
        
        // process next queues
        List<Queue__c> nextQueues = QueueDAO.getQueueByEventName(evtName, 'CREATED', 100);

        if (!nextQueues.isEmpty()) 
        {
            
            ProcessControl.ignoredByTrigger = true;
            
            for(Queue__c q : nextQueues)
            {
                q.Status__c = 'RUNNING';
            }
            
            update nextQueues;

            System.enqueueJob(new QueueBO(nextQueues));
        }
    }
	public void metodo2(){}
}