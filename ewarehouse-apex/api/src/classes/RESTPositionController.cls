@RestResource(urlMapping='/CustomPosition/*')
global class RESTPositionController {
	
    @HttpGet
    global static Position getPosition() {

        String id = RestContext.request.params.get('id');
        eu_himmit__Position__c position = [ Select ID, Name, eu_himmit__Responsibilities__c from eu_himmit__Position__c where Id = :id];
        
        Position pos = new Position();
        pos.title = position.Name;
        pos.responsibilities = position.eu_himmit__Responsibilities__c;
        
    	return pos;
	
	}
	
	@HttpPost
	global static String setCompany(){
		
		String id = RestContext.request.params.get('id');
		String responsibilities = RestContext.request.params.get('responsibilities');
		String bla = 'bla';
		return bla;
		
	}

}