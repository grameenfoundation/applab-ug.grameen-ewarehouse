@RestResource(urlMapping='/client/*')
global class ClientWS extends ServiceResponses {
	
 	@HttpGet
    global static ServiceResponses.ServiceResultResponse getClient() {
    	
    	Map<String, String> params = null;
		
		// get the id from the request parameter
		String id = RestContext.request.params.get('id');
		
		if(id == null){
			System.debug('ERROR: request param [id] should not be null');
			return new ErrorResponse('400', 'We could find required parameter [id]');
		}
        
        system.debug('id = ' + id);
        																
        List<Farmer__c> lstClient = getFarmer(id);
		
		if (lstClient.size() > 0)
		{
			// TODO catch of not able to get the farmer to a client object
			Farmer__c clObj = lstClient.get(0);
			return new ClientWS.ClientResponse('200', 'OK', Client.fromFarmer(clObj));
		}
		else{
			System.debug('no Farmer found with ID:' + id);
			return new ErrorResponse('400', 'We could find a client with the gived id: ['+id+']');
		}
	}

	/*
	@HttpPatch
	global static String updateClient(){
		
		// take the client from the parameters
		String jsonString = RestContext.request.params.get('client');	
		system.debug('json: ' + jsonString);
		
		// parse the client data
		Client updateClient = (Client) JSON.deserialize(jsonString, Client.class);
		system.debug(updateClient);
		
		// get the appropriate client
		List<Farmer__c> lstClient= getFarmer(updateClient.id);
		
		// check if the client exists
		if (lstClient.size() > 0)
		{
			Farmer__c clObj = lstClient.get(0);
	        
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
	*/
	
	global class ClientResponse extends ServiceResultResponse {
		public ClientResponse(String code, String description, Client client){
			this.code = code;
			this.description = description;
			this.client = client;
		}
		
		public Client client;
	}
	
	private static List<Farmer__c> getFarmer(String name){
		return [SELECT 
					ID, 
					Name, 
					Person__r.First_Name__c,
					Person__r.Last_Name__c,
					Person__r.Date_of_Birth__c,
					Person__r.Mobile_Number__c,
					Person__r.Phone_Number__c,
					Person__r.ID_Number__c,
					Person__r.Village__c,
					Person__r.District__r.Name,
					Person__r.City__c,
					Person__r.Country__r.Name,
					Person__r.Gender__c
				FROM Farmer__c WHERE Name = :name];

	}
	
	
}