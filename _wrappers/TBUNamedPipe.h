#ifndef __TBUNP_H__
#define __TBUNP_H__

#include <iostream>
#include <windows.h>
#include <assert.h>
#include <string>
#include <stdexcept>

/// <summary>
/// Named pipe classes for use with local and remote IPC
/// </summary>
namespace TBUNamedPipe
{
	using namespace System;
	using namespace System::Runtime::InteropServices;
	using namespace std;

#pragma region Server Delegates
	/// <summary>
    /// OnConnect callback delegate
    /// </summary>
    /// <param name="self">The sender</param>
    /// <param name="aPipe">The pipe ID</param>
	delegate void TPipeServerConnectCallback(void *self, unsigned int aPipe);
	/// <summary>
	/// OnDisconnect callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	delegate void TPipeServerDisconnectCallback(void *self, unsigned int aPipe);
	/// <summary>
	/// OnError callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	/// <param name="aPipeContext">The context of the error</param>
	/// <param name="aErrorCode">The error code</param>
	delegate void TPipeServerErrorCallback(void *self, unsigned int aPipe, SByte aPipeContext, int aErrorCode);
	/// <summary>
	/// OnMessage callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	/// <param name="aMsg">The message</param>
	delegate void TPipeServerMessageCallback(void *self, unsigned int aPipe, wchar_t *aMsg);
	/// <summary>
	/// OnSent callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	/// <param name="aSize">The message size in bytes</param>
	delegate void TPipeServerSentCallback(void *self, unsigned int aPipe, unsigned int aSize);
#pragma endregion
#pragma region Client Delegates
	/// <summary>
	/// OnDisconnect callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	delegate void TPipeClientDisconnectCallback(void *self, unsigned int aPipe);
	/// <summary>
	/// OnError callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	/// <param name="aPipeContext">The context of the error</param>
	/// <param name="aErrorCode">The error code</param>
	delegate void TPipeClientErrorCallback(void *self, unsigned int aPipe, SByte aPipeContext, int aErrorCode);
	/// <summary>
	/// OnMessage callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	/// <param name="aMsg">The message</param>
	delegate void TPipeClientMessageCallback(void *self, unsigned int aPipe, wchar_t *aMsg);
	/// <summary>
	/// OnSent callback delegate
	/// </summary>
	/// <param name="self">The sender</param>
	/// <param name="aPipe">The pipe ID</param>
	/// <param name="aSize">The message size in bytes</param>
	delegate void TPipeClientSentCallback(void *self, unsigned int aPipe, unsigned int aSize);
#pragma endregion

#pragma region Constants and Variables
	/// <summary>
	/// Windows linebreak constant
	/// </summary>
	static const wchar_t *sLineBreak = L"\r\n";
	/// <summary>
	/// DLL handle
	/// </summary>
	static HMODULE hModuleLibrary;
#pragma endregion

#pragma region Init/Destroy Library
	/// <summary>
	/// Load the DLL
	/// </summary>
	static void InitLibrary()
	{
		hModuleLibrary = LoadLibrary(TEXT("TBUNamedPipe.dll"));
	}

	/// <summary>
	/// Free the DLL handle
	/// </summary>
	static void DestroyLibrary()
	{
		FreeLibrary(hModuleLibrary);
	}
#pragma endregion

#pragma region Utilities
	/// <summary>
	/// Translates a context ID to it's string value
	/// </summary>
	/// <param name="aPipeContext">The context ID</param>
	/// <returns>The name of the context</returns>
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

