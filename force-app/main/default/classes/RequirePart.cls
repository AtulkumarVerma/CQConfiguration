/*
Class Name: RequirePart
Requirement: Interview
Used Where : Used to sync parts from home page
Purpose/Overview : sync parts from home page
Test Class Name : RequirePartTest
*/

Public class RequirePart {
    
    @AuraEnabled
    public static String syncRequirePart(){
        String strReturn = '';
        try{
            if(FeatureManagement.checkPermission('Integration_Admin')){
                Parts_Api__c partsApi = Parts_Api__c.getValues('Get Parts');

            HttP http = new HttP();
            HttpRequest request = new HttpRequest();
            request.setHeader('x-api-key', partsApi.Api_key__c);
            request.setHeader('Content-Type', partsApi.Content_Type__c);
            request.setEndpoint(partsApi.End_Point__c);
            request.setMethod(partsApi.Method__c);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                string result  = response.getBody();
                System.debug(result);
                List<ParseJsonRequirePart> parseJsonList =  ParseJsonRequirePart.parse(result);
                if(!parseJsonList.isEmpty()){
                    upsertCQPart(parseJsonList);
                }
                strReturn = 'Records sync successfully.';
            }
                else{
                    strReturn = 'SomeThing Worong!';
                }

            }
            else {
                 strReturn = 'Insufficient Access';
            }
            
            
            
        }
        catch(Exception e){
            strReturn = e.getMessage();
            throw new AuraHandledException(strReturn);
            
        }
        return strReturn;
    }
    
    public static void upsertCQPart(List<ParseJsonRequirePart> parseJsonList){
        Set<String> accountNameSet = new Set<String>{'Low Volume','High Volume'};
        Map<String,String> accountNameWithIdMap = getAccountNameMapwithId(accountNameSet);
        
        if(!accountNameWithIdMap.isEmpty()) {
            
            List<SQX_Part__c> cqPartList = new List<SQX_Part__c>();
            for(ParseJsonRequirePart jsonRequirePart : parseJsonList){
                System.debug('jsonRequirePart');
                SQX_Part__c cqPart = new SQX_Part__c();
                cqPart.Name	= jsonRequirePart.partName;
                cqPart.Part_Number__c = jsonRequirePart.x_id;
                cqPart.Active__c = true;
                if(jsonRequirePart.totalQuantityShipped < 99 && accountNameWithIdMap.containskey('High Volume') ) {
                     cqPart.Related_Account__c = accountNameWithIdMap.get('High Volume') ; // Mapped high volume Account
                }
                else if(jsonRequirePart.totalQuantityShipped >= 99 && accountNameWithIdMap.containskey('Low Volume') ) {
                     cqPart.Related_Account__c = accountNameWithIdMap.get('Low Volume') ; // Mapped low volume Account
                }
                cqPartList.add(cqPart);
            }
            upsert cqPartList Part_Number__c;
        }
    }
    
    public static Map<String,String> getAccountNameMapwithId(Set<String> accountNameSet){
        Map<String,String> accountNameWithIdMap = new Map<String,String>();
        for(Account acc :[Select Id,Name FROM Account WHERE Name =: accountNameSet]){
            accountNameWithIdMap.put(acc.Name,acc.Id);
        }
        return accountNameWithIdMap;
    }
    
}