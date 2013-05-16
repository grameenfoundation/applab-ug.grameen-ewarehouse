@RestResource(urlMapping='/ewarehouse/repayments/*')
global class LoanRepaymentRestService extends EwarehouseServiceBase  {
	
	@HttpGet
    global static ServiceResultResponse getRepayments() {
    	
    	Map<String, String> params = null;
		
		// get the id from the request parameter
		String loanId = RestContext.request.params.get('LoanId');
		
		if(loanId == null){
			System.debug('ERROR: request param [LoanId] should not be null');
			return new ErrorResponse('We could find required parameter [LoanId]');
		}
        
        system.debug('LoanId = ' + loanId);
        
        // get all the sObjects
        List<Repayment> repayments = new List<Repayment>();
        List<Loan_Repayment__c> sfRepayments;
        try {
        	sfRepayments = EwarehouseServiceBase.dataSource.getLoanRepayments(loanId);
        }
        catch(Exception e){
        	system.debug('ERROR: ' + e);
	       	return new ExceptionResponse(e);
        }
        		
        // iterate through repayments and convert to objects for json														
		for(Loan_Repayment__c lr: sfRepayments){
			
			Repayment item = new Repayment();
			item.Amount = lr.Amount__c;
			item.PaymentDate = lr.Payment_Date__c;
			item.Remarks = lr.Remarks__c;
			item.LoanId = lr.Loan__c;
			item.SaleId = lr.Sale__c;
			
			repayments.add(item);
		}

		// return the Loan Repayments
		return new RepaymentResponse(repayments);
	}
	
	@HttpPost
	global static ServiceResultResponse addRepayments(){ 
		
		// list of repayments to be stored
		List<Loan_Repayment__c> loanRepayments = new List<Loan_Repayment__c>();
		
		// take the client from the parameters
		String jsonString = RestContext.request.requestBody.toString();	
		system.debug('json: ' + jsonString);
		
		// parse the client data
		List<Repayment> repayments = null;
		try{
			repayments = (List<Repayment>) JSON.deserialize(jsonString, List<Repayment>.class);
			
			// Loop through the repayments and convert to SObjects
			for(Repayment item : repayments){
				Loan_Repayment__c lr = new Loan_Repayment__c();
				lr.Amount__c = item.Amount;
				lr.Payment_Date__c = item.PaymentDate;
				lr.Remarks__c = item.Remarks;
				lr.Loan__c = item.LoanId;
				lr.Sale__c = item.SaleId;
				loanRepayments.add(lr);
			}
		}
		catch(Exception e){
			system.debug('EXCEPTION: ' + e);
	       	return new ExceptionResponse(e);
		}
		
		if(loanRepayments.size() > 9000){
			return new ErrorResponse('Only 9000 records are allowed in one batch, please split the upload in smaller amounts');
		}
		
		system.debug('Repayments: ' + repayments);
	
		// insert the loan repayments
		Database.Saveresult[] results = null;
		try {
			system.debug('tester-start');
			results = EwarehouseServiceBase.dataSource.addLoanRepayments(loanRepayments);
			system.debug(results);
			system.debug('tester-end');
			
		}
		catch(Exception e){
			system.debug('EXCEPTION: ' + e);
	       	return new ExceptionResponse(e);
		}
		
		// check if there where errors
		boolean errors = false;
		String errorMessage = '';
		for(Database.SaveResult result : results){
			if(!result.isSuccess()){
				errors = true;
				errorMessage += '--------------------------\n';
				for(Database.Error err : result.getErrors()){
					errorMessage += err.getStatusCode() + ':' + err.getMessage() + '\n\n';
				}
			}
		}
		// check whether there were errors during posting
		if(errors){
			system.debug(errorMessage);
			return new ErrorResponse('Error while posting loan repayments:\n ' + errorMessage);
		}
		
		// return success if no errors occured
		return new SuccessResponse('Loan repayments posted successfully.');
	}
	
	global class RepaymentResponse extends ServiceResultResponse {
		public RepaymentResponse(Repayment[] repayments){
			this.code = '200';
			this.description = 'OK';
			this.repayments = repayments;
		}
		
		public Repayment[] repayments;
	}
	
	public class Repayment {
		public String Id { get; set; }
		public String LoanId { get; set; }
		public String SaleId { get; set; }
		public Decimal Amount { get; set; }
		public String Remarks { get; set; }
		public Date PaymentDate { get; set; }
	}

}