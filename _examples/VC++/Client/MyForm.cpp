#include "MyForm.h"

using namespace Client;

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
	PipeClient::PipeClientInitialize();
	// Register our method delegates as callbacks
	TPipeClientDisconnectCallback^ sdcb = gcnew TPipeClientDisconnectCallback(&MyForm::OnDisconnect);
	PipeClient::RegisterOnDisconnectCallback(sdcb);
	TPipeClientErrorCallback^ secb = gcnew TPipeClientErrorCallback(&MyForm::OnError);
	PipeClient::RegisterOnErrorCallback(secb);
	TPipeClientMessageCallback^ smcb = gcnew TPipeClientMessageCallback(&MyForm::OnMessage);
	PipeClient::RegisterOnMessageCallback(smcb);
	TPipeClientSentCallback^ sscb = gcnew TPipeClientSentCallback(&MyForm::OnSent);
	PipeClient::RegisterOnSentCallback(sscb);
}

void MyForm::MyForm_FormClosing(Object^ sender, FormClosingEventArgs^ e)
{
	PipeClient::PipeClientDestroy();
	DestroyLibrary();
}

void MyForm::button1_Click(Object^ sender, EventArgs^ e)
{
	if (Connected) {
		// Pin memory so GC can't move it while native function is called  
		pin_ptr<const wchar_t> wch = PtrToStringChars(textBox1->Text);

		if (PipeClient::PipeClientSend(wch))
			MyForm::textBox2->AppendText(String::Format("<< Successfully sent message: {0}\r\n", textBox1->Text));
		else
			MyForm::textBox2->AppendText(String::Format("<< Failed to send message: {0}\r\n", textBox1->Text));

		textBox1->Text = String::Empty;
	};
}

void MyForm::button2_Click(Object^ sender, EventArgs^ e)
{
	if (Connected) {
		PipeClient::PipeClientDisconnect();
		MyForm::textBox2->AppendText("<< Disconnected from pipe server.\r\n");
		Connected = false;
	};

	SetButtons();
}

void MyForm::button3_Click(Object^ sender, EventArgs^ e)
{
	if (!Connected) {
		Connected = PipeClient::PipeClientConnect();

		if (Connected)
			MyForm::textBox2->AppendText("<< Connected to pipe server.\r\n");
		else
			MyForm::textBox2->AppendText("<< Failed to connected to pipe server.\r\n");
	};

	SetButtons();
}

void MyForm::OnDisconnect(void *self, unsigned int aPipe)
{
	MyForm::textBox2->AppendText(String::Format(">> Pipe ({0}) disconnected.\r\n", aPipe));
	Connected = false;
	SetButtons();
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
