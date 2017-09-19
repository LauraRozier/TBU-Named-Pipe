using System;
using System.Windows.Forms;
using TBUNamedPipe;

namespace Client
{
    public partial class Form1 : Form
    {
        private Boolean connected = false;

        public Form1()
        {
            InitializeComponent();
        }

        private void SetButtons()
        {
            button1.Enabled = !connected;
            button2.Enabled = connected;
            button3.Enabled = connected;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            SetButtons();
            PipeClient.PipeClientInitialize();
            // Register our method delegates as callbacks
            PipeClient.RegisterOnDisconnectCallback(OnDisconnect);
            PipeClient.RegisterOnErrorCallback(OnError);
            PipeClient.RegisterOnMessageCallback(OnMessage);
            PipeClient.RegisterOnSentCallback(OnSent);
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            PipeClient.PipeClientDestroy();
        }

        private void Button1_Click(object sender, EventArgs e)
        {
            connected = PipeClient.PipeClientConnect();

            if (connected)
                textBox2.AppendText("<< Connected to pipe server." + PipeUtils.sLineBreak);
            else
                textBox2.AppendText("<< Failed to connected to pipe server." + PipeUtils.sLineBreak);

            SetButtons();
        }

        private void Button3_Click(object sender, EventArgs e)
        {
            PipeClient.PipeClientDisconnect();
            textBox2.AppendText("<< Disconnected from pipe server." + PipeUtils.sLineBreak);
            connected = false;
            SetButtons();
        }

        private void Button2_Click(object sender, EventArgs e)
        {
            if (PipeClient.PipeClientSend(textBox1.Text))
                textBox2.AppendText(string.Format("<< Successfully sent message: {0}", textBox1.Text) + PipeUtils.sLineBreak);
            else
                textBox2.AppendText(string.Format("<< Failed to send message: {0}", textBox1.Text) + PipeUtils.sLineBreak);

            textBox1.Text = string.Empty;
        }

        public void OnDisconnect(IntPtr self, UInt32 aPipe)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) disconnected.", aPipe) + PipeUtils.sLineBreak);
            connected = false;
            SetButtons();
        }

        public void OnError(IntPtr self, UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) generated error ({1}) in the {2} context.",
                                              aPipe, aErrorCode, PipeUtils.PipeContextToString(aPipeContext)) + PipeUtils.sLineBreak);
        }

        public void OnMessage(IntPtr self, UInt32 aPipe, string aMsg)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) sent a message: {1}", aPipe, aMsg) + PipeUtils.sLineBreak);
        }

        public void OnSent(IntPtr self, UInt32 aPipe, UInt32 aSize)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) received our message with a length of ({1}).", aPipe, aSize) + PipeUtils.sLineBreak);
        }
    }
}
