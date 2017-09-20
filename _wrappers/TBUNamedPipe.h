#ifndef __TBUNP_H__
#define __TBUNP_H__

#include <iostream>
#include <windows.h>
#include <assert.h>
#include <string>
#include <stdexcept>

namespace TBUNamedPipe
{
	using namespace System;
	using namespace System::Runtime::InteropServices;
	using namespace std;

#pragma region Server Delegates
	delegate void TPipeServerConnectCallback(void *self, unsigned int aPipe);
	delegate void TPipeServerDisconnectCallback(void *self, unsigned int aPipe);
	delegate void TPipeServerErrorCallback(void *self, unsigned int aPipe, SByte aPipeContext, int aErrorCode);
	delegate void TPipeServerMessageCallback(void *self, unsigned int aPipe, wchar_t *aMsg);
	delegate void TPipeServerSentCallback(void *self, unsigned int aPipe, unsigned int aSize);
#pragma endregion
#pragma region Client Delegates
	delegate void TPipeClientDisconnectCallback(void *self, unsigned int aPipe);
	delegate void TPipeClientErrorCallback(void *self, unsigned int aPipe, SByte aPipeContext, int aErrorCode);
	delegate void TPipeClientMessageCallback(void *self, unsigned int aPipe, wchar_t *aMsg);
	delegate void TPipeClientSentCallback(void *self, unsigned int aPipe, unsigned int aSize);
#pragma endregion

#pragma region Constants and Variables
	static const wchar_t *sLineBreak = L"\r\n";
	static HMODULE hModuleLibrary;
#pragma endregion

#pragma region Init/Destroy Library
	static void InitLibrary()
	{
		hModuleLibrary = LoadLibrary(TEXT("TBUNamedPipe.dll"));
	}

	static void DestroyLibrary()
	{
		FreeLibrary(hModuleLibrary);
	}
#pragma endregion

#pragma region Utilities
	static wchar_t *PipeContextToString(SByte aPipeContext)
	{
		switch (aPipeContext)
		{
			case 0:
				return L"Listener";
			case 1:
				return L"Worker";
			default:
				throw exception("Unknown Pipe Context ID");
		};
	}
#pragma endregion

	ref class PipeServer
	{
#pragma region Typedefs
		private: // Server methods
			typedef void(PASCAL *tPipeServerInitialize)();
			typedef void(PASCAL *tPipeServerDestroy)();
			typedef bool(PASCAL *tPipeServerStart)();
			typedef bool(PASCAL *tPipeServerStartNamed)(const wchar_t *aPipeName);
			typedef void(PASCAL *tPipeServerStop)();
			typedef bool(PASCAL *tPipeServerBroadcast)(const wchar_t *aMsg);
			typedef bool(PASCAL *tPipeServerSend)(unsigned int aPipe, const wchar_t *aMsg);
			typedef bool(PASCAL *tPipeServerDisconnect)(unsigned int aPipe);
			typedef unsigned int(PASCAL *tPipeServerGetClientCount)();

		private: // Server Callback Registration Procedures
			typedef void(PASCAL *tRegisterOnPipeServerConnectCallback)(TPipeServerConnectCallback^ aCallback, void *instance);
			typedef void(PASCAL *tRegisterOnPipeServerDisconnectCallback)(TPipeServerDisconnectCallback^ aCallback, void *instance);
			typedef void(PASCAL *tRegisterOnPipeServerErrorCallback)(TPipeServerErrorCallback^ aCallback, void *instance);
			typedef void(PASCAL *tRegisterOnPipeServerMessageCallback)(TPipeServerMessageCallback^ aCallback, void *instance);
			typedef void(PASCAL *tRegisterOnPipeServerSentCallback)(TPipeServerSentCallback^ aCallback, void *instance);
#pragma endregion

#pragma region Variables
		private:
			static TPipeServerConnectCallback^ sccb;
			static TPipeServerDisconnectCallback^ sdcb;
			static TPipeServerErrorCallback^ secb;
			static TPipeServerMessageCallback^ smcb;
			static TPipeServerSentCallback^ sscb;
#pragma endregion

#pragma region Server Methods
		public:
			static void PipeServerInitialize()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerInitialize pPipeServerInitialize =
					(tPipeServerInitialize)GetProcAddress(hModuleLibrary, "PipeServerInitialize");
				assert(pPipeServerInitialize != NULL);
				(*pPipeServerInitialize)();
			}

