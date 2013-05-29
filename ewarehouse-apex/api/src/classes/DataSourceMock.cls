@isTest
public with sharing class DataSourceMock {
	
	public static Map<String, String> insertTestData(){
		
		Map<String, String> ids = new Map<String, String>();
		
		// create and insert country
        Country__c country = getTestCountry();
        insert country;
        
        // create and insert district
        District__c district = getTestDistrict();
        insert district;
        
        // create and insert 2 Persons
        Person__c person1 = getTestPerson(country, district);
        Person__c person2 = getTestPerson(country, district);
        person2.First_Name__c = 'John';
        person2.Last_Name__c = 'Lennon';
        insert person1;
        insert person2;
        
        // with the person id, create and insert a Farmer
        Farmer__c farmer1 = getTestFarmer(person1);
        Farmer__c farmer2 = getTestFarmer(person2);
        farmer2.Name = '2eyUUD';
        insert farmer1;
        insert farmer2;
        
        Harvest__c harvest1 = getHarvest(farmer1);
        Harvest__c harvest2 = getHarvest(farmer2);
        insert harvest1;
        insert harvest2;
        
        // create a loan
    	Loan__c loan1 = getLoan(farmer1, harvest1);
    	Loan__c loan2 = getLoan(farmer2, harvest2);
    	insert loan1;
    	insert loan2;
    	
    	// create sales
    	Sale__c sale1_1 = getSale(farmer1);
    	Sale__c sale1_2 = getSale(farmer1);
    	Sale__c sale2_1 = getSale(farmer2);
    	Sale__c sale2_2 = getSale(farmer2);
    	insert sale1_1;
    	insert sale1_2;
    	insert sale2_1;
    	insert sale2_2;
    	
    	// create loan repayments
    	Loan_Repayment__c loanRepayment1_1 = getLoanRepayment(loan1, sale1_1);
    	Loan_Repayment__c loanRepayment1_2 = getLoanRepayment(loan1, sale1_2);
    	Loan_Repayment__c loanRepayment2_1 = getLoanRepayment(loan2, sale2_1);
    	Loan_Repayment__c loanRepayment2_2 = getLoanRepayment(loan2, sale2_2);
    	insert loanRepayment1_1;
    	insert loanRepayment1_2;
    	insert loanRepayment2_1;
    	insert loanRepayment2_2;   
    	
    	Sale_Farmer__c sf1 = getSaleFarmer(sale1_1, farmer1);
    	Sale_Farmer__c sf2 = getSaleFarmer(sale1_1, farmer2);
    	Sale_Farmer__c sf3 = getSaleFarmer(sale2_1, farmer1);
    	Sale_Farmer__c sf4 = getSaleFarmer(sale2_1, farmer2);
    	insert sf1;
    	insert sf2;
    	insert sf3;
    	insert sf4;
        
        ids.put('person1Id', person1.Id);
        ids.put('person2Id', person2.Id);
        ids.put('farmer1Id', farmer1.Id);
        ids.put('farmer2Id', farmer2.Id);
        ids.put('farmer1Name', farmer1.Name);
        ids.put('farmer2Name', farmer2.Name);
        ids.put('loan1Id', loan1.Id);
        ids.put('loan2Id', loan2.Id);
        ids.put('sale1_1Id', sale1_1.Id);
        ids.put('sale1_2Id', sale1_2.Id);
        ids.put('sale2_1Id', sale2_1.Id);
        ids.put('sale2_2Id', sale2_2.Id);
        ids.put('loanRepayment1_1Id', loanRepayment1_1.Id);
        ids.put('loanRepayment1_2Id', loanRepayment1_2.Id);
        ids.put('loanRepayment2_1Id', loanRepayment2_1.Id);
        ids.put('loanRepayment2_2Id', loanRepayment2_2.Id);
        ids.put('sf1Id', sf1.Id);
        ids.put('sf2Id', sf2.Id);
        ids.put('sf3Id', sf3.Id);
        ids.put('sf4Id', sf4.Id);
        
        system.debug(ids);

        return ids;
	}
	
	// mock data for test runs
	static District__c getTestDistrict(){
        District__c district = new District__c();
        district.Name = 'Isiolo';
        return district;
    }
    
    static Country__c getTestCountry(){
        Country__c country = new Country__c();
        country.Name = 'Kenya';
        country.ISO_Standard_Code__c = 'KE';
        country.Language__c = 'Swahili';
        return country;
    }

    static Person__c getTestPerson(Country__c country, District__c district){
        
        Person__c person = new Person__c();
        
        person.First_Name__c = 'Jane';
        person.Middle_Name__c = 'The Actrice';
        person.Last_Name__c = 'Fonda';
        person.Date_of_Birth__c = date.newinstance(1937, 12, 21);
        person.Raw_Mobile_Number__c = '+254123456789';
        person.Gender__c = 'Female';
        person.Village__c = 'Kisumu';
        person.City__c = 'Kisumu city';
        person.District__c = district.Id;
        person.Country__c = country.Id;
        person.ID_Number__c = 'ID0987654321';
        person.Picture_URL__c = 'http://www.himmelreich-it.com/image.jpg';
        person.Next_Of_Kin__c = 'Ted Turner';
        person.Next_Of_Kin_Telephone__c = '+254123456788';
        
        return person;
    }
    
    static Farmer__c getTestFarmer(Person__c person){
        Farmer__c farmer = new Farmer__c();
        farmer.Name = '3eyUUD';
        farmer.Person__c = person.Id;
        farmer.Status__c = 'Processed';
        return farmer;
    }
    
    static Harvest__c getHarvest(Farmer__c farmer){
    	Harvest__c h = new Harvest__c();
    	h.Crop__c = 'Beans';
    	h.Date_Harvested__c = date.newinstance(2013, 4, 30);
    	h.Farmer__c = farmer.Id;
    	h.Quantity_Accepted__c = 1000.01;
    	h.Quantity_Harvested__c = 2000.03;
    	h.Quantity_Rejected__c = 1000.02;
    	h.Storage_Location__c = 'Home';
    	return h;
    }
    
    static Loan__c getLoan(Farmer__c farmer, Harvest__c harvest){
    	
    	Loan__c loan = new Loan__c();
		loan.Amount_Applied_For__c = 130000;
		loan.Amount_Approved__c = 120000;
		loan.Application_Date__c = date.newinstance(2013, 4, 30);
		loan.Decision_Date__c = date.newinstance(2013, 5, 1);
		loan.Balance__c = 120000;
		loan.Status__c = 'Applied';
		loan.Currency__c = 'KES';
		loan.Farmer__c = farmer.Id;	
		loan.Harvest__c = harvest.Id; 
    	
		return loan;
    	
    }
    
    static Sale__c getSale(Farmer__c farmer){
    	Sale__c sale = new Sale__c();
    	sale.Farmer__c = farmer.Id;
    	sale.Sale_Price__c = 1500.00;
    	sale.Purchaser_Name__c = 'John Doe';
		
		return sale;
    	
    }
    
    static Sale_Farmer__c getSaleFarmer(Sale__c sale, Farmer__c farmer){
    	Sale_Farmer__c sf = new Sale_Farmer__c();
    	sf.Amount_Applied__c = 6000.10;
    	sf.Farmer__c = farmer.Id;
    	sf.Sale__c = sale.Id;
    	return sf;
    }
    
    static Loan_Repayment__c getLoanRepayment(Loan__c loan, Sale__c sale){

    	Loan_Repayment__c lr = new Loan_Repayment__c();
    	lr.Amount__c = 1500.00;
		lr.Payment_Date__c = date.newinstance(2013, 4, 30);
		lr.Remarks__c = 'reason';
		lr.Loan__c = loan.Id;
		lr.Sale__c = sale.Id;
		
		return lr;
    	
    }
	
	// mock datasource implementations
	public class AllExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
		public List<Farmer__c> getFarmer(String name){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateFarmer(Farmer__c farmer){
			throwError();
			return null;
		}
		
		public List<Farmer__c> getFarmersByStatus(String status){
			throwError();
			return null;
		}
		
		public Farmer__c[] getFarmers(Set<String> farmerIds){
			throwError();
			return null;
		}
		
		public List<Loan__c> getLoan(String id){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateLoan(Loan__c loan){
			throwError();
			return null;
		}
		
		public Loan__c[] getLoansByStatus(String status){
			throwError();
			return null;
		}
		
		public Loan__c[] getLoans(Set<String> loanIds){
			throwError();
			return null;
		}
		
		public Database.SaveResult[] addLoanRepayments(Loan_Repayment__c[] loanRepayments){
			throwError();
			return null;
		}
		
		public Loan_Repayment__c[] getLoanRepayments(String loanId){
			throwError();
			return null;
		}
		
		public Sale__c[] getSales(String status){
			throwError();
			return null;
		}
		
		public Sale_Farmer__c[] getSaleFarmers(String saleId){
			throwError();
			return null;
		}
		
		public Sale__c[] getSales(Set<String> saleIds){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateSale(Sale__c sale){
			throwError();
			return null;
		}
	}
	
	public class UpdateFarmerLoanExceptionMock implements EwarehouseDataSource.IEwarehouseDataSource {
		EwarehouseDataSource ds = new EwarehouseDataSource();
		public List<Farmer__c> getFarmer(String name){
			return ds.getFarmer(name);
		}
		
		public List<Farmer__c> getFarmersByStatus(String status){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateFarmer(Farmer__c farmer){
			throwError();
			return null;
		}
		
		public Farmer__c[] getFarmers(Set<String> farmerIds){
			throwError();
			return null;
		}
		
		public List<Loan__c> getLoan(String id){
			return ds.getLoan(id);
		}
		
		public Database.SaveResult updateLoan(Loan__c loan){
			throwError();
			return null;
		}
		
		public Loan__c[] getLoansByStatus(String status){
			throwError();
			return null;
		}
		
		public Loan__c[] getLoans(Set<String> loanIds){
			throwError();
			return null;
		}
		
		public Database.SaveResult[] addLoanRepayments(Loan_Repayment__c[] loanRepayments){
			throwError();
			return null;
		}
		
		public Loan_Repayment__c[] getLoanRepayments(String loanId){
			throwError();
			return null;
		}
		
		public Sale__c[] getSales(String status){
			throwError();
			return null;
		}
		
		public Sale_Farmer__c[] getSaleFarmers(String saleId){
			throwError();
			return null;
		}
		
		public Sale__c[] getSales(Set<String> saleIds){
			throwError();
			return null;
		}
		
		public Database.SaveResult updateSale(Sale__c sale){
			throwError();
			return null;
		}
	}
	
	public static void throwError(){
		insert new Farmer__c();
	}
	
	
}