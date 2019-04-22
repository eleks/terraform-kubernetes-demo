
public class REST{
    public static Object $static_propertyMissing(String key){
    	Object v = CONFIG.get("rest."+key);
    	if(v==null)throw new RuntimeException("Config key not found `rest."+key+"`");
        return v;
    }
}
