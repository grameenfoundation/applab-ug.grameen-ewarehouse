/**
 * This class contains unit tests for validating the behavior of Client REST API
 */
@isTest
private class ClientRestServiceTest {
// TODO create test for no farmer found and no parameter given, check other things that might happen

    private static String testRequestURI = '/services/apexrest/ewarehouse/client';

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
        
        system.debug('Farmer Id=' + id);
        
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
        ClientRestService.ClientResponse result = (ClientRestService.ClientResponse) ClientRestService.getClient();
        
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
        req.addParameter('Id', 'dummy');
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientRestService.getClient();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('500',result.code);
        
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
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) ClientRestService.getClient();
        
        test.stopTest();
    
        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('We could find required parameter [Id]', result.description);
        
        System.debug('Test finished');
    }
    
    static testMethod void getClientNotExist() {

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
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse) ClientRestService.getClient();
        
        test.stopTest();
        

        // assert error returned
        System.assertEquals('400',result.code);
        System.assertEquals('We could not find a client with the gived Id: [NOTEXISTING]',result.description);
        
        System.debug('Test finished');
        
    }
    
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
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.SuccessResponse result = (EwarehouseServiceBase.SuccessResponse)ClientRestService.updateClient();
        
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
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientRestService.updateClient();
        
        test.stopTest();
        
        // assert error returned
        System.assertEquals('400',result.code);
       
        System.debug('Test finished');
        
    }
    
    static testMethod void updateClientDMLException() {
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
        
        // get the newly inserted farmer id (name field)
        String id = farmer.Name; 
        
        system.debug('farmer id=' + id);
        
        test.startTest();

        // create request and response
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        // do the request
        req.requestURI = testRequestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"'+id+'","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse)ClientRestService.updateClient();
        
        test.stopTest();
        
        // assert error returned
        System.assertEquals('500',result.code);
        
        EwarehouseServiceBase.setDataSource(new EwarehouseDataSource());
        
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
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"Id":"dummy","Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // get an error response instead of client response
        EwarehouseServiceBase.ExceptionResponse result = (EwarehouseServiceBase.ExceptionResponse) ClientRestService.updateClient();
        
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
        req.requestBody = Blob.valueOf('{"Status":"Processed"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        // load the results in the client (normally converted to JSON via API)
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientRestService.updateClient();
        
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
        EwarehouseServiceBase.ErrorResponse result = (EwarehouseServiceBase.ErrorResponse)ClientRestService.updateClient();
        
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
}