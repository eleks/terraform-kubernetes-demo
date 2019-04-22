import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.impl.context.Context;
import org.camunda.bpm.engine.impl.persistence.entity.ExecutionEntity;
//import org.camunda.bpm.model.bpmn.instance.FlowElement;
import org.camunda.bpm.model.bpmn.instance.Documentation;
import org.camunda.bpm.engine.IdentityService;
import org.camunda.bpm.engine.identity.User;
import java.util.Collection;
import java.util.Map;

public class CAMUNDA{
	//returns current documentation element
	public static String doc(){
		ExecutionEntity execution=Context.getBpmnExecutionContext().getProcessInstance();
		StringBuilder sb = new StringBuilder();
		Collection<Documentation> docs = execution.getBpmnModelElementInstance().getDocumentations();
		for(Documentation doc : docs){
			sb.append( doc.getRawTextContent() );
		}
		return sb.toString();
	}

	//returns current documentation element
	public static String doc(DelegateExecution execution){
		StringBuilder sb = new StringBuilder();
		Collection<Documentation> docs = execution.getBpmnModelElementInstance().getDocumentations();
		for(Documentation doc : docs){
			sb.append( doc.getRawTextContent() );
		}
		return sb.toString();
	}

	public static User user(String userId){
		ExecutionEntity execution=Context.getBpmnExecutionContext().getProcessInstance();
       	IdentityService ids = execution.getProcessEngineServices().getIdentityService();
       	User user = ids.createUserQuery().userId(userId).singleResult();
		return user;
	}
	public static User currentUser(){
		return user( currentUserId() );
	}
	public static String currentUserId(){
		ExecutionEntity execution=Context.getBpmnExecutionContext().getProcessInstance();
       	IdentityService ids = execution.getProcessEngineServices().getIdentityService();
       	String userId = ids.getCurrentAuthentication().getUserId();
       	return userId;
	}
	public static Map variables(){
		ExecutionEntity execution=Context.getBpmnExecutionContext().getProcessInstance();
		return execution.getVariables();
	}
}
