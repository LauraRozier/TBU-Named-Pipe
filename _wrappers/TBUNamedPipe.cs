using System;
using System.Runtime.InteropServices;

/// <summary>
/// Named pipe classes for use with local and remote IPC
/// </summary>
namespace TBUNamedPipe
{
    #region Structs
    /// <summary>
    /// Defines the structure of a typical Delphi method object
    /// This is used to provide the callback to the DLL
    /// </summary>
    public struct PipeMethod
    {
        public IntPtr code;
        public IntPtr data;
    }
    #endregion

    /// <summary>
    /// Utilities for the pipe client/server
    /// </summary>
    public class PipeUtils
    {
        #region Constants
        /// <summary>
        /// Windows linebreak constant
        /// </summary>
        public const string sLineBreak = "\r\n";
        #endregion

        #region Pipe Context
        /// <summary>
        /// Translates a context ID to it's string value
        /// </summary>
        /// <param name="aPipeContext">The context ID</param>
        /// <returns>The name of the context</returns>
        public static string PipeContextToString(SByte aPipeContext)
        {
            switch(aPipeContext)
            {
                case 0: return "Listener";
                case 1: return "Worker";
                default: throw new Exception("Unknown Pipe Context ID");
            }
        }
        #endregion
    }

    /// <summary>
    /// The pipe server enables you to setup a pipe listner
    /// </summary>
    public class PipeServer
    {
        #region Server Delegates
        /// <summary>
        /// OnConnect callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        public delegate void TPipeServerConnectCallback(IntPtr self, UInt32 aPipe);
        /// <summary>
        /// OnDisconnect callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        public delegate void TPipeServerDisconnectCallback(IntPtr self, UInt32 aPipe);
        /// <summary>
        /// OnError callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        /// <param name="aPipeContext">The context of the error</param>
        /// <param name="aErrorCode">The error code</param>
        public delegate void TPipeServerErrorCallback(IntPtr self, UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode);
        /// <summary>
        /// OnMessage callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        /// <param name="aMsg">The message</param>
        public delegate void TPipeServerMessageCallback(IntPtr self, UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        /// <summary>
        /// OnSent callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        /// <param name="aSize">The message size in bytes</param>
        public delegate void TPipeServerSentCallback(IntPtr self, UInt32 aPipe, UInt32 aSize);
        #endregion

        #region Variables
        /// <summary>
        /// Holds the OnConnect callback to prevent GC collection
        /// </summary>
        private static TPipeServerConnectCallback sccb;
        /// <summary>
        /// Holds the OnDisconnect callback to prevent GC collection
        /// </summary>
        private static TPipeServerDisconnectCallback sdcb;
        /// <summary>
        /// Holds the OnError callback to prevent GC collection
        /// </summary>
        private static TPipeServerErrorCallback secb;
        /// <summary>
        /// Holds the OnMessage callback to prevent GC collection
        /// </summary>
        private static TPipeServerMessageCallback smcb;
        /// <summary>
        /// Holds the OnSent callback to prevent GC collection
        /// </summary>
        private static TPipeServerSentCallback sscb;
        #endregion

        #region Declare Pipe Server Procedures
        /// <summary>
        /// Initialize the pipe server class
        /// </summary>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeServerInitialize();
        /// <summary>
        /// Destroy the pipe server class
        /// </summary>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeServerDestroy();
        /// <summary>
        /// Start the pipe server listener thread
        /// </summary>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerStart();
        /// <summary>
        /// Start the pipe server listener thread
        /// </summary>
        /// <param name="aPipeName">The pipe name</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerStartNamed([MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        /// <summary>
        /// Stop the pipe server listener thread
        /// </summary>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeServerStop();
        /// <summary>
        /// Broadcast a message to all connected pipes
        /// </summary>
        /// <param name="aMsg">The message</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerBroadcast([MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        /// <summary>
        /// Send a message to the specified pipe
        /// </summary>
        /// <param name="aPipe">Pipe ID</param>
        /// <param name="aMsg">The message</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerSend(UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        /// <summary>
        /// Disconnect a specific pipe ( Use 0 [zero] for all connected pipes )
        /// </summary>
        /// <param name="aPipe">Pipe ID</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerDisconnect(UInt32 aPipe);
        /// <summary>
        /// Retrieve the amount of connected pipes
        /// </summary>
        /// <returns>The amount of pipes that are currently connected</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Int32 PipeServerGetClientCount();
        #endregion

        #region Declare Pipe Server Callback Registration Procedures
        /// <summary>
        /// Register the OnConnect callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerConnectCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnDisconnect callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerDisconnectCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnError callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerErrorCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnMessage callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerMessageCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnSent callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerSentCallback(PipeMethod aCallback);

        /// <summary>
        /// Register the OnConnect callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnConnectCallback(TPipeServerConnectCallback aCallback)
        {
            // Store the delegate to prevent GC
            sccb = aCallback;
            // Get the delegate pointer
            IntPtr psccb = Marshal.GetFunctionPointerForDelegate(sccb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = psccb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeServerConnectCallback(methodObj);
        }

        /// <summary>
        /// Register the OnDisconnect callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnDisconnectCallback(TPipeServerDisconnectCallback aCallback)
        {
            // Store the delegate to prevent GC
            sdcb = aCallback;
            // Get the delegate pointer
            IntPtr psdcb = Marshal.GetFunctionPointerForDelegate(sdcb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = psdcb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeServerDisconnectCallback(methodObj);
        }

        /// <summary>
        /// Register the OnError callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnErrorCallback(TPipeServerErrorCallback aCallback)
        {
            // Store the delegate to prevent GC
            secb = aCallback;
            // Get the delegate pointer
            IntPtr psecb = Marshal.GetFunctionPointerForDelegate(secb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = psecb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeServerErrorCallback(methodObj);
        }

        /// <summary>
        /// Register the OnMessage callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnMessageCallback(TPipeServerMessageCallback aCallback)
        {
            // Store the delegate to prevent GC
            smcb = aCallback;
            // Get the delegate pointer
            IntPtr psmcb = Marshal.GetFunctionPointerForDelegate(smcb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = psmcb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeServerMessageCallback(methodObj);
        }

        /// <summary>
        /// Register the OnSent callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnSentCallback(TPipeServerSentCallback aCallback)
        {
            // Store the delegate to prevent GC
            sscb = aCallback;
            // Get the delegate pointer
            IntPtr psscb = Marshal.GetFunctionPointerForDelegate(sscb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = psscb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeServerSentCallback(methodObj);
        }
        #endregion
    }

    /// <summary>
    /// The pipe client enables you to connect to a pipe server
    /// </summary>
    public class PipeClient
    {
        #region Client Delegates
        /// <summary>
        /// OnDisconnect callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        public delegate void TPipeClientDisconnectCallback(IntPtr self, UInt32 aPipe);
        /// <summary>
        /// OnError callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        /// <param name="aPipeContext">The context of the error</param>
        /// <param name="aErrorCode">The error code</param>
        public delegate void TPipeClientErrorCallback(IntPtr self, UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode);
        /// <summary>
        /// OnMessage callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        /// <param name="aMsg">The message</param>
        public delegate void TPipeClientMessageCallback(IntPtr self, UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        /// <summary>
        /// OnSent callback delegate
        /// </summary>
        /// <param name="self">The sender</param>
        /// <param name="aPipe">The pipe ID</param>
        /// <param name="aSize">The message size in bytes</param>
        public delegate void TPipeClientSentCallback(IntPtr self, UInt32 aPipe, UInt32 aSize);
        #endregion

        #region Variables
        /// <summary>
        /// Holds the OnDisconnect callback to prevent GC collection
        /// </summary>
        public static TPipeClientDisconnectCallback cdcb;
        /// <summary>
        /// Holds the OnError callback to prevent GC collection
        /// </summary>
        public static TPipeClientErrorCallback cecb;
        /// <summary>
        /// Holds the OnMessage callback to prevent GC collection
        /// </summary>
        public static TPipeClientMessageCallback cmcb;
        /// <summary>
        /// Holds the OnSent callback to prevent GC collection
        /// </summary>
        public static TPipeClientSentCallback cscb;
        #endregion

        #region Declare Pipe Server Procedures
        /// <summary>
        /// Initialize the pipe client class
        /// </summary>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeClientInitialize();
        /// <summary>
        /// Destroy the pipe client class
        /// </summary>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeClientDestroy();
        /// <summary>
        /// Connect to the local pipe server
        /// </summary>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnect();
        /// <summary>
        /// Connect to the local pipe server
        /// </summary>
        /// <param name="aPipeName">The pipe name</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectNamed([MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        /// <summary>
        /// Connect to a remote pipe server
        /// </summary>
        /// <param name="aServerName">The server name ( Hostname )</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectRemote([MarshalAs(UnmanagedType.LPWStr)] string aServerName);
        /// <summary>
        /// Connect to a remote pipe server
        /// </summary>
        /// <param name="aServerName">The server name ( Hostname )</param>
        /// <param name="aPipeName">The pipe name</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectRemoteNamed([MarshalAs(UnmanagedType.LPWStr)] string aServerName, [MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        /// <summary>
        /// Send a message to the pipe server
        /// </summary>
        /// <param name="aMsg">The message</param>
        /// <returns>True on success</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientSend([MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        /// <summary>
        /// Disconnect from the pipe server
        /// </summary>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeClientDisconnect();
        /// <summary>
        /// Get the ID of the current pipe
        /// </summary>
        /// <returns>The pipe ID</returns>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern UInt32 PipeClientGetPipeId();
        #endregion

        #region Declare Pipe Server Callback Registration Procedures
        /// <summary>
        /// Register the OnDisconnect callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientDisconnectCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnError callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientErrorCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnMessage callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientMessageCallback(PipeMethod aCallback);
        /// <summary>
        /// Register the OnSent callback method
        /// </summary>
        /// <param name="aCallback">The callback struct</param>
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientSentCallback(PipeMethod aCallback);

        /// <summary>
        /// Register the OnDisconnect callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnDisconnectCallback(TPipeClientDisconnectCallback aCallback)
        {
            // Store the delegate to prevent GC
            cdcb = aCallback;
            // Get the delegate pointer
            IntPtr pcdcb = Marshal.GetFunctionPointerForDelegate(cdcb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = pcdcb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeClientDisconnectCallback(methodObj);
        }

        /// <summary>
        /// Register the OnError callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnErrorCallback(TPipeClientErrorCallback aCallback)
        {
            // Store the delegate to prevent GC
            cecb = aCallback;
            // Get the delegate pointer
            IntPtr pcecb = Marshal.GetFunctionPointerForDelegate(cecb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = pcecb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeClientErrorCallback(methodObj);
        }

        /// <summary>
        /// Register the OnMessage callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnMessageCallback(TPipeClientMessageCallback aCallback)
        {
            // Store the delegate to prevent GC
            cmcb = aCallback;
            // Get the delegate pointer
            IntPtr pcmcb = Marshal.GetFunctionPointerForDelegate(cmcb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = pcmcb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeClientMessageCallback(methodObj);
        }

        /// <summary>
        /// Register the OnSent callback method
        /// </summary>
        /// <param name="aCallback">The callback method</param>
        public static void RegisterOnSentCallback(TPipeClientSentCallback aCallback)
        {
            // Store the delegate to prevent GC
            cscb = aCallback;
            // Get the delegate pointer
            IntPtr pcscb = Marshal.GetFunctionPointerForDelegate(cscb);
            // Create the method object to hold the call
            PipeMethod methodObj = new PipeMethod()
            {
                code = pcscb,
                data = IntPtr.Zero
            };
            // Register the callback with the DLL
            RegisterOnPipeClientSentCallback(methodObj);
        }
        #endregion
    }
}
