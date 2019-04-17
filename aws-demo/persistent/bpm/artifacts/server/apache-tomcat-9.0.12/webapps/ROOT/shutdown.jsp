<%
//dev mode only! just to restart pod faster.
new Thread(new Runnable(){
	public void run(){
		System.out.println("SHUTDOWN in 1 second");
		Thread.sleep(1001);
		System.exit(0);
	}
}).start();

//redirect to camunda here
response.sendRedirect("/camunda-welcome/index.html");
%>
