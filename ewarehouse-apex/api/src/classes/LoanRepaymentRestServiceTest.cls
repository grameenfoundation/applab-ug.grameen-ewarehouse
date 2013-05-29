/**
 * This class contains unit tests for validating the behavior of Loan Repayment REST API
 */
@isTest
private class LoanRepaymentRestServiceTest {

	private static String testRequestURI = '/services/apexrest/ewarehouse/repayments'; 

    static testMethod void getLoanRepayments() {
    	
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
		req.addParameter('LoanId', ids.get('loan1Id'));
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the loan (normally converted to JSON via API)
		LoanRepaymentRestService.RepaymentResponse result = (LoanRepaymentRestService.RepaymentResponse) LoanRepaymentRestService.getRepayments();
		system.debug(result);
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		
		System.assertEquals(1500.00, result.repayments[0].Amount);
		System.assertEquals(date.newinstance(2013, 4, 30), result.repayments[0].PaymentDate);
		System.assertEquals('reason', result.repayments[0].Remarks);
		System.assertEquals(ids.get('loan1Id'), result.repayments[0].LoanId);
		//System.assertEquals(sale1_1.Id, result.repayments[0].SaleId);
		
		System.assertEquals(1500.00, result.repayments[1].Amount);
		System.assertEquals(date.newinstance(2013, 4, 30), result.repayments[1].PaymentDate);
		System.assertEquals('reason', result.repayments[1].Remarks);
		System.assertEquals(ids.get('loan1Id'), result.repayments[1].LoanId);
		//System.assertEquals(sale1_2.Id, result.repayments[1].SaleId);
		
		
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
		req.addParameter('LoanId', 'dummy');
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRepaymentRestService.getRepayments();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500', result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
    }
    
    
    static testMethod void getLoansNoLoanIdParam() {
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
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) LoanRepaymentRestService.getRepayments();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [LoanId]', result.description);
		
		System.debug('Test finished');
    }
    
    static testMethod void getNoLoanRepaymentsReturned() {

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
		// set as parameter the just stored id
		req.addParameter('LoanId', ids.get('loan1Id') + 'nop');
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		LoanRepaymentRestService.RepaymentResponse result = (LoanRepaymentRestService.RepaymentResponse) LoanRepaymentRestService.getRepayments();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(0,result.repayments.size());
		System.debug('Test finished');
    	
    }
    
    
    
    static testMethod void addLoanRepayment() {
    	// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
    	
    	String json = '[{"LoanId" : "'+ids.get('loan1Id')+'","SaleId" : "'+ids.get('sale1_1Id')+'","Amount" : "130000","Remarks" : "Loan re-payment completed","PaymentDate" : "2013-04-17"}]';
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// assert that the loan1 has two loan repayments as precheck
		List<Loan_Repayment__c> lr1p = EwarehouseServiceBase.dataSource.getLoanRepayments(ids.get('loan1Id'));
		System.assertEquals(2, lr1p.size());
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse) LoanRepaymentRestService.addRepayments();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Loan repayments posted successfully.', result.description);
		
		// assert that the loan1 has three loan repayments
		List<Loan_Repayment__c> lr1 = EwarehouseServiceBase.dataSource.getLoanRepayments(ids.get('loan1Id'));
		
		System.assertEquals(3, lr1.size());
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void addRepaymentsLoansNotExists() {
		// insert test data
        Map<String, String> ids = DataSourceMock.insertTestData();
        
    	
    	String json = '[{"LoanId" : "a1Oi00000001qsk","SaleId" : "'+ids.get('sale1_1Id')+'","Amount" : "130000","Remarks" : "Loan re-payment completed","PaymentDate" : "2013-04-17"}]';
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(json);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results (normally converted to JSON via API)
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse)LoanRepaymentRestService.addRepayments();
		
		test.stopTest();
		
		// assert an error, the payment was to a non-existing loan
		System.assertEquals('500', result.code);
		System.assertEquals('EXCEPTION:', result.description.substring(0, 10));
		
		// check if there are indeed no new payments
		List<Loan_Repayment__c> lr1 = [SELECT 
										Id
									FROM Loan_Repayment__c WHERE Loan__c = :ids.get('loan1Id')];
		
		// only the 2 existing loans should exist
		System.assertEquals(2, lr1.size());
		
		System.debug('Test finished');
 		
    }
    
}