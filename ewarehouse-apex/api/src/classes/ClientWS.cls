@RestResource(urlMapping='/client/*')
global class ClientWS extends ServiceResponses {

 	@HttpGet
    global static ServiceResultResponse getClient() {
    	
		// get the id from the request parameter
        String id = RestContext.request.params.get('id');
        system.debug('id = ' + id);
        
        /*
        id: String,
                  FirstName: String,
                  LastName: String,
                  DateOfBirth: String,
                  PhoneNumber: String,
                  MobileNumber: String,
                  IDNumber: String,
                  Gender: String,
                  Address1: String,
                  Address2: String,
                  City: String,
                  Country: String
        */
        
        // check PhoneNumber
        // Person__c.IDNumber,
		// Person__c.Address1,
		// Person__c.Address2,
		// Person__c.City,
																		
        List<Farmer__c> lstClient= [SELECT 
									ID, 
									Name, 
									Person__r.First_Name__c,
									Person__r.Last_Name__c,
									Person__r.Date_of_Birth__c,
									Person__r.Contact__r.Phone, 
									Person__r.Mobile_Number__c,
									Person__r.Gender__c,
									Person__r.Country__c
								FROM Farmer__c WHERE Id = :id];
		
		if (lstClient.size() > 0)
		{
			Farmer__c clObj = lstClient.get(0);
			return Client.fromFarmer(clObj);
		}
		return null;
        
	
	}
	
	@HttpPatch
	global static String updateClient(){
		
		// take the client from the parameters
		String jsonString = RestContext.request.params.get('client');	
		system.debug('json: ' + jsonString);
		
		// parse the client data
		Client updateClient = (Client) JSON.deserialize(jsonString, Client.class);
		system.debug(updateClient);
		
		// get the appropriate client
		List<eu_himmit__Client__c> lstClient= [SELECT 
									ID, 
									Name, 
									eu_himmit__Date_of_birth__c,
									eu_himmit__Time_authorized__c,
									eu_himmit__Married__c
								FROM eu_himmit__Client__c WHERE Id = :updateClient.id];
		
		// check if the client exists
		if (lstClient.size() > 0)
		{
			eu_himmit__Client__c clObj = lstClient.get(0);
	        
	        clObj.Name = updateClient.name;
	        clObj.eu_himmit__Date_of_birth__c = updateClient.dateOfBirth;
	        clObj.eu_himmit__Time_authorized__c = updateClient.timeAuthorized;
	        clObj.eu_himmit__Married__c = updateClient.married;
			
			Database.SaveResult results = Database.update(clObj);
			system.debug(results);
			
			//if(results.isSuccess() == 'true')
				return 'success';
		
		}
		return 'error';
	}
}