﻿using System;
using System.Windows.Forms;
using TBUNamedPipe;

namespace Server
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
            button1.Enabled = connected;
            button2.Enabled = !connected;
            button3.Enabled = connected;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            SetButtons();
            PipeServer.PipeServerInitialize();
            PipeServer.RegisterOnPipeServerConnectCallback(OnConnect);
            PipeServer.RegisterOnPipeServerDisconnectCallback(OnDisconnect);
            PipeServer.RegisterOnPipeServerErrorCallback(OnError);
            PipeServer.RegisterOnPipeServerMessageCallback(OnMessage);
            PipeServer.RegisterOnPipeServerSentCallback(OnSent);
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            PipeServer.PipeServerDestroy();
        }

        private void Button2_Click(object sender, EventArgs e)
        {
            connected = PipeServer.PipeServerStart();
            textBox2.AppendText("<< Pipe server started." + PipeUtils.sLineBreak);
            SetButtons();
        }

        private void Button3_Click(object sender, EventArgs e)
        {
            PipeServer.PipeServerStop();
            textBox2.AppendText("<< Pipe server stopped." + PipeUtils.sLineBreak);
            connected = false;
            SetButtons();
        }

        private void Button1_Click(object sender, EventArgs e)
        {
            if (PipeServer.PipeServerBroadcast(textBox1.Text))
                textBox2.AppendText(string.Format("<< Successfully broadcasted message: {0}", textBox1.Text) + PipeUtils.sLineBreak);
            else
                textBox2.AppendText(string.Format("<< Failed to broadcast message: {0}", textBox1.Text) + PipeUtils.sLineBreak);

            textBox1.Text = string.Empty;
        }

        public void OnConnect(UInt32 aPipe)
        {
            textBox2.AppendText(string.Format(">> New pipe ({0}) connected.", aPipe) + PipeUtils.sLineBreak);
        }

        public void OnDisconnect(UInt32 aPipe)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) disconnected.", aPipe) + PipeUtils.sLineBreak);
        }

        public void OnError(UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) generated error ({1}) in the {2} context.",
                                              aPipe, aErrorCode, PipeUtils.PipeContextToString(aPipeContext)) + PipeUtils.sLineBreak);
        }
        
        public void OnMessage(UInt32 aPipe, string aMsg)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) sent a message: {1}", aPipe, aMsg) + PipeUtils.sLineBreak);
        }

        public void OnSent(UInt32 aPipe, UInt32 aSize)
        {
            textBox2.AppendText(string.Format(">> Pipe ({0}) received our message with a length of ({1}).", aPipe, aSize) + PipeUtils.sLineBreak);
        }
    }
}
