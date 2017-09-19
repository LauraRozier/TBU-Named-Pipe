using System;
using System.Runtime.InteropServices;

namespace TBUNamedPipe
{
    public struct PipeMethod
    {
        public IntPtr code;
        public IntPtr data;
    }

    public class PipeUtils
    {
        public const string sLineBreak = "\r\n";

        #region Pipe Context
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

    public class PipeServer
    {
        #region Server Delegates
        public delegate void TPipeServerConnectCallback(IntPtr self, UInt32 aPipe);
        public delegate void TPipeServerDisconnectCallback(IntPtr self, UInt32 aPipe);
        public delegate void TPipeServerErrorCallback(IntPtr self, UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode);
        public delegate void TPipeServerMessageCallback(IntPtr self, UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        public delegate void TPipeServerSentCallback(IntPtr self, UInt32 aPipe, UInt32 aSize);
        #endregion

        #region Variables
        private static TPipeServerConnectCallback sccb;
        private static TPipeServerDisconnectCallback sdcb;
        private static TPipeServerErrorCallback secb;
        private static TPipeServerMessageCallback smcb;
        private static TPipeServerSentCallback sscb;
        #endregion

        #region Declare Pipe Server Procedures
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeServerInitialize();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeServerDestroy();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerStart();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerStartNamed([MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeServerStop();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerBroadcast([MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerSend(UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeServerDisconnect(UInt32 aPipe);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Int32 PipeServerGetClientCount();
        #endregion

        #region Declare Pipe Server Callback Registration Procedures
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerConnectCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerDisconnectCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerErrorCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerMessageCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeServerSentCallback(PipeMethod aCallback);

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

    public class PipeClient
    {
        #region Client Delegates
        public delegate void TPipeClientDisconnectCallback(IntPtr self, UInt32 aPipe);
        public delegate void TPipeClientErrorCallback(IntPtr self, UInt32 aPipe, SByte aPipeContext, Int32 aErrorCode);
        public delegate void TPipeClientMessageCallback(IntPtr self, UInt32 aPipe, [MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        public delegate void TPipeClientSentCallback(IntPtr self, UInt32 aPipe, UInt32 aSize);
        #endregion

        #region Variables
        public static TPipeClientDisconnectCallback cdcb;
        public static TPipeClientErrorCallback cecb;
        public static TPipeClientMessageCallback cmcb;
        public static TPipeClientSentCallback cscb;
        #endregion

        #region Declare Pipe Server Procedures
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeClientInitialize();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeClientDestroy();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnect();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectNamed([MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectRemote([MarshalAs(UnmanagedType.LPWStr)] string aServerName);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientConnectRemoteNamed([MarshalAs(UnmanagedType.LPWStr)] string aServerName, [MarshalAs(UnmanagedType.LPWStr)] string aPipeName);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern Boolean PipeClientSend([MarshalAs(UnmanagedType.LPWStr)] string aMsg);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern void PipeClientDisconnect();
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        public static extern UInt32 PipeClientGetPipeId();
        #endregion

        #region Declare Pipe Server Callback Registration Procedures
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientDisconnectCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientErrorCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientMessageCallback(PipeMethod aCallback);
        [DllImport("TBUNamedPipe.dll", CallingConvention = CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        private static extern void RegisterOnPipeClientSentCallback(PipeMethod aCallback);

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
