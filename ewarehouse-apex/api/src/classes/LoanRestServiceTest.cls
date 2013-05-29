/**
 * This class contains unit tests for validating the behavior of Loan REST API
 */
@isTest
private class LoanRestServiceTest {

	private static String testRequestURI = '/services/apexrest/ewarehouse/loan'; //'https://na15.salesforce.com/services/apexrest/ewarehouse/client'; 

    static testMethod void getLoan() {
    	
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
    	String farmerId = ids.get('farmer1Name');
    	String id = ids.get('loan1Id'); 
 		
 		system.debug('Loan Id=' + id);
 		
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		
		// set as parameter the just stored id
		req.addParameter('Id', id);
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		LoanRestService.LoanResponse result = (LoanRestService.LoanResponse) LoanRestService.getLoan();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);

		System.assertEquals(130000,result.loan.AmountApplied);
		System.assertEquals(120000,result.loan.AmountApproved);
		System.assertEquals(120000,result.loan.Balance);
		System.assertEquals(date.newinstance(2013, 4, 30),result.loan.ApplicationDate);
		System.assertEquals(date.newinstance(2013, 5, 1),result.loan.DecisionDate);
		System.assertEquals('Applied',result.loan.Status);
		System.assertEquals(farmerId,result.loan.FarmerId);
		
		System.debug('Test finished');
    }
    
    static testMethod void getLoanDMLException() {
     	
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
		req.addParameter('Id', 'dummy');
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRestService.getLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
    }
    
    static testMethod void getLoanNoIdParam() {
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
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) LoanRestService.getLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [Id]', result.description);
		
		System.debug('Test finished');
    }
    
    static testMethod void getLoanNotExist() {

 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		// set as parameter the just stored id
		req.addParameter('Id', 'NOTEXISTING');
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) LoanRestService.getLoan();
		
		test.stopTest();
		

		// assert error returned
		System.assertEquals('400',result.code);
		System.assertEquals('We could not find a loan with the gived Id: [NOTEXISTING]',result.description);
		
		System.debug('Test finished');
    	
    }

    static testMethod void updateLoan() {
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
    	String farmerId = ids.get('farmer1Name');
    	String id = ids.get('loan1Id'); 
 		
 		system.debug('Loan Id=' + id);
 		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed", "Balance": 10000.01}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// update the loan
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Updated: Loan Id ['+id+'], Status: [Processed], Balance: [10000.01]', result.description);
		
		List<Loan__c> lstLoan = [SELECT 
										ID, 
										Status__c,
										Balance__c
									FROM Loan__c WHERE Id = :id];
		
		System.assertEquals(1, lstLoan.size());
		
		Loan__c loanObj = lstLoan.get(0);
        
        System.assertEquals('Processed', loanObj.Status__c);
       	System.assertEquals(10000.01, loanObj.Balance__c);
       
		System.debug('Test finished');
 		
    }
    
    
    static testMethod void updateClientNotExists() {
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
    	String farmerId = ids.get('farmer1Name');
    	String id = ids.get('loan1Id') + 'oeps'; 
 		
 		system.debug('Loan Id=' + id);
 	 		
 	 	test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed", "Balance": 10000.01}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert error returned
		System.assertEquals('400',result.code);
	    System.assertEquals('We could find a loan with the gived id: ['+ id +']',result.description);
	   
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoanDMLException() {
    	// set the datasource to mock
     	EwarehouseServiceBase.setDataSource(new DataSourceMock.UpdateFarmerLoanExceptionMock());
     	
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
    	String farmerId = ids.get('farmer1Name');
    	String id = ids.get('loan1Id'); 
 		
 		system.debug('Loan Id=' + id);
 		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed", "Balance": 10000.01}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert error returned
		System.assertEquals('500',result.code);
		System.assertEquals('EXCEPTION: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Person__c]: [Person__c]',result.description);
		
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
		
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoanGetException() {
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
		req.requestBody = Blob.valueOf('{"Id":"dummy","Status":"Processed", "Balance": 10000.01}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRestService.updateLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    
    static testMethod void updateLoanBalanceParseException() {
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
		req.requestBody = Blob.valueOf('{"Id":"dummy","Status":"Processed", "Balance": "oeps"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRestService.updateLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    
    static testMethod void updateLoanBalanceEmptyException() {
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
		req.requestBody = Blob.valueOf('{"Id":"dummy","Status":"Processed", "Balance": ""}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRestService.updateLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    
    
    static testMethod void updateLoanNoIdParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		String jsonString = '{"Status":"Processed", "Balance": 100}';
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find the property Id in the passed json: ['+ jsonString +']', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoanNoStatusParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		String jsonString = '{"Id":"whatever", "Balance": 100}';
  
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"Id":"whatever", "Balance": 100}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find the property Status in the passed json: ['+ jsonString +']', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoanNoBalanceParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		String jsonString = '{"Id":"whatever", "Status": "whatever"}';
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find the property Balance in the passed json: ['+ jsonString +']', result.description);
	   
		System.debug('Test finished');
 		
    }
}