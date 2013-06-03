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
    
    
    public static Client fromFarmer(Farmer__c farmer){
    	
    	// get a reference of the farmer's person object
    	Person__c personRef = farmer.Person__r;
    	District__c districtRef = personRef.District__r;
    	Country__c countryRef = personRef.Country__r;
    	
    	// create new client
        Client client = new Client();
    	
    	client.Id = farmer.Name;
    	client.SaleStatus = farmer.Sale_Status__c; 
    	
    	// take the information from the referenced objects when they are available
    	if(personRef != null){
    		client.FirstName = personRef.First_Name__c;
    		client.MiddleName = personRef.Middle_Name__c;
		    client.LastName = personRef.Last_Name__c;
		    client.DateOfBirth = personRef.Date_of_Birth__c;
		    client.MobileNumber = personRef.Mobile_Number__c;
		    client.IDNumber = personRef.ID_Number__c;
		    client.Gender = personRef.Gender__c;
		    client.Village = personRef.Village__c;
		    client.City = personRef.City__c;
		    client.PictureURL = personRef.Picture_URL__c;
		    client.Picture = getImage(client.PictureURL);
		    client.NextOfKin = personRef.Next_Of_Kin__c;
		    client.NextOfKinTelephone = personRef.Next_Of_Kin_Telephone__c;
		    client.CPGId = personRef.Group_ID__c;
		    client.CPGName = personRef.Group_Name__c;
		}
    	
    	if(districtRef != null)
			client.District = districtRef.Name;
			
		if(countryRef != null)
	    	client.Country = countryRef.Name;
	    
		System.debug(client);
		
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