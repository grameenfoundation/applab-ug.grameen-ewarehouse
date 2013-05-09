/**
 * This class contains unit tests for validating the behavior of Loan REST API
 */
@isTest
private class LoanRestServiceTest {

	private static String testRequestURI = '/services/apexrest/ewarehouse/loan'; //'https://na15.salesforce.com/services/apexrest/ewarehouse/client'; 

    static testMethod void getLoan() {
    	
    	// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person = getTestPerson(country, district);
    	insert person;
    	system.debug('person id=' + person.Id);
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer = getTestFarmer(person);
    	insert farmer;
    	
    	// create a loan
    	Loan__c loan = getLoan(farmer);
    	insert loan;
    	
    	// get the newly inserted farmer id (name field)
    	String farmerId = farmer.Name;
    	String id = loan.Id; 
 		
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
		System.assertEquals(date.newinstance(2013, 4, 30),result.loan.ApplicationDate);
		System.assertEquals(date.newinstance(2013, 5, 1),result.loan.DecisionDate);
		System.assertEquals('Applied',result.loan.Status);
		System.assertEquals(farmerId,result.loan.FarmerId);
		
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
		req.addParameter('Id', 'dummy');
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRestService.getLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		
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
    	// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person = getTestPerson(country, district);
    	insert person;
    	system.debug('person id=' + person.Id);
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer = getTestFarmer(person);
    	insert farmer;
    
    	// create a loan
    	Loan__c loan = getLoan(farmer);
    	insert loan;
    	
    	// get the newly inserted farmer id (name field)
    	String farmerId = farmer.Name;
    	String id = loan.Id; 
 		
 		system.debug('Loan Id=' + id);
 		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// update the loan
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Updated: Loan Id ['+id+'], Status: [Processed]', result.description);
		
		List<Loan__c> lstLoan = [SELECT 
										ID, 
										Status__c
									FROM Loan__c WHERE Id = :id];
		
		System.assertEquals(1, lstLoan.size());
		
		Loan__c loanObj = lstLoan.get(0);
        
        System.assertEquals('Processed', loanObj.Status__c);
       
		System.debug('Test finished');
 		
    }
    
    
    static testMethod void updateClientNotExists() {
    	// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person = getTestPerson(country, district);
    	insert person;
    	system.debug('person id=' + person.Id);
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer = getTestFarmer(person);
    	insert farmer;
    	
    	// create a loan
    	Loan__c loan = getLoan(farmer);
    	insert loan;
    	
    	// get the newly inserted farmer id (name field)
    	String farmerId = farmer.Name;
    	String id = loan.Id + 'oeps'; 
 		
 		system.debug('Loan Id=' + id);
 	 		
 	 	test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
		
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
     	EwarehouseServiceBase.setDataSource(new DataSourceExceptionMock.UpdateFarmerLoanExceptionMock());
     	
    	// create and insert country
    	Country__c country = getTestCountry();
    	insert country;
    	
    	// create and insert district
    	District__c district = getTestDistrict();
    	insert district;
    	
    	// create and insert a Person
    	Person__c person = getTestPerson(country, district);
    	insert person;
    	system.debug('person id=' + person.Id);
    	
    	// with the person id, create and insert a Farmer
    	Farmer__c farmer = getTestFarmer(person);
    	insert farmer;
    	
    	// create a loan
    	Loan__c loan = getLoan(farmer);
    	insert loan;
    	
    	// get the newly inserted farmer id (name field)
    	String farmerId = farmer.Name;
    	String id = loan.Id; 
 		
 		system.debug('Loan Id=' + id);
 		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert error returned
		System.assertEquals('400',result.code);
		System.assertEquals('EXCEPTION: System.DmlException: Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Person__c]: [Person__c]',result.description);
		
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
		
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoanGetException() {
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
		req.requestBody = Blob.valueOf('{"Id":"dummy","Status":"Processed"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoanRestService.updateLoan();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    
    
    static testMethod void updateLoanNoIdParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('{"Status":"Processed"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [Id]', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoanNoStatusParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('{"Id":"whatever"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoanRestService.updateLoan();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [Status]', result.description);
		
       
		System.debug('Test finished');
 		
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
}