	/// <summary>
	/// The pipe server enables you to setup a pipe listner
	/// </summary>
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
			/// <summary>
			/// Holds the OnConnect callback to prevent GC collection
			/// </summary>
			static TPipeServerConnectCallback^ sccb;
			/// <summary>
			/// Holds the OnDisconnect callback to prevent GC collection
			/// </summary>
			static TPipeServerDisconnectCallback^ sdcb;
			/// <summary>
			/// Holds the OnError callback to prevent GC collection
			/// </summary>
			static TPipeServerErrorCallback^ secb;
			/// <summary>
			/// Holds the OnMessage callback to prevent GC collection
			/// </summary>
			static TPipeServerMessageCallback^ smcb;
			/// <summary>
			/// Holds the OnSent callback to prevent GC collection
			/// </summary>
			static TPipeServerSentCallback^ sscb;
#pragma endregion

#pragma region Server Methods
		public:
			/// <summary>
			/// Initialize the pipe server class
			/// </summary>
			static void PipeServerInitialize()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerInitialize pPipeServerInitialize =
					(tPipeServerInitialize)GetProcAddress(hModuleLibrary, "PipeServerInitialize");
				assert(pPipeServerInitialize != NULL);
				(*pPipeServerInitialize)();
			}

			/// <summary>
			/// Destroy the pipe server class
			/// </summary>
			static void PipeServerDestroy()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerDestroy pPipeServerDestroy =
					(tPipeServerDestroy)GetProcAddress(hModuleLibrary, "PipeServerDestroy");
				assert(pPipeServerDestroy != NULL);
				(*pPipeServerDestroy)();
			}

			/// <summary>
			/// Start the pipe server listener thread
			/// </summary>
			/// <returns>True on success</returns>
			static bool PipeServerStart()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerStart pPipeServerStart =
					(tPipeServerStart)GetProcAddress(hModuleLibrary, "PipeServerStart");
				assert(pPipeServerStart != NULL);
				return (*pPipeServerStart)();
			}

			/// <summary>
			/// Start the pipe server listener thread
			/// </summary>
			/// <param name="aPipeName">The pipe name</param>
			/// <returns>True on success</returns>
			static bool PipeServerStartNamed(const wchar_t *aPipeName)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerStartNamed pPipeServerStartNamed =
					(tPipeServerStartNamed)GetProcAddress(hModuleLibrary, "PipeServerStartNamed");
				assert(pPipeServerStartNamed != NULL);
				return (*pPipeServerStartNamed)(aPipeName);
			}

			/// <summary>
			/// Stop the pipe server listener thread
			/// </summary>
			static void PipeServerStop()
			{
				assert(hModuleLibrary != NULL);
				tPipeServerStop pPipeServerStop =
					(tPipeServerStop)GetProcAddress(hModuleLibrary, "PipeServerStop");
				assert(pPipeServerStop != NULL);
				(*pPipeServerStop)();
			}

			/// <summary>
			/// Broadcast a message to all connected pipes
			/// </summary>
			/// <param name="aMsg">The message</param>
			/// <returns>True on success</returns>
			static bool PipeServerBroadcast(const wchar_t *aMsg)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerBroadcast pPipeServerBroadcast =
					(tPipeServerBroadcast)GetProcAddress(hModuleLibrary, "PipeServerBroadcast");
				assert(pPipeServerBroadcast != NULL);
				return (*pPipeServerBroadcast)(aMsg);
			}

			/// <summary>
			/// Send a message to the specified pipe
			/// </summary>
			/// <param name="aPipe">Pipe ID</param>
			/// <param name="aMsg">The message</param>
			/// <returns>True on success</returns>
			static bool PipeServerSend(unsigned int aPipe, const wchar_t *aMsg)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerSend pPipeServerSend =
					(tPipeServerSend)GetProcAddress(hModuleLibrary, "PipeServerSend");
				assert(pPipeServerSend != NULL);
				return (*pPipeServerSend)(aPipe, aMsg);
			}

			/// <summary>
			/// Disconnect a specific pipe ( Use 0 [zero] for all connected pipes )
			/// </summary>
			/// <param name="aPipe">Pipe ID</param>
			/// <returns>True on success</returns>
			static bool PipeServerDisconnect(unsigned int aPipe)
			{
				assert(hModuleLibrary != NULL);
				tPipeServerDisconnect pPipeServerDisconnect =
					(tPipeServerDisconnect)GetProcAddress(hModuleLibrary, "PipeServerDisconnect");
				assert(pPipeServerDisconnect != NULL);
				return (*pPipeServerDisconnect)(aPipe);
			}

			/// <summary>
			/// Retrieve the amount of connected pipes
			/// </summary>
			/// <returns>The amount of pipes that are currently connected</returns>
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
			/// <summary>
			/// Register the OnConnect callback method
			/// </summary>
			/// <param name="aCallback">The callback method</param>
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

			/// <summary>
			/// Register the OnDisconnect callback method
			/// </summary>
			/// <param name="aCallback">The callback method</param>
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

			/// <summary>
			/// Register the OnError callback method
			/// </summary>
			/// <param name="aCallback">The callback method</param>
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

			/// <summary>
			/// Register the OnMessage callback method
			/// </summary>
			/// <param name="aCallback">The callback method</param>
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

			/// <summary>
			/// Register the OnSent callback method
			/// </summary>
			/// <param name="aCallback">The callback method</param>
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

	/// <summary>
	/// The pipe client enables you to connect to a pipe server
	/// </summary>
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
		/// <summary>
		/// Holds the OnDisconnect callback to prevent GC collection
		/// </summary>
		static TPipeClientDisconnectCallback^ cdcb;
		/// <summary>
		/// Holds the OnError callback to prevent GC collection
		/// </summary>
		static TPipeClientErrorCallback^ cecb;
		/// <summary>
		/// Holds the OnMessage callback to prevent GC collection
		/// </summary>
		static TPipeClientMessageCallback^ cmcb;
		/// <summary>
		/// Holds the OnSent callback to prevent GC collection
		/// </summary>
		static TPipeClientSentCallback^ cscb;
