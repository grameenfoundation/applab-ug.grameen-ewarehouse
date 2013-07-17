/*
 * Datasource for accessing objcets within Salesforce. Includes Interface which can be used to Mock the class during testing
 * Classes will use the Interface [IEwarehouseDataSource] and instantiate by default the [EwarehouseDataSource]
 */
public with sharing class EwarehouseDataSource implements IEwarehouseDataSource {
	
	public List<Farmer__c> getFarmer(String name){
		return [SELECT
					ID, 
					Name, 
				    Sale_Status__c,
				    Status__c
				FROM 
					Farmer__c
				WHERE
				    Name = :name];
	}
	
	public List<Person__c> getPersons(String value, String columnName){
		// creating the where clause to decide what Persons/Farmers we need to return
		String whereClause = '';
		
		// Status has a special treatment, when it is new, it also should return Status empty results
		if(columnName == 'Status__c'){
			if(value == 'New'){
				whereClause = 'Status__c = \'New\' OR Status__c = \'\'';
			}
			else{
				whereClause = 'Status__c = \''+ value +'\'';
			}
		}
		else {
			whereClause = String.format('%s = \'%s\'', new List<String>{value, columnName});
		}
		String q = 'SELECT Name, First_Name__c, Middle_Name__c, Last_Name__c, Date_of_Birth__c, Mobile_Number__c, ' + 
				   'ID_Number__c,  Village__c, District__r.Name, City__c, Picture_URL__c, Next_Of_Kin__c, ' +
				   'Next_Of_Kin_Telephone__c, Country__r.Name, Gender__c, ' +
				   '(SELECT Name, Group__r.Group_ID__c, Group__r.Name FROM PersonGroupAssociations__r),' +
				   '(SELECT ID, Name, Sale_Status__c FROM Farmers__r)' +
				   'FROM Person__c WHERE Id IN ' +
				   '(SELECT Person__c FROM Farmer__c WHERE '+ whereClause +')';
		return Database.query(q);
	}
	
	public List<Person__c> getPersonsBySet(Set<String> values, String columnName){
        
        String q = 'SELECT Name, First_Name__c, Middle_Name__c, Last_Name__c, Date_of_Birth__c, Mobile_Number__c, ' + 
                   'ID_Number__c,  Village__c, District__r.Name, City__c, Picture_URL__c, Next_Of_Kin__c, ' +
                   'Next_Of_Kin_Telephone__c, Country__r.Name, Gender__c, ' +
                   '(SELECT Name, Group__r.Group_ID__c, Group__r.Name FROM PersonGroupAssociations__r),' +
                   '(SELECT ID, Name, Sale_Status__c FROM Farmers__r)' +
                   'FROM Person__c WHERE Id IN ' +
                   '(SELECT Person__c FROM Farmer__c WHERE '+ columnName +' IN :values)';
        return Database.query(q);
    }
    
    public List<Loan__c> getLoansByFarmerNameSet(Set<String> farmers, Set<String> contracts){
        return [SELECT 
                    Id, 
                    Name, 
                    Amount_Applied_For__c,
                    Amount_Approved__c,
                    Balance__c,
                    Application_Date__c,
                    Currency__c,
                    Decision_Date__c,
                    Farmer__r.Name,
                    Saving_Account_No__c,
                    Loan_Account_No__c,
                    Loan_Contract_No__c,
                    Disburse_Date__c,
                    Maturity_Date__c,
                    Status__c
                FROM Loan__c WHERE Farmer__r.Name IN :farmers];
    }
	
	
	/*
	 * This method returns a Farmer object from SalesForce wuth the appropriate information needed for the Client object
	 * The name is the ID field in the Farmer__c object
	 */
	public List<Person__c> getPerson(String name){
		
		return [SELECT 
				  Name,
				  First_Name__c,
				  Middle_Name__c,
				  Last_Name__c,
				  Date_of_Birth__c,
				  Mobile_Number__c,
				  ID_Number__c,
				  Village__c,
				  District__r.Name,
				  City__c,
				  Picture_URL__c,
				  Next_Of_Kin__c,
				  Next_Of_Kin_Telephone__c,
				  Country__r.Name,
				  Gender__c,
				  (SELECT
				   Name,
					Group__r.Group_ID__c,
					Group__r.Name
				  FROM 
					PersonGroupAssociations__r),
				  (SELECT
					ID, 
					Name, 
				    Sale_Status__c
				  FROM 
					Farmers__r)
				FROM Person__c
				WHERE Id IN
				    (
				    SELECT 
				        Person__c
				    FROM
				        Farmer__c
				    WHERE
				        Name = :name
				    )		
		];
		
	}
	
	public List<Person__c> getPersonsByStatus(String status){
		// Select the client by status
		// when the service gets a request for a status New we get items with Status New but also empty
		if(status == 'New'){
			return [SELECT 
				  Name,
				  First_Name__c,
				  Middle_Name__c,
				  Last_Name__c,
				  Date_of_Birth__c,
				  Mobile_Number__c,
				  ID_Number__c,
				  Village__c,
				  District__r.Name,
				  City__c,
				  Picture_URL__c,
				  Next_Of_Kin__c,
				  Next_Of_Kin_Telephone__c,
				  Country__r.Name,
				  Gender__c,
				  (SELECT
				    Name,
					Group__r.Group_ID__c,
					Group__r.Name
				  FROM 
					PersonGroupAssociations__r),
				  (SELECT
					ID, 
					Name, 
				    Sale_Status__c
				  FROM 
					Farmers__r)
				FROM Person__c
				WHERE Id IN
				    (
				    SELECT 
				        Person__c
				    FROM
				        Farmer__c
				    WHERE
				        Status__c = 'New' OR Status__c = ''
				    )];
		}
		
		// if not status New, get the other
		return [SELECT 
				  Name,
				  First_Name__c,
				  Middle_Name__c,
				  Last_Name__c,
				  Date_of_Birth__c,
				  Mobile_Number__c,
				  ID_Number__c,
				  Village__c,
				  District__r.Name,
				  City__c,
				  Picture_URL__c,
				  Next_Of_Kin__c,
				  Next_Of_Kin_Telephone__c,
				  Country__r.Name,
				  Gender__c,
				  (SELECT
				    Name,
					Group__r.Group_ID__c,
					Group__r.Name
				  FROM 
					PersonGroupAssociations__r),
				  (SELECT
					ID, 
					Name, 
				    Sale_Status__c
				  FROM 
					Farmers__r)
				FROM Person__c
				WHERE Id IN
				    (
				    SELECT 
				        Person__c
				    FROM
				        Farmer__c
				    WHERE Status__c = :status
				    )];
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
					Balance__c,
					Application_Date__c,
					Currency__c,
					Decision_Date__c,
					Farmer__r.Name,
					Harvest__r.Id,
					Harvest__r.Crop__c,
					Harvest__r.Date_Harvested__c,
					Harvest__r.Quantity_Accepted__c,
					Harvest__r.Quantity_Harvested__c,
					Harvest__r.Quantity_Rejected__c,
					Harvest__r.Storage_Location__c,
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
					Balance__c,
					Application_Date__c,
					Currency__c,
					Decision_Date__c,
					Farmer__r.Name,
					Harvest__r.Id,
					Harvest__r.Crop__c,
					Harvest__r.Date_Harvested__c,
					Harvest__r.Quantity_Accepted__c,
					Harvest__r.Quantity_Harvested__c,
					Harvest__r.Quantity_Rejected__c,
					Harvest__r.Storage_Location__c,
					Status__c
				FROM Loan__c WHERE Status__c = :status];
	}
	
	public Loan__c[] getLoans(Set<String> loanIds){
		String q = 'SELECT Id, Status__c FROM Loan__c WHERE Id IN :loanIds';
		return Database.query(q);
	}
	
	public Database.SaveResult[] addLoanRepayments(Loan_Repayment__c[] loanRepayments){
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
	
	// retrieve new sales (not synchronized)
	public Sale__c[] getSales(String status){
		return [SELECT 
					Id, 
					Name, 
					Sale_Price__c,
					Sale_Date__c,
					Volume_Sold__c
				FROM Sale__c WHERE Status__c = :status];
	}
	
	public Sale_Farmer_Association__c[] getSaleFarmers(String saleId){
		return [SELECT 
					Id, 
					Name, 
					Amount_Applied__c,
					Fee_Due__c,
					Fee_Paid__C,
					Farmer__c
				FROM Sale_Farmer_Association__c WHERE Sale__c = :saleId];
	}
	
	public Sale__c[] getSales(Set<String> saleIds){
		String q = 'SELECT Id, Name, Status__c FROM Sale__c WHERE Id IN :saleIds';
		return Database.query(q);
	}
	
	public Database.SaveResult updateSale(Sale__c sale){
		return Database.update(sale);
	}
		
	/*
	 * Interface for accessing SalesForce objects for the e-Warehouse
	 */
	public interface IEwarehouseDataSource{
		// returns a Farmer (single item List) given an name (Farmer id)
		List<Farmer__c> getFarmer(String name);
		
		List<Person__c> getPersons(String value, String columnName);
		
		List<Person__c> getPerson(String name);
		
		// returns a list of Farmers by status
		List<Person__c> getPersonsByStatus(String status);
		
		// get a list of persons given a Set of Strings and a columnname
		List<Person__c> getPersonsBySet(Set<String> values, String columnName);
		
		// retrieve loans by list of farmers for the manual CSV upload from SMEP
		List<Loan__c> getLoansByFarmerNameSet(Set<String> farmers, Set<String> contracts);
		
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
		
		// retrieve sales by status
		Sale__c[] getSales(String status);
		
		// retrieve the sale/farmer list by Sale Id
		Sale_Farmer_Association__c[] getSaleFarmers(String saleId);
		
		// retrieve a list of Sales with a Set of Ids
		Sale__c[] getSales(Set<String> saleIds);
		
		// update the Sale, currently only used to update the Status
		Database.SaveResult updateSale(Sale__c sale);
	}
	
	
}