/**/

public class RESTTest extends groovy.util.GroovyTestCase {
	public void test1(){
		assert (REST.jira instanceof ConfigObject)
		assert (CONFIG.rest.jira instanceof ConfigObject)
	}
	public void test2(){
		//println REST.jira.tripRegister("new trip ${new Date()}","Привіт всім \n ${new Date()}")
		//println REST.jira.comment("BT-1","Привіт всім \n ${new Date()}")
		//println REST.jira.toStatus("BT-1","Done")
	}


}
