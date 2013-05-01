@RestResource(urlMapping='/ewarehouse/clients/*')
global class ClientsWS extends EwarehouseServiceBase  {
	
	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getClients() {
    	
    	Map<String, String> params = null;
		
		// get the id from the request parameter
		String status = RestContext.request.params.get('Status');
		
		if(status == null){
			System.debug('ERROR: request param [Status] should not be null');
			return new ErrorResponse('We could find required parameter [Status]');
		}
        
        system.debug('Status = ' + status);
        
        List<Client> clientList = new List<Client>();
        List<Farmer__c> farmers;
        try {
        	farmers = EwarehouseServiceBase.dataSource.getFarmersByStatus(status);
        }
        catch(Exception e){
        	system.debug('ERROR: ' + e);
	       	return new ExceptionResponse(e);
        }
        		
        // iterate through farmers and convert to clients														
		for(Farmer__c f: farmers){
			clientList.add(Client.fromFarmer(f));
		}

		return new ClientsWS.ClientsResponse(clientList);
	}
	
	global class ClientsResponse extends ServiceResultResponse {
		public ClientsResponse(Client[] clients){
			this.code = '200';
			this.description = 'OK';
			this.clients = clients;
		}
		
		public Client[] clients;
	}

}