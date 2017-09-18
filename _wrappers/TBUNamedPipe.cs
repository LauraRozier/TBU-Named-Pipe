using System;
using System.Runtime.InteropServices;

namespace TBUNamedPipe
{
    class PipeUtils
    {
        public const string sLineBreak = "\r\n";

        #region Pipe Context
        public static string PipeContextToString(SByte aPipeContext)
        {
            switch(aPipeContext)
            {
                case 0:
                    return "Listener";
                case 1:
                    return "Worker";
                default:
                    throw new Exception("Unknown Pipe Context ID");
            }
        }
        #endregion
    }

    class PipeServer
    {
        #region Server Delegates
        public delegate void TPipeServerConnectCallback(UInt32 aPipe);
        public delegate void TPipeServerDisconnectCallback(UInt32 aPipe);
        public delegate void TPipeServerErrorCallback(UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode);
        public delegate void TPipeServerMessageCallback(UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        public delegate void TPipeServerSentCallback(UInt32 aPipe, UInt32 aSize);
        #endregion

        #region Declare Pipe Server Procedures
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void PipeServerInitialize();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void PipeServerDestroy();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerStart();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerStartNamed([MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void PipeServerStop();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerBroadcast([MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerSend(UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerDisconnect(UInt32 aPipe);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Int32 PipeServerGetClientCount();
        #endregion

        #region Declare Pipe Server Callback Registration Procedures
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeServerConnectCallback(TPipeServerConnectCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeServerDisconnectCallback(TPipeServerDisconnectCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeServerErrorCallback(TPipeServerErrorCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeServerMessageCallback(TPipeServerMessageCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeServerSentCallback(TPipeServerSentCallback aCallback);
        #endregion
    }

    class PipeClient
    {
        #region Client Delegates
        public delegate void TPipeClientDisconnectCallback(UInt32 aPipe);
        public delegate void TPipeClientErrorCallback(UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode);
        public delegate void TPipeClientMessageCallback(UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        public delegate void TPipeClientSentCallback(UInt32 aPipe, UInt32 aSize);
        #endregion

        #region Declare Pipe Server Procedures
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void PipeClientInitialize();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void PipeClientDestroy();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnect();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectNamed([MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectRemote([MarshalAs(UnmanagedType.LPWStr)] string aServerName);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectRemoteNamed([MarshalAs(UnmanagedType.LPWStr)] string aServerName, [MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientSend([MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void PipeClientDisconnect();
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern UInt32 PipeClientGetPipeId();
        #endregion

        #region Declare Pipe Server Callback Registration Procedures
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeClientDisconnectCallback(TPipeClientDisconnectCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeClientErrorCallback(TPipeClientErrorCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeClientMessageCallback(TPipeClientMessageCallback aCallback);
        [DllImport("TBUNamedPipe.dll",
                   CallingConvention = CallingConvention.StdCall,
                   CharSet = CharSet.Unicode)]
        public static extern void RegisterOnPipeClientSentCallback(TPipeClientSentCallback aCallback);
        #endregion
    }
}
