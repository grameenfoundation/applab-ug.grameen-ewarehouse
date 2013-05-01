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
    
    static testMethod void getClientNoIdParam() {
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
    /*
    static testMethod void updateClient() {
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
    	
    	// get the newly inserted farmer id (name field)
    	String id = farmer.Name; 
    	
 		system.debug('farmer id=' + id);
 		
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
		EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)ClientWS.updateClient();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('200', result.code);
		System.assertEquals('Updated: client id ['+id+'], status: [Processed]', result.description);
		
		List<Farmer__c> lstFarmer = [SELECT 
										ID, 
										Name, 
										Status__c
									FROM Farmer__c WHERE Name = :id];
		
		System.assertEquals(1, lstFarmer.size());
		
		Farmer__c clObj = lstFarmer.get(0);
        
        System.assertEquals('Processed', clObj.Status__c);
       
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
    	
    	// get the newly inserted farmer id (name field), but create an error
    	String id = farmer.Name + 'oeps'; 
    	
 		system.debug('farmer id=' + id);
 		
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
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientWS.updateClient();
		
		test.stopTest();
		
		// assert error returned
		System.assertEquals('400',result.code);
	   
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateClientDMLException() {
    	// set the datasource to mock
     	ClientWS.setDataSource(new DataSourceExceptionMock.UpdateFarmerExceptionMock());
     	
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
    	
    	// get the newly inserted farmer id (name field)
    	String id = farmer.Name; 
    	
 		system.debug('farmer id=' + id);
 		
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
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse)ClientWS.updateClient();
		
		test.stopTest();
		
		// assert error returned
		System.assertEquals('400',result.code);
		
		ClientWS.setDataSource(new EwarehouseDataSource());
		
		System.debug('Test finished');
 		
    }
    
    static testMethod void updateClientGetException() {
    	// set the datasource to mock
     	ClientWS.setDataSource(new DataSourceExceptionMock.AllExceptionMock());
     	
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
		EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientWS.updateClient();
		
		test.stopTest();
	
		// assert error returned
		System.assertEquals('400',result.code);
		
		System.debug('Test finished');
		
		// reset the datasource
		ClientWS.setDataSource(new EwarehouseDataSource());
 		
    }
    
    static testMethod void updateClientNoIdParam() {
    	
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
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientWS.updateClient();
		
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
		req.httpMethod = 'PATCH';
		req.requestBody = Blob.valueOf('{"Id":"whatever"}');
		
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientWS.updateClient();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('400',result.code);
		System.assertEquals('We could find required parameter [Status]', result.description);
		
       
		System.debug('Test finished');
 		
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
}