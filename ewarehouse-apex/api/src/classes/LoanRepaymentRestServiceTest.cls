/**
 * This class contains unit tests for validating the behavior of Clients REST API
 */
@isTest
private class LoanRepaymentRestServiceTest {

	private static String testRequestURI = '/services/apexrest/ewarehouse/repayments'; 

    static testMethod void getLoanRepayments() {
    	
    	// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person1 = getTestPerson(country, district);
    	Person__c person2 = getTestPerson(country, district);
    	insert person1;
    	person2.First_Name__c = 'Jon';
    	person2.Last_Name__c = 'Stewart';
    	insert person2;
    	
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer1 = getTestFarmer(person1);
    	Farmer__c farmer2 = getTestFarmer(person2);
    	insert farmer1;
    	farmer2.Name = '2eyUUD';
    	insert farmer2;
    	
    	String farmerId1 = farmer1.Name;
    	String farmerId2 = farmer2.Name;
    	
    	// create a loan
    	Loan__c loan1 = getLoan(farmer1);
    	Loan__c loan2 = getLoan(farmer2);
    	insert loan1;
    	insert loan2;
    	
    	// create sales
    	Sale__c sale1_1 = getSale(farmer1);
    	Sale__c sale1_2 = getSale(farmer1);
    	Sale__c sale2_1 = getSale(farmer2);
    	Sale__c sale2_2 = getSale(farmer2);
    	insert sale1_1;
    	insert sale1_2;
    	insert sale2_1;
    	insert sale2_2;
    	
    	// create loan repayments
    	Loan_Repayment__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
    	Loan_Repayment__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
    	Loan_Repayment__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
    	Loan_Repayment__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
    	insert loanRepayment1_1;
    	insert loanRepayment1_2;
    	insert loanRepayment2_1;
    	insert loanRepayment2_2;    	
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		req.addParameter('LoanId', loan1.Id);
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the loan (normally converted to JSON via API)
		LoanRepaymentRestService.RepaymentResponse result = (LoanRepaymentRestService.RepaymentResponse) LoanRepaymentRestService.getRepayments();
		system.debug(result);
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		
		System.assertEquals(loanRepayment1_1.Amount__c, result.repayments[0].Amount);
		System.assertEquals(loanRepayment1_1.Payment_Date__c, result.repayments[0].PaymentDate);
		System.assertEquals(loanRepayment1_1.Remarks__c, result.repayments[0].Remarks);
		System.assertEquals(loan1.Id, result.repayments[0].LoanId);
		//System.assertEquals(sale1_1.Id, result.repayments[0].SaleId);
		
		System.assertEquals(loanRepayment1_2.Amount__c, result.repayments[1].Amount);
		System.assertEquals(loanRepayment1_2.Payment_Date__c, result.repayments[1].PaymentDate);
		System.assertEquals(loanRepayment1_2.Remarks__c, result.repayments[1].Remarks);
		System.assertEquals(loan1.Id, result.repayments[1].LoanId);
		//System.assertEquals(sale1_2.Id, result.repayments[1].SaleId);
		
		
		System.debug('Test finished');
    }
    
    
    static testMethod void getLoanDMLException() {
     	
     	// set the datasource to mock
     	EwarehouseServiceBase.setDataSource(new DataSourceExceptionMock.AllExceptionMock());
     	
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
		System.assertEquals('400', result.code);
		
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

 		// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person1 = getTestPerson(country, district);
    	Person__c person2 = getTestPerson(country, district);
    	insert person1;
    	person2.First_Name__c = 'Jon';
    	person2.Last_Name__c = 'Stewart';
    	insert person2;
    	
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer1 = getTestFarmer(person1);
    	Farmer__c farmer2 = getTestFarmer(person2);
    	insert farmer1;
    	farmer2.Name = '2eyUUD';
    	insert farmer2;
    	
    	String farmerId1 = farmer1.Name;
    	String farmerId2 = farmer2.Name;
    	
    	// create a loan
    	Loan__c loan1 = getLoan(farmer1);
    	Loan__c loan2 = getLoan(farmer2);
    	insert loan1;
    	insert loan2;
    	
    	// create sales
    	Sale__c sale1_1 = getSale(farmer1);
    	Sale__c sale1_2 = getSale(farmer1);
    	Sale__c sale2_1 = getSale(farmer2);
    	Sale__c sale2_2 = getSale(farmer2);
    	insert sale1_1;
    	insert sale1_2;
    	insert sale2_1;
    	insert sale2_2;
    	
    	// create loan repayments
    	Loan_Repayment__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
    	Loan_Repayment__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
    	Loan_Repayment__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
    	Loan_Repayment__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
    	insert loanRepayment1_1;
    	insert loanRepayment1_2;
    	insert loanRepayment2_1;
    	insert loanRepayment2_2;
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		// set as parameter the just stored id
		req.addParameter('LoanId', loan1.Id + 'nop');
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
    
    
    
    static testMethod void updateLoan() {
    	// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person1 = getTestPerson(country, district);
    	Person__c person2 = getTestPerson(country, district);
    	insert person1;
    	person2.First_Name__c = 'Jon';
    	person2.Last_Name__c = 'Stewart';
    	insert person2;
    	
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer1 = getTestFarmer(person1);
    	Farmer__c farmer2 = getTestFarmer(person2);
    	insert farmer1;
    	farmer2.Name = '2eyUUD';
    	insert farmer2;
    	
    	String farmerId1 = farmer1.Name;
    	String farmerId2 = farmer2.Name;
    	
    	// create a loan
    	Loan__c loan1 = getLoan(farmer1);
    	Loan__c loan2 = getLoan(farmer2);
    	insert loan1;
    	insert loan2;
    	
    	// create sales
    	Sale__c sale1_1 = getSale(farmer1);
    	Sale__c sale1_2 = getSale(farmer1);
    	Sale__c sale2_1 = getSale(farmer2);
    	Sale__c sale2_2 = getSale(farmer2);
    	insert sale1_1;
    	insert sale1_2;
    	insert sale2_1;
    	insert sale2_2;
    	
    	/*// create loan repayments
    	Loan_Repayment__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
    	Loan_Repayment__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
    	Loan_Repayment__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
    	Loan_Repayment__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
    	insert loanRepayment1_1;
    	insert loanRepayment1_2;
    	insert loanRepayment2_1;
    	insert loanRepayment2_2;
    	*/
    	
    	String json = '[{"LoanId" : "'+loan1.Id+'","SaleId" : "'+sale1_1.Id+'","Amount" : "130000","Remarks" : "Loan re-payment completed","PaymentDate" : "2013-04-17"}]';
    	
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
		
		// load the results in the client (normally converted to JSON via API)
		system.debug(LoansRestService.updateLoans());
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse) LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Update success', result.description);
		
		List<Loan__c> lstLoan1 = [SELECT 
										ID, 
										Status__c
									FROM Loan__c WHERE Farmer__c = :farmer1.Id];
		
		System.assertEquals(1, lstLoan1.size());
		System.assertEquals('Default', lstLoan1.get(0).Status__c);
        
        List<Loan__c> lstLoan2 = [SELECT 
										ID, 
										Status__c
									FROM Loan__c WHERE Farmer__c = :farmer2.Id];
		
		System.assertEquals(1, lstLoan2.size());
		System.assertEquals('Applied', lstLoan2.get(0).Status__c);
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoansNotExists() {
		// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert 2 Persons
    	Person__c person1 = getTestPerson(country, district);
    	Person__c person2 = getTestPerson(country, district);
    	person2.First_Name__c = 'John';
    	person2.Last_Name__c = 'Lennon';
    	insert person1;
    	insert person2;
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer1 = getTestFarmer(person1);
    	Farmer__c farmer2 = getTestFarmer(person2);
    	farmer2.Name = '2eyUUD';
    	
    	insert farmer1;
    	insert farmer2;
    	
    	// create a loan
    	Loan__c loan1 = getLoan(farmer1);
    	Loan__c loan2 = getLoan(farmer2);
    	insert loan1;
    	insert loan2;
    	
    	String farmerId1 = farmer1.Id;
    	String farmerId2 = farmer2.Id;
    	String loanId1 = loan1.Id;
    	String loanId2 = loan2.Id;
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('[{"Id":"'+loanId1+'","Status":"Default"},{"Id":"non-existing","Status":"Default"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorMapResponse result = (EwarehouseServiceBase.ErrorMapResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('Not all IDs where found as client, attached Ids not updated.', result.description);
		
		// assert that the farmers are the same for the not updated farmers
		List<Loan__c> lstLoan1 = [SELECT 
										Id, 
										Status__c
									FROM Loan__c WHERE Id = :loanId1];
		
		System.assertEquals(1, lstLoan1.size());
		System.assertEquals('Default', lstLoan1.get(0).Status__c);
        // farmer 2 was not updated, the Id was wrong
        List<Loan__c> lstLoan2 = [SELECT 
										Id, 
										Status__c
									FROM Loan__c WHERE Id = :loanId2];
		
		System.assertEquals(1, lstLoan2.size());
		System.assertEquals('Applied', lstLoan2.get(0).Status__c);
		
		System.debug('Test finished');
 		
    }
    
     static testMethod void updateLoansNoIdParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		// error in the JSON last Id wrong
		req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Ids":"dummy","Status":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Id] in one of the objects', result.description);
		
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoansNoStatusParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		// error in the JSON, last Status wrong
		req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Id":"dummy","Statqs":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Status] in one of the objects', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoansGetException() {
    	// set the datasource to mock
     	EwarehouseServiceBase.setDataSource(new DataSourceExceptionMock.AllExceptionMock());
     	
     	// start the test
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Processed"}]');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoansRestService.updateLoans();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    
    
    static District__c getTestDistrict(){
    	District__c district = new District__c();
    	district.Name = 'Isiolo';
    	return district;
    }
    
    static Country__c getTestCountry(){
    	Country__c country = new Country__c();
    	country.Name = 'Kenya';
    	country.ISO_Standard_Code__c = 'KE';
    	country.Language__c = 'Swahili';
    	return country;
    }

    static Person__c getTestPerson(Country__c country, District__c district){
    	
    	Person__c person = new Person__c();
    	
    	person.First_Name__c = 'Jane';
    	person.Last_Name__c = 'Fonda';
    	person.Date_of_Birth__c = date.newinstance(1937, 12, 21);
    	person.Raw_Mobile_Number__c = '+254123456789';
    	person.Phone_Number__c = '+254987654321';
    	person.Gender__c = 'Female';
    	person.Village__c = 'Kisumu';
    	person.City__c = 'Kisumu city';
    	person.District__c = district.Id;
    	person.Country__c = country.Id;
    	person.ID_Number__c = 'ID0987654321';
    	
    	return person;
    }
    
    static Farmer__c getTestFarmer(Person__c person){
    	Farmer__c farmer = new Farmer__c();
    	farmer.Name = '3eyUUD';
    	farmer.Person__c = person.Id;
    	farmer.Status__c = 'Processed';
    	return farmer;
    }
    
    static Loan__c getLoan(Farmer__c farmer){
    	
    	Loan__c loan = new Loan__c();
		loan.Amount_Applied_For__c = 130000;
		loan.Amount_Approved__c = 120000;
		loan.Application_Date__c = date.newinstance(2013, 4, 30);
		loan.Decision_Date__c = date.newinstance(2013, 5, 1);
		loan.Status__c = 'Applied';
		loan.Currency__c = 'KES';
		loan.Farmer__c = farmer.Id;	
    	
		return loan;
    	
    }
    
    static Sale__c getSale(Farmer__c farmer){
    	Sale__c sale = new Sale__c();
    	sale.Farmer__c = farmer.Id;
    	sale.Sale_Price__c = 1500.00;
    	sale.Purchaser_Name__c = 'John Doe';
		
		return sale;
    	
    }
    
    static Loan_Repayment__c getLoanRepayment(Loan__c loan, Sale__c sale){

    	Loan_Repayment__c lr = new Loan_Repayment__c();
    	lr.Amount__c = 1500.00;
		lr.Payment_Date__c = date.newinstance(2013, 4, 30);
		lr.Remarks__c = 'reason';
		lr.Loan__c = loan.Id;
		lr.Sale__c = sale.Id;
		
		return lr;
    	
    }
}