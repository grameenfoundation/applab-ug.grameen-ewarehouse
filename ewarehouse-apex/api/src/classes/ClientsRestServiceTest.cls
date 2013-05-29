/**
 * This class contains unit tests for validating the behavior of Clients REST API
 */
@isTest
private class ClientsRestServiceTest{
// TODO create test for no farmer found and no parameter given, check other things that might happen

    private static String testRequestURI = '/services/apexrest/ewarehouse/clients'; 

    static testMethod void getClients() {
        // insert test data
        DataSourceMock.insertTestData();
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'Processed');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        ClientsRestService.ClientsResponse result = (ClientsRestService.ClientsResponse) ClientsRestService.getClients();
        
        test.stopTest();
        
        // assert what was stored
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals('Jane',result.clients[0].FirstName);
        System.assertEquals('Fonda',result.clients[0].LastName);
        System.assertEquals(date.newinstance(1937, 12, 21),result.clients[0].DateOfBirth);
        System.assertEquals('+254123456789',result.clients[0].MobileNumber);
        System.assertEquals('Female',result.clients[0].Gender);
        System.assertEquals('Kisumu',result.clients[0].Village);
        System.assertEquals('Kisumu city',result.clients[0].City);
        System.assertEquals('Isiolo',result.clients[0].District);
        System.assertEquals('Kenya',result.clients[0].Country);
        System.assertEquals('ID0987654321',result.clients[0].IDNumber);
        
        System.assertEquals('John',result.clients[1].FirstName);
        System.assertEquals('Lennon',result.clients[1].LastName);
        System.assertEquals(date.newinstance(1937, 12, 21),result.clients[1].DateOfBirth);
        System.assertEquals('+254123456789',result.clients[1].MobileNumber);
        System.assertEquals('Female',result.clients[1].Gender);
        System.assertEquals('Kisumu',result.clients[1].Village);
        System.assertEquals('Kisumu city',result.clients[1].City);
        System.assertEquals('Isiolo',result.clients[1].District);
        System.assertEquals('Kenya',result.clients[1].Country);
        System.assertEquals('ID0987654321',result.clients[1].IDNumber);
        
