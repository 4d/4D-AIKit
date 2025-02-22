singleton Class constructor
	
Function get client : cs:C1710.OpenAI
	return Form:C1466.openAI
	
Function get model : Text
	return Form:C1466.models.currentValue
	
Function onLoad()
	Form:C1466.openAI:=cs:C1710.OpenAI.new()
	
	Form:C1466.modelsByPage:=[]
	Form:C1466.modelsByPage[1]:=["gpt-4o-mini"; "gpt-4o"]
	Form:C1466.modelsByPage[2]:=["dall-e-2"; "dall-e-3"]
	Form:C1466.modelsByPage[3]:=["gpt-4o-mini"]
	Form:C1466.modelsByPage[4]:=["omni-moderation-latest"; "text-moderation-latest"; "text-moderation-stable"; "text-moderation-007"; "omni-moderation-2024-9-26"]
	
	Form:C1466.models:={values: Form:C1466.modelsByPage[1]; index: 0}
	
Function onPageChange()
	Form:C1466.models:={values: Form:C1466.modelsByPage[FORM Get current page:C276]; index: 0}
	
	Case of 
		: (FORM Get current page:C276=1)  // chat
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Talk to your assistant")
			
		: (FORM Get current page:C276=2)  // image
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Describe the image to generate")
			
		: (FORM Get current page:C276=3)  // vision
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Ask anything about the image. ex: Could you describe the image")
			
		: (FORM Get current page:C276=4)  // moderation
			
			OBJECT SET PLACEHOLDER:C1295(*; "userPrompt"; "Propose sentence to analyse")
			
	End case 
	
	
Function onClicked()
	
	If (Length:C16(String:C10(Form:C1466.prompt))=0)
		ALERT:C41("Please fill the prompt")
		return 
	End if 
	
	If (Shift down:C543)
		Form:C1466.openAI.apiKey:=""
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
		
		Case of 
			: ($message.role="assistant")
				$chat+="🤖 "+$message.content+" \n\n"
			: ($message.role="user")
				$chat+="👤 "+$message.content+" \n\n"
		End case 
		
	End for each 
	
	If (Length:C16(String:C10(Form:C1466.streamed))>0)
		$chat+="🤖 "+String:C10(Form:C1466.streamed)
	End if 
	
	Form:C1466.chat:=$chat
	
Function sendChat()
	
	var $options : cs:C1710.OpenAIChatCompletionParameters:={\
		stream: Bool:C1537(Form:C1466.stream); \
		model: This:C1470.modelSETDRAGICON; \
		formula: Formula:C1597(Bool:C1537(Form:C1466.stream) ? cs:C1710._FormDemo.me.onStreamChatReceive($1) : cs:C1710._FormDemo.me.onChatReceive($1))}
	
	
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
			
			Form:C1466.streamed+=$result.choices.map(Formula:C1597($1.value.delta.text)).join("")
			
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
		
		Form:C1466.modelsRemote:=$result.models.extract("id")
		
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