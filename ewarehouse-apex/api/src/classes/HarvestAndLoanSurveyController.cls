public with sharing class HarvestAndLoanSurveyController{
	
	private Map<String, Integer> cropPrice = new Map<String, Integer>();
	
    public HarvestAndLoanSurveyController() {
    }
    
    public List<HarvestLoan> getLeadData(){
    	List<Harvest__c> harvestList = [SELECT 
											Id,
											Name,
											Crop__c,
											Farmer__r.Name,
											Farmer__r.Person__r.First_Name__c,
											Farmer__r.Person__r.Middle_Name__c,
											Farmer__r.Person__r.Last_Name__c,
											Farmer__r.Person__r.ID_Number__C,
											Quantity_Harvested__c,
											Quantity_Accepted__c,
											Quantity_Rejected__c
											FROM Harvest__c
											WHERE Farmer__c NOT IN (SELECT Farmer__c FROM Loan__c WHERE Loan_Contract_No__c != '')
											ORDER BY Farmer__c ASC NULLS FIRST];
	    List<HarvestLoan> hlList = new List<HarvestLoan>();
	        
	    for(Harvest__c h: harvestList){
	    	hlList.add(fromHarvest(h));
	    }
	    return hlList;
    }
    
    public PageReference exportPage(){
    	PageReference newPage = new PageReference('/apex/HarvestAndLoanSurveyExport');
    	
    	return newPage;
    }
    
    public String getFileName(){
        return 'harvestloan-export-' + DateTime.now().format('yyyyMMddHHmmss');
    }
    public String getRunDate(){
        return DateTime.now().format('dd MMM yyyy, HH:mm:ss');
    }
    
    private HarvestLoan fromHarvest(Harvest__c data){
    	HarvestLoan hl = new HarvestLoan();
    	hl.ID = data.Name;
    	hl.Crop = data.Crop__c;
    	hl.FciID = data.Farmer__r.Name;
	    hl.FirstName = data.Farmer__r.Person__r.First_Name__c;
	    hl.MiddleName = data.Farmer__r.Person__r.Middle_Name__c;
	    hl.LastName = data.Farmer__r.Person__r.Last_Name__c;
	    hl.NationalID = data.Farmer__r.Person__r.ID_Number__c;
	    hl.QuantityHarvested = Integer.valueOf(data.Quantity_Harvested__c);
	    hl.QuantityAccepted = Integer.valueOf(data.Quantity_Accepted__c);
	    hl.QuantityRejected = Integer.valueOf(data.Quantity_Rejected__c);
	    
	    Integer valueOfCrop = -1;
	    Integer valueOfHarvest = -1;
	    if(cropPrice.containsKey(hl.Crop)){
	    	valueOfCrop = cropPrice.get(hl.Crop);
	    	valueOfHarvest = hl.QuantityAccepted * cropPrice.get(hl.Crop);
	    }
	    else {
            List<Commodities__c> comm = [SELECT Highest_Wholesale_Price__c FROM Commodities__c WHERE Name = :hl.Crop ORDER BY Effective_date__c DESC LIMIT 1];
            if(comm.size() == 1){
                if(comm[0].Highest_Wholesale_Price__c > 0){
	    		    cropPrice.put(hl.Crop, Integer.valueOf(comm[0].Highest_Wholesale_Price__c));
                    valueOfHarvest = hl.QuantityAccepted * cropPrice.get(hl.Crop);
                    valueOfCrop = cropPrice.get(hl.Crop);
	    		}
	    		else{
	    			hl.ValueOfHarvest = 'No valid crop price found.';
	    			hl.ValueOfCrop = 'No valid crop price found.';
	    		}
	    	}
	    	else {
	    		hl.ValueOfHarvest = 'No valid crop price found.';
                hl.ValueOfCrop = 'No valid crop price found.';
	    	}
	    }
	    
	    if(valueOfCrop > 0){
	    	hl.ValueOfCrop = String.valueOf(valueOfCrop);
	    	hl.ValueOfHarvest = String.valueOf(valueOfHarvest);
	    }
	    
	    if(valueOfCrop > 0){
	    	hl.EstimatedLoanAmount = valueOfHarvest / 2;
	    }
	    else {
	    	hl.EstimatedLoanAmount = 0;
	    }
	    
	    return hl;
    }
    
    public class HarvestLoan {
    	public String ID {get; set; }
    	public String Crop {get; set; }
        public String FciID {get; set; }
        public String FirstName {get; set; }
        public String MiddleName {get; set; }
        public String LastName {get; set; }
        public String NationalID {get; set; }
        public Integer QuantityHarvested {get; set; }
        public Integer QuantityAccepted {get; set; }
        public Integer QuantityRejected {get; set; }
        public String ValueOfCrop {get; set; }
        public String ValueOfHarvest {get; set; }
        public Integer EstimatedLoanAmount {get; set; }
        
    	
    }
    
    
    static testMethod void testLeadData(){
    	HarvestAndLoanSurveyController controller = new HarvestAndLoanSurveyController();
    	controller.getLeadData();
    }
}