#pragma endregion

#pragma region Client Methods
	public:
		/// <summary>
		/// Initialize the pipe client class
		/// </summary>
		static void PipeClientInitialize()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientInitialize pPipeClientInitialize =
				(tPipeClientInitialize)GetProcAddress(hModuleLibrary, "PipeClientInitialize");
			assert(pPipeClientInitialize != NULL);
			(*pPipeClientInitialize)();
		}

		/// <summary>
		/// Destroy the pipe client class
		/// </summary>
		static void PipeClientDestroy()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientDestroy pPipeClientDestroy =
				(tPipeClientDestroy)GetProcAddress(hModuleLibrary, "PipeClientDestroy");
			assert(pPipeClientDestroy != NULL);
			(*pPipeClientDestroy)();
		}

		/// <summary>
		/// Connect to the local pipe server
		/// </summary>
		/// <returns>True on success</returns>
		static bool PipeClientConnect()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnect pPipeClientConnect =
				(tPipeClientConnect)GetProcAddress(hModuleLibrary, "PipeClientConnect");
			assert(pPipeClientConnect != NULL);
			return (*pPipeClientConnect)();
		}

		/// <summary>
		/// Connect to the local pipe server
		/// </summary>
		/// <param name="aPipeName">The pipe name</param>
		/// <returns>True on success</returns>
		static bool PipeClientConnectNamed(const wchar_t *aPipeName)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnectNamed pPipeClientConnectNamed =
				(tPipeClientConnectNamed)GetProcAddress(hModuleLibrary, "PipeClientConnectNamed");
			assert(pPipeClientConnectNamed != NULL);
			return (*pPipeClientConnectNamed)(aPipeName);
		}

		/// <summary>
		/// Connect to a remote pipe server
		/// </summary>
		/// <param name="aServerName">The server name ( Hostname )</param>
		/// <returns>True on success</returns>
		static bool PipeClientConnectRemote(const wchar_t *aServerName)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnectRemote pPipeClientConnectRemote =
				(tPipeClientConnectRemote)GetProcAddress(hModuleLibrary, "PipeClientConnectRemote");
			assert(pPipeClientConnectRemote != NULL);
			return (*pPipeClientConnectRemote)(aServerName);
		}

		/// <summary>
		/// Connect to a remote pipe server
		/// </summary>
		/// <param name="aServerName">The server name ( Hostname )</param>
		/// <param name="aPipeName">The pipe name</param>
		/// <returns>True on success</returns>
		static bool PipeClientConnectRemoteNamed(const wchar_t *aServerName, const wchar_t *aPipeName)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientConnectRemoteNamed pPipeClientConnectRemoteNamed =
				(tPipeClientConnectRemoteNamed)GetProcAddress(hModuleLibrary, "PipeClientConnectRemoteNamed");
			assert(pPipeClientConnectRemoteNamed != NULL);
			return (*pPipeClientConnectRemoteNamed)(aServerName, aPipeName);
		}

		/// <summary>
		/// Send a message to the pipe server
		/// </summary>
		/// <param name="aMsg">The message</param>
		/// <returns>True on success</returns>
		static bool PipeClientSend(const wchar_t *aMsg)
		{
			assert(hModuleLibrary != NULL);
			tPipeClientSend pPipeClientSend =
				(tPipeClientSend)GetProcAddress(hModuleLibrary, "PipeClientSend");
			assert(pPipeClientSend != NULL);
			return (*pPipeClientSend)(aMsg);
		}

		/// <summary>
		/// Disconnect from the pipe server
		/// </summary>
		static void PipeClientDisconnect()
		{
			assert(hModuleLibrary != NULL);
			tPipeClientDisconnect pPipeClientDisconnect =
				(tPipeClientDisconnect)GetProcAddress(hModuleLibrary, "PipeClientDisconnect");
			assert(pPipeClientDisconnect != NULL);
			return (*pPipeClientDisconnect)();
		}

		/// <summary>
		/// Get the ID of the current pipe
		/// </summary>
		/// <returns>The pipe ID</returns>
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
		/// <summary>
		/// Register the OnDisconnect callback method
		/// </summary>
		/// <param name="aCallback">The callback method</param>
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

		/// <summary>
		/// Register the OnError callback method
		/// </summary>
		/// <param name="aCallback">The callback method</param>
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

		/// <summary>
		/// Register the OnMessage callback method
		/// </summary>
		/// <param name="aCallback">The callback method</param>
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

		/// <summary>
		/// Register the OnSent callback method
		/// </summary>
		/// <param name="aCallback">The callback method</param>
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
