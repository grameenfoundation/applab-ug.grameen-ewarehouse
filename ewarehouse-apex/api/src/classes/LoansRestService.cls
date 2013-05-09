@RestResource(urlMapping='/ewarehouse/loans/*')
global class LoansRestService extends EwarehouseServiceBase {
	
	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getLoans() {
    	
    	Map<String, String> params = null;
		
		// get the id from the request parameter
		String status = RestContext.request.params.get('Status');
		
		if(status == null){
			System.debug('ERROR: request param [Status] should not be null');
			return new ErrorResponse('We could find required parameter [Status]');
		}
        
        system.debug('Status = ' + status);
        
        List<Loan> loanList = new List<Loan>();
        List<Loan__c> loans;
        try {
        	loans = EwarehouseServiceBase.dataSource.getLoansByStatus(status);
        }
        catch(Exception e){
        	system.debug('ERROR: ' + e);
	       	return new ExceptionResponse(e);
        }
        		
        // iterate through farmers and convert to clients														
		for(Loan__c f: loans){
			loanList.add(Loan.fromSObject(f));
		}

		return new LoansRestService.LoansResponse(loanList);
	}
	
	@HttpPatch
	global static EwarehouseServiceBase.ServiceResultResponse updateLoans(){ //String id, String status
		
		// take the client from the parameters
		String jsonString = RestContext.request.requestBody.toString();	
		system.debug('json: ' + jsonString);
		
		// parse the loan data
		List<Map<String, String>> parameters = (List<Map<String, String>>) JSON.deserialize(jsonString, List<Map<String, String>>.class);
		system.debug(parameters);
		
		// Store all the Ids in a Set and the objects in its own update map to be able to find the Status by Id
		Set<String> ids = new Set<String>();
		Map<String, String> updateMap = new Map<String, String>();
		for(Map<String, String> item : parameters){
			// first check if the required parameters are available
			if(!item.containsKey('Id'))
				return new ErrorResponse('JSON ERROR: We could find required parameter [Id] in one of the objects');
			if(!item.containsKey('Status'))
				return new ErrorResponse('JSON ERROR: We could find required parameter [Status] in one of the objects');
				
			ids.add(item.get('Id'));
			updateMap.put(item.get('Id'), item.get('Status'));
		}
		system.debug(ids);
		
		// put the whole loop for updating records in a try-catch, any exception thrown will be returned to the user
		try {
			// build a query with all the Ids and update item per item
			for(Loan__c l: EwarehouseServiceBase.dataSource.getLoans(ids)){
				// check if the Id can be found in the update map, using the Id field
				if(!updateMap.containsKey(l.Id))
					return new ErrorResponse('Trying to update ['+l.Id+'], while the Status is not stored in the Map. POST-JSON:' + jsonString);
					
				// update the farmer, set the status to the one given
				l.Status__c = updateMap.get(l.Id);
				EwarehouseServiceBase.dataSource.updateLoan(l);
				
				// remove the farmer from the update map, the map while then be left with farmers not found in the query 
				updateMap.remove(l.Id);
			}	
		}
		catch(Exception e){
			system.debug('EXCEPTION: ' + e);
	       	return new ExceptionResponse(e);
		}
		
		if(updateMap.isEmpty()){
			return new SuccessResponse('Update success');
		}
		else {
			system.debug(updateMap);
			return new ErrorMapResponse('Not all IDs where found as client, attached Ids not updated.', updateMap);
		}
	}
	
	global class LoansResponse extends ServiceResultResponse {
		public LoansResponse(Loan[] loans){
			this.code = '200';
			this.description = 'OK';
			this.loans = loans;
		}
		
		public Loan[] loans;
	}
}