import groovy.text.SimpleTemplateEngine;
import org.camunda.bpm.engine.delegate.DelegateExecution;
import java.util.Map;
import java.io.IOException;

public class TEMPLATE {
	public static String make(String template, Map binding) throws ClassNotFoundException, IOException{
		SimpleTemplateEngine engine = new SimpleTemplateEngine();
		return engine.createTemplate(template).make(binding).toString();
	}
	public static String make(String template) throws ClassNotFoundException, IOException{
		return make( template, CAMUNDA.variables() );
	}
	public static String doc() throws ClassNotFoundException, IOException{
		return make( CAMUNDA.doc(), CAMUNDA.variables() );
	}
	public static String doc(Map binding) throws ClassNotFoundException, IOException{
		return make( CAMUNDA.doc(), binding );
	}

}
