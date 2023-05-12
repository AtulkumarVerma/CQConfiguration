@isTest
private class RequirePartTest {
    @testSetup public static void setup(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            PermissionSet ps = new PermissionSet();
            ps.Name = 'Test';
            ps.Label = 'Test';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [SELECT Id from CustomPermission where DeveloperName = 'Integration_Admin'][0].Id;
            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserInfo.getUserId();
            psa.PermissionSetId = ps.Id;
            insert psa; 
            
            testNonSetupEntity();
        }
    }
    @Future    
    static  void testNonSetupEntity() {
        Parts_Api__c objParts = new Parts_Api__c();
        objParts.Name = 'Get Parts';
        objParts.Api_key__c = '98234982kjhi4u8';
        objParts.Content_Type__c = 'application/json';
        objParts.End_Point__c = 'endPoint';
        objParts.Method__c = 'Get';
        insert objParts;
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account();
        acc1.Name ='Low Volume';
        accList.add(acc1);
        Account acc2 = new Account();
        acc2.Name ='High Volume';
        accList.add(acc2);
        insert accList;
    }  
    
    Static User getStandardUser(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'last',
            Email = 'Cpt.Awesome@awesomesauce.com',
            UserName = 'Cpt.Awesome.' + DateTime.now().getTime() + '@awesomesauce.com',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        return u;
    }
    
    Static List<Account> getAccountByName(String name){
       List<Account> accList = [SELECT id,Name FROM Account where name =: name];
       return accList;
    }
    
    @isTest static  void testGetCalloutForHighVolumeAccount() {
        User objUser = new User();
        objUser.id = UserInfo.getUserId();
        System.runAs (objUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('getParts');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            String result = RequirePart.syncRequirePart();
            
            Test.stopTest();
            System.assertNotEquals('', result, 'Value of result should be success.');
            ////High Volume, Low Volume
            List<Account> accList = getAccountByName('High Volume');
            System.assertNotEquals(null, accList, 'Value of accList should not be null.');
        }
        
    }  
    
    @isTest 
    static  void testGetCalloutWithoutPermission() {
        User objUser = getStandardUser();
        System.runAs (objUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('getParts');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            String result = RequirePart.syncRequirePart();
            Test.stopTest();
            System.assertEquals('Insufficient Access', result, 'Value of result should be Insufficient Access.');
        }
    } 
    
    @isTest 
    static void testGetForException() {
        User objUser = new User();
        objUser.id = UserInfo.getUserId();
        System.runAs (objUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            //mock.setStaticResource('getParts');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            
            
            Test.setMock(HttpCalloutMock.class, mock);
            String exceptionMessage = '';
            try{
                RequirePart.syncRequirePart();
            }
            catch(Exception e){
                exceptionMessage = e.getMessage();
            }
            
            System.assertNotEquals('', exceptionMessage, 'exceptionMessage should not be empty.');
        }
        
    } 
    
    @isTest static  void testGetCalloutForOtherStatusCode() {
        User objUser = new User();
        objUser.id = UserInfo.getUserId();
        System.runAs (objUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('getParts');
            mock.setStatusCode(401);
            mock.setHeader('Content-Type', 'application/json');
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            String result = RequirePart.syncRequirePart();
            Test.stopTest();
            System.assertNotEquals('', result, 'Value of result should be success.');
        }
        
    }  
    
     @isTest static  void testGetCalloutForLowVolumeAccount() {
        User objUser = new User();
        objUser.id = UserInfo.getUserId();
        System.runAs (objUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('getParts');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            String result = RequirePart.syncRequirePart();
            
            Test.stopTest();
            System.assertNotEquals('', result, 'Value of result should be success.');
            // Low Volume
            List<Account> accList = getAccountByName('Low Volume');
            System.assertNotEquals(null, accList, 'Value of accList should not be null.');
        }
        
    } 
}