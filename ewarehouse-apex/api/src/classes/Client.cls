global with sharing class Client {
	
	public String Id { get; set; }
	public String FirstName { get; set; }
	public String MiddleName { get; set; }
    public String LastName { get; set; }
    public Date DateOfBirth { get; set; }
    public String MobileNumber { get; set; }
    public String IDNumber { get; set; }
    public String Gender { get; set; }
    public String Village { get; set; }
    public String District { get; set; }
    public String City { get; set; }
    public String Country { get; set; }
    public String PictureURL { get; set; }
    public Blob Picture { get; set; }
    
    public String NextOfKin { get; set; }
    public String NextOfKinTelephone { get; set; }
    public String CPGId { get; set; }
    public String CPGName { get; set; }
    public String SaleStatus {get; set; }
    
    
    //photo,Next of Kin Name and Next of Kin Telephone
    
    
    public static Client fromFarmer(Person__c person){
    	
    	List<Farmer__c> farmerRef = person.Farmers__r;
    	// farmer should not be null
    	if(farmerRef.size() == 0)
    		return null;
    	
    	District__c districtRef = person.District__r;
    	Country__c countryRef = person.Country__r;
    	List<Person_Group_Association__c> pgaRef = person.PersonGroupAssociations__r;
    	
    	// create new client
        Client client = new Client();
    	client.Id = farmerRef[0].Name;
    	client.SaleStatus = farmerRef[0].Sale_Status__c; 
    	
    	// take the information from the referenced objects when they are available
		client.FirstName = person.First_Name__c;
		client.MiddleName = person.Middle_Name__c;
	    client.LastName = person.Last_Name__c;
	    client.DateOfBirth = person.Date_of_Birth__c;
	    client.MobileNumber = person.Mobile_Number__c;
	    client.IDNumber = person.ID_Number__c;
	    client.Gender = person.Gender__c;
	    client.Village = person.Village__c;
	    client.City = person.City__c;
	    client.PictureURL = person.Picture_URL__c;
	    client.Picture = getImage(client.PictureURL);
	    client.NextOfKin = person.Next_Of_Kin__c;
	    client.NextOfKinTelephone = person.Next_Of_Kin_Telephone__c;
		
    	if(districtRef != null)
			client.District = districtRef.Name;
			
		if(countryRef != null)
	    	client.Country = countryRef.Name;
	    	
	    if(pgaRef.size() > 0){
	    	Group__c groupRef = pgaRef[0].Group__r;
	    	if(groupRef != null){
		    	client.CPGId = groupRef.Group_ID__c;
		    	client.CPGName = groupRef.Name;	
	    	}
	    	
	    }
	    
		system.debug(client);
		
		return client;
    }
    
    private static Blob getImage(String url){
    	if(url == null)
    		return null;
    		
		try{
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			
			//Replace any spaces with %20
			url = url.replace(' ', '%20');
			req.setEndpoint(url);
			req.setMethod('GET');
			
			//If you want to get a PDF file the Content Type would be 'application/pdf'
			req.setHeader('Content-Type', 'image/jpeg');
			req.setCompressed(true);
			req.setTimeout(60000);
			                 
			HttpResponse res = null;
			res = h.send(req);
			//These next three lines can show you the actual response for dealing with error situations
			string responseValue = '';
			responseValue = res.getBody();
			
			// Get the body of the response as blob
			blob image = res.getBodyAsBlob();
	                
			return image;
    	}
    	catch(Exception e){
    		system.debug(e);
    		// return null when an exception was thrown
    		return null;
    	}
    	
    }
    
}