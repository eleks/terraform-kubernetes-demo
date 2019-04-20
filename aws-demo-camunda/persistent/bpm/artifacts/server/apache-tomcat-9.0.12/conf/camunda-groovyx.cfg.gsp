import groovyx.acme.net.AcmeHTTP;

//sensitive = dependency.load('sensitive.cfg')

email {
	//for gmail smtp check your mailbox if google not blocking you...
	mail.transport.protocol = "smtp"
	mail.smtp.host          = "smtp.gmail.com"
	mail.smtp.port          = "587"
	//mail.smtp.socketFactory.port = "465"
    //mail.smtp.socketFactory.class = "javax.net.ssl.SSLSocketFactory"
	//mail.smtp.ssl.enable    = "true"
	mail.smtp.starttls.enable= "true"
	//=======  custom fields processed by class EMAIL =======
	mail.user               = "<%= camunda.mail.user %>"
	mail.pass               = "<%= camunda.mail.pass %>"
	mail.from               = "<%= camunda.mail.user %>"
	mail.fromName           = "camunda demo"
}


database {
	demo {
		//all db parameters defined during templating because they are coming from terraform
		driver   = "<%= camunda.db.main.driver %>"
		url      = "<%= camunda.db.main.url    %>"
		user     = "<%= camunda.db.main.user   %>"
		password = "<%= camunda.db.main.pass   %>"
	}
}

rest {
    //define jira requests
    jira {
        http_client = AcmeHTTP.builder(
            url: 'https://jiravm.atlassian.net/rest/api/2',
            headers: [
                Authorization   : "<%= camunda.rest.jira.auth %>",
                "Content-Type"  : "application/json"
            ]
        )
        //method to register issue in jira
        tripRegister = { _summary, _description ->
            def t = rest.jira.http_client.post{
                setPath ('/issue')
                body = [
                    fields: [
                        project: [id: "10001" ],
                        issuetype:[ id: "10001" ],
                        summary: _summary,
                        description: _description,
                    ],
                ]
            }
            assert t.response.code in [200,201]
            return t.response.body
        }
        //method add a comment into an jira issue 
        comment = { _key, _body ->
            def t = rest.jira.http_client.post{
                setPath ("/issue/${_key}/comment")
                setBody ( [ 'body': _body ] )
            }
            assert t.response.code in [200,201]
            return t.response.body
        }
        //moves issue to a defined status
        toStatus = { _key, _status ->
        	//get current status
            def t = rest.jira.http_client.get{
                setPath ("/issue/${_key}")
            }
            assert t.response.code in [200,201]
        	if( _status.equalsIgnoreCase(t.response.body.fields.status.name) ) return true
        	//get available paths
            t = rest.jira.http_client.get{
                setUrl ("https://jiravm.atlassian.net/rest/internal/2/issue/${_key}/optimisticTransitions")
            }
            //println t.response
            assert t.response.code in [200,201]
            def trn = t.response.body.transitions.find{ _status.equalsIgnoreCase(it.to.name) }
            assert trn: "transition for $_status not found "
            t = rest.jira.http_client.post{
                setPath ("/issue/${_key}/transitions")
                setBody ( [ 'transition': [id:trn.id] ] )
                setReceiver(AcmeHTTP.TEXT_RECEIVER)
            }
            assert t.response.code in [200,201,204]
            return true
        }
    }
}
