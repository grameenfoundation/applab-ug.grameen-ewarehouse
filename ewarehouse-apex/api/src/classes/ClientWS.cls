@RestResource(urlMapping='/ewarehouse/client/*')
global class ClientWS extends EwarehouseServiceBase {
	
	static EwarehouseDataSource.IEwarehouseDataSource dataSource = new EwarehouseDataSource();
	
	public static void setDataSource(EwarehouseDataSource.IEwarehouseDataSource sDataSource){
		dataSource = sDataSource;
	}
	
 	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getClient() {
    	
    	Map<String, String> params = null;
		
		// get the id from the request parameter
		String id = RestContext.request.params.get('Id');
		
		if(id == null){
			System.debug('ERROR: request param [Id] should not be null');
			return new ErrorResponse('We could find required parameter [Id]');
		}
        
        system.debug('id = ' + id);
        
        List<Farmer__c> lstClient;
        try {
        	lstClient = dataSource.getFarmer(id);
        }
        catch(Exception e){
        	system.debug('ERROR: ' + e);
	       	return new ExceptionResponse(e);
        }																
		
		if (lstClient.size() > 0)
		{
			// TODO catch of not able to get the farmer to a client object
			Farmer__c clObj = lstClient.get(0);
			return new ClientWS.ClientResponse(Client.fromFarmer(clObj));
		}
		else{
			System.debug('no Farmer found with Id:' + id);
			return new ErrorResponse('We could find a client with the gived Id: ['+id+']');
		}
	}

	
	@HttpPatch
	global static EwarehouseServiceBase.ServiceResultResponse updateClient(){ //String id, String status
		
		// take the client from the parameters
		String jsonString = RestContext.request.requestBody.toString();	
		system.debug('json: ' + jsonString);
		
		// parse the client data
		Map<String, String> parameters = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);
		system.debug(parameters);
		
		// get id parameter
		String id = EwarehouseServiceBase.getParameter(parameters, 'Id');
		if(id == null){
			System.debug('ERROR: request param [Id] should not be null');
			return new ErrorResponse('We could find required parameter [Id]');
		}
		
		String status = EwarehouseServiceBase.getParameter(parameters, 'Status');
		if(status == null){
			System.debug('ERROR: request param [Status] should not be null');
			return new ErrorResponse('We could find required parameter [Status]');
		}
		
		// get the appropriate client
		List<Farmer__c> lstClient = null;
		
		try {
			lstClient = dataSource.getFarmer(id);
		}
		catch(Exception e){
			system.debug('EXCEPTION: ' + e);
	       	return new ExceptionResponse(e);
		}
		
		// check if the client exists
		if (lstClient.size() == 0) {
			// no client found to update
			return new ErrorResponse('We could find a client with the gived id: ['+ id +']');
		}
		
		// seems there is a farmer with this Id to update
		Farmer__c clObj = lstClient.get(0);
        clObj.Status__c = status;
       	
       	// save the update
       	Database.SaveResult results;
       	try {
       		results = dataSource.updateFarmer(clObj);
        }
       	catch(Exception e){
       		system.debug('ERROR: ' + e);
       		return new ExceptionResponse(e);
       	}
       	
		system.debug(results);
		
		// check if the update was succesful otherwise return the errors -- TODO check how I can get a DML Error in the update for testing
		if(results.isSuccess()){
			return new SuccessResponse('Updated: client id ['+id+'], status: ['+status+']');
		}
		else{
			system.debug('ERROR: ' + results.getErrors());
			return new DmlErrorResponse('We could update client with the gived id: ['+ id +']', results.getErrors());
		}
		
	}
	
	
	global class ClientResponse extends ServiceResultResponse {
		public ClientResponse(Client client){
			this.code = '200';
			this.description = 'OK';
			this.client = client;
		}
		
		public Client client;
	}
	/*
	private static List<Farmer__c> getFarmer(String name){
		
		if(Test.isRunningTest()) {
	        // Cause DMLException
	        insert new Lead();
	    }
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
	*/
	
}