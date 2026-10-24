using System;
using System.Management;
using System.Text;
using BatteryGuard.PluginApi;
namespace Community.Hp8570w {
    // This example is executable hardware-control code, not a simulator.
    // Its exact hardware restriction is intentional. Do not expand it by guessing.
    public sealed class Provider:IChargeProvider {
        public void Initialize(HardwareIdentity m){
            if(m.Manufacturer!="Hewlett-Packard"||m.Model!="HP EliteBook 8570w"||m.Board!="176B"||m.Bios!="68IAV Ver. F.70")throw new NotSupportedException("This example supports only the documented HP 8570w configuration.");
        }
        public ControlStatus ReadStatus(){var data=Command(false,0);return new ControlStatus{State=data.Length>0&&data[0]==0?ChargeControlState.Automatic:data.Length>0&&data[0]==5?ChargeControlState.Paused:ChargeControlState.Unknown};}
        public string CaptureRecovery(){if(ReadStatus().State!=ChargeControlState.Automatic)throw new InvalidOperationException("Initial automatic mode required.");return "automatic-v1";}
        public void SetPaused(bool paused){Command(true,paused?(byte)5:(byte)0);}
        public void SetThresholds(int? lower,int upper){throw new NotSupportedException("Software pause provider.");}
        public void Restore(string state){if(state!="automatic-v1")throw new InvalidOperationException("Invalid recovery data.");Command(true,0);}
        public void Dispose(){}
        static byte[] Command(bool write,byte mode){
            var scope=new ManagementScope(@"root\wmi");scope.Options.EnablePrivileges=true;scope.Connect();
            using(var search=new ManagementObjectSearcher(scope,new ObjectQuery("SELECT * FROM hpqBIntM")))using(var items=search.Get()){
                foreach(ManagementObject endpoint in items)using(endpoint)using(var cls=new ManagementClass(scope,new ManagementPath("hpqBDataIn"),null))using(var input=cls.CreateInstance())using(var args=endpoint.GetMethodParameters("hpqBIOSInt4")){
                    input["Sign"]=new byte[]{0x53,0x45,0x43,0x55};input["Command"]=(uint)(write?2:1);input["CommandType"]=(uint)0x2B;input["Size"]=(uint)4;input["hpqBData"]=new byte[]{0,mode,0,0};args["InData"]=input;
                    using(var result=endpoint.InvokeMethod("hpqBIOSInt4",args,new InvokeMethodOptions{Timeout=TimeSpan.FromSeconds(8)}))using(var output=result["OutData"] as ManagementBaseObject){if(output==null||Encoding.ASCII.GetString((byte[])output["Sign"])!="PASS"||Convert.ToUInt32(output["rwReturnCode"])!=0)throw new InvalidOperationException("HP WMI command failed.");return (byte[])output["Data"];}
                }
            }
            throw new InvalidOperationException("HP endpoint not found.");
        }
    }
}
