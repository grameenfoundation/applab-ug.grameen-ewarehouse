public with sharing class Loan {
	public String Id { get; set; }
	public String FarmerId { get; set; }
	public Decimal AmountApplied { get; set; }
	public Decimal AmountApproved { get; set; }
	public Date ApplicationDate { get; set; }
	public Date DecisionDate { get; set; }
	public String Status { get; set; }
	
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
}