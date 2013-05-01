/**
 * This class contains unit tests for validating the behavior of Client REST API
 */
@isTest
private class ClientWsTest {
// TODO create test for no farmer found and no parameter given, check other things that might happen

    static testMethod void getClient() {
    	
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
 		
 		system.debug('Farmer id=' + id);
 		
 		// ready to start the test
 		test.startTest();
    	
    	// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = 'https://na15.salesforce.com/services/apexrest/client';
		req.httpMethod = 'GET';
		// set as parameter the just stored id
		req.addParameter('id', id);
		RestContext.request = req;
		RestContext.response = res;
		
		// load the results in the client (normally converted to JSON via API)
		ClientWS.ClientResponse result = (ClientWS.ClientResponse) ClientWS.getClient();
		
		test.stopTest();
		
		// assert what was stored
		
		System.assertEquals('200',result.code);
		System.assertEquals('OK',result.description);
		System.assertEquals('Jane',result.client.FirstName);
		System.assertEquals('Fonda',result.client.LastName);
		System.assertEquals(date.newinstance(1937, 12, 21),result.client.DateOfBirth);
		System.assertEquals('+254123456789',result.client.MobileNumber);
		System.assertEquals('+254987654321',result.client.PhoneNumber);
		System.assertEquals('Female',result.client.Gender);
		System.assertEquals('Kisumu',result.client.Village);
		System.assertEquals('Kisumu city',result.client.City);
		System.assertEquals('Isiolo',result.client.District);
		System.assertEquals('Kenya',result.client.Country);
		System.assertEquals('ID0987654321',result.client.IDNumber);
		
		System.debug('Test finished');
    }
    /*
    static testMethod void updateClient() {
    	// insert a test client
    	eu_himmit__Client__c client = getTestClient();
    	insert client;
    	
    	// get the newly inserted client id
    	String id = client.id; 
 		
 		system.debug('client id=' + id);
 		
 		test.startTest();

		// create request and response
    	RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
 		// do the request
		req.requestURI = 'https://na15.salesforce.com/services/apexrest/client';
		req.httpMethod = 'PATCH';
		// set as parameter the just stored id
		req.addParameter('client', '{"timeAuthorized":"2013-04-27T14:32:00.000Z","name":"Jane Fonda","married":false,"id":"'+id+'","dateOfBirth":"1937-12-21"}');
		RestContext.request = req;
		RestContext.response = res;
		// load the results in the client (normally converted to JSON via API)
		String result = ClientRESTController.updateClient();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('success', result);

        List<eu_himmit__Client__c> lstClient= [SELECT 
									ID, 
									Name, 
									eu_himmit__Date_of_birth__c,
									eu_himmit__Time_authorized__c,
									eu_himmit__Married__c
								FROM eu_himmit__Client__c WHERE Id = :id];
		
		System.assertEquals(1, lstClient.size());
		
		eu_himmit__Client__c clObj = lstClient.get(0);
        
        System.assertEquals('Jane Fonda', clObj.Name);
        System.assertEquals(date.newinstance(1937, 12, 21), clObj.eu_himmit__Date_of_birth__c);
        // 3 hour time difference, check how we can do this without
        System.assertEquals(datetime.newinstance(2013, 4, 27, 17, 32, 00), clObj.eu_himmit__Time_authorized__c);
        System.assertEquals(false, clObj.eu_himmit__Married__c);
	
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
    	return farmer;
    }
}