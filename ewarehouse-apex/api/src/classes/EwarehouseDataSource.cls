/*
 * Datasource for accessing objcets within Salesforce. Includes Interface which can be used to Mock the class during testing
 * Classes will use the Interface [IEwarehouseDataSource] and instantiate by default the [EwarehouseDataSource]
 */
public with sharing class EwarehouseDataSource implements IEwarehouseDataSource {
	/*
	 * This method returns a Farmer object from SalesForce wuth the appropriate information needed for the Client object
	 */
	public List<Farmer__c> getFarmer(String name){
		
		// Select the client by name (Farmer ID in SalesForce)
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
	
	public List<Farmer__c> getFarmersByStatus(String status){
		// Select the client by status 
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
				FROM Farmer__c WHERE Status__c = :status];
	}
	
	public Database.SaveResult updateFarmer(Farmer__c farmer){
		return Database.update(farmer);
	}
	
	public Farmer__c[] getFarmers(Set<String> farmerIds){
		String q = 'SELECT Id, Name, Status__c FROM Farmer__c WHERE Name IN :farmerIds';
		return Database.query(q);
	}
	
	public List<Loan__c> getLoan(String id){
		// Select the client by status 
		return [SELECT 
					Id, 
					Name, 
					Amount_Applied_For__c,
					Amount_Approved__c,
					Application_Date__c,
					Currency__c,
					Decision_Date__c,
					Farmer__r.Name,
					Status__c
				FROM Loan__c WHERE Id = :id];
	}
	
	public Database.SaveResult updateLoan(Loan__c loan){
		return Database.update(loan);
	}
	
	public Loan__c[] getLoansByStatus(String status){
		// Select the client by status 
		return [SELECT 
					Id, 
					Name, 
					Amount_Applied_For__c,
					Amount_Approved__c,
					Application_Date__c,
					Currency__c,
					Decision_Date__c,
					Farmer__r.Name,
					Status__c
				FROM Loan__c WHERE Status__c = :status];
	}
	
	public Loan__c[] getLoans(Set<String> loanIds){
		String q = 'SELECT Id, Status__c FROM Loan__c WHERE Id IN :loanIds';
		return Database.query(q);
	}
	
	public Database.SaveResult[] addLoanRepayments(Loan_Repayment__c[] loanRepayments){
		//List<Database.Saveresult> sr = new List<Database.Saveresult>();
		system.debug('Loan Repayments: ' + loanRepayments);
		/*for(Loan_Repayment__c lr : loanRepayments){
			sr.add(Database.Insert(lr));
		}
		system.debug(sr);
		return sr;//*/
		return Database.Insert(loanRepayments, true);
	}
	
	public Loan_Repayment__c[] getLoanRepayments(String loanId){
		return [SELECT 
					Id, 
					Name, 
					Loan__c,
					Sale__c,
					Amount__c,
					Payment_Date__c,
					Remarks__c
				FROM Loan_Repayment__c WHERE Loan__r.Id = :loanId];
	}
		
	/*
	 * Interface for accessing SalesForce objects for the e-Warehouse
	 */
	public interface IEwarehouseDataSource{
		// returns a Farmer (single item List) given an name (Farmer id)
		List<Farmer__c> getFarmer(String name);
		
		// returns a list of Farmers by status
		List<Farmer__c> getFarmersByStatus(String status);
		
		// update a farmer, currently only used to update the Status
		Database.SaveResult updateFarmer(Farmer__c farmer);
		
		// runs a dynamic query to get clients and returns the associated objects
		Farmer__c[] getFarmers(Set<String> farmerIds);
		
		// get loan by specific id
		List<Loan__c> getLoan(String id);
		
		// get loans by status
		Loan__c[] getLoansByStatus(String status);
		
		// update a loan
		Database.SaveResult updateLoan(Loan__c loan);
		
		// runs a dynamic query to get loans and returns the associated objects
		Loan__c[] getLoans(Set<String> loanIds);
		
		// add loan repayments to salesforce
		Database.SaveResult[] addLoanRepayments(Loan_Repayment__c[] loanRepayments);
		
		// get loan repayments for a specific loan
		Loan_Repayment__c[] getLoanRepayments(String loanId);
	}
	
	
}