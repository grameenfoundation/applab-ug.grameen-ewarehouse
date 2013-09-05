@isTest
public with sharing class PaymentAllocationReportControllerTest {
	
    static testMethod void testLeadData(){
    	insertTestData();
    	PaymentAllocationReportController controller = new PaymentAllocationReportController();
        controller.startDate = Date.newinstance(2013, 8, 16);
        //controller.endDate = Date.newinstance(2013, 8, 16);
        
        List<PaymentAllocationReportController.PaymentAllocation> payments = controller.getPayments();
        
        System.assertEquals(0, payments.size());
	}
   
	
	

    private static void insertTestData(){
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
        person2.Gender__c = 'Male';
        insert person1;
        insert person2;
        
        // with the person id, create and insert a Farmer
        Farmer__c farmer1 = getTestFarmer(person1);
        Farmer__c farmer2 = getTestFarmer(person2);
        farmer2.Name = '2eyUUD';
        farmer2.Land_Size__c = 10;
        insert farmer1;
        insert farmer2;
        
        Group__c group1 = getGroup();
        insert group1;
        
        Person_Group_Association__c pga1 = getPersonGroupAsso(group1, person1);
        Person_Group_Association__c pga2 = getPersonGroupAsso(group1, person2);
        insert pga1;
        insert pga2;
        
        Harvest__c harvest1 = getHarvest(farmer1);
        Harvest__c harvest2 = getHarvest(farmer2);
        Harvest__c harvest3 = getHarvest(farmer2);
        harvest1.Quantity_Accepted__c = 10;
        harvest1.Quantity_Harvested__c = 11;
        harvest1.Quantity_Rejected__c = 1;
        harvest2.Quantity_Accepted__c = 10;
        harvest2.Quantity_Harvested__c = 11;
        harvest2.Quantity_Rejected__c = 1;
        harvest3.Quantity_Accepted__c = 5;
        harvest3.Quantity_Harvested__c = 7;
        harvest3.Quantity_Rejected__c = 2;
        harvest3.Crop__c = 'Maize';
        insert harvest1;
        insert harvest2;
        insert harvest3;
        
        // create a loan
        Loan__c loan1 = getLoan(farmer1, harvest1);
        Loan__c loan2 = getLoan(farmer2, harvest2);
        insert loan1;
        insert loan2;
        
        Markets__c market1 = getMarket();
        insert market1;
        
        Commodities__c commodity1 = getCommodity(market1);
        Commodities__c commodity2 = getCommodity(market1);
        Commodities__c commodityExisting = getCommodity(market1);
        commodity2.Name = 'Maize';
        commodityExisting.Market__c = null;
        commodityExisting.Effective_date__c = null;
        commodityExisting.Highest_Wholesale_Price__c = null;
        insert commodityExisting;
        insert commodity1;
        insert commodity2;
        
        Sale__c sale1 = getSale();
        Sale__c sale2 = getSale();
        sale2.Status__c = 'New';
        sale2.Beans_Number_of_90kg_Bags_Sold__c = 1;
        sale2.Beans_Price_Per_90kg_Bag__c = 1000;
        sale2.Sale_Date__c = Date.newInstance(2013, 8, 16);
        insert sale1;
        insert sale2;
        
        Sale_Farmer_Association__c sf1 = getSaleFarmer(sale1, farmer1);
        Sale_Farmer_Association__c sf2 = getSaleFarmer(sale1, farmer2);
        Sale_Farmer_Association__c sf3 = getSaleFarmer(sale2, farmer1);
        sf1.Beans_Number_of_90kg_Bags_Sold__c = 2;
        sf2.Beans_Number_of_90kg_Bags_Sold__c = 0;
        sf3.Beans_Number_of_90kg_Bags_Sold__c = 1;
        sf1.Cow_Peas_Number_of_90kg_Bags_Sold__c = 2;
        sf2.Cow_Peas_Number_of_90kg_Bags_Sold__c = 1;
        sf3.Cow_Peas_Number_of_90kg_Bags_Sold__c = 0;
        //sf1.Fee_Due__c = sf1.Amount_Applied__c * 0.01;
        //sf2.Fee_Due__c = sf2.Amount_Applied__c * 0.01;
        //sf3.Fee_Due__c = sf3.Amount_Applied__c * 0.01;
        insert sf1;
        insert sf2;
        insert sf3;
        
        
    }

    // mock data for test runs
    public static District__c getTestDistrict(){
        District__c district = new District__c();
        district.Name = 'Isiolo';
        return district;
    }
    
    public static Country__c getTestCountry(){
        Country__c country = new Country__c();
        country.Name = 'Kenya';
        country.ISO_Standard_Code__c = 'KE';
        country.Language__c = 'Swahili';
        return country;
    }

    public static Person__c getTestPerson(Country__c country, District__c district){
        
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
    
    public static Farmer__c getTestFarmer(Person__c person){
        Farmer__c farmer = new Farmer__c();
        farmer.Name = '3eyUUD';
        farmer.Person__c = person.Id;
        farmer.Status__c = 'Processed';
        farmer.Sale_Status__c = 'Paid';
        farmer.Land_Size__c = 35;
        farmer.Crops__c = 'Maize';
        farmer.Livestock__c = 'Goats';
        return farmer;
    }
    
    public static Group__c getGroup(){
        Group__c groupC = new Group__c();
        groupC.Name = 'Kiruri Farmers';
        groupC.Group_ID__c = 'A12/012/001/002';
        return groupC;
    }
    
    public static Person_Group_Association__c getPersonGroupAsso(Group__c groupC, Person__c person){
        Person_Group_Association__c pga = new Person_Group_Association__c();
        pga.Group__c = groupC.Id;
        pga.Person__c = person.Id;
        return pga;
    }
    
    public static Harvest__c getHarvest(Farmer__c farmer){
        Harvest__c h = new Harvest__c();
        h.Crop__c = 'Beans';
        h.Date_Harvested__c = date.newinstance(2013, 4, 30);
        h.Farmer__c = farmer.Id;
        h.Quantity_Accepted__c = 10;
        h.Quantity_Harvested__c = 11;
        h.Quantity_Rejected__c = 1;
        h.Storage_Location__c = 'Home';
        return h;
    }
    
    public static Loan__c getLoan(Farmer__c farmer, Harvest__c harvest){
        
        Loan__c loan = new Loan__c();
        loan.Amount_Applied_For__c = 130000;
        loan.Amount_Approved__c = 120000;
        loan.Application_Date__c = date.newinstance(2013, 4, 30);
        loan.Decision_Date__c = date.newinstance(2013, 5, 1);
        loan.Balance__c = 120000;
        loan.Status__c = 'Applied';
        loan.Currency__c = 'KES';
        loan.Farmer__c = farmer.Id; 
        if(harvest != null)
            loan.Harvest__c = harvest.Id; 
        
        return loan;
        
    }
    
    public static Sale__c getSale(){
        Sale__c sale = new Sale__c();
        sale.Status__c = 'New';
        sale.Beans_Number_of_90kg_Bags_Sold__c = 2;
        sale.Beans_Price_Per_90kg_Bag__c = 2000;
        sale.Cow_Peas_Number_of_90kg_Bags_Sold__c = 3;
        sale.Cow_Peas_Price_Per_90kg_Bag__c = 1500;
        sale.Sale_Date__c = Date.newInstance(2013, 8, 16);
        return sale;
        
    }
    
    public static Sale_Farmer_Association__c getSaleFarmer(Sale__c sale, Farmer__c farmer){
        Sale_Farmer_Association__c sf = new Sale_Farmer_Association__c();
        
        sf.Farmer__c = farmer.Id;
        sf.Sale__c = sale.Id;
        sf.Beans_Number_of_90kg_Bags_Sold__c = 2;
        sf.Cow_Peas_Number_of_90kg_Bags_Sold__c = 3;
        sf.Fee_Due__c = sf.Amount_Applied__c != null ? sf.Amount_Applied__c * 0.01 : 0;
        sf.Fee_Paid__c = 0;
        return sf;
    }
    
    public static Markets__c getMarket(){
        Markets__c m = new Markets__c();
        
        m.Name = 'e-warehouse';
        
        return m;
        
    }
    
    public static Commodities__c getCommodity(Markets__c market1){
        Commodities__c c = new Commodities__c();
        
        c.Name = 'Beans';
        c.Effective_date__c = Date.newInstance(2010, 1, 1);
        c.Market__c = market1.Id;
        c.Highest_Wholesale_Price__c = 200;
        
        return c;
        
    }
 
}