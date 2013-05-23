/**
 * This class contains unit tests for validating the behavior of Sales REST API
 */
@isTest
private class SalesRestServiceTest {

	private static String testRequestURI = '/services/apexrest/ewarehouse/sales'; 

    static testMethod void getSales() {
    	
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
    	
    	Sale__c sale1 = getSale(farmer1);
    	Sale__c sale2 = getSale(farmer2);
    	insert sale1;
    	insert sale2;
    	
    	Sale_Farmer__c sf1 = getSaleFarmer(sale1, farmer1);
    	Sale_Farmer__c sf2 = getSaleFarmer(sale1, farmer2);
    	Sale_Farmer__c sf3 = getSaleFarmer(sale2, farmer1);
    	Sale_Farmer__c sf4 = getSaleFarmer(sale2, farmer2);
    	insert sf1;
    	insert sf2;
    	insert sf3;
    	insert sf4;
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		req.addParameter('Status', 'New');
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the loan (normally converted to JSON via API)
		SalesRestService.SalesResponse result = (SalesRestService.SalesResponse) SalesRestService.getSales();
		
		test.stopTest();
		
		// assert what was stored
		system.debug(result);
		
		
		System.debug('Test finished');
    }
    /*
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
		req.addParameter('Status', 'dummy');
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoansRestService.getLoans();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
     }
    
    static testMethod void getLoansNoStatusParam() {
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
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) LoansRestService.getLoans();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [Status]', result.description);
		
		System.debug('Test finished');
    }
    
    static testMethod void getNoLoansReturned() {

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
    	
    	String farmerId1 = farmer1.Name;
    	String farmerId2 = farmer2.Name;
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		// set as parameter the just stored id
		req.addParameter('Status', 'Applied');
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		LoansRestService.LoansResponse result = (LoansRestService.LoansResponse) LoansRestService.getLoans();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(0,result.loans.size());
		System.debug('Test finished');
    	
    }
    
     static testMethod void getOneLoanReturned() {

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
    	loan2.Status__c = 'Default';
    	insert loan1;
    	insert loan2;
    	
    	String farmerId1 = farmer1.Name;
    	String farmerId2 = farmer2.Name;
    	
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'GET';
		// set as parameter the just stored id
		req.addParameter('Status', 'Applied');
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		LoansRestService.LoansResponse result = (LoansRestService.LoansResponse) LoansRestService.getLoans();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(1,result.loans.size());
		
		System.assertEquals(130000,result.loans[0].AmountApplied);
		System.assertEquals(120000,result.loans[0].AmountApproved);
		System.assertEquals(date.newinstance(2013, 4, 30),result.loans[0].ApplicationDate);
		System.assertEquals(date.newinstance(2013, 5, 1),result.loans[0].DecisionDate);
		System.assertEquals('Applied',result.loans[0].Status);
		System.assertEquals(farmerId1,result.loans[0].FarmerId);
		
		System.debug('Test finished');
    	
    }
    */
    
    static testMethod void updateSale() {
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
    	loan2.Status__c = 'Default';
    	insert loan1;
    	insert loan2;
    	
    	Sale__c sale1 = getSale(farmer1);
    	Sale__c sale2 = getSale(farmer2);
    	insert sale1;
    	insert sale2;
    	
    	Sale_Farmer__c sf1 = getSaleFarmer(sale1, farmer1);
    	Sale_Farmer__c sf2 = getSaleFarmer(sale1, farmer2);
    	Sale_Farmer__c sf3 = getSaleFarmer(sale2, farmer1);
    	Sale_Farmer__c sf4 = getSaleFarmer(sale2, farmer2);
    	insert sf1;
    	insert sf2;
    	insert sf3;
    	insert sf4;
    		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"Id":"'+sale1.Id+'","Status":"Duplicate"},{"Id":"'+sale2.Id+'","Status":"Failed"}]}');
        
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
									FROM Sale__c WHERE Id = :sale1.Id];
		
		System.assertEquals(1, lstSale1.size());
		System.assertEquals('Duplicate', lstSale1.get(0).Status__c);
        
        List<Sale__c> lstSale2 = [SELECT 
										ID, 
										Status__c
									FROM Sale__c WHERE Id = :sale2.Id];
		
		System.assertEquals(1, lstSale2.size());
		System.assertEquals('Failed', lstSale2.get(0).Status__c);
       
		System.debug('Test finished');
 		
    }
    /*
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
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('[{"Id":"'+loanId1+'","Status":"Default", "Balance": 100.02},{"Id":"non-existing","Status":"Default", "Balance": 100.03}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		LoansRestService.LoansErrorResponse result = (LoansRestService.LoansErrorResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('Not all IDs where found as loans, attached Ids not updated.', result.description);
		
		// assert that the farmers are the same for the not updated farmers
		List<Loan__c> lstLoan1 = [SELECT 
										Id, 
										Status__c,
										Balance__c
									FROM Loan__c WHERE Id = :loanId1];
		
		System.assertEquals(1, lstLoan1.size());
		System.assertEquals('Default', lstLoan1.get(0).Status__c);
        // farmer 2 was not updated, the Id was wrong
        List<Loan__c> lstLoan2 = [SELECT 
										Id, 
										Status__c,
										Balance__c
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
		req.httpMethod = 'POST';
		// error in the JSON last Id wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate", "Balance": 100.01},{"Ids":"dummy","Status":"Failed", "Balance": 100.01}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('We could find the property Id in the passed json: ['+ jsonString +']', result.description);
		
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoansNoStatusParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		// error in the JSON, last Status wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate", "Balance": 100.01},{"Id":"dummy","Statqs":"Failed", "Balance": 100.01}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find the property Status in the passed json: ['+ jsonString +']', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateLoansNoBalanceParam() {
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'POST';
		// error in the JSON, last Balance wrong
		String jsonString = '[{"Id":"dummy","Status":"Duplicate", "Balance": 100.01},{"Id":"dummy","Status":"Failed", "Bslance": 100.01}]}';
		req.requestBody = Blob.valueOf(jsonString);
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)LoansRestService.updateLoans();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find the property Balance in the passed json: ['+ jsonString +']', result.description);
	   
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
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Processed", "Balance":100.01}]');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// get an error response instead of client response
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) LoansRestService.updateLoans();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('500',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
 		
    }
    */
        
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
    	sale.Purchaser_Name__c = 'John the purchaser';
    	sale.Sale_Date__c = date.newinstance(2013, 4, 30);
    	sale.Sale_Price__c = 12000.20;
    	sale.Volume_Sold__c = 10101.01;
    	sale.Status__c = 'New';
    	return sale;
    }
    
    static Sale_Farmer__c getSaleFarmer(Sale__c sale, Farmer__c farmer){
    	Sale_Farmer__c sf = new Sale_Farmer__c();
    	sf.Amount_Applied__c = 6000.10;
    	sf.Farmer__c = farmer.Id;
    	sf.Sale__c = sale.Id;
    	return sf;
    }
}