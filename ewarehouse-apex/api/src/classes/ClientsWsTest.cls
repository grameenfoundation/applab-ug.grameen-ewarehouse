/**
 * This class contains unit tests for validating the behavior of Clients REST API
 */
@isTest
private class ClientsWsTest {
// TODO create test for no farmer found and no parameter given, check other things that might happen

	private static String testRequestURI = '/services/apexrest/ewarehouse/clients'; 

    static testMethod void getClients() {
    	
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
		ClientsWS.ClientsResponse result = (ClientsWS.ClientsResponse) ClientsWS.getClients();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals('Jane',result.clients[0].FirstName);
		System.assertEquals('Fonda',result.clients[0].LastName);
		System.assertEquals(date.newinstance(1937, 12, 21),result.clients[0].DateOfBirth);
		System.assertEquals('+254123456789',result.clients[0].MobileNumber);
		System.assertEquals('+254987654321',result.clients[0].PhoneNumber);
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
		System.assertEquals('+254987654321',result.clients[1].PhoneNumber);
		System.assertEquals('Female',result.clients[1].Gender);
		System.assertEquals('Kisumu',result.clients[1].Village);
		System.assertEquals('Kisumu city',result.clients[1].City);
		System.assertEquals('Isiolo',result.clients[1].District);
		System.assertEquals('Kenya',result.clients[1].Country);
		System.assertEquals('ID0987654321',result.clients[1].IDNumber);
		
		System.debug('Test finished');
    }
    
    static testMethod void getClientDMLException() {
     	
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
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientsWS.getClients();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		
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
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) ClientsWS.getClients();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [Status]', result.description);
		
		System.debug('Test finished');
    }
    
    static testMethod void getNoClientsReturned() {

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
		ClientsWS.ClientsResponse result = (ClientsWS.ClientsResponse) ClientsWS.getClients();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(0,result.clients.size());
		System.debug('Test finished');
    	
    }
    
     static testMethod void getOneClientsReturned() {

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
    	farmer2.Status__c = 'Duplicate';
    	insert farmer1;
    	insert farmer2;
    	
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
		ClientsWS.ClientsResponse result = (ClientsWS.ClientsResponse) ClientsWS.getClients();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals(1,result.clients.size());
		System.assertEquals('John',result.clients[0].FirstName);
		System.assertEquals('Lennon',result.clients[0].LastName);
		System.assertEquals(date.newinstance(1937, 12, 21),result.clients[0].DateOfBirth);
		System.assertEquals('+254123456789',result.clients[0].MobileNumber);
		System.assertEquals('+254987654321',result.clients[0].PhoneNumber);
		System.assertEquals('Female',result.clients[0].Gender);
		System.assertEquals('Kisumu',result.clients[0].Village);
		System.assertEquals('Kisumu city',result.clients[0].City);
		System.assertEquals('Isiolo',result.clients[0].District);
		System.assertEquals('Kenya',result.clients[0].Country);
		System.assertEquals('ID0987654321',result.clients[0].IDNumber);
		
		System.debug('Test finished');
    	
    }
    
    static testMethod void updateClient() {
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
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('[{"Id":"'+farmer1.Name+'","Status":"Duplicate"},{"Id":"'+farmer2.Name+'","Status":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)ClientsWS.updateClients();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Update success', result.description);
		
		List<Farmer__c> lstFarmer1 = [SELECT 
										ID, 
										Name, 
										Status__c
									FROM Farmer__c WHERE Name = :farmer1.Name];
		
		System.assertEquals(1, lstFarmer1.size());
		System.assertEquals('Duplicate', lstFarmer1.get(0).Status__c);
        
        List<Farmer__c> lstFarmer2 = [SELECT 
										ID, 
										Name, 
										Status__c
									FROM Farmer__c WHERE Name = :farmer2.Name];
		
		System.assertEquals(1, lstFarmer2.size());
		System.assertEquals('Failed', lstFarmer2.get(0).Status__c);
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateClientsNotExists() {
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
    	
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = testRequestURI;
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('[{"Id":"'+farmer1.Name+'","Status":"Duplicate"},{"Id":"2eyUUE","Status":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorMapResponse result = (EwarehouseServiceBase.ErrorMapResponse)ClientsWS.updateClients();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400', result.code);
		System.assertEquals('Not all IDs where found as client, attached Ids not updated.', result.description);
		
		// assert that the farmers are the same for the not updated farmers
		List<Farmer__c> lstFarmer1 = [SELECT 
										ID, 
										Name, 
										Status__c
									FROM Farmer__c WHERE Name = :farmer1.Name];
		
		System.assertEquals(1, lstFarmer1.size());
		System.assertEquals('Duplicate', lstFarmer1.get(0).Status__c);
        
        // farmer 2 was not updated, the Id was wrong
        List<Farmer__c> lstFarmer2 = [SELECT 
										ID, 
										Name, 
										Status__c
									FROM Farmer__c WHERE Name = :farmer2.Name];
		
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
		req.httpMethod = 'PATCH';
		// error in the JSON last Id wrong
		req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Ids":"dummy","Status":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientsWS.updateClients();
		
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
		req.httpMethod = 'PATCH';
		// error in the JSON, last Status wrong
		req.requestBody = Blob.valueOf('[{"Id":"dummy","Status":"Duplicate"},{"Id":"dummy","Statqs":"Failed"}]}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// retrieve an error
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientsWS.updateClients();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('JSON ERROR: We could find required parameter [Status] in one of the objects', result.description);
		
       
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateClientGetException() {
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
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientsWS.updateClients();
		
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
}