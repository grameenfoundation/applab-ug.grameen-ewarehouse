public with sharing class Loan {
	public String Id { get; set; }
	public String FarmerId { get; set; }
	public Decimal AmountApplied { get; set; }
	public Decimal AmountApproved { get; set; }
	public Decimal Balance { get; set; }
	public Date ApplicationDate { get; set; }
	public Date DecisionDate { get; set; }
	public String Status { get; set; }
	public Loan.Harvest Harvest {get; set; }
	
	public static Loan fromSObject(Loan__c loan){
		// get a reference of the farmer's person object
    	Farmer__c farmerRef = loan.Farmer__r;
    	Harvest__c harvestRef = loan.Harvest__r;
    	
    	Loan l = new Loan();
		l.Id = loan.Id;
		l.AmountApplied = loan.Amount_Applied_For__c;
		l.AmountApproved = loan.Amount_Approved__c;
		l.Balance = loan.Balance__c;
		l.ApplicationDate = loan.Application_Date__c;
		l.DecisionDate = loan.Decision_Date__c;
		l.Status = loan.Status__c;
		
    	// take the information from the referenced objects when they are available
    	if(farmerRef != null){
    		l.FarmerId = farmerRef.Name;	
    	}
    	
    	if(harvestRef != null){
    		//Quality_Rating__c cqrRef = harvestRef.Current_Quality_Rating__r;
    		//Quality_Rating__c pqrRef = harvestRef.Previous_Quality_Rating__r;
    		Loan.Harvest h = new Harvest();
    		h.Crop = harvestRef.Crop__c;
    		h.DateHarvested = harvestRef.Date_Harvested__c;
    		h.QuantityAccepted = harvestRef.Quantity_Accepted__c;
    		h.QuantityHarvested = harvestRef.Quantity_Harvested__c;
    		h.QuantityRejected = harvestRef.Quantity_Rejected__c;
    		h.StorageLocation = harvestRef.Storage_Location__c;
    		h.Id = harvestRef.Id;
    		
    		// add the harvest to the loan
    		l.Harvest = h;
    	}
    	
		return l;

		
	}
	
	public class Harvest {
		public String Id { get; set; }
		public String Crop { get; set; }
		public Date DateHarvested { get; set; }
		public Decimal QuantityAccepted { get; set; }
		public Decimal QuantityHarvested { get; set; }
		public Decimal QuantityRejected { get; set; }
		public String StorageLocation{ get; set; }
		
	}
	
}