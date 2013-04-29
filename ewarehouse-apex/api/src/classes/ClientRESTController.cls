@RestResource(urlMapping='/client/*')
global class ClientRESTController {

 	@HttpGet
    global static Client getClient() {
		// get the id from the request parameter
        String id = RestContext.request.params.get('id');
        system.debug('id = ' + id);
        
        List<eu_himmit__Client__c> lstClient= [SELECT 
									ID, 
									Name, 
									eu_himmit__Date_of_birth__c,
									eu_himmit__Time_authorized__c,
									eu_himmit__Married__c
								FROM eu_himmit__Client__c WHERE Id = :id];
		if (lstClient.size() > 0)
		{
			eu_himmit__Client__c clObj = lstClient.get(0);
	        
	        Client client = new Client();
        								
	        client.id = clObj.ID;
	        client.name = clObj.Name;
	        client.dateOfBirth = clObj.eu_himmit__Date_of_birth__c;
	        client.timeAuthorized = clObj.eu_himmit__Time_authorized__c;
	        client.married = clObj.eu_himmit__Married__c;
			
			return client;
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