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
			return new LoanRestService.LoanResponse(fromSObject(lObject));
		}
		else{
			System.debug('No Loan found with Id:' + id);
			return new ErrorResponse('We could not find a loan with the gived Id: ['+id+']');
		}
	}
	
	
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
	
	global class LoanResponse extends ServiceResultResponse {
		public LoanResponse(Loan loan){
			this.code = '200';
			this.description = 'OK';
			this.loan = loan;
		}
		
		public Loan loan;
	}

	
}