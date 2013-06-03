/**
 * This class contains unit tests for validating the behavior of ClientSaleStatus REST API
 */
@isTest
public with sharing class ClientSaleStatusRestTest {
    private static String testRequestURI = '/services/apexrest/ewarehouse/clientsalestatus';
    static testMethod void updateClient() {
         
        Map<String, String> ids = DataSourceMock.insertTestData();
        // get the newly inserted farmer id (name field)
        String id = ids.get('farmer1Name');
        
        system.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","SaleStatus":"Unpaid"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)ClientSaleStatusRest.updateClientSaleStatus();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('200', result.code);
        System.assertEquals('Updated: client id ['+id+'], sale-status: [Unpaid]', result.description);
        
        List<Farmer__c> lstFarmer = [SELECT 
                                        ID, 
                                        Name, 
                                        Sale_Status__c
                                    FROM Farmer__c WHERE Name = :id];
        
        System.assertEquals(1, lstFarmer.size());
        
        Farmer__c clObj = lstFarmer.get(0);
        
        System.assertEquals('Unpaid', clObj.Sale_Status__c);
       
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientNotExists() {
        
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        // get the newly inserted farmer id (name field), but create an error
        String id = ids.get('farmer1Name') + 'oeps'; 
        
        system.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","SaleStatus":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientSaleStatusRest.updateClientSaleStatus();
        
        test.stopTest();
        
        // assert error returned
        System.assertEquals('400',result.code);
       
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientDMLException() {
        // set the datasource to mock
        EwarehouseServiceBase.setDataSource(new DataSourceMock.UpdateFarmerLoanExceptionMock());
        
         Map<String, String> ids = DataSourceMock.insertTestData();
        // get the newly inserted farmer id (name field)
        String id = ids.get('farmer1Name');
        
        system.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","SaleStatus":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse)ClientSaleStatusRest.updateClientSaleStatus();
        
        test.stopTest();
        
        // assert error returned
        System.assertEquals('500',result.code);
        
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
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
        req.requestBody = Blob.valueOf('{"Id":"dummy","SaleStatus":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientSaleStatusRest.updateClientSaleStatus();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('500',result.code);
        
        System.debug('Test finished');
        
        // reset the datasource
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
    }
    
    static testMethod void updateClientNoIdParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"SaleStatus":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientSaleStatusRest.updateClientSaleStatus();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400',result.code);
        System.assertEquals('We could find required parameter [Id]', result.description);
        
       
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientNoStatusParam() {
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"whatever"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientSaleStatusRest.updateClientSaleStatus();
        
        test.stopTest();
        
        // assert what was stored
        System.assertEquals('400',result.code);
        System.assertEquals('We could find required parameter [SaleStatus]', result.description);
        
       
        System.debug('Test finished');
        
    } 
}