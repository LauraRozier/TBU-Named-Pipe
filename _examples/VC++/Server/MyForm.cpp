#include "MyForm.h"

using namespace Server;

[STAThread]
void Main()
{
	Application::EnableVisualStyles();
	Application::SetCompatibleTextRenderingDefault(false);
	MyForm mainForm;
	Application::Run(%mainForm);
}

void MyForm::SetButtons()
{
	button1->Enabled = Connected;
	button2->Enabled = Connected;
	button3->Enabled = !Connected;
}

void MyForm::MyForm_Load(Object^ sender, EventArgs^ e)
{
	InitLibrary();
	SetButtons();
	PipeServer::PipeServerInitialize();
	// Register our method delegates as callbacks
	TPipeServerConnectCallback^ sccb = gcnew TPipeServerConnectCallback(&MyForm::OnConnect);
	PipeServer::RegisterOnConnectCallback(sccb);
	TPipeServerDisconnectCallback^ sdcb = gcnew TPipeServerDisconnectCallback(&MyForm::OnDisconnect);
	PipeServer::RegisterOnDisconnectCallback(sdcb);
	TPipeServerErrorCallback^ secb = gcnew TPipeServerErrorCallback(&MyForm::OnError);
	PipeServer::RegisterOnErrorCallback(secb);
	TPipeServerMessageCallback^ smcb = gcnew TPipeServerMessageCallback(&MyForm::OnMessage);
	PipeServer::RegisterOnMessageCallback(smcb);
	TPipeServerSentCallback^ sscb = gcnew TPipeServerSentCallback(&MyForm::OnSent);
	PipeServer::RegisterOnSentCallback(sscb);
}

void MyForm::MyForm_FormClosing(Object^ sender, FormClosingEventArgs^ e)
{
	PipeServer::PipeServerDestroy();
	DestroyLibrary();
}

void MyForm::button1_Click(Object^ sender, EventArgs^ e)
{
	if (Connected) {
		// Pin memory so GC can't move it while native function is called  
		pin_ptr<const wchar_t> wch = PtrToStringChars(textBox1->Text);

		if (PipeServer::PipeServerBroadcast(wch))
			MyForm::textBox2->AppendText(String::Format("<< Successfully broadcasted message: {0}\r\n", textBox1->Text));
		else
			MyForm::textBox2->AppendText(String::Format("<< Failed to broadcast message: {0}\r\n", textBox1->Text));

		textBox1->Text = String::Empty;
	};
}

void MyForm::button2_Click(Object^ sender, EventArgs^ e)
{
	if (Connected) {
		PipeServer::PipeServerStop();
		MyForm::textBox2->AppendText("<< Pipe server stopped.\r\n");
		Connected = false;
	};

	SetButtons();
}

void MyForm::button3_Click(Object^ sender, EventArgs^ e)
{
	if (!Connected) {
		Connected = PipeServer::PipeServerStart();

		if (Connected)
			MyForm::textBox2->AppendText("<< Pipe server started.\r\n");
		else
			MyForm::textBox2->AppendText("<< Unable to start the pipe server.\r\n");
	};

	SetButtons();
}

void MyForm::OnConnect(void *self, unsigned int aPipe)
{
	MyForm::textBox2->AppendText(String::Format(">> New pipe ({0}) connected.\r\n", aPipe));
}

void MyForm::OnDisconnect(void *self, unsigned int aPipe)
{
	MyForm::textBox2->AppendText(String::Format(">> Pipe ({0}) disconnected.\r\n", aPipe));
}

void MyForm::OnError(void *self, unsigned int aPipe, SByte aPipeContext, int aErrorCode)
{
	wchar_t *contextStr = PipeContextToString(aPipeContext);
	String^ contextText = gcnew String(contextStr);
	MyForm::textBox2->AppendText(String::Format(">> Pipe ({0}) generated error ({1}) in the {2} context.\r\n", aPipe, aErrorCode, contextText));
}

void MyForm::OnMessage(void *self, unsigned int aPipe, wchar_t *aMsg)
{
	String^ msgText = gcnew String(aMsg);
	MyForm::textBox2->AppendText(String::Format(">> Pipe ({0}) sent a message: {1}\r\n", aPipe, msgText));
}

void MyForm::OnSent(void *self, unsigned int aPipe, unsigned int aSize)
{
	MyForm::textBox2->AppendText(String::Format(">> Pipe ({0}) received our message with a length of ({1}).\r\n", aPipe, aSize));
}
