singleton Class constructor
	
Function get client : cs:C1710.OpenAI
	return Form:C1466.openAI
	
Function get model : Text
	return Form:C1466.models.currentValue
	
Function onLoad()
	Form:C1466.openAI:=cs:C1710.OpenAI.new()
	
	If ((Length:C16(Form:C1466.openAI.apiKey)=0) && (Folder:C1567(fk home folder:K87:24).file(".openai").exists))
		Form:C1466.openAI.apiKey:=Folder:C1567(fk home folder:K87:24).file(".openai").getText()
	End if 
	
	Form:C1466.modelsByPage:=[]
	Form:C1466.modelsByPage[1]:=["gpt-4o-mini"; "gpt-4o"]
	Form:C1466.modelsByPage[2]:=["dall-e-2"; "dall-e-3"]
	Form:C1466.modelsByPage[3]:=["gpt-4o-mini"]
	Form:C1466.modelsByPage[4]:=["omni-moderation-latest"; "text-moderation-latest"; "text-moderation-stable"; "text-moderation-007"; "omni-moderation-2024-9-26"]
	Form:C1466.modelsByPage[5]:=[]
	Form:C1466.modelsByPage[6]:=["text-embedding-3-small"; "text-embedding-3-large"; "text-embedding-ada-002"]
	Form:C1466.modelsByPage[7]:=["gpt-4o-mini"]
	
	Form:C1466.models:={values: Form:C1466.modelsByPage[1]; index: 0}
	
	Form:C1466.chats:=[]
	Form:C1466.roleEmoticon:=This:C1470.roleEmoticon
	
Function onPageChange()
	Form:C1466.models:={values: Form:C1466.modelsByPage[FORM Get current page:C276]; index: 0}
	
	OBJECT SET ENABLED:C1123(*; "userPrompt"; True:C214)
	
	Case of 
		: ((FORM Get current page:C276=1) || (FORM Get current page:C276=7))  // chat
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Talk to your assistant")
			
		: (FORM Get current page:C276=2)  // image
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Describe the image to generate")
			
		: (FORM Get current page:C276=3)  // vision
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Ask anything about the image. ex: Could you describe the image")
			
		: (FORM Get current page:C276=4)  // moderation
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Propose sentence to analyse")
			
		: (FORM Get current page:C276=5)  // model
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Connect and refresh model")
			OBJECT SET ENABLED:C1123(*; "userPrompt"; False:C215)
			
		: (FORM Get current page:C276=6)  // embeddings
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Sentence to vectorize")
			
	End case 
	
	
