global abstract with sharing class ServiceResponses {

	


	global class ErrorResponse extends ServiceResultResponse {
		
		public ErrorResponse(String code, String description){
			this.code = code;
			this.description = description;
		}
	}

	global abstract with sharing class ServiceResultResponse {
		public String code;
		public String description;
	}
	
	global static String test(){
		return 'test';
	}
	
	global static ServiceResultResponse malformedJsonResponse(String json){
		return new ErrorResponse('400', 'We could not parse the body of the request as JSON, maybe it is malformed?\n Body: ' + json);
	}
	
	
}