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
	
	@HttpPatch
	global static EwarehouseServiceBase.ServiceResultResponse updateLoan(){ //String id, String status
		
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
		List<Loan__c> lstLoan = null;
		
		try {
			lstLoan = EwarehouseServiceBase.dataSource.getLoan(id);
		}
		catch(Exception e){
			system.debug('EXCEPTION: ' + e);
	       	return new ExceptionResponse(e);
		}
		
		// check if the client exists
		if (lstLoan.size() == 0) {
			// no client found to update
			return new ErrorResponse('We could find a loan with the gived id: ['+ id +']');
		}
		
		// seems there is a farmer with this Id to update
		Loan__c loanObj = lstLoan.get(0);
        loanObj.Status__c = status;
       	
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
			return new SuccessResponse('Updated: Loan Id ['+id+'], Status: ['+status+']');
		}
		else{
			system.debug('ERROR: ' + results.getErrors());
			return new DmlErrorResponse('We could update Loan with the gived Id: ['+ id +']', results.getErrors());
		}
	}
	/*
	
	
	public static Loan fromSObject(Loan__c loan){
		// get a reference of the farmer's person object
    	Farmer__c farmerRef = loan.Farmer__r;
    	
    	Loan l = new Loan();
		l.Id = loan.Id;
		l.AmountApplied = loan.Amount_Applied_For__c;
		l.AmountApproved = loan.Amount_Approved__c;
		l.ApplicationDate = loan.Application_Date__c;
		l.DecisionDate = loan.Decision_Date__c;
		l.Status = loan.Status__c;
		
    	// take the information from the referenced objects when they are available
    	if(farmerRef != null){
    		l.FarmerId = farmerRef.Name;	
    	}
    	
		System.debug(l);
		
		return l;

		
	}
	
	global class Loan {
		public String Id { get; set; }
		public String FarmerId { get; set; }
		public Decimal AmountApplied { get; set; }
		public Decimal AmountApproved { get; set; }
		public Date ApplicationDate { get; set; }
		public Date DecisionDate { get; set; }
		public String Status { get; set; }
		
	}
	*/
	global class LoanResponse extends ServiceResultResponse {
		public LoanResponse(Loan loan){
			this.code = '200';
			this.description = 'OK';
			this.loan = loan;
		}
		
		public Loan loan;
	}

	
}