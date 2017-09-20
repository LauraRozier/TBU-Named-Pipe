#ifndef Client_H
#define Client_H

#include <vcclr.h>
#include <string>
#include <windows.h>
#include "..\..\..\_wrappers\TBUNamedPipe.h"

namespace Client {
	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	using namespace std;
	using namespace TBUNamedPipe;

	/// <summary>
	/// Summary for MyForm
	/// </summary>
	public ref class MyForm : Form
	{
		public:
			MyForm(void)
			{
				InitializeComponent();
			}

		protected:
			/// <summary>
			/// Clean up any resources being used.
			/// </summary>
			~MyForm()
			{
				if (components)
					delete components;
			}

		private:
			static System::Windows::Forms::Button^ button1;
			static System::Windows::Forms::Button^ button2;
			static System::Windows::Forms::Button^ button3;
			System::Windows::Forms::Label^ label1;
			System::Windows::Forms::Label^ label2;
			System::Windows::Forms::TextBox^ textBox1;
			static System::Windows::Forms::TextBox^ textBox2;
			/// <summary>
			/// Required designer variable.
			/// </summary>
			System::ComponentModel::Container ^components;
			static bool Connected = false;

#pragma region Windows Form Designer generated code
		private:
			/// <summary>
			/// Required method for Designer support - do not modify
			/// the contents of this method with the code editor.
			/// </summary>
			void InitializeComponent(void)
			{
				this->button1 = (gcnew System::Windows::Forms::Button());
				this->button2 = (gcnew System::Windows::Forms::Button());
				this->button3 = (gcnew System::Windows::Forms::Button());
				this->label1 = (gcnew System::Windows::Forms::Label());
				this->label2 = (gcnew System::Windows::Forms::Label());
				this->textBox1 = (gcnew System::Windows::Forms::TextBox());
				this->textBox2 = (gcnew System::Windows::Forms::TextBox());
				this->SuspendLayout();
				// 
				// button1
				// 
				this->button1->Location = System::Drawing::Point(566, 315);
				this->button1->Name = L"button1";
				this->button1->Size = System::Drawing::Size(57, 23);
				this->button1->TabIndex = 0;
				this->button1->Text = L"Send";
				this->button1->UseVisualStyleBackColor = true;
				this->button1->Click += gcnew System::EventHandler(this, &MyForm::button1_Click);
				// 
				// button2
				// 
				this->button2->Location = System::Drawing::Point(548, 12);
				this->button2->Name = L"button2";
				this->button2->Size = System::Drawing::Size(75, 23);
				this->button2->TabIndex = 1;
				this->button2->Text = L"Disconnect";
				this->button2->UseVisualStyleBackColor = true;
				this->button2->Click += gcnew System::EventHandler(this, &MyForm::button2_Click);
				// 
				// button3
				// 
				this->button3->Location = System::Drawing::Point(458, 12);
				this->button3->Name = L"button3";
				this->button3->Size = System::Drawing::Size(75, 23);
				this->button3->TabIndex = 2;
				this->button3->Text = L"Connect";
				this->button3->UseVisualStyleBackColor = true;
				this->button3->Click += gcnew System::EventHandler(this, &MyForm::button3_Click);
				// 
				// label1
				// 
				this->label1->AutoSize = true;
				this->label1->Location = System::Drawing::Point(12, 25);
				this->label1->Name = L"label1";
				this->label1->Size = System::Drawing::Size(28, 13);
				this->label1->TabIndex = 3;
				this->label1->Text = L"Log:";
				// 
				// label2
				// 
				this->label2->AutoSize = true;
				this->label2->Location = System::Drawing::Point(12, 320);
				this->label2->Name = L"label2";
				this->label2->Size = System::Drawing::Size(81, 13);
				this->label2->TabIndex = 4;
				this->label2->Text = L"Send Message:";
				// 
				// textBox1
				// 
				this->textBox1->Location = System::Drawing::Point(99, 317);
				this->textBox1->Name = L"textBox1";
				this->textBox1->Size = System::Drawing::Size(461, 20);
				this->textBox1->TabIndex = 5;
				// 
				// textBox2
				// 
				this->textBox2->Location = System::Drawing::Point(12, 41);
				this->textBox2->Multiline = true;
				this->textBox2->Name = L"textBox2";
				this->textBox2->ReadOnly = true;
				this->textBox2->Size = System::Drawing::Size(611, 268);
				this->textBox2->TabIndex = 6;
				// 
				// MyForm
				// 
				this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
				this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
				this->ClientSize = System::Drawing::Size(635, 350);
				this->Controls->Add(this->textBox2);
				this->Controls->Add(this->textBox1);
				this->Controls->Add(this->label2);
				this->Controls->Add(this->label1);
				this->Controls->Add(this->button3);
				this->Controls->Add(this->button2);
				this->Controls->Add(this->button1);
				this->Name = L"MyForm";
				this->Text = L"C++ Client";
				this->FormClosing += gcnew System::Windows::Forms::FormClosingEventHandler(this, &MyForm::MyForm_FormClosing);
				this->Load += gcnew System::EventHandler(this, &MyForm::MyForm_Load);
				this->ResumeLayout(false);
				this->PerformLayout();

			}
#pragma endregion

		private:
			static void SetButtons();
			void MyForm_Load(Object^ sender, EventArgs^ e);
			void MyForm_FormClosing(Object^ sender, FormClosingEventArgs^ e);
			void button1_Click(Object^ sender, EventArgs^ e);
			void button2_Click(Object^ sender, EventArgs^ e);
			void button3_Click(Object^ sender, EventArgs^ e);

		public:
			static void OnDisconnect(void *self, unsigned int aPipe);
			static void OnError(void *self, unsigned int aPipe, SByte aPipeContext, int aErrorCode);
			static void OnMessage(void *self, unsigned int aPipe, wchar_t *aMsg);
			static void OnSent(void *self, unsigned int aPipe, unsigned int aSize);
	};
}
#endif /*Client_H*/