        System.debug('Test finished');
    }
    
    static testMethod void getNewClients() {
        
        // insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        Farmer__c farmer = [SELECT Status__c FROM Farmer__c WHERE Id = :ids.get('farmer2Id')];
        farmer.Status__c = 'New';
        update farmer;
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'New');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        ClientsRestService.ClientsResponse result = (ClientsRestService.ClientsResponse) ClientsRestService.getClients();
        
        test.stopTest();
        
        System.assertEquals(1,result.clients.size());
        
        System.assertEquals('John',result.clients[0].FirstName);
        System.assertEquals('Lennon',result.clients[0].LastName);
        System.assertEquals(date.newinstance(1937, 12, 21),result.clients[0].DateOfBirth);
        System.assertEquals('+254123456789',result.clients[0].MobileNumber);
        System.assertEquals('Female',result.clients[0].Gender);
        System.assertEquals('Kisumu',result.clients[0].Village);
        System.assertEquals('Kisumu city',result.clients[0].City);
        System.assertEquals('Isiolo',result.clients[0].District);
        System.assertEquals('Kenya',result.clients[0].Country);
        System.assertEquals('ID0987654321',result.clients[0].IDNumber);
        
        System.debug('Test finished');
    }
    
    static testMethod void getClientDMLException() {
        
        // set the datasource to mock
        EwarehouseServiceBase.setDataSource(new DataSourceMock.AllExceptionMock());
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        
        // set as parameter the just stored id
        req.addParameter('Status', 'dummy');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) ClientsRestService.getClients();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('Param [Status] can only be: New, Processed, Failed, Duplicate',result.description);
        
        System.debug('Test finished');
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
     }
    
    static testMethod void getClientNoStatusParam() {
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('bla-param', 'NOTEXISTING');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) ClientsRestService.getClients();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('We could find required parameter [Status]', result.description);
        
        System.debug('Test finished');
    }
    
    static testMethod void getNoClientsReturned() {

        // insert test data
        DataSourceMock.insertTestData();
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'Duplicate');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        ClientsRestService.ClientsResponse result = (ClientsRestService.ClientsResponse) ClientsRestService.getClients();
        
        test.stopTest();
        
        // assert what was stored
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals(0,result.clients.size());
        System.debug('Test finished');
        
    }
    
     static testMethod void getOneClientsReturned() {

        // insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        Farmer__c farmer = [SELECT Status__c FROM Farmer__c WHERE Id = :ids.get('farmer2Id')];
        farmer.Status__c = 'Duplicate';
        update farmer;
        
        // ready to start the test
        test.startTest();
        
        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'GET';
        // set as parameter the just stored id
        req.addParameter('Status', 'Duplicate');
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        ClientsRestService.ClientsResponse result = (ClientsRestService.ClientsResponse) ClientsRestService.getClients();
        
        test.stopTest();
        
        // assert what was stored
        
        System.assertEquals('200',result.code);
        System.assertEquals('OK',result.description);
        System.assertEquals(1,result.clients.size());
        System.assertEquals('John',result.clients[0].FirstName);
        System.assertEquals('Lennon',result.clients[0].LastName);
        System.assertEquals(date.newinstance(1937, 12, 21),result.clients[0].DateOfBirth);
        System.assertEquals('+254123456789',result.clients[0].MobileNumber);
        System.assertEquals('Female',result.clients[0].Gender);
        System.assertEquals('Kisumu',result.clients[0].Village);
        System.assertEquals('Kisumu city',result.clients[0].City);
        System.assertEquals('Isiolo',result.clients[0].District);
        System.assertEquals('Kenya',result.clients[0].Country);
        System.assertEquals('ID0987654321',result.clients[0].IDNumber);
        
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClient() {
        // insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('farmer1Name')+'","Status":"Duplicate"},{"Id":"'+ids.get('farmer2Name')+'","Status":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)ClientsRestService.updateClients();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('200', result.code);
        System.assertEquals('Update success', result.description);
        
        List<Farmer__c> lstFarmer1 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Farmer__c WHERE Name = :ids.get('farmer1Name')];
        
        System.assertEquals(1, lstFarmer1.size());
        System.assertEquals('Duplicate', lstFarmer1.get(0).Status__c);
        
        List<Farmer__c> lstFarmer2 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Farmer__c WHERE Name = :ids.get('farmer2Name')];
        
        System.assertEquals(1, lstFarmer2.size());
        System.assertEquals('Failed', lstFarmer2.get(0).Status__c);
       
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientsNotExists() {
        
        // insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('farmer1Name')+'","Status":"Duplicate"},{"Id":"2eyUUE","Status":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorMapResponse result = (EwarehouseServiceBase.ErrorMapResponse)ClientsRestService.updateClients();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400', result.code);
        System.assertEquals('Not all IDs where found as client, attached Ids not updated.', result.description);
        
        // assert that the farmers are the same for the not updated farmers
        List<Farmer__c> lstFarmer1 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Farmer__c WHERE Name = :ids.get('farmer1Name')];
        
        System.assertEquals(1, lstFarmer1.size());
        System.assertEquals('Duplicate', lstFarmer1.get(0).Status__c);
        
        // farmer 2 was not updated, the Id was wrong
        List<Farmer__c> lstFarmer2 = [SELECT 
                                        ID, 
                                        Name, 
                                        Status__c
                                    FROM Farmer__c WHERE Name = :ids.get('farmer2Name')];
        
        System.assertEquals(1, lstFarmer2.size());
        System.assertEquals('Processed', lstFarmer2.get(0).Status__c);
       
        System.debug('Test finished');
        
    }
    
     static testMethod void updateClientsNoIdParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        // error in the JSON last Id wrong
        req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Ids":"dummy","Status":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // retrieve an error
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientsRestService.updateClients();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400', result.code);
        System.assertEquals('JSON ERROR: We could find required parameter [Id] in one of the objects', result.description);
        
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientsNoStatusParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        // error in the JSON, last Status wrong
        req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Id":"dummy","Statqs":"Failed"}]}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // retrieve an error
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientsRestService.updateClients();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400',result.code);
        System.assertEquals('JSON ERROR: We could find required parameter [Status] in one of the objects', result.description);
        
       
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientGetException() {
        // set the datasource to mock
        EwarehouseServiceBase.setDataSource(new DataSourceMock.AllExceptionMock());
        
        // start the test
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Processed"}]');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientsRestService.updateClients();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('500',result.code);
        
        System.debug('Test finished');
        
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
    }   
}