			static void PipeServerDestroy()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerDestroy pPipeServerDestroy =
					(tPipeServerDestroy)GetProcAddress(hModuleLibrary, "PipeServerDestroy");
				assert(pPipeServerDestroy != NULL);
				(*pPipeServerDestroy)();
			}

			static bool PipeServerStart()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerStart pPipeServerStart =
					(tPipeServerStart)GetProcAddress(hModuleLibrary, "PipeServerStart");
				assert(pPipeServerStart != NULL);
				return (*pPipeServerStart)();
			}

			static bool PipeServerStartNamed(const wchar_t *aPipeName)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerStartNamed pPipeServerStartNamed =
					(tPipeServerStartNamed)GetProcAddress(hModuleLibrary, "PipeServerStartNamed");
				assert(pPipeServerStartNamed != NULL);
				return (*pPipeServerStartNamed)(aPipeName);
			}

			static void PipeServerStop()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerStop pPipeServerStop =
					(tPipeServerStop)GetProcAddress(hModuleLibrary, "PipeServerStop");
				assert(pPipeServerStop != NULL);
				(*pPipeServerStop)();
			}

			static bool PipeServerBroadcast(const wchar_t *aMsg)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerBroadcast pPipeServerBroadcast =
					(tPipeServerBroadcast)GetProcAddress(hModuleLibrary, "PipeServerBroadcast");
				assert(pPipeServerBroadcast != NULL);
				return (*pPipeServerBroadcast)(aMsg);
			}

			static bool PipeServerSend(unsigned int aPipe, const wchar_t *aMsg)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerSend pPipeServerSend =
					(tPipeServerSend)GetProcAddress(hModuleLibrary, "PipeServerSend");
				assert(pPipeServerSend != NULL);
				return (*pPipeServerSend)(aPipe, aMsg);
			}

			static bool PipeServerDisconnect(unsigned int aPipe)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerDisconnect pPipeServerDisconnect =
					(tPipeServerDisconnect)GetProcAddress(hModuleLibrary, "PipeServerDisconnect");
				assert(pPipeServerDisconnect != NULL);
				return (*pPipeServerDisconnect)(aPipe);
			}

			static unsigned int PipeServerGetClientCount()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerGetClientCount pPipeServerGetClientCount =
					(tPipeServerGetClientCount)GetProcAddress(hModuleLibrary, "PipeServerGetClientCount");
				assert(pPipeServerGetClientCount != NULL);
				return (*pPipeServerGetClientCount)();
			}
#pragma endregion

