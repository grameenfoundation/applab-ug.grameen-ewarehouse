public with sharing class EWarehouseMEDashboardController  {
	private static List<String> crops = null;
    private static List<String> livestocks = null;
    
	private String farmersTrained = 'No of Farmers registered';
	private Integer acreSteps = 5;
	
	//private Map<String, String> impactData;
	private List<NameCount> impactData;
	private List<NameCount> farmersByGender;
	private List<NameCount> farmersByAcre;
	private List<NameCount> farmersByCrop;
	private List<NameCount> farmersByLivestock;
	private List<NameCount> grainCollected;
	private List<NameCount> grainSold;
	
	private List<IntegerRange> acreRanges;
	
    public EWarehouseMEDashboardController() {
    	loadData();        
    }
    
    private void loadData(){
    	// set defaults, ranges and values
    	acreRanges = new List<IntegerRange>();
    	acreRanges.add(new IntegerRange(0, 10));
    	acreRanges.add(new IntegerRange(11, 20));
    	acreRanges.add(new IntegerRange(21, 30));
    	acreRanges.add(new IntegerRange(31, 40));
    	acreRanges.add(new IntegerRange(41, -1));
    	
    	loadCropsValues();
    	loadLivestockValues();
    	
    	// reset all the data
    	impactData = new List<NameCount>();
        farmersByGender = new List<NameCount>();
        farmersByAcre = new List<NameCount>();
    	farmersByCrop = new List<NameCount>();
    	farmersByLivestock = new List<NameCount>();
    	grainCollected = new List<NameCount>();
    	grainSold = new List<NameCount>();
    	
    	// load farmers by gender and also set the total farmers
    	loadFarmersByGender();
    	loadVKWInformation();
    	loadFarmersByAcre();
    	loadFarmersByCrop();
    	loadFarmersByLivestock();
    	loadLoanInformation();
    	loadFarmersWhoArePaid();
    	loadGrainCollected();
    	loadGrainSold();
    }
    
    public List<NameCount> getImpactData(){
        return impactData;
    }
    
    public List<NameCount> getFarmersByGender(){
        return farmersByGender;
    }
    public List<NameCount> getFarmersByAcre(){
        return farmersByAcre;
    }
    public List<NameCount> getFarmersByCrop(){
        return farmersByCrop;
    }
    public List<NameCount> getFarmersByLivestock(){
        return farmersByLivestock;
    }
    public List<NameCount> getGrainCollected(){
        return grainCollected;
    }
    public List<NameCount> getGrainSold(){
        return grainSold;
    }
    
    private void loadFarmersByGender(){
    	Integer totalFarmers = 0;
        
        for(AggregateResult ar: [SELECT Person__r.Gender__c, COUNT(Id) c FROM Farmer__c GROUP BY Person__r.Gender__c ORDER BY Person__r.Gender__c DESC]){
            farmersByGender.add(new NameCount(String.valueOf(ar.get('Gender__c')), String.valueOf(ar.get('c'))));
            totalFarmers += Integer.valueOf(ar.get('c'));
        }
        
        // add the total amount of farmers to the impactData
        impactData.add(new NameCount(farmersTrained, String.valueOf(totalFarmers)));
        for(NameCount nc : farmersByGender){
        	impactData.add(nc);
        }
    }
    
    private void loadVKWInformation(){
        Integer vkws = Database.countQuery('SELECT COUNT() FROM Person__c WHERE Type__c = \'VKW\'');
        impactData.add(new NameCount('No of Village Knowledge Workers registered', String.valueOf(vkws)));
    }
    
    private void loadFarmersWhoArePaid(){
        Integer result = Database.countQuery('SELECT COUNT() FROM Farmer__c WHERE Sale_Status__c = \'Paid\'');
        impactData.add(new NameCount('No of farmers fully paid for sales', String.valueOf(result)));
    }
    
    private void loadFarmersByAcre(){
    	// make sure they are sorted to loop through them correctly
    	acreRanges.sort();
    	
    	for (IntegerRange range : acreRanges){
    		Integer stepMin = range.min;
    		Integer stepMax = range.max;
    		String q;
    		if(stepMax != -1)
                q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin+' AND Land_Size__c <= '+stepMax;
            else
                q = 'SELECT Count() FROM Farmer__c WHERE Land_Size__c >= '+stepMin;
                
            Integer result = Database.countQuery(q);
            if(stepMax != -1)
                farmersByAcre.add(new NameCount(stepMin+' - '+stepMax, String.valueOf(result)));
            else
                farmersByAcre.add(new NameCount('> ' + (stepMin - 1), String.valueOf(result)));
        }
        
        system.debug(LoggingLevel.Debug, farmersByAcre);
    }
    
    private void loadFarmersByCrop(){
    	for(String crop : crops){
    		String q = 'SELECT COUNT() FROM Farmer__c WHERE Crops__c includes (\''+crop+'\')';
    		Integer result = Database.countQuery(q);
    		if(result > 0){
                farmersByCrop.add(new NameCount(crop, String.valueOf(result)));	
    		}
    	}
    }
    
    private void loadFarmersByLivestock(){
    	for(String livestock : livestocks){
            String q = 'SELECT COUNT() FROM Farmer__c WHERE Livestock__c includes (\''+livestock+'\')';
            Integer result = Database.countQuery(q);
            if(result > 0){
                farmersByLivestock.add(new NameCount(livestock, String.valueOf(result))); 
            }
        }
    }
    
    private void loadLoanInformation(){
    	//
    	Integer repaidLoans = 0;
        Integer totalLoans = 0;
        for(AggregateResult ar: [SELECT COUNT(ID) c, Status__c FROM Loan__c GROUP BY Status__c]){
        	Integer cnt = Integer.valueOf(ar.get('c'));
        	String status = String.valueOf(ar.get('Status__c'));
        	
        	if(status == 'Repaid'){
        		repaidLoans = cnt;
        	}
        	
        	if(status == 'Approved' || status == 'Service' || status == 'Repaid' || status == 'Overdue'){
        		totalLoans += cnt;
        	}
        }
        
        impactData.add(new NameCount('Total loans', String.valueOf(totalLoans)));
        impactData.add(new NameCount('Repaid loans', String.valueOf(repaidLoans)));
        Decimal ratio = (repaidLoans / (Decimal)totalLoans);
        impactData.add(new NameCount('Repaid ratio (loans)', String.valueOf(ratio.setScale(2))));
    }
    
    private void loadGrainCollected(){
    	for(AggregateResult ar: [SELECT SUM(Quantity_Accepted__c) s, Crop__c FROM Harvest__c GROUP BY Crop__c]){
    		Integer quantity = Integer.valueOf(ar.get('s'));
    		String crop = String.valueOf(ar.get('Crop__c'));
    		Integer tons = (quantity * 90) / 1000;
            grainCollected.add(new NameCount(crop, String.valueOf(tons)));
        }
        system.debug(grainCollected);
    }
    
    private void loadGrainSold(){
        for(AggregateResult ar: [SELECT SUM(Volume_Sold__c) vs, Harvest__r.Crop__c FROM Sale__c GROUP BY Harvest__r.Crop__c]){
        	system.debug('aggregate loop');
        	if(ar.get('vs') != null && ar.get('Crop__c') != null){
        		Integer quantity = Integer.valueOf(ar.get('vs'));
	            String crop = String.valueOf(ar.get('Crop__c'));
	            Integer tons = (quantity * 90) / 1000;
	            system.debug(tons);
	            system.debug(grainSold);
	            grainSold.add(new NameCount(crop, String.valueOf(tons)));
        	}
        }
        system.debug(grainSold);
    }

    private static void loadCropsValues() {
        if(crops == null){
            crops = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Crops__c.getDescribe().getPicklistValues()){
                crops.add(entry.getValue());
            }
        }
    }
    
    private static void loadLivestockValues() {
        if(livestocks == null){
            livestocks = new List<String>();
            for(Schema.PicklistEntry entry : Farmer__c.Livestock__c.getDescribe().getPicklistValues()){
                livestocks.add(entry.getValue());
            }
        }
    }
    
    public class NameCount {
        public String name { get; set; }
        public String count { get; set; }

        public NameCount(String name, String count) {
            this.name = name;
            this.count = count;
        }
    }
    
    public class IntegerRange implements Comparable {
        public Integer min { get; set; }
        public Integer max { get; set; }

        public IntegerRange(Integer min, Integer max) {
            this.min = min;
            this.max = max;
        }
        
        // Implement the compareTo() method
	    public Integer compareTo(Object compareTo) {
	        IntegerRange compareToEmp = (IntegerRange)compareTo;
	        if (min == compareToEmp.min) return 0;
	        if (min > compareToEmp.min) return 1;
	        return -1;        
	    }
    }
    
}