/**
 * This class contains unit tests for validating the behavior of Client REST API
 */
@isTest
private class ClientRESTTest {

    static testMethod void getClient() {
    	
    	// insert a test client
    	eu_himmit__Client__c client = getTestClient();
    	insert client;
    	
    	// get the newly inserted client id
    	String id = client.id; 
 		
 		system.debug('client id=' + id);
 		
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
		Client result = ClientRESTController.getClient();
		
		test.stopTest();
		
		// assert what was stored
		System.assertEquals('Jane Fonda',result.name);
		System.assertEquals(true,result.married);
		System.debug('Test finished');
    }
    
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
    
    static eu_himmit__Client__c getTestClient(){
    	// insert a test client
    	eu_himmit__Client__c client = new eu_himmit__Client__c();
    	client.Name = 'Jane Fonda';
    	client.eu_himmit__Married__c = true;
    	client.eu_himmit__Date_of_birth__c = date.newinstance(1937, 12, 21);
    	client.eu_himmit__Time_authorized__c = datetime.newinstance(1960, 1, 22, 8, 20, 51);
    	return client;
    }
}