Function onClicked()
	
	If ((Length:C16(String:C10(Form:C1466.prompt))=0) && (FORM Get current page:C276#5))
		ALERT:C41("Please fill the prompt")
		return 
	End if 
	
	If (Shift down:C543)
		Form:C1466.openAI.apiKey:=""
		
		If ((Folder:C1567(fk home folder:K87:24).file(".openai").exists))
			Form:C1466.openAI.apiKey:=Folder:C1567(fk home folder:K87:24).file(".openai").getText()
			This:C1470.getModels()
		End if 
		
	End if 
	
	If (Length:C16(String:C10(Form:C1466.openAI.apiKey))=0)
		ALERT:C41("Your must configure")
		var $key:=Request:C163("Open API key"; "")
		If ((OK=1) && (Length:C16($key)>0))
			Form:C1466.openAI.apiKey:=$key
			
			This:C1470.getModels()
			
		Else 
			return 
		End if 
	End if 
	
	This:C1470.enableSendButton(False:C215)
	
	Case of 
		: (FORM Get current page:C276=1)  // chat
			
			This:C1470.sendChat()
			
		: (FORM Get current page:C276=2)  // image
			
			This:C1470.sendImage()
			
		: (FORM Get current page:C276=3)  // vision
			
			This:C1470.sendVision()
			
		: (FORM Get current page:C276=4)  // moderation
			
			This:C1470.sendModeration()
			
		: (FORM Get current page:C276=5)  // model
			
			This:C1470.getModels()
			
		: (FORM Get current page:C276=6)  // embeddings
			
			This:C1470.sendEmbeddings()
			
		: (FORM Get current page:C276=7)  // embeddings
			
			This:C1470.sendChatHelper()
			
	End case 
	
	Form:C1466.prompt:=""
	
	
Function enableSendButton($enable : Boolean)
	OBJECT SET ENABLED:C1123(*; "SendButton"; $enable)
	
	OBJECT SET TITLE:C194(*; "SendButton"; $enable ? "➤✨" : "⏳✨")
	
	// MARK:- Chat
Function _formatChat()
	
	var $chat:=""
	var $message : Object
	For each ($message; Form:C1466.messages)
		
		
		$chat+=This:C1470.roleEmoticon($message.role)+" "
		Case of 
			: ($message.content#Null:C1517)
				$chat+=$message.content+" \n\n"
				
			: ($message.tool_calls#Null:C1517)
				
				$chat+="...["+$message.tool_calls.map(Formula:C1597($1.value.function.name)).join(",")+"] \n\n"
				
			Else 
				
		End case 
		
	End for each 
	
	If (Length:C16(String:C10(Form:C1466.streamed))>0)
		$chat+="🤖 "+String:C10(Form:C1466.streamed)
	End if 
	
	Form:C1466.chat:=$chat
	
Function sendChat()
	
	var $options : cs:C1710.OpenAIChatCompletionsParameters:={\
		stream: Bool:C1537(Form:C1466.stream); \
		model: This:C1470.model; \
		formula: Formula:C1597(Bool:C1537(Form:C1466.stream) ? cs:C1710._FormDemo.me.onStreamChatReceive($1) : cs:C1710._FormDemo.me.onChatReceive($1))}
	
	If ($options.stream)
		$options.stream_options:={include_usage: True:C214}
	End if 
	
	If (Bool:C1537(Form:C1466.tools))
		
		var $tool:={type: "function"; \
			function: {name: "get_database_table"; description: "Get the database table list."; parameters: {}; required: []; additionalProperties: False:C215}; \
			strict: True:C214}
		$options.tools:=[$tool]
	End if 
	
	
	If (Form:C1466.messages=Null:C1517)
		Form:C1466.messages:=[cs:C1710.OpenAIMessage.new({role: "system"; content: "You are a helpful assistant."})]
	End if 
	
	Form:C1466.messages.push({role: "user"; content: Form:C1466.prompt})
	
	Form:C1466.streamed:=""
	This:C1470._formatChat()
	
	This:C1470.client.chat.completions.create(Form:C1466.messages; $options)
	
Function onChatReceive($result : cs:C1710.OpenAIChatCompletionsResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		var $assistant:=$result.choice.message
		
		Form:C1466.messages.push($assistant)
		
		This:C1470._formatChat()
		
		If ($assistant.tool_calls#Null:C1517)
			// XXX: here we respond to the one tool installed, we must execute a tool according to its name
			var $toolReponse:=cs:C1710.OpenAIMessage.new()
			$toolReponse.role:="tool"
			$toolReponse.tool_call_id:=$assistant.tool_calls.first().id
			$toolReponse.content:=JSON Stringify:C1217(OB Keys:C1719(ds:C1482))
			
			Form:C1466.messages.push($toolReponse)
			
			var $options : cs:C1710.OpenAIChatCompletionsParameters:={\
				stream: Bool:C1537(Form:C1466.stream); \
				model: This:C1470.model; \
				formula: Formula:C1597(Bool:C1537(Form:C1466.stream) ? cs:C1710._FormDemo.me.onStreamChatReceive($1) : cs:C1710._FormDemo.me.onChatReceive($1))}
			
			If ($options.stream)
				$options.stream_options:={include_usage: True:C214}
			End if 
			
			This:C1470.client.chat.completions.create(Form:C1466.messages; $options)
			
		End if 
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
Function onStreamChatReceive($result : cs:C1710.OpenAIChatCompletionsStreamResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		If ($result.terminated)
			
			Form:C1466.messages.push({role: "assistant"; content: Form:C1466.streamed})
			Form:C1466.streamed:=""
			
		Else 
			
			If ($result.choice#Null:C1517)  // could be null if usage send
				var $morceau:=$result.choice.delta.text
				Form:C1466.streamed+=$morceau
			
		End if 
		
		This:C1470._formatChat()
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	// MARK:- model
	
Function getModels()
	var $options : cs:C1710.OpenAIParameters:={\
		formula: Formula:C1597(cs:C1710._FormDemo.me.onModelReceive($1))}
	
	This:C1470.client.models.list($options)
	
Function onModelReceive($result : cs:C1710.OpenAIModelListResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		Form:C1466.modelsRemote:=$result.models
		
		Form:C1466.modelsByPage[5]:=Form:C1466.modelsRemote.extract("id").sort()
		If (FORM Get current page:C276=5)
			Form:C1466.models:={values: Form:C1466.modelsByPage[FORM Get current page:C276]; index: 0}
		End if 
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	
	// MARK:- image
	
Function sendImage()
	var $options : cs:C1710.OpenAIImageParameters:={\
		response_format: "b64_json"; \
		size: "512x512"; \
		model: This:C1470.model; \
		formula: Formula:C1597(cs:C1710._FormDemo.me.onImageReceive($1))}
	
	This:C1470.client.images.generate(Form:C1466.prompt; $options)
	
Function onImageReceive($result : cs:C1710.OpenAIImagesResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		Form:C1466.picture:=$result.image.asPicture()
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	// MARK:- Vision
Function sendVision()
	var $options : cs:C1710.OpenAIChatCompletionsResult:={\
		model: This:C1470.model; \
		formula: Formula:C1597(cs:C1710._FormDemo.me.onVisionReceive($1))}
	
	This:C1470.client.chat.vision.fromFile(Form:C1466.visionFile).prompt(Form:C1466.prompt; $options)
	
Function onVisionReceive($result : cs:C1710.OpenAIChatCompletionsResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		Form:C1466.vision:=$result.choice.message.text
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	
Function onVisionCliked()
	
	var $res:=Select document:C905(Folder:C1567(fk home folder:K87:24).platformPath; ".png"; "Select an image to analyse"; 0)
	If (OK=1)
		Form:C1466.visionFile:=File:C1566(Document; fk platform path:K87:2)
	End if 
	
Function onVisionDroped()
	// XXX file ?
	
	// MARK:- Moderation
Function sendModeration()
	var $options : cs:C1710.OpenAIChatCompletionsResult:={\
		formula: Formula:C1597(cs:C1710._FormDemo.me.onModerationReceive($1))}
	
	This:C1470.client.moderations.create(Form:C1466.prompt; This:C1470.model; $options)
	
Function onModerationReceive($result : cs:C1710.OpenAIModerationResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		Form:C1466.moderation:=JSON Stringify:C1217($result.moderation.results; *)
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	// MARK:- Embeddings
	
Function sendEmbeddings()
	var $options : cs:C1710.OpenAIEmbeddingsParameters:={\
		formula: Formula:C1597(cs:C1710._FormDemo.me.onEmbeddingsReceive($1))}
	
	This:C1470.client.embeddings.create(Form:C1466.prompt; This:C1470.model; $options)
	
Function onEmbeddingsReceive($result : cs:C1710.OpenAIEmbeddingsResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		Form:C1466.embeddings:=JSON Stringify:C1217($result.embeddings; *)
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	
	
	// MARK:- ChatHelper
	
Function roleEmoticon($role : Text) : Text
	Case of 
		: ($role="assistant")
			return "🤖"
		: ($role="user")
			return "👤"
		: ($role="tool")
			return "🛠️"
		Else 
			return ""
	End case 
	
Function createChatHelper()
	var $name:=Request:C163("Chat name?")
	If (Length:C16($name)=0)
		$name:="Chat "+String:C10(Form:C1466.chats.length+1)
	End if 
	
	var $stream:=Shift down:C543
	
	var $chat:=This:C1470.client.chat.create("You are a helpful assistant."; {stream: $stream; onTerminate: Formula:C1597(cs:C1710._FormDemo.me.onChatHelperReceive($1)); onData: Formula:C1597(cs:C1710._FormDemo.me.onChatHelperReceiveStream($1))})
	
	Form:C1466.chats.push({name: $name; chat: $chat})
	
	If (Form:C1466.chats.length=1)
		Form:C1466.currentChatIndex:=1
	End if 
	
Function removeChatHelper()
	
	If (Form:C1466.currentChatIndex>0)
		Form:C1466.chats.remove(Form:C1466.currentChatIndex-1)
	End if 
	
Function sendChatHelper()
	If (Form:C1466.currentChat=Null:C1517)
		This:C1470.enableSendButton(True:C214)
		ALERT:C41("Select or create a chat")
		return 
	End if 
	Form:C1466.currentChat.chat.prompt(Form:C1466.prompt)
	
Function onChatHelperReceive($result : cs:C1710.OpenAIChatCompletionsResult)
	
	This:C1470.enableSendButton(True:C214)
	
	If ($result.success)
		
		
	Else 
		
		ALERT:C41(JSON Stringify:C1217($result.errors))
		
	End if 
	
	
Function onChatHelperReceiveStream($result : cs:C1710.OpenAIChatCompletionsStreamResult)
	
	// XXX: want to do something?
	