#pragma region Server Callback Registration Procedures
		public:
			static void RegisterOnConnectCallback(TPipeServerConnectCallback^ aCallback)
			{
				assert(hModuleLibrary != NULL);
				tRegisterOnPipeServerConnectCallback pRegisterOnPipeServerConnectCallback =
					(tRegisterOnPipeServerConnectCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeServerConnectCallback");
				assert(pRegisterOnPipeServerConnectCallback != NULL);

				// Store the delegate to prevent GC
				sccb = aCallback;

				// Register the callback with the DLL
				(*pRegisterOnPipeServerConnectCallback)(sccb, NULL);
			}

			static void RegisterOnDisconnectCallback(TPipeServerDisconnectCallback^ aCallback)
			{
				assert(hModuleLibrary != NULL);
				tRegisterOnPipeServerDisconnectCallback pRegisterOnPipeServerDisconnectCallback =
					(tRegisterOnPipeServerDisconnectCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeServerDisconnectCallback");
				assert(pRegisterOnPipeServerDisconnectCallback != NULL);

				// Store the delegate to prevent GC
				sdcb = aCallback;

				// Register the callback with the DLL
				(*pRegisterOnPipeServerDisconnectCallback)(sdcb, NULL);
			}

			static void RegisterOnErrorCallback(TPipeServerErrorCallback^ aCallback)
			{
				assert(hModuleLibrary != NULL);
				tRegisterOnPipeServerErrorCallback pRegisterOnPipeServerErrorCallback =
					(tRegisterOnPipeServerErrorCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeServerErrorCallback");
				assert(pRegisterOnPipeServerErrorCallback != NULL);

				// Store the delegate to prevent GC
				secb = aCallback;

				// Register the callback with the DLL
				(*pRegisterOnPipeServerErrorCallback)(secb, NULL);
			}

			static void RegisterOnMessageCallback(TPipeServerMessageCallback^ aCallback)
			{
				assert(hModuleLibrary != NULL);
				tRegisterOnPipeServerMessageCallback pRegisterOnPipeServerMessageCallback =
					(tRegisterOnPipeServerMessageCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeServerMessageCallback");
				assert(pRegisterOnPipeServerMessageCallback != NULL);

				// Store the delegate to prevent GC
				smcb = aCallback;

				// Register the callback with the DLL
				(*pRegisterOnPipeServerMessageCallback)(smcb, NULL);
			}

			static void RegisterOnSentCallback(TPipeServerSentCallback^ aCallback)
			{
				assert(hModuleLibrary != NULL);
				tRegisterOnPipeServerSentCallback pRegisterOnPipeServerSentCallback =
					(tRegisterOnPipeServerSentCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeServerSentCallback");
				assert(pRegisterOnPipeServerSentCallback != NULL);

				// Store the delegate to prevent GC
				sscb = aCallback;

				// Register the callback with the DLL
				(*pRegisterOnPipeServerSentCallback)(sscb, NULL);
			}
#pragma endregion
	};

	ref class PipeClient
	{
#pragma region Typedefs
	private: // Client methods
		typedef void(PASCAL *tPipeClientInitialize)();
		typedef void(PASCAL *tPipeClientDestroy)();
		typedef bool(PASCAL *tPipeClientConnect)();
		typedef bool(PASCAL *tPipeClientConnectNamed)(const wchar_t *aPipeName);
		typedef bool(PASCAL *tPipeClientConnectRemote)(const wchar_t *aServerName);
		typedef bool(PASCAL *tPipeClientConnectRemoteNamed)(const wchar_t *aServerName, const wchar_t *aPipeName);
		typedef bool(PASCAL *tPipeClientSend)(const wchar_t *aMsg);
		typedef void(PASCAL *tPipeClientDisconnect)();
		typedef unsigned int(PASCAL *tPipeClientGetPipeId)();

	private: // Client Callback Registration Procedures
		typedef void(PASCAL *tRegisterOnPipeClientDisconnectCallback)(TPipeClientDisconnectCallback^ aCallback, void *instance);
		typedef void(PASCAL *tRegisterOnPipeClientErrorCallback)(TPipeClientErrorCallback^ aCallback, void *instance);
		typedef void(PASCAL *tRegisterOnPipeClientMessageCallback)(TPipeClientMessageCallback^ aCallback, void *instance);
		typedef void(PASCAL *tRegisterOnPipeClientSentCallback)(TPipeClientSentCallback^ aCallback, void *instance);
#pragma endregion

#pragma region Variables
	private:
		static TPipeClientDisconnectCallback^ cdcb;
		static TPipeClientErrorCallback^ cecb;
		static TPipeClientMessageCallback^ cmcb;
		static TPipeClientSentCallback^ cscb;
#pragma endregion

#pragma region Client Methods
	public:
		static void PipeClientInitialize()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientInitialize pPipeClientInitialize =
				(tPipeClientInitialize)GetProcAddress(hModuleLibrary, "PipeClientInitialize");
			assert(pPipeClientInitialize != NULL);
			(*pPipeClientInitialize)();
		}

		static void PipeClientDestroy()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientDestroy pPipeClientDestroy =
				(tPipeClientDestroy)GetProcAddress(hModuleLibrary, "PipeClientDestroy");
			assert(pPipeClientDestroy != NULL);
			(*pPipeClientDestroy)();
		}

		static bool PipeClientConnect()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnect pPipeClientConnect =
				(tPipeClientConnect)GetProcAddress(hModuleLibrary, "PipeClientConnect");
			assert(pPipeClientConnect != NULL);
			return (*pPipeClientConnect)();
		}

		static bool PipeClientConnectNamed(const wchar_t *aPipeName)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnectNamed pPipeClientConnectNamed =
				(tPipeClientConnectNamed)GetProcAddress(hModuleLibrary, "PipeClientConnectNamed");
			assert(pPipeClientConnectNamed != NULL);
			return (*pPipeClientConnectNamed)(aPipeName);
		}

		static bool PipeClientConnectRemote(const wchar_t *aServerName)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnectRemote pPipeClientConnectRemote =
				(tPipeClientConnectRemote)GetProcAddress(hModuleLibrary, "PipeClientConnectRemote");
			assert(pPipeClientConnectRemote != NULL);
			return (*pPipeClientConnectRemote)(aServerName);
		}

		static bool PipeClientConnectRemoteNamed(const wchar_t *aServerName, const wchar_t *aPipeName)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnectRemoteNamed pPipeClientConnectRemoteNamed =
				(tPipeClientConnectRemoteNamed)GetProcAddress(hModuleLibrary, "PipeClientConnectRemoteNamed");
			assert(pPipeClientConnectRemoteNamed != NULL);
			return (*pPipeClientConnectRemoteNamed)(aServerName, aPipeName);
		}

		static bool PipeClientSend(const wchar_t *aMsg)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientSend pPipeClientSend =
				(tPipeClientSend)GetProcAddress(hModuleLibrary, "PipeClientSend");
			assert(pPipeClientSend != NULL);
			return (*pPipeClientSend)(aMsg);
		}

		static void PipeClientDisconnect()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientDisconnect pPipeClientDisconnect =
				(tPipeClientDisconnect)GetProcAddress(hModuleLibrary, "PipeClientDisconnect");
			assert(pPipeClientDisconnect != NULL);
			return (*pPipeClientDisconnect)();
		}

		static unsigned int PipeClientGetPipeId()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientGetPipeId pPipeClientGetPipeId =
				(tPipeClientGetPipeId)GetProcAddress(hModuleLibrary, "PipeClientGetPipeId");
			assert(pPipeClientGetPipeId != NULL);
			return (*pPipeClientGetPipeId)();
		}
