@RestResource(urlMapping='/ewarehouse/loan/*')
global class LoanRestService extends EwarehouseServiceBase {
	
	@HttpGet
    global static EwarehouseServiceBase.ServiceResultResponse getLoan() {
    	
    	Map<String, String> params = null;
		
		// get the id from the request parameter
		String id = RestContext.request.params.get('Id');
		
		if(id == null){
			System.debug('ERROR: request param [Id] should not be null');
			return new ErrorResponse('We could find required parameter [Id]');
		}
        
        system.debug('id = ' + id);
        
        List<Loan__c> lstLoans;
        try {
        	lstLoans = EwarehouseServiceBase.dataSource.getLoan(id);
        }
        catch(Exception e){
        	system.debug('ERROR: ' + e);
	       	return new ExceptionResponse(e);
        }																
		
		if (lstLoans.size() > 0)
		{
			Loan__c lObject = lstLoans.get(0);
			return new LoanRestService.LoanResponse(Loan.fromSObject(lObject));
		}
		else{
			System.debug('No Loan found with Id:' + id);
			return new ErrorResponse('We could not find a loan with the gived Id: ['+id+']');
		}
	}
	
	@HttpPost
	global static ServiceResultResponse updateLoan(){ //String id, String status
		
		// take the client from the parameters
		String jsonString = RestContext.request.requestBody.toString();	
		system.debug('json: ' + jsonString);
		
		// parse the client data
		UpdateLoan parameter = null;
		
		// try parse the loan data
		try {
			parameter = (UpdateLoan) JSON.deserialize(jsonString, UpdateLoan.class);
		}catch (Exception e){
			system.debug(e);
			return new ExceptionResponse(e);
		}
		system.debug(parameter);
		
		// check the parameters
		if(parameter.Id == null){
			return new ErrorResponse('We could find the property Id in the passed json: ['+ jsonString +']');
		}
		
		// check the parameters
		if(parameter.Status == null){
			return new ErrorResponse('We could find the property Status in the passed json: ['+ jsonString +']');
		}
		
		// check the parameters
		if(parameter.Balance == null){
			return new ErrorResponse('We could find the property Balance in the passed json: ['+ jsonString +']');
		}
		
		// get the appropriate client
		List<Loan__c> lstLoan = null;
		
		try {
			lstLoan = EwarehouseServiceBase.dataSource.getLoan(parameter.Id);
		}
		catch(Exception e){
			system.debug('EXCEPTION: ' + e);
	       	return new ExceptionResponse(e);
		}
		
		// check if the client exists
		if (lstLoan.size() == 0) {
			// no client found to update
			return new ErrorResponse('We could find a loan with the gived id: ['+ parameter.Id +']');
		}
		
		// seems there is a farmer with this Id to update
		Loan__c loanObj = lstLoan.get(0);
        loanObj.Status__c = parameter.Status;
        loanObj.Balance__c = parameter.Balance;
       	
       	// save the update
       	Database.SaveResult results;
       	try {
       		results = EwarehouseServiceBase.dataSource.updateLoan(loanObj);
        }
       	catch(Exception e){
       		system.debug('ERROR: ' + e);
       		return new ExceptionResponse(e);
       	}
       	
		system.debug(results);
		
		// check if the update was succesful otherwise return the errors -- TODO check how I can get a DML Error in the update for testing
		if(results.isSuccess()){
			return new SuccessResponse('Updated: Loan Id ['+parameter.Id+'], Status: ['+parameter.Status+'], Balance: ['+parameter.Balance+']');
		}
		else{
			system.debug('ERROR: ' + results.getErrors());
			return new DmlErrorResponse('We could update Loan with the gived Id: ['+ parameter.Id +']', results.getErrors());
		}
	}
	
	global class LoanResponse extends ServiceResultResponse {
		public LoanResponse(Loan loan){
			this.code = '200';
			this.description = 'OK';
			this.loan = loan;
		}
		
		public Loan loan;
	}

	
}