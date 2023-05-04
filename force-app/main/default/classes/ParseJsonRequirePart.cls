/*
Class Name: ParseJsonRequirePart
Requirement: Interview
Used Where : Used to parse parts json response
Purpose/Overview : parse parts json response
Test Class Name : RequirePartTest
*/

public class ParseJsonRequirePart {

	public String x_id {get;set;} // in json: _id
	public String partName {get;set;} 
	public Integer totalQuantityShipped {get;set;} 

	public ParseJsonRequirePart(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == '_id') {
						x_id = parser.getText();
					} else if (text == 'Part Name') {
						partName = parser.getText();
					} else if (text == 'Total Quantity Shipped') {
						totalQuantityShipped = parser.getIntegerValue();
					} 
				}
			}
		}
	}
	
	
	public static List<ParseJsonRequirePart> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfParseJsonRequirePart(parser);
	}
	

    private static List<ParseJsonRequirePart> arrayOfParseJsonRequirePart(System.JSONParser p) {
        List<ParseJsonRequirePart> res = new List<ParseJsonRequirePart>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ParseJsonRequirePart(p));
        }
        return res;
    }



}