#pragma endregion

#pragma region Client Callback Registration Procedures
	public:
		static void RegisterOnDisconnectCallback(TPipeClientDisconnectCallback^ aCallback)
		{
			assert(hModuleLibrary != NULL);
			tRegisterOnPipeClientDisconnectCallback pRegisterOnPipeClientDisconnectCallback =
				(tRegisterOnPipeClientDisconnectCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeClientDisconnectCallback");
			assert(pRegisterOnPipeClientDisconnectCallback != NULL);

			// Store the delegate to prevent GC
			cdcb = aCallback;

			// Register the callback with the DLL
			(*pRegisterOnPipeClientDisconnectCallback)(cdcb, NULL);
		}

		static void RegisterOnErrorCallback(TPipeClientErrorCallback^ aCallback)
		{
			assert(hModuleLibrary != NULL);
			tRegisterOnPipeClientErrorCallback pRegisterOnPipeClientErrorCallback =
				(tRegisterOnPipeClientErrorCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeClientErrorCallback");
			assert(pRegisterOnPipeClientErrorCallback != NULL);

			// Store the delegate to prevent GC
			cecb = aCallback;

			// Register the callback with the DLL
			(*pRegisterOnPipeClientErrorCallback)(cecb, NULL);
		}

		static void RegisterOnMessageCallback(TPipeClientMessageCallback^ aCallback)
		{
			assert(hModuleLibrary != NULL);
			tRegisterOnPipeClientMessageCallback pRegisterOnPipeClientMessageCallback =
				(tRegisterOnPipeClientMessageCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeClientMessageCallback");
			assert(pRegisterOnPipeClientMessageCallback != NULL);

			// Store the delegate to prevent GC
			cmcb = aCallback;

			// Register the callback with the DLL
			(*pRegisterOnPipeClientMessageCallback)(cmcb, NULL);
		}

		static void RegisterOnSentCallback(TPipeClientSentCallback^ aCallback)
		{
			assert(hModuleLibrary != NULL);
			tRegisterOnPipeClientSentCallback pRegisterOnPipeClientSentCallback =
				(tRegisterOnPipeClientSentCallback)GetProcAddress(hModuleLibrary, "RegisterOnPipeClientSentCallback");
			assert(pRegisterOnPipeClientSentCallback != NULL);

			// Store the delegate to prevent GC
			cscb = aCallback;

			// Register the callback with the DLL
			(*pRegisterOnPipeClientSentCallback)(cscb, NULL);
		}
#pragma endregion
	};
}

#endif /*__TBUNP_H__*/
