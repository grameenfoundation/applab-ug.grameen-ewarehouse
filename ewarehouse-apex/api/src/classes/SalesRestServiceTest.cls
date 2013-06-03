/**
 * This class contains unit tests for validating the behavior of Sales REST API
 */
@isTest
private class SalesRestServiceTest {

	private static String testRequestURI = '/services/apexrest/ewarehouse/sales'; 

    static testMethod void getSales() {
    	
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the sales (normally converted to JSON via API)
		SalesRestService.SalesResponse result = (SalesRestService.SalesResponse) SalesRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		system.debug(result);
		
		// assert error returned
		System.assertEquals('200',result.code);
		//System.assertEquals(ids.get('sale1Id'), result.sales[0].Id);
		System.assertEquals(1500, result.sales[0].Amount);
		System.assertEquals(6000.10, result.sales[0].SaleFarmers[0].AmountApplied);
		System.assertEquals(5000.10, result.sales[0].SaleFarmers[0].FeeDue);
		System.assertEquals(4000.10, result.sales[0].SaleFarmers[0].FeePaid);
		System.assertEquals(6000.10, result.sales[0].SaleFarmers[0].AmountApplied);
		System.assertEquals(5000.10, result.sales[0].SaleFarmers[0].FeeDue);
		System.assertEquals(4000.10, result.sales[0].SaleFarmers[0].FeePaid);
		
		System.assertEquals(1500, result.sales[1].Amount);
				
		System.assertEquals(1500, result.sales[2].Amount);
		System.assertEquals(6000.10, result.sales[2].SaleFarmers[0].AmountApplied);
		System.assertEquals(5000.10, result.sales[2].SaleFarmers[0].FeeDue);
		System.assertEquals(4000.10, result.sales[2].SaleFarmers[0].FeePaid);
		System.assertEquals(6000.10, result.sales[2].SaleFarmers[0].AmountApplied);
		System.assertEquals(5000.10, result.sales[2].SaleFarmers[0].FeeDue);
		System.assertEquals(4000.10, result.sales[2].SaleFarmers[0].FeePaid);
		
		System.assertEquals(1500, result.sales[3].Amount);
		
		System.debug('Test finished');
    }
    
    static testMethod void getSalesDMLException() {
     	
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
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of sales response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) SalesRestService.getSales();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
    }
    
    static testMethod void getNoSalesReturned() {
    	
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        List<Sale__c> sales = [SELECT Status__c FROM Sale__c];
        for(Sale__c sale : sales){
        	sale.Status__c = 'Processing';
        }
        update sales;
        
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the sales (normally converted to JSON via API)
		SalesRestService.SalesResponse result = (SalesRestService.SalesResponse) SalesRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(0,result.sales.size());
		System.debug('Test finished');
    	
    }
    
     static testMethod void getThreeSalesReturned() {

		// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
        Sale__c sale = [SELECT Status__c FROM Sale__c WHERE Id = :ids.get('sale1_1Id')];
        sale.Status__c = 'Processing';
        update sale;
 		
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		// set as parameter the just stored id
		req.addParameter('Status', 'Processing');
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the sales (normally converted to JSON via API)
		SalesRestService.SalesResponse result = (SalesRestService.SalesResponse) SalesRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		system.debug(result);
		System.assertEquals(3,result.sales.size());		
		
		System.debug('Test finished');
    	
    }
    
    
    static testMethod void updateSale() {
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
    		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('sale1_1Id')+'","Status":"Duplicate"},{"Id":"'+ids.get('sale2_1Id')+'","Status":"Failed"}]}');
        
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse) SalesRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Update success', result.description);
		
		List<Sale__c> lstSale1 = [SELECT 
										ID, 
										Status__c
									FROM Sale__c WHERE Id = :ids.get('sale1_1Id')];
		
		System.assertEquals(1, lstSale1.size());
		System.assertEquals('Duplicate', lstSale1.get(0).Status__c);
        
        List<Sale__c> lstSale2 = [SELECT 
										ID, 
										Status__c
									FROM Sale__c WHERE Id = :ids.get('sale2_1Id')];
		
		System.assertEquals(1, lstSale2.size());
		System.assertEquals('Failed', lstSale2.get(0).Status__c);
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateSalesNotExists() {
		// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('[{"Id":"'+ids.get('sale1_1Id')+'","Status":"Processing"},{"Id":"non-existing","Status":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorMapResponse result = (EwarehouseServiceBase.ErrorMapResponse) SalesRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('Not all IDs where found as sales, attached Ids not updated.', result.description);
		
		Sale__c sale1 = [SELECT Status__c FROM Sale__c WHERE Id = :ids.get('sale1_1Id')];
		Sale__c sale2 = [SELECT Status__c FROM Sale__c WHERE Id = :ids.get('sale1_2Id')];
		Sale__c sale3 = [SELECT Status__c FROM Sale__c WHERE Id = :ids.get('sale2_1Id')];
		Sale__c sale4 = [SELECT Status__c FROM Sale__c WHERE Id = :ids.get('sale2_2Id')];
		
		System.assertEquals('Processing', sale1.Status__c);
		System.assertEquals('New', sale2.Status__c);
		System.assertEquals('New', sale3.Status__c);
		System.assertEquals('New', sale4.Status__c);
		
		System.debug('Test finished');
 		
    }
    
     static testMethod void updateSalesNoIdParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		// error in the JSON last Id wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate"},{"Ids":"dummy","Status":"Failed"}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) SalesRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Id] in one of the objects', result.description);
		
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateSalesNoStatusParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		// error in the JSON, last Status wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate"},{"Id":"dummy","Statqs":"Failed"}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) SalesRestService.updateSales();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Status] in one of the objects', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    
    static testMethod void updateSalesGetException() {
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
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) SalesRestService.updateSales();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    